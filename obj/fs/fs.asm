
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 49 1a 00 00       	call   801a7a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 e0 39 80 00       	push   $0x8039e0
  8000b7:	e8 f7 1a 00 00       	call   801bb3 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 f7 39 80 00       	push   $0x8039f7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 07 3a 80 00       	push   $0x803a07
  8000e0:	e8 f5 19 00 00       	call   801ada <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 10 3a 80 00       	push   $0x803a10
  80010b:	68 1d 3a 80 00       	push   $0x803a1d
  800110:	6a 44                	push   $0x44
  800112:	68 07 3a 80 00       	push   $0x803a07
  800117:	e8 be 19 00 00       	call   801ada <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 10 3a 80 00       	push   $0x803a10
  8001cf:	68 1d 3a 80 00       	push   $0x803a1d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 07 3a 80 00       	push   $0x803a07
  8001db:	e8 fa 18 00 00       	call   801ada <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 34 3a 80 00       	push   $0x803a34
  80029f:	6a 27                	push   $0x27
  8002a1:	68 38 3b 80 00       	push   $0x803b38
  8002a6:	e8 2f 18 00 00       	call   801ada <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 64 3a 80 00       	push   $0x803a64
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 38 3b 80 00       	push   $0x803b38
  8002c6:	e8 0f 18 00 00       	call   801ada <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	// round addr to page boundry
	addr = ROUNDDOWN(addr, BLKSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	// allocate a page 
	if((r = sys_page_alloc(0, (void *)addr, PTE_P|PTE_U|PTE_W)) < 0) 
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 83 23 00 00       	call   802661 <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("in bc_pgfault, sys_page_alloc: %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 88 3a 80 00       	push   $0x803a88
  8002eb:	6a 38                	push   $0x38
  8002ed:	68 38 3b 80 00       	push   $0x803b38
  8002f2:	e8 e3 17 00 00       	call   801ada <_panic>

	// read from the disk
	if((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
		panic("in bc_pgfault, ide_read: %e", r);
  800311:	50                   	push   %eax
  800312:	68 40 3b 80 00       	push   $0x803b40
  800317:	6a 3c                	push   $0x3c
  800319:	68 38 3b 80 00       	push   $0x803b38
  80031e:	e8 b7 17 00 00       	call   801ada <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 61 23 00 00       	call   8026a4 <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 ac 3a 80 00       	push   $0x803aac
  800350:	6a 41                	push   $0x41
  800352:	68 38 3b 80 00       	push   $0x803b38
  800357:	e8 7e 17 00 00       	call   801ada <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 91 04 00 00       	call   8007ff <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 5c 3b 80 00       	push   $0x803b5c
  80037b:	6a 47                	push   $0x47
  80037d:	68 38 3b 80 00       	push   $0x803b38
  800382:	e8 53 17 00 00       	call   801ada <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 cc 3a 80 00       	push   $0x803acc
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 38 3b 80 00       	push   $0x803b38
  8003b7:	e8 1e 17 00 00       	call   801ada <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 75 3b 80 00       	push   $0x803b75
  800427:	6a 57                	push   $0x57
  800429:	68 38 3b 80 00       	push   $0x803b38
  80042e:	e8 a7 16 00 00       	call   801ada <_panic>

	// LAB 5: Your code here.
	// round addr down
	addr = ROUNDDOWN(addr, BLKSIZE);
  800433:	89 de                	mov    %ebx,%esi
  800435:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	// check if it is in the block cache or is cache
	if(va_is_mapped(addr) && va_is_dirty(addr)) {
  80043b:	83 ec 0c             	sub    $0xc,%esp
  80043e:	56                   	push   %esi
  80043f:	e8 82 ff ff ff       	call   8003c6 <va_is_mapped>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	84 c0                	test   %al,%al
  800449:	74 7a                	je     8004c5 <flush_block+0xb9>
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	56                   	push   %esi
  80044f:	e8 a0 ff ff ff       	call   8003f4 <va_is_dirty>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	84 c0                	test   %al,%al
  800459:	74 6a                	je     8004c5 <flush_block+0xb9>
		int r;

		// write back to the disk
		if((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  80045b:	83 ec 04             	sub    $0x4,%esp
  80045e:	6a 08                	push   $0x8
  800460:	56                   	push   %esi
  800461:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800467:	c1 eb 0c             	shr    $0xc,%ebx
  80046a:	c1 e3 03             	shl    $0x3,%ebx
  80046d:	53                   	push   %ebx
  80046e:	e8 3d fd ff ff       	call   8001b0 <ide_write>
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	85 c0                	test   %eax,%eax
  800478:	79 12                	jns    80048c <flush_block+0x80>
			panic("in flush_block, ide_write: %e", r);
  80047a:	50                   	push   %eax
  80047b:	68 90 3b 80 00       	push   $0x803b90
  800480:	6a 63                	push   $0x63
  800482:	68 38 3b 80 00       	push   $0x803b38
  800487:	e8 4e 16 00 00       	call   801ada <_panic>

		// clear the dirty bit
		if((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80048c:	89 f0                	mov    %esi,%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800498:	83 ec 0c             	sub    $0xc,%esp
  80049b:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a0:	50                   	push   %eax
  8004a1:	56                   	push   %esi
  8004a2:	6a 00                	push   $0x0
  8004a4:	56                   	push   %esi
  8004a5:	6a 00                	push   $0x0
  8004a7:	e8 f8 21 00 00       	call   8026a4 <sys_page_map>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 12                	jns    8004c5 <flush_block+0xb9>
			panic("in flush_block, sys_page_map: %e", r);
  8004b3:	50                   	push   %eax
  8004b4:	68 f0 3a 80 00       	push   $0x803af0
  8004b9:	6a 67                	push   $0x67
  8004bb:	68 38 3b 80 00       	push   $0x803b38
  8004c0:	e8 15 16 00 00       	call   801ada <_panic>
	}


}
  8004c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c8:	5b                   	pop    %ebx
  8004c9:	5e                   	pop    %esi
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	53                   	push   %ebx
  8004d0:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004d6:	68 74 02 80 00       	push   $0x800274
  8004db:	e8 72 23 00 00       	call   802852 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004e7:	e8 a2 fe ff ff       	call   80038e <diskaddr>
  8004ec:	83 c4 0c             	add    $0xc,%esp
  8004ef:	68 08 01 00 00       	push   $0x108
  8004f4:	50                   	push   %eax
  8004f5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	e8 78 1e 00 00       	call   802379 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800501:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800508:	e8 81 fe ff ff       	call   80038e <diskaddr>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	68 ae 3b 80 00       	push   $0x803bae
  800515:	50                   	push   %eax
  800516:	e8 cc 1c 00 00       	call   8021e7 <strcpy>
	flush_block(diskaddr(1));
  80051b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800522:	e8 67 fe ff ff       	call   80038e <diskaddr>
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 dd fe ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80052f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800536:	e8 53 fe ff ff       	call   80038e <diskaddr>
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	e8 83 fe ff ff       	call   8003c6 <va_is_mapped>
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	84 c0                	test   %al,%al
  800548:	75 16                	jne    800560 <bc_init+0x94>
  80054a:	68 d0 3b 80 00       	push   $0x803bd0
  80054f:	68 1d 3a 80 00       	push   $0x803a1d
  800554:	6a 7a                	push   $0x7a
  800556:	68 38 3b 80 00       	push   $0x803b38
  80055b:	e8 7a 15 00 00       	call   801ada <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800560:	83 ec 0c             	sub    $0xc,%esp
  800563:	6a 01                	push   $0x1
  800565:	e8 24 fe ff ff       	call   80038e <diskaddr>
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	e8 82 fe ff ff       	call   8003f4 <va_is_dirty>
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	84 c0                	test   %al,%al
  800577:	74 16                	je     80058f <bc_init+0xc3>
  800579:	68 b5 3b 80 00       	push   $0x803bb5
  80057e:	68 1d 3a 80 00       	push   $0x803a1d
  800583:	6a 7b                	push   $0x7b
  800585:	68 38 3b 80 00       	push   $0x803b38
  80058a:	e8 4b 15 00 00       	call   801ada <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80058f:	83 ec 0c             	sub    $0xc,%esp
  800592:	6a 01                	push   $0x1
  800594:	e8 f5 fd ff ff       	call   80038e <diskaddr>
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	50                   	push   %eax
  80059d:	6a 00                	push   $0x0
  80059f:	e8 42 21 00 00       	call   8026e6 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ab:	e8 de fd ff ff       	call   80038e <diskaddr>
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	e8 0e fe ff ff       	call   8003c6 <va_is_mapped>
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	84 c0                	test   %al,%al
  8005bd:	74 16                	je     8005d5 <bc_init+0x109>
  8005bf:	68 cf 3b 80 00       	push   $0x803bcf
  8005c4:	68 1d 3a 80 00       	push   $0x803a1d
  8005c9:	6a 7f                	push   $0x7f
  8005cb:	68 38 3b 80 00       	push   $0x803b38
  8005d0:	e8 05 15 00 00       	call   801ada <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	6a 01                	push   $0x1
  8005da:	e8 af fd ff ff       	call   80038e <diskaddr>
  8005df:	83 c4 08             	add    $0x8,%esp
  8005e2:	68 ae 3b 80 00       	push   $0x803bae
  8005e7:	50                   	push   %eax
  8005e8:	e8 a4 1c 00 00       	call   802291 <strcmp>
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	74 19                	je     80060d <bc_init+0x141>
  8005f4:	68 14 3b 80 00       	push   $0x803b14
  8005f9:	68 1d 3a 80 00       	push   $0x803a1d
  8005fe:	68 82 00 00 00       	push   $0x82
  800603:	68 38 3b 80 00       	push   $0x803b38
  800608:	e8 cd 14 00 00       	call   801ada <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	6a 01                	push   $0x1
  800612:	e8 77 fd ff ff       	call   80038e <diskaddr>
  800617:	83 c4 0c             	add    $0xc,%esp
  80061a:	68 08 01 00 00       	push   $0x108
  80061f:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800625:	53                   	push   %ebx
  800626:	50                   	push   %eax
  800627:	e8 4d 1d 00 00       	call   802379 <memmove>
	flush_block(diskaddr(1));
  80062c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800633:	e8 56 fd ff ff       	call   80038e <diskaddr>
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	e8 cc fd ff ff       	call   80040c <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800640:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800647:	e8 42 fd ff ff       	call   80038e <diskaddr>
  80064c:	83 c4 0c             	add    $0xc,%esp
  80064f:	68 08 01 00 00       	push   $0x108
  800654:	50                   	push   %eax
  800655:	53                   	push   %ebx
  800656:	e8 1e 1d 00 00       	call   802379 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80065b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800662:	e8 27 fd ff ff       	call   80038e <diskaddr>
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	68 ae 3b 80 00       	push   $0x803bae
  80066f:	50                   	push   %eax
  800670:	e8 72 1b 00 00       	call   8021e7 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800675:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80067c:	e8 0d fd ff ff       	call   80038e <diskaddr>
  800681:	83 c0 14             	add    $0x14,%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	e8 80 fd ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80068c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800693:	e8 f6 fc ff ff       	call   80038e <diskaddr>
  800698:	89 04 24             	mov    %eax,(%esp)
  80069b:	e8 26 fd ff ff       	call   8003c6 <va_is_mapped>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	84 c0                	test   %al,%al
  8006a5:	75 19                	jne    8006c0 <bc_init+0x1f4>
  8006a7:	68 d0 3b 80 00       	push   $0x803bd0
  8006ac:	68 1d 3a 80 00       	push   $0x803a1d
  8006b1:	68 93 00 00 00       	push   $0x93
  8006b6:	68 38 3b 80 00       	push   $0x803b38
  8006bb:	e8 1a 14 00 00       	call   801ada <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	6a 01                	push   $0x1
  8006c5:	e8 c4 fc ff ff       	call   80038e <diskaddr>
  8006ca:	83 c4 08             	add    $0x8,%esp
  8006cd:	50                   	push   %eax
  8006ce:	6a 00                	push   $0x0
  8006d0:	e8 11 20 00 00       	call   8026e6 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006dc:	e8 ad fc ff ff       	call   80038e <diskaddr>
  8006e1:	89 04 24             	mov    %eax,(%esp)
  8006e4:	e8 dd fc ff ff       	call   8003c6 <va_is_mapped>
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	84 c0                	test   %al,%al
  8006ee:	74 19                	je     800709 <bc_init+0x23d>
  8006f0:	68 cf 3b 80 00       	push   $0x803bcf
  8006f5:	68 1d 3a 80 00       	push   $0x803a1d
  8006fa:	68 9b 00 00 00       	push   $0x9b
  8006ff:	68 38 3b 80 00       	push   $0x803b38
  800704:	e8 d1 13 00 00       	call   801ada <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	6a 01                	push   $0x1
  80070e:	e8 7b fc ff ff       	call   80038e <diskaddr>
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	68 ae 3b 80 00       	push   $0x803bae
  80071b:	50                   	push   %eax
  80071c:	e8 70 1b 00 00       	call   802291 <strcmp>
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	74 19                	je     800741 <bc_init+0x275>
  800728:	68 14 3b 80 00       	push   $0x803b14
  80072d:	68 1d 3a 80 00       	push   $0x803a1d
  800732:	68 9e 00 00 00       	push   $0x9e
  800737:	68 38 3b 80 00       	push   $0x803b38
  80073c:	e8 99 13 00 00       	call   801ada <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800741:	83 ec 0c             	sub    $0xc,%esp
  800744:	6a 01                	push   $0x1
  800746:	e8 43 fc ff ff       	call   80038e <diskaddr>
  80074b:	83 c4 0c             	add    $0xc,%esp
  80074e:	68 08 01 00 00       	push   $0x108
  800753:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800759:	52                   	push   %edx
  80075a:	50                   	push   %eax
  80075b:	e8 19 1c 00 00       	call   802379 <memmove>
	flush_block(diskaddr(1));
  800760:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800767:	e8 22 fc ff ff       	call   80038e <diskaddr>
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	e8 98 fc ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800774:	c7 04 24 ea 3b 80 00 	movl   $0x803bea,(%esp)
  80077b:	e8 33 14 00 00       	call   801bb3 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800780:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800787:	e8 02 fc ff ff       	call   80038e <diskaddr>
  80078c:	83 c4 0c             	add    $0xc,%esp
  80078f:	68 08 01 00 00       	push   $0x108
  800794:	50                   	push   %eax
  800795:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	e8 d8 1b 00 00       	call   802379 <memmove>
}
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007af:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8007b4:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007ba:	74 14                	je     8007d0 <check_super+0x27>
		panic("bad file system magic number");
  8007bc:	83 ec 04             	sub    $0x4,%esp
  8007bf:	68 ff 3b 80 00       	push   $0x803bff
  8007c4:	6a 0f                	push   $0xf
  8007c6:	68 1c 3c 80 00       	push   $0x803c1c
  8007cb:	e8 0a 13 00 00       	call   801ada <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007d0:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007d7:	76 14                	jbe    8007ed <check_super+0x44>
		panic("file system is too large");
  8007d9:	83 ec 04             	sub    $0x4,%esp
  8007dc:	68 24 3c 80 00       	push   $0x803c24
  8007e1:	6a 12                	push   $0x12
  8007e3:	68 1c 3c 80 00       	push   $0x803c1c
  8007e8:	e8 ed 12 00 00       	call   801ada <_panic>

	cprintf("superblock is good\n");
  8007ed:	83 ec 0c             	sub    $0xc,%esp
  8007f0:	68 3d 3c 80 00       	push   $0x803c3d
  8007f5:	e8 b9 13 00 00       	call   801bb3 <cprintf>
}
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800806:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80080c:	85 d2                	test   %edx,%edx
  80080e:	74 24                	je     800834 <block_is_free+0x35>
		return 0;
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  800815:	39 4a 04             	cmp    %ecx,0x4(%edx)
  800818:	76 1f                	jbe    800839 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80081a:	89 cb                	mov    %ecx,%ebx
  80081c:	c1 eb 05             	shr    $0x5,%ebx
  80081f:	b8 01 00 00 00       	mov    $0x1,%eax
  800824:	d3 e0                	shl    %cl,%eax
  800826:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80082c:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80082f:	0f 95 c0             	setne  %al
  800832:	eb 05                	jmp    800839 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800839:	5b                   	pop    %ebx
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	83 ec 04             	sub    $0x4,%esp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800846:	85 c9                	test   %ecx,%ecx
  800848:	75 14                	jne    80085e <free_block+0x22>
		panic("attempt to free zero block");
  80084a:	83 ec 04             	sub    $0x4,%esp
  80084d:	68 51 3c 80 00       	push   $0x803c51
  800852:	6a 2d                	push   $0x2d
  800854:	68 1c 3c 80 00       	push   $0x803c1c
  800859:	e8 7c 12 00 00       	call   801ada <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80085e:	89 cb                	mov    %ecx,%ebx
  800860:	c1 eb 05             	shr    $0x5,%ebx
  800863:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800869:	b8 01 00 00 00       	mov    $0x1,%eax
  80086e:	d3 e0                	shl    %cl,%eax
  800870:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// search for a free block
	for(uint32_t blockno = 0; blockno < super->s_nblocks; ++blockno)
  80087d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800882:	8b 70 04             	mov    0x4(%eax),%esi
  800885:	bb 00 00 00 00       	mov    $0x0,%ebx
  80088a:	eb 43                	jmp    8008cf <alloc_block+0x57>
		if(block_is_free(blockno)) {
  80088c:	53                   	push   %ebx
  80088d:	e8 6d ff ff ff       	call   8007ff <block_is_free>
  800892:	83 c4 04             	add    $0x4,%esp
  800895:	84 c0                	test   %al,%al
  800897:	74 33                	je     8008cc <alloc_block+0x54>
			// mark it used
			bitmap[blockno/32] &= (~(1<<(blockno%32)));
  800899:	89 d8                	mov    %ebx,%eax
  80089b:	c1 e8 05             	shr    $0x5,%eax
  80089e:	c1 e0 02             	shl    $0x2,%eax
  8008a1:	89 c6                	mov    %eax,%esi
  8008a3:	03 35 08 a0 80 00    	add    0x80a008,%esi
  8008a9:	ba 01 00 00 00       	mov    $0x1,%edx
  8008ae:	89 d9                	mov    %ebx,%ecx
  8008b0:	d3 e2                	shl    %cl,%edx
  8008b2:	f7 d2                	not    %edx
  8008b4:	21 16                	and    %edx,(%esi)

			// flush the bitmap
			flush_block(&bitmap[blockno/32]);
  8008b6:	83 ec 0c             	sub    $0xc,%esp
  8008b9:	03 05 08 a0 80 00    	add    0x80a008,%eax
  8008bf:	50                   	push   %eax
  8008c0:	e8 47 fb ff ff       	call   80040c <flush_block>

			return blockno;
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	eb 0c                	jmp    8008d8 <alloc_block+0x60>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	// search for a free block
	for(uint32_t blockno = 0; blockno < super->s_nblocks; ++blockno)
  8008cc:	83 c3 01             	add    $0x1,%ebx
  8008cf:	39 f3                	cmp    %esi,%ebx
  8008d1:	75 b9                	jne    80088c <alloc_block+0x14>
			flush_block(&bitmap[blockno/32]);

			return blockno;
		}

	return -E_NO_DISK;
  8008d3:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	83 ec 1c             	sub    $0x1c,%esp
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
    // LAB 5: Your code here.
    // if filebno is out of range
	if(filebno >= NDIRECT + NINDIRECT)
  8008eb:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008f1:	0f 87 a0 00 00 00    	ja     800997 <file_block_walk+0xb8>
		return -E_INVAL;

	// the block number is stored in f_direct
	if(filebno < NDIRECT) {
  8008f7:	83 fa 09             	cmp    $0x9,%edx
  8008fa:	77 13                	ja     80090f <file_block_walk+0x30>
		*ppdiskbno = &f->f_direct[filebno];
  8008fc:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  800903:	89 01                	mov    %eax,(%ecx)
		else {
			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
		}
	}

	return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	e9 9b 00 00 00       	jmp    8009aa <file_block_walk+0xcb>
  80090f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800912:	89 d3                	mov    %edx,%ebx
  800914:	89 c6                	mov    %eax,%esi
		*ppdiskbno = &f->f_direct[filebno];
	}
	// the block number is stored in f_indirect
	else {
		// need to allocate an indirect
		if((void *)f->f_indirect == NULL) {
  800916:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  80091c:	85 c0                	test   %eax,%eax
  80091e:	75 5b                	jne    80097b <file_block_walk+0x9c>
			if(alloc == 0)
  800920:	89 f8                	mov    %edi,%eax
  800922:	84 c0                	test   %al,%al
  800924:	74 78                	je     80099e <file_block_walk+0xbf>
				return -E_NOT_FOUND;

			// alloc a block
			int indirectbno;
			indirectbno = alloc_block();
  800926:	e8 4d ff ff ff       	call   800878 <alloc_block>
  80092b:	89 c7                	mov    %eax,%edi

			// no space for an indirect block
			if(indirectbno < 0)
  80092d:	85 c0                	test   %eax,%eax
  80092f:	78 74                	js     8009a5 <file_block_walk+0xc6>
				return -E_NO_DISK;

			// clear the block
			memset(diskaddr(indirectbno), 0, BLKSIZE);
  800931:	83 ec 0c             	sub    $0xc,%esp
  800934:	50                   	push   %eax
  800935:	e8 54 fa ff ff       	call   80038e <diskaddr>
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	68 00 10 00 00       	push   $0x1000
  800942:	6a 00                	push   $0x0
  800944:	50                   	push   %eax
  800945:	e8 e2 19 00 00       	call   80232c <memset>
			flush_block(diskaddr(indirectbno));
  80094a:	89 3c 24             	mov    %edi,(%esp)
  80094d:	e8 3c fa ff ff       	call   80038e <diskaddr>
  800952:	89 04 24             	mov    %eax,(%esp)
  800955:	e8 b2 fa ff ff       	call   80040c <flush_block>

			// set the file's metadata
			// f->f_indirect = (uint32_t)diskaddr(indirectbno);
			f->f_indirect = indirectbno;
  80095a:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)

			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
  800960:	89 3c 24             	mov    %edi,(%esp)
  800963:	e8 26 fa ff ff       	call   80038e <diskaddr>
  800968:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80096c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80096f:	89 06                	mov    %eax,(%esi)
  800971:	83 c4 10             	add    $0x10,%esp
		else {
			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
		}
	}

	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
  800979:	eb 2f                	jmp    8009aa <file_block_walk+0xcb>
			f->f_indirect = indirectbno;

			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
		}
		else {
			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
  80097b:	83 ec 0c             	sub    $0xc,%esp
  80097e:	50                   	push   %eax
  80097f:	e8 0a fa ff ff       	call   80038e <diskaddr>
  800984:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800988:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80098b:	89 03                	mov    %eax,(%ebx)
  80098d:	83 c4 10             	add    $0x10,%esp
		}
	}

	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
  800995:	eb 13                	jmp    8009aa <file_block_walk+0xcb>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
    // LAB 5: Your code here.
    // if filebno is out of range
	if(filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800997:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099c:	eb 0c                	jmp    8009aa <file_block_walk+0xcb>
	// the block number is stored in f_indirect
	else {
		// need to allocate an indirect
		if((void *)f->f_indirect == NULL) {
			if(alloc == 0)
				return -E_NOT_FOUND;
  80099e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8009a3:	eb 05                	jmp    8009aa <file_block_walk+0xcb>
			int indirectbno;
			indirectbno = alloc_block();

			// no space for an indirect block
			if(indirectbno < 0)
				return -E_NO_DISK;
  8009a5:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno-NDIRECT];
		}
	}

	return 0;
}
  8009aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009b7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8009bc:	8b 70 04             	mov    0x4(%eax),%esi
  8009bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009c4:	eb 29                	jmp    8009ef <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  8009c6:	8d 43 02             	lea    0x2(%ebx),%eax
  8009c9:	50                   	push   %eax
  8009ca:	e8 30 fe ff ff       	call   8007ff <block_is_free>
  8009cf:	83 c4 04             	add    $0x4,%esp
  8009d2:	84 c0                	test   %al,%al
  8009d4:	74 16                	je     8009ec <check_bitmap+0x3a>
  8009d6:	68 6c 3c 80 00       	push   $0x803c6c
  8009db:	68 1d 3a 80 00       	push   $0x803a1d
  8009e0:	6a 5b                	push   $0x5b
  8009e2:	68 1c 3c 80 00       	push   $0x803c1c
  8009e7:	e8 ee 10 00 00       	call   801ada <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009ec:	83 c3 01             	add    $0x1,%ebx
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	c1 e0 0f             	shl    $0xf,%eax
  8009f4:	39 f0                	cmp    %esi,%eax
  8009f6:	72 ce                	jb     8009c6 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009f8:	83 ec 0c             	sub    $0xc,%esp
  8009fb:	6a 00                	push   $0x0
  8009fd:	e8 fd fd ff ff       	call   8007ff <block_is_free>
  800a02:	83 c4 10             	add    $0x10,%esp
  800a05:	84 c0                	test   %al,%al
  800a07:	74 16                	je     800a1f <check_bitmap+0x6d>
  800a09:	68 80 3c 80 00       	push   $0x803c80
  800a0e:	68 1d 3a 80 00       	push   $0x803a1d
  800a13:	6a 5e                	push   $0x5e
  800a15:	68 1c 3c 80 00       	push   $0x803c1c
  800a1a:	e8 bb 10 00 00       	call   801ada <_panic>
	assert(!block_is_free(1));
  800a1f:	83 ec 0c             	sub    $0xc,%esp
  800a22:	6a 01                	push   $0x1
  800a24:	e8 d6 fd ff ff       	call   8007ff <block_is_free>
  800a29:	83 c4 10             	add    $0x10,%esp
  800a2c:	84 c0                	test   %al,%al
  800a2e:	74 16                	je     800a46 <check_bitmap+0x94>
  800a30:	68 92 3c 80 00       	push   $0x803c92
  800a35:	68 1d 3a 80 00       	push   $0x803a1d
  800a3a:	6a 5f                	push   $0x5f
  800a3c:	68 1c 3c 80 00       	push   $0x803c1c
  800a41:	e8 94 10 00 00       	call   801ada <_panic>

	cprintf("bitmap is good\n");
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	68 a4 3c 80 00       	push   $0x803ca4
  800a4e:	e8 60 11 00 00       	call   801bb3 <cprintf>
}
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800a63:	e8 f7 f5 ff ff       	call   80005f <ide_probe_disk1>
  800a68:	84 c0                	test   %al,%al
  800a6a:	74 0f                	je     800a7b <fs_init+0x1e>
		ide_set_disk(1);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	6a 01                	push   $0x1
  800a71:	e8 4d f6 ff ff       	call   8000c3 <ide_set_disk>
  800a76:	83 c4 10             	add    $0x10,%esp
  800a79:	eb 0d                	jmp    800a88 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800a7b:	83 ec 0c             	sub    $0xc,%esp
  800a7e:	6a 00                	push   $0x0
  800a80:	e8 3e f6 ff ff       	call   8000c3 <ide_set_disk>
  800a85:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a88:	e8 3f fa ff ff       	call   8004cc <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a8d:	83 ec 0c             	sub    $0xc,%esp
  800a90:	6a 01                	push   $0x1
  800a92:	e8 f7 f8 ff ff       	call   80038e <diskaddr>
  800a97:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800a9c:	e8 08 fd ff ff       	call   8007a9 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800aa1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800aa8:	e8 e1 f8 ff ff       	call   80038e <diskaddr>
  800aad:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800ab2:	e8 fb fe ff ff       	call   8009b2 <check_bitmap>
	
}
  800ab7:	83 c4 10             	add    $0x10,%esp
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 24             	sub    $0x24,%esp
    // LAB 5: Your code here.
    uint32_t *diskbno;
    int r;

    // the block number is stored in the diskbno
    if((r = file_block_walk(f, filebno, &diskbno, 1)) < 0)
  800ac2:	6a 01                	push   $0x1
  800ac4:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	e8 0d fe ff ff       	call   8008df <file_block_walk>
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	78 5c                	js     800b35 <file_get_block+0x79>
    	return r;

    // a new block needed to be allocate
    if(*diskbno == 0) {
  800ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adc:	8b 00                	mov    (%eax),%eax
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	75 36                	jne    800b18 <file_get_block+0x5c>
	    int newbno;
	    newbno = alloc_block();
  800ae2:	e8 91 fd ff ff       	call   800878 <alloc_block>

	    // the disk is full
	    if(newbno < 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	78 45                	js     800b30 <file_get_block+0x74>
	    	return -E_NO_DISK;

	    *diskbno = newbno;
  800aeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aee:	89 02                	mov    %eax,(%edx)
	    *blk = diskaddr(newbno);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	50                   	push   %eax
  800af4:	e8 95 f8 ff ff       	call   80038e <diskaddr>
  800af9:	8b 55 10             	mov    0x10(%ebp),%edx
  800afc:	89 02                	mov    %eax,(%edx)
	    memset(*blk, 0, BLKSIZE);
  800afe:	83 c4 0c             	add    $0xc,%esp
  800b01:	68 00 10 00 00       	push   $0x1000
  800b06:	6a 00                	push   $0x0
  800b08:	50                   	push   %eax
  800b09:	e8 1e 18 00 00       	call   80232c <memset>
  800b0e:	83 c4 10             	add    $0x10,%esp
	}
	else
		*blk = diskaddr(*diskbno);

	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	eb 1d                	jmp    800b35 <file_get_block+0x79>
	    *diskbno = newbno;
	    *blk = diskaddr(newbno);
	    memset(*blk, 0, BLKSIZE);
	}
	else
		*blk = diskaddr(*diskbno);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	50                   	push   %eax
  800b1c:	e8 6d f8 ff ff       	call   80038e <diskaddr>
  800b21:	8b 55 10             	mov    0x10(%ebp),%edx
  800b24:	89 02                	mov    %eax,(%edx)
  800b26:	83 c4 10             	add    $0x10,%esp

	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	eb 05                	jmp    800b35 <file_get_block+0x79>
	    int newbno;
	    newbno = alloc_block();

	    // the disk is full
	    if(newbno < 0)
	    	return -E_NO_DISK;
  800b30:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	}
	else
		*blk = diskaddr(*diskbno);

	return 0;
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b43:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b49:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b4f:	eb 03                	jmp    800b54 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b51:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b54:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b57:	74 f8                	je     800b51 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b59:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800b5f:	83 c1 08             	add    $0x8,%ecx
  800b62:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b68:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b6f:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	74 06                	je     800b7f <walk_path+0x48>
		*pdir = 0;
  800b79:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b7f:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800b85:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b90:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b96:	e9 5f 01 00 00       	jmp    800cfa <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b9b:	83 c7 01             	add    $0x1,%edi
  800b9e:	eb 02                	jmp    800ba2 <walk_path+0x6b>
  800ba0:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800ba2:	0f b6 17             	movzbl (%edi),%edx
  800ba5:	80 fa 2f             	cmp    $0x2f,%dl
  800ba8:	74 04                	je     800bae <walk_path+0x77>
  800baa:	84 d2                	test   %dl,%dl
  800bac:	75 ed                	jne    800b9b <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800bae:	89 fb                	mov    %edi,%ebx
  800bb0:	29 c3                	sub    %eax,%ebx
  800bb2:	83 fb 7f             	cmp    $0x7f,%ebx
  800bb5:	0f 8f 69 01 00 00    	jg     800d24 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800bbb:	83 ec 04             	sub    $0x4,%esp
  800bbe:	53                   	push   %ebx
  800bbf:	50                   	push   %eax
  800bc0:	56                   	push   %esi
  800bc1:	e8 b3 17 00 00       	call   802379 <memmove>
		name[path - p] = '\0';
  800bc6:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800bcd:	00 
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	eb 03                	jmp    800bd6 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800bd3:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800bd6:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800bd9:	74 f8                	je     800bd3 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800bdb:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800be1:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800be8:	0f 85 3d 01 00 00    	jne    800d2b <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800bee:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bf4:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bf9:	74 19                	je     800c14 <walk_path+0xdd>
  800bfb:	68 b4 3c 80 00       	push   $0x803cb4
  800c00:	68 1d 3a 80 00       	push   $0x803a1d
  800c05:	68 f3 00 00 00       	push   $0xf3
  800c0a:	68 1c 3c 80 00       	push   $0x803c1c
  800c0f:	e8 c6 0e 00 00       	call   801ada <_panic>
	nblock = dir->f_size / BLKSIZE;
  800c14:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	0f 48 c2             	cmovs  %edx,%eax
  800c1f:	c1 f8 0c             	sar    $0xc,%eax
  800c22:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800c28:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800c2f:	00 00 00 
  800c32:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800c38:	eb 5e                	jmp    800c98 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c3a:	83 ec 04             	sub    $0x4,%esp
  800c3d:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c43:	50                   	push   %eax
  800c44:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c4a:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c50:	e8 67 fe ff ff       	call   800abc <file_get_block>
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	0f 88 ee 00 00 00    	js     800d4e <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800c60:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c66:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c6c:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c72:	83 ec 08             	sub    $0x8,%esp
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	e8 15 16 00 00       	call   802291 <strcmp>
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	0f 84 ab 00 00 00    	je     800d32 <walk_path+0x1fb>
  800c87:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c8d:	39 fb                	cmp    %edi,%ebx
  800c8f:	75 db                	jne    800c6c <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c91:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800c98:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c9e:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800ca4:	75 94                	jne    800c3a <walk_path+0x103>
  800ca6:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800cac:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800cb1:	80 3f 00             	cmpb   $0x0,(%edi)
  800cb4:	0f 85 a3 00 00 00    	jne    800d5d <walk_path+0x226>
				if (pdir)
  800cba:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	74 08                	je     800ccc <walk_path+0x195>
					*pdir = dir;
  800cc4:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800cca:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800ccc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cd0:	74 15                	je     800ce7 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800cd2:	83 ec 08             	sub    $0x8,%esp
  800cd5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800cdb:	50                   	push   %eax
  800cdc:	ff 75 08             	pushl  0x8(%ebp)
  800cdf:	e8 03 15 00 00       	call   8021e7 <strcpy>
  800ce4:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800ce7:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800ced:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800cf3:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cf8:	eb 63                	jmp    800d5d <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cfa:	80 38 00             	cmpb   $0x0,(%eax)
  800cfd:	0f 85 9d fe ff ff    	jne    800ba0 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800d03:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	74 02                	je     800d0f <walk_path+0x1d8>
		*pdir = dir;
  800d0d:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800d0f:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d15:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d1b:	89 08                	mov    %ecx,(%eax)
	return 0;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d22:	eb 39                	jmp    800d5d <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800d24:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d29:	eb 32                	jmp    800d5d <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800d2b:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d30:	eb 2b                	jmp    800d5d <walk_path+0x226>
  800d32:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d38:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d3e:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d44:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d4a:	89 f8                	mov    %edi,%eax
  800d4c:	eb ac                	jmp    800cfa <walk_path+0x1c3>
  800d4e:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d54:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d57:	0f 84 4f ff ff ff    	je     800cac <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d6b:	6a 00                	push   $0x0
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	e8 ba fd ff ff       	call   800b37 <walk_path>
}
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 2c             	sub    $0x2c,%esp
  800d88:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d8b:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800d97:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d9c:	39 ca                	cmp    %ecx,%edx
  800d9e:	7e 7c                	jle    800e1c <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800da0:	29 ca                	sub    %ecx,%edx
  800da2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800da5:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800da9:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800dac:	89 ce                	mov    %ecx,%esi
  800dae:	01 d1                	add    %edx,%ecx
  800db0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800db3:	eb 5d                	jmp    800e12 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800dbb:	50                   	push   %eax
  800dbc:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800dc2:	85 f6                	test   %esi,%esi
  800dc4:	0f 49 c6             	cmovns %esi,%eax
  800dc7:	c1 f8 0c             	sar    $0xc,%eax
  800dca:	50                   	push   %eax
  800dcb:	ff 75 08             	pushl  0x8(%ebp)
  800dce:	e8 e9 fc ff ff       	call   800abc <file_get_block>
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	78 42                	js     800e1c <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dda:	89 f2                	mov    %esi,%edx
  800ddc:	c1 fa 1f             	sar    $0x1f,%edx
  800ddf:	c1 ea 14             	shr    $0x14,%edx
  800de2:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800de5:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dea:	29 d0                	sub    %edx,%eax
  800dec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800def:	29 da                	sub    %ebx,%edx
  800df1:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800df6:	29 c3                	sub    %eax,%ebx
  800df8:	39 da                	cmp    %ebx,%edx
  800dfa:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	53                   	push   %ebx
  800e01:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e04:	50                   	push   %eax
  800e05:	57                   	push   %edi
  800e06:	e8 6e 15 00 00       	call   802379 <memmove>
		pos += bn;
  800e0b:	01 de                	add    %ebx,%esi
		buf += bn;
  800e0d:	01 df                	add    %ebx,%edi
  800e0f:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800e12:	89 f3                	mov    %esi,%ebx
  800e14:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e17:	77 9c                	ja     800db5 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e19:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 2c             	sub    $0x2c,%esp
  800e2d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e30:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e36:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e39:	0f 8e a7 00 00 00    	jle    800ee6 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e3f:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e45:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e4a:	0f 49 f8             	cmovns %eax,%edi
  800e4d:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5b:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e61:	0f 49 c2             	cmovns %edx,%eax
  800e64:	c1 f8 0c             	sar    $0xc,%eax
  800e67:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	eb 39                	jmp    800ea7 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	6a 00                	push   $0x0
  800e73:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e76:	89 da                	mov    %ebx,%edx
  800e78:	89 f0                	mov    %esi,%eax
  800e7a:	e8 60 fa ff ff       	call   8008df <file_block_walk>
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	78 4d                	js     800ed3 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800e86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e89:	8b 00                	mov    (%eax),%eax
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	74 15                	je     800ea4 <file_set_size+0x80>
		free_block(*ptr);
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	50                   	push   %eax
  800e93:	e8 a4 f9 ff ff       	call   80083c <free_block>
		*ptr = 0;
  800e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ea1:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ea4:	83 c3 01             	add    $0x1,%ebx
  800ea7:	39 df                	cmp    %ebx,%edi
  800ea9:	77 c3                	ja     800e6e <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800eab:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800eaf:	77 35                	ja     800ee6 <file_set_size+0xc2>
  800eb1:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	74 2b                	je     800ee6 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	e8 78 f9 ff ff       	call   80083c <free_block>
		f->f_indirect = 0;
  800ec4:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800ecb:	00 00 00 
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	eb 13                	jmp    800ee6 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	50                   	push   %eax
  800ed7:	68 d1 3c 80 00       	push   $0x803cd1
  800edc:	e8 d2 0c 00 00       	call   801bb3 <cprintf>
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	eb be                	jmp    800ea4 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	56                   	push   %esi
  800ef3:	e8 14 f5 ff ff       	call   80040c <flush_block>
	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 2c             	sub    $0x2c,%esp
  800f0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f11:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800f14:	89 f0                	mov    %esi,%eax
  800f16:	03 45 10             	add    0x10(%ebp),%eax
  800f19:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1f:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f25:	76 72                	jbe    800f99 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800f27:	83 ec 08             	sub    $0x8,%esp
  800f2a:	50                   	push   %eax
  800f2b:	51                   	push   %ecx
  800f2c:	e8 f3 fe ff ff       	call   800e24 <file_set_size>
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 61                	jns    800f99 <file_write+0x94>
  800f38:	eb 69                	jmp    800fa3 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f3a:	83 ec 04             	sub    $0x4,%esp
  800f3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f47:	85 f6                	test   %esi,%esi
  800f49:	0f 49 c6             	cmovns %esi,%eax
  800f4c:	c1 f8 0c             	sar    $0xc,%eax
  800f4f:	50                   	push   %eax
  800f50:	ff 75 08             	pushl  0x8(%ebp)
  800f53:	e8 64 fb ff ff       	call   800abc <file_get_block>
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 44                	js     800fa3 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	c1 fa 1f             	sar    $0x1f,%edx
  800f64:	c1 ea 14             	shr    $0x14,%edx
  800f67:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f6a:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f6f:	29 d0                	sub    %edx,%eax
  800f71:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f74:	29 d9                	sub    %ebx,%ecx
  800f76:	89 cb                	mov    %ecx,%ebx
  800f78:	ba 00 10 00 00       	mov    $0x1000,%edx
  800f7d:	29 c2                	sub    %eax,%edx
  800f7f:	39 d1                	cmp    %edx,%ecx
  800f81:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	53                   	push   %ebx
  800f88:	57                   	push   %edi
  800f89:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	e8 e7 13 00 00       	call   802379 <memmove>
		pos += bn;
  800f92:	01 de                	add    %ebx,%esi
		buf += bn;
  800f94:	01 df                	add    %ebx,%edi
  800f96:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f99:	89 f3                	mov    %esi,%ebx
  800f9b:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f9e:	77 9a                	ja     800f3a <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800fa0:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 10             	sub    $0x10,%esp
  800fb3:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbb:	eb 3c                	jmp    800ff9 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	6a 00                	push   $0x0
  800fc2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800fc5:	89 da                	mov    %ebx,%edx
  800fc7:	89 f0                	mov    %esi,%eax
  800fc9:	e8 11 f9 ff ff       	call   8008df <file_block_walk>
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 21                	js     800ff6 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	74 1a                	je     800ff6 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800fdc:	8b 00                	mov    (%eax),%eax
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	74 14                	je     800ff6 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	50                   	push   %eax
  800fe6:	e8 a3 f3 ff ff       	call   80038e <diskaddr>
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 19 f4 ff ff       	call   80040c <flush_block>
  800ff3:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800ff6:	83 c3 01             	add    $0x1,%ebx
  800ff9:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fff:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801005:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80100b:	85 c9                	test   %ecx,%ecx
  80100d:	0f 49 c1             	cmovns %ecx,%eax
  801010:	c1 f8 0c             	sar    $0xc,%eax
  801013:	39 c3                	cmp    %eax,%ebx
  801015:	7c a6                	jl     800fbd <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	56                   	push   %esi
  80101b:	e8 ec f3 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  801020:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	85 c0                	test   %eax,%eax
  80102b:	74 14                	je     801041 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	50                   	push   %eax
  801031:	e8 58 f3 ff ff       	call   80038e <diskaddr>
  801036:	89 04 24             	mov    %eax,(%esp)
  801039:	e8 ce f3 ff ff       	call   80040c <flush_block>
  80103e:	83 c4 10             	add    $0x10,%esp
}
  801041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	53                   	push   %ebx
  80104e:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801054:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80105a:	50                   	push   %eax
  80105b:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801061:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	e8 c8 fa ff ff       	call   800b37 <walk_path>
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	0f 84 d1 00 00 00    	je     80114b <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80107a:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80107d:	0f 85 0c 01 00 00    	jne    80118f <file_create+0x147>
  801083:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801089:	85 f6                	test   %esi,%esi
  80108b:	0f 84 c1 00 00 00    	je     801152 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801091:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801097:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80109c:	74 19                	je     8010b7 <file_create+0x6f>
  80109e:	68 b4 3c 80 00       	push   $0x803cb4
  8010a3:	68 1d 3a 80 00       	push   $0x803a1d
  8010a8:	68 0c 01 00 00       	push   $0x10c
  8010ad:	68 1c 3c 80 00       	push   $0x803c1c
  8010b2:	e8 23 0a 00 00       	call   801ada <_panic>
	nblock = dir->f_size / BLKSIZE;
  8010b7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	0f 48 c2             	cmovs  %edx,%eax
  8010c2:	c1 f8 0c             	sar    $0xc,%eax
  8010c5:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8010cb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010d0:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8010d6:	eb 3b                	jmp    801113 <file_create+0xcb>
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	57                   	push   %edi
  8010dc:	53                   	push   %ebx
  8010dd:	56                   	push   %esi
  8010de:	e8 d9 f9 ff ff       	call   800abc <file_get_block>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	0f 88 a1 00 00 00    	js     80118f <file_create+0x147>
			return r;
		f = (struct File*) blk;
  8010ee:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010f4:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010fa:	80 38 00             	cmpb   $0x0,(%eax)
  8010fd:	75 08                	jne    801107 <file_create+0xbf>
				*file = &f[j];
  8010ff:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801105:	eb 52                	jmp    801159 <file_create+0x111>
  801107:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  80110c:	39 d0                	cmp    %edx,%eax
  80110e:	75 ea                	jne    8010fa <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  801110:	83 c3 01             	add    $0x1,%ebx
  801113:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801119:	75 bd                	jne    8010d8 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  80111b:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  801122:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	53                   	push   %ebx
  801130:	56                   	push   %esi
  801131:	e8 86 f9 ff ff       	call   800abc <file_get_block>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 52                	js     80118f <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80113d:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801143:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801149:	eb 0e                	jmp    801159 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80114b:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801150:	eb 3d                	jmp    80118f <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801152:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801157:	eb 36                	jmp    80118f <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801162:	50                   	push   %eax
  801163:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  801169:	e8 79 10 00 00       	call   8021e7 <strcpy>
	*pf = f;
  80116e:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801174:	8b 45 0c             	mov    0xc(%ebp),%eax
  801177:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801179:	83 c4 04             	add    $0x4,%esp
  80117c:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801182:	e8 24 fe ff ff       	call   800fab <file_flush>
	return 0;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	53                   	push   %ebx
  80119b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80119e:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011a3:	eb 17                	jmp    8011bc <fs_sync+0x25>
		flush_block(diskaddr(i));
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	53                   	push   %ebx
  8011a9:	e8 e0 f1 ff ff       	call   80038e <diskaddr>
  8011ae:	89 04 24             	mov    %eax,(%esp)
  8011b1:	e8 56 f2 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8011b6:	83 c3 01             	add    $0x1,%ebx
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8011c1:	39 58 04             	cmp    %ebx,0x4(%eax)
  8011c4:	77 df                	ja     8011a5 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  8011c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    

008011cb <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8011d1:	e8 c1 ff ff ff       	call   801197 <fs_sync>
	return 0;
}
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8011e5:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011ef:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011f1:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011f4:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011fa:	83 c0 01             	add    $0x1,%eax
  8011fd:	83 c2 10             	add    $0x10,%edx
  801200:	3d 00 04 00 00       	cmp    $0x400,%eax
  801205:	75 e8                	jne    8011ef <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	89 d8                	mov    %ebx,%eax
  80121b:	c1 e0 04             	shl    $0x4,%eax
  80121e:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801224:	e8 03 20 00 00       	call   80322c <pageref>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	74 07                	je     801237 <openfile_alloc+0x2e>
  801230:	83 f8 01             	cmp    $0x1,%eax
  801233:	74 20                	je     801255 <openfile_alloc+0x4c>
  801235:	eb 51                	jmp    801288 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801237:	83 ec 04             	sub    $0x4,%esp
  80123a:	6a 07                	push   $0x7
  80123c:	89 d8                	mov    %ebx,%eax
  80123e:	c1 e0 04             	shl    $0x4,%eax
  801241:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801247:	6a 00                	push   $0x0
  801249:	e8 13 14 00 00       	call   802661 <sys_page_alloc>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 43                	js     801298 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801255:	c1 e3 04             	shl    $0x4,%ebx
  801258:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80125e:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801265:	04 00 00 
			*o = &opentab[i];
  801268:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	68 00 10 00 00       	push   $0x1000
  801272:	6a 00                	push   $0x0
  801274:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80127a:	e8 ad 10 00 00       	call   80232c <memset>
			return (*o)->o_fileid;
  80127f:	8b 06                	mov    (%esi),%eax
  801281:	8b 00                	mov    (%eax),%eax
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	eb 10                	jmp    801298 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801288:	83 c3 01             	add    $0x1,%ebx
  80128b:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801291:	75 83                	jne    801216 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801293:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 18             	sub    $0x18,%esp
  8012a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8012ab:	89 fb                	mov    %edi,%ebx
  8012ad:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8012b3:	89 de                	mov    %ebx,%esi
  8012b5:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012b8:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8012be:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012c4:	e8 63 1f 00 00       	call   80322c <pageref>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	83 f8 01             	cmp    $0x1,%eax
  8012cf:	7e 17                	jle    8012e8 <openfile_lookup+0x49>
  8012d1:	c1 e3 04             	shl    $0x4,%ebx
  8012d4:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  8012da:	75 13                	jne    8012ef <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  8012dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012df:	89 30                	mov    %esi,(%eax)
	return 0;
  8012e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e6:	eb 0c                	jmp    8012f4 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8012e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ed:	eb 05                	jmp    8012f4 <openfile_lookup+0x55>
  8012ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8012f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	53                   	push   %ebx
  801300:	83 ec 18             	sub    $0x18,%esp
  801303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 33                	pushl  (%ebx)
  80130c:	ff 75 08             	pushl  0x8(%ebp)
  80130f:	e8 8b ff ff ff       	call   80129f <openfile_lookup>
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 14                	js     80132f <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	ff 73 04             	pushl  0x4(%ebx)
  801321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801324:	ff 70 04             	pushl  0x4(%eax)
  801327:	e8 f8 fa ff ff       	call   800e24 <file_set_size>
  80132c:	83 c4 10             	add    $0x10,%esp
}
  80132f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 18             	sub    $0x18,%esp
  80133b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Lab 5: Your code here:
	int r; 

	// find struct OpenFile for this file
	struct OpenFile *o;
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	ff 33                	pushl  (%ebx)
  801344:	ff 75 08             	pushl  0x8(%ebp)
  801347:	e8 53 ff ff ff       	call   80129f <openfile_lookup>
  80134c:	83 c4 10             	add    $0x10,%esp
		return r;
  80134f:	89 c2                	mov    %eax,%edx
	// Lab 5: Your code here:
	int r; 

	// find struct OpenFile for this file
	struct OpenFile *o;
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801351:	85 c0                	test   %eax,%eax
  801353:	78 23                	js     801378 <serve_read+0x44>
		return r;
	
	// read and store the data in the page provided by the client
	size_t cnt;
	if((cnt = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  801355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801358:	8b 50 0c             	mov    0xc(%eax),%edx
  80135b:	ff 72 04             	pushl  0x4(%edx)
  80135e:	ff 73 04             	pushl  0x4(%ebx)
  801361:	53                   	push   %ebx
  801362:	ff 70 04             	pushl  0x4(%eax)
  801365:	e8 15 fa ff ff       	call   800d7f <file_read>
  80136a:	89 c2                	mov    %eax,%edx
		return cnt;
	// update the seek position
	o->o_fd->fd_offset += cnt;
  80136c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136f:	8b 40 0c             	mov    0xc(%eax),%eax
  801372:	01 50 04             	add    %edx,0x4(%eax)

	return cnt;
  801375:	83 c4 10             	add    $0x10,%esp


}
  801378:	89 d0                	mov    %edx,%eax
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 18             	sub    $0x18,%esp
  801386:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	int r;

	struct OpenFile *o;
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801389:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 33                	pushl  (%ebx)
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 08 ff ff ff       	call   80129f <openfile_lookup>
  801397:	83 c4 10             	add    $0x10,%esp
		return r;
  80139a:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	int r;

	struct OpenFile *o;
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 26                	js     8013c6 <serve_write+0x47>
		return r;

	size_t cnt;
	if((cnt = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  8013a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a3:	8b 50 0c             	mov    0xc(%eax),%edx
  8013a6:	ff 72 04             	pushl  0x4(%edx)
  8013a9:	ff 73 04             	pushl  0x4(%ebx)
  8013ac:	83 c3 08             	add    $0x8,%ebx
  8013af:	53                   	push   %ebx
  8013b0:	ff 70 04             	pushl  0x4(%eax)
  8013b3:	e8 4d fb ff ff       	call   800f05 <file_write>
  8013b8:	89 c2                	mov    %eax,%edx
		return cnt;

	// update the seek position
	o->o_fd->fd_offset += cnt;
  8013ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c0:	01 50 04             	add    %edx,0x4(%eax)

	return cnt;
  8013c3:	83 c4 10             	add    $0x10,%esp
}
  8013c6:	89 d0                	mov    %edx,%eax
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 18             	sub    $0x18,%esp
  8013d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	ff 33                	pushl  (%ebx)
  8013dd:	ff 75 08             	pushl  0x8(%ebp)
  8013e0:	e8 ba fe ff ff       	call   80129f <openfile_lookup>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 3f                	js     80142b <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f2:	ff 70 04             	pushl  0x4(%eax)
  8013f5:	53                   	push   %ebx
  8013f6:	e8 ec 0d 00 00       	call   8021e7 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fe:	8b 50 04             	mov    0x4(%eax),%edx
  801401:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801407:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80140d:	8b 40 04             	mov    0x4(%eax),%eax
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80141a:	0f 94 c0             	sete   %al
  80141d:	0f b6 c0             	movzbl %al,%eax
  801420:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801426:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801436:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143d:	ff 30                	pushl  (%eax)
  80143f:	ff 75 08             	pushl  0x8(%ebp)
  801442:	e8 58 fe ff ff       	call   80129f <openfile_lookup>
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 16                	js     801464 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801454:	ff 70 04             	pushl  0x4(%eax)
  801457:	e8 4f fb ff ff       	call   800fab <file_flush>
	return 0;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801470:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801473:	68 00 04 00 00       	push   $0x400
  801478:	53                   	push   %ebx
  801479:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	e8 f4 0e 00 00       	call   802379 <memmove>
	path[MAXPATHLEN-1] = 0;
  801485:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801489:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80148f:	89 04 24             	mov    %eax,(%esp)
  801492:	e8 72 fd ff ff       	call   801209 <openfile_alloc>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	0f 88 f0 00 00 00    	js     801592 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8014a2:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8014a9:	74 33                	je     8014de <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	e8 87 fb ff ff       	call   801048 <file_create>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	79 37                	jns    8014ff <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8014c8:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8014cf:	0f 85 bd 00 00 00    	jne    801592 <serve_open+0x12c>
  8014d5:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014d8:	0f 85 b4 00 00 00    	jne    801592 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	e8 71 f8 ff ff       	call   800d65 <file_open>
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	0f 88 93 00 00 00    	js     801592 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8014ff:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801506:	74 17                	je     80151f <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	6a 00                	push   $0x0
  80150d:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  801513:	e8 0c f9 ff ff       	call   800e24 <file_set_size>
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 73                	js     801592 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	e8 30 f8 ff ff       	call   800d65 <file_open>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 56                	js     801592 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80153c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801542:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801548:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  80154b:	8b 50 0c             	mov    0xc(%eax),%edx
  80154e:	8b 08                	mov    (%eax),%ecx
  801550:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801553:	8b 48 0c             	mov    0xc(%eax),%ecx
  801556:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80155c:	83 e2 03             	and    $0x3,%edx
  80155f:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801562:	8b 40 0c             	mov    0xc(%eax),%eax
  801565:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80156b:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80156d:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801573:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801579:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80157c:	8b 50 0c             	mov    0xc(%eax),%edx
  80157f:	8b 45 10             	mov    0x10(%ebp),%eax
  801582:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801584:	8b 45 14             	mov    0x14(%ebp),%eax
  801587:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80158d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <serve>:
	#endif 
};

void
serve(void)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80159f:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8015a2:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8015a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	53                   	push   %ebx
  8015b0:	ff 35 44 50 80 00    	pushl  0x805044
  8015b6:	56                   	push   %esi
  8015b7:	e8 25 13 00 00       	call   8028e1 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8015c3:	75 15                	jne    8015da <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cb:	68 f0 3c 80 00       	push   $0x803cf0
  8015d0:	e8 de 05 00 00       	call   801bb3 <cprintf>
				whom);
			continue; // just leave it hanging...
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb cb                	jmp    8015a5 <serve+0xe>
		}

		pg = NULL;
  8015da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8015e1:	83 f8 01             	cmp    $0x1,%eax
  8015e4:	75 18                	jne    8015fe <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015e6:	53                   	push   %ebx
  8015e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	ff 35 44 50 80 00    	pushl  0x805044
  8015f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f4:	e8 6d fe ff ff       	call   801466 <serve_open>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	eb 3c                	jmp    80163a <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015fe:	83 f8 08             	cmp    $0x8,%eax
  801601:	77 1e                	ja     801621 <serve+0x8a>
  801603:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  80160a:	85 d2                	test   %edx,%edx
  80160c:	74 13                	je     801621 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	ff 35 44 50 80 00    	pushl  0x805044
  801617:	ff 75 f4             	pushl  -0xc(%ebp)
  80161a:	ff d2                	call   *%edx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb 19                	jmp    80163a <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	ff 75 f4             	pushl  -0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	68 20 3d 80 00       	push   $0x803d20
  80162d:	e8 81 05 00 00       	call   801bb3 <cprintf>
  801632:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80163a:	ff 75 f0             	pushl  -0x10(%ebp)
  80163d:	ff 75 ec             	pushl  -0x14(%ebp)
  801640:	50                   	push   %eax
  801641:	ff 75 f4             	pushl  -0xc(%ebp)
  801644:	e8 01 13 00 00       	call   80294a <ipc_send>
		sys_page_unmap(0, fsreq);
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	ff 35 44 50 80 00    	pushl  0x805044
  801652:	6a 00                	push   $0x0
  801654:	e8 8d 10 00 00       	call   8026e6 <sys_page_unmap>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	e9 44 ff ff ff       	jmp    8015a5 <serve+0xe>

00801661 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801667:	c7 05 60 90 80 00 43 	movl   $0x803d43,0x809060
  80166e:	3d 80 00 
	cprintf("FS is running\n");
  801671:	68 46 3d 80 00       	push   $0x803d46
  801676:	e8 38 05 00 00       	call   801bb3 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80167b:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801680:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801685:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801687:	c7 04 24 55 3d 80 00 	movl   $0x803d55,(%esp)
  80168e:	e8 20 05 00 00       	call   801bb3 <cprintf>

	serve_init();
  801693:	e8 45 fb ff ff       	call   8011dd <serve_init>
	fs_init();
  801698:	e8 c0 f3 ff ff       	call   800a5d <fs_init>
        fs_test();
  80169d:	e8 05 00 00 00       	call   8016a7 <fs_test>
	serve();
  8016a2:	e8 f0 fe ff ff       	call   801597 <serve>

008016a7 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8016ae:	6a 07                	push   $0x7
  8016b0:	68 00 10 00 00       	push   $0x1000
  8016b5:	6a 00                	push   $0x0
  8016b7:	e8 a5 0f 00 00       	call   802661 <sys_page_alloc>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	79 12                	jns    8016d5 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  8016c3:	50                   	push   %eax
  8016c4:	68 64 3d 80 00       	push   $0x803d64
  8016c9:	6a 12                	push   $0x12
  8016cb:	68 77 3d 80 00       	push   $0x803d77
  8016d0:	e8 05 04 00 00       	call   801ada <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	68 00 10 00 00       	push   $0x1000
  8016dd:	ff 35 08 a0 80 00    	pushl  0x80a008
  8016e3:	68 00 10 00 00       	push   $0x1000
  8016e8:	e8 8c 0c 00 00       	call   802379 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016ed:	e8 86 f1 ff ff       	call   800878 <alloc_block>
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	79 12                	jns    80170b <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016f9:	50                   	push   %eax
  8016fa:	68 81 3d 80 00       	push   $0x803d81
  8016ff:	6a 17                	push   $0x17
  801701:	68 77 3d 80 00       	push   $0x803d77
  801706:	e8 cf 03 00 00       	call   801ada <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  80170b:	8d 50 1f             	lea    0x1f(%eax),%edx
  80170e:	85 c0                	test   %eax,%eax
  801710:	0f 49 d0             	cmovns %eax,%edx
  801713:	c1 fa 05             	sar    $0x5,%edx
  801716:	89 c3                	mov    %eax,%ebx
  801718:	c1 fb 1f             	sar    $0x1f,%ebx
  80171b:	c1 eb 1b             	shr    $0x1b,%ebx
  80171e:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801721:	83 e1 1f             	and    $0x1f,%ecx
  801724:	29 d9                	sub    %ebx,%ecx
  801726:	b8 01 00 00 00       	mov    $0x1,%eax
  80172b:	d3 e0                	shl    %cl,%eax
  80172d:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801734:	75 16                	jne    80174c <fs_test+0xa5>
  801736:	68 91 3d 80 00       	push   $0x803d91
  80173b:	68 1d 3a 80 00       	push   $0x803a1d
  801740:	6a 19                	push   $0x19
  801742:	68 77 3d 80 00       	push   $0x803d77
  801747:	e8 8e 03 00 00       	call   801ada <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80174c:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  801752:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801755:	74 16                	je     80176d <fs_test+0xc6>
  801757:	68 0c 3f 80 00       	push   $0x803f0c
  80175c:	68 1d 3a 80 00       	push   $0x803a1d
  801761:	6a 1b                	push   $0x1b
  801763:	68 77 3d 80 00       	push   $0x803d77
  801768:	e8 6d 03 00 00       	call   801ada <_panic>
	cprintf("alloc_block is good\n");
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	68 ac 3d 80 00       	push   $0x803dac
  801775:	e8 39 04 00 00       	call   801bb3 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80177a:	83 c4 08             	add    $0x8,%esp
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	68 c1 3d 80 00       	push   $0x803dc1
  801786:	e8 da f5 ff ff       	call   800d65 <file_open>
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801791:	74 1b                	je     8017ae <fs_test+0x107>
  801793:	89 c2                	mov    %eax,%edx
  801795:	c1 ea 1f             	shr    $0x1f,%edx
  801798:	84 d2                	test   %dl,%dl
  80179a:	74 12                	je     8017ae <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80179c:	50                   	push   %eax
  80179d:	68 cc 3d 80 00       	push   $0x803dcc
  8017a2:	6a 1f                	push   $0x1f
  8017a4:	68 77 3d 80 00       	push   $0x803d77
  8017a9:	e8 2c 03 00 00       	call   801ada <_panic>
	else if (r == 0)
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	75 14                	jne    8017c6 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	68 2c 3f 80 00       	push   $0x803f2c
  8017ba:	6a 21                	push   $0x21
  8017bc:	68 77 3d 80 00       	push   $0x803d77
  8017c1:	e8 14 03 00 00       	call   801ada <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	68 e5 3d 80 00       	push   $0x803de5
  8017d2:	e8 8e f5 ff ff       	call   800d65 <file_open>
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	79 12                	jns    8017f0 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8017de:	50                   	push   %eax
  8017df:	68 ee 3d 80 00       	push   $0x803dee
  8017e4:	6a 23                	push   $0x23
  8017e6:	68 77 3d 80 00       	push   $0x803d77
  8017eb:	e8 ea 02 00 00       	call   801ada <_panic>
	cprintf("file_open is good\n");
  8017f0:	83 ec 0c             	sub    $0xc,%esp
  8017f3:	68 05 3e 80 00       	push   $0x803e05
  8017f8:	e8 b6 03 00 00       	call   801bb3 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017fd:	83 c4 0c             	add    $0xc,%esp
  801800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	6a 00                	push   $0x0
  801806:	ff 75 f4             	pushl  -0xc(%ebp)
  801809:	e8 ae f2 ff ff       	call   800abc <file_get_block>
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	85 c0                	test   %eax,%eax
  801813:	79 12                	jns    801827 <fs_test+0x180>
		panic("file_get_block: %e", r);
  801815:	50                   	push   %eax
  801816:	68 18 3e 80 00       	push   $0x803e18
  80181b:	6a 27                	push   $0x27
  80181d:	68 77 3d 80 00       	push   $0x803d77
  801822:	e8 b3 02 00 00       	call   801ada <_panic>
	if (strcmp(blk, msg) != 0)
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	68 4c 3f 80 00       	push   $0x803f4c
  80182f:	ff 75 f0             	pushl  -0x10(%ebp)
  801832:	e8 5a 0a 00 00       	call   802291 <strcmp>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	74 14                	je     801852 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	68 74 3f 80 00       	push   $0x803f74
  801846:	6a 29                	push   $0x29
  801848:	68 77 3d 80 00       	push   $0x803d77
  80184d:	e8 88 02 00 00       	call   801ada <_panic>
	cprintf("file_get_block is good\n");
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	68 2b 3e 80 00       	push   $0x803e2b
  80185a:	e8 54 03 00 00       	call   801bb3 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80185f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801862:	0f b6 10             	movzbl (%eax),%edx
  801865:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186a:	c1 e8 0c             	shr    $0xc,%eax
  80186d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	a8 40                	test   $0x40,%al
  801879:	75 16                	jne    801891 <fs_test+0x1ea>
  80187b:	68 44 3e 80 00       	push   $0x803e44
  801880:	68 1d 3a 80 00       	push   $0x803a1d
  801885:	6a 2d                	push   $0x2d
  801887:	68 77 3d 80 00       	push   $0x803d77
  80188c:	e8 49 02 00 00       	call   801ada <_panic>
	file_flush(f);
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	ff 75 f4             	pushl  -0xc(%ebp)
  801897:	e8 0f f7 ff ff       	call   800fab <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189f:	c1 e8 0c             	shr    $0xc,%eax
  8018a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	a8 40                	test   $0x40,%al
  8018ae:	74 16                	je     8018c6 <fs_test+0x21f>
  8018b0:	68 43 3e 80 00       	push   $0x803e43
  8018b5:	68 1d 3a 80 00       	push   $0x803a1d
  8018ba:	6a 2f                	push   $0x2f
  8018bc:	68 77 3d 80 00       	push   $0x803d77
  8018c1:	e8 14 02 00 00       	call   801ada <_panic>
	cprintf("file_flush is good\n");
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	68 5f 3e 80 00       	push   $0x803e5f
  8018ce:	e8 e0 02 00 00       	call   801bb3 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018d3:	83 c4 08             	add    $0x8,%esp
  8018d6:	6a 00                	push   $0x0
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 44 f5 ff ff       	call   800e24 <file_set_size>
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	79 12                	jns    8018f9 <fs_test+0x252>
		panic("file_set_size: %e", r);
  8018e7:	50                   	push   %eax
  8018e8:	68 73 3e 80 00       	push   $0x803e73
  8018ed:	6a 33                	push   $0x33
  8018ef:	68 77 3d 80 00       	push   $0x803d77
  8018f4:	e8 e1 01 00 00       	call   801ada <_panic>
	assert(f->f_direct[0] == 0);
  8018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fc:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801903:	74 16                	je     80191b <fs_test+0x274>
  801905:	68 85 3e 80 00       	push   $0x803e85
  80190a:	68 1d 3a 80 00       	push   $0x803a1d
  80190f:	6a 34                	push   $0x34
  801911:	68 77 3d 80 00       	push   $0x803d77
  801916:	e8 bf 01 00 00       	call   801ada <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80191b:	c1 e8 0c             	shr    $0xc,%eax
  80191e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801925:	a8 40                	test   $0x40,%al
  801927:	74 16                	je     80193f <fs_test+0x298>
  801929:	68 99 3e 80 00       	push   $0x803e99
  80192e:	68 1d 3a 80 00       	push   $0x803a1d
  801933:	6a 35                	push   $0x35
  801935:	68 77 3d 80 00       	push   $0x803d77
  80193a:	e8 9b 01 00 00       	call   801ada <_panic>
	cprintf("file_truncate is good\n");
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	68 b3 3e 80 00       	push   $0x803eb3
  801947:	e8 67 02 00 00       	call   801bb3 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80194c:	c7 04 24 4c 3f 80 00 	movl   $0x803f4c,(%esp)
  801953:	e8 56 08 00 00       	call   8021ae <strlen>
  801958:	83 c4 08             	add    $0x8,%esp
  80195b:	50                   	push   %eax
  80195c:	ff 75 f4             	pushl  -0xc(%ebp)
  80195f:	e8 c0 f4 ff ff       	call   800e24 <file_set_size>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	79 12                	jns    80197d <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80196b:	50                   	push   %eax
  80196c:	68 ca 3e 80 00       	push   $0x803eca
  801971:	6a 39                	push   $0x39
  801973:	68 77 3d 80 00       	push   $0x803d77
  801978:	e8 5d 01 00 00       	call   801ada <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80197d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801980:	89 c2                	mov    %eax,%edx
  801982:	c1 ea 0c             	shr    $0xc,%edx
  801985:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80198c:	f6 c2 40             	test   $0x40,%dl
  80198f:	74 16                	je     8019a7 <fs_test+0x300>
  801991:	68 99 3e 80 00       	push   $0x803e99
  801996:	68 1d 3a 80 00       	push   $0x803a1d
  80199b:	6a 3a                	push   $0x3a
  80199d:	68 77 3d 80 00       	push   $0x803d77
  8019a2:	e8 33 01 00 00       	call   801ada <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019a7:	83 ec 04             	sub    $0x4,%esp
  8019aa:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8019ad:	52                   	push   %edx
  8019ae:	6a 00                	push   $0x0
  8019b0:	50                   	push   %eax
  8019b1:	e8 06 f1 ff ff       	call   800abc <file_get_block>
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	79 12                	jns    8019cf <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  8019bd:	50                   	push   %eax
  8019be:	68 de 3e 80 00       	push   $0x803ede
  8019c3:	6a 3c                	push   $0x3c
  8019c5:	68 77 3d 80 00       	push   $0x803d77
  8019ca:	e8 0b 01 00 00       	call   801ada <_panic>
	strcpy(blk, msg);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	68 4c 3f 80 00       	push   $0x803f4c
  8019d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8019da:	e8 08 08 00 00       	call   8021e7 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e2:	c1 e8 0c             	shr    $0xc,%eax
  8019e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	a8 40                	test   $0x40,%al
  8019f1:	75 16                	jne    801a09 <fs_test+0x362>
  8019f3:	68 44 3e 80 00       	push   $0x803e44
  8019f8:	68 1d 3a 80 00       	push   $0x803a1d
  8019fd:	6a 3e                	push   $0x3e
  8019ff:	68 77 3d 80 00       	push   $0x803d77
  801a04:	e8 d1 00 00 00       	call   801ada <_panic>
	file_flush(f);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0f:	e8 97 f5 ff ff       	call   800fab <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a17:	c1 e8 0c             	shr    $0xc,%eax
  801a1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	a8 40                	test   $0x40,%al
  801a26:	74 16                	je     801a3e <fs_test+0x397>
  801a28:	68 43 3e 80 00       	push   $0x803e43
  801a2d:	68 1d 3a 80 00       	push   $0x803a1d
  801a32:	6a 40                	push   $0x40
  801a34:	68 77 3d 80 00       	push   $0x803d77
  801a39:	e8 9c 00 00 00       	call   801ada <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a41:	c1 e8 0c             	shr    $0xc,%eax
  801a44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a4b:	a8 40                	test   $0x40,%al
  801a4d:	74 16                	je     801a65 <fs_test+0x3be>
  801a4f:	68 99 3e 80 00       	push   $0x803e99
  801a54:	68 1d 3a 80 00       	push   $0x803a1d
  801a59:	6a 41                	push   $0x41
  801a5b:	68 77 3d 80 00       	push   $0x803d77
  801a60:	e8 75 00 00 00       	call   801ada <_panic>
	cprintf("file rewrite is good\n");
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	68 f3 3e 80 00       	push   $0x803ef3
  801a6d:	e8 41 01 00 00       	call   801bb3 <cprintf>
}
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a82:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801a85:	e8 99 0b 00 00       	call   802623 <sys_getenvid>
  801a8a:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a8f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a92:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a97:	a3 10 a0 80 00       	mov    %eax,0x80a010
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	7e 07                	jle    801aa7 <libmain+0x2d>
		binaryname = argv[0];
  801aa0:	8b 06                	mov    (%esi),%eax
  801aa2:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801aa7:	83 ec 08             	sub    $0x8,%esp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	e8 b0 fb ff ff       	call   801661 <umain>

	// exit gracefully
	exit();
  801ab1:	e8 0a 00 00 00       	call   801ac0 <exit>
}
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801ac6:	e8 d9 10 00 00       	call   802ba4 <close_all>
	sys_env_destroy(0);
  801acb:	83 ec 0c             	sub    $0xc,%esp
  801ace:	6a 00                	push   $0x0
  801ad0:	e8 0d 0b 00 00       	call   8025e2 <sys_env_destroy>
}
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801adf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ae2:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ae8:	e8 36 0b 00 00       	call   802623 <sys_getenvid>
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	ff 75 0c             	pushl  0xc(%ebp)
  801af3:	ff 75 08             	pushl  0x8(%ebp)
  801af6:	56                   	push   %esi
  801af7:	50                   	push   %eax
  801af8:	68 a4 3f 80 00       	push   $0x803fa4
  801afd:	e8 b1 00 00 00       	call   801bb3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b02:	83 c4 18             	add    $0x18,%esp
  801b05:	53                   	push   %ebx
  801b06:	ff 75 10             	pushl  0x10(%ebp)
  801b09:	e8 54 00 00 00       	call   801b62 <vcprintf>
	cprintf("\n");
  801b0e:	c7 04 24 b3 3b 80 00 	movl   $0x803bb3,(%esp)
  801b15:	e8 99 00 00 00       	call   801bb3 <cprintf>
  801b1a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b1d:	cc                   	int3   
  801b1e:	eb fd                	jmp    801b1d <_panic+0x43>

00801b20 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	53                   	push   %ebx
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b2a:	8b 13                	mov    (%ebx),%edx
  801b2c:	8d 42 01             	lea    0x1(%edx),%eax
  801b2f:	89 03                	mov    %eax,(%ebx)
  801b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b34:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b38:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b3d:	75 1a                	jne    801b59 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b3f:	83 ec 08             	sub    $0x8,%esp
  801b42:	68 ff 00 00 00       	push   $0xff
  801b47:	8d 43 08             	lea    0x8(%ebx),%eax
  801b4a:	50                   	push   %eax
  801b4b:	e8 55 0a 00 00       	call   8025a5 <sys_cputs>
		b->idx = 0;
  801b50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b56:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b59:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801b6b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b72:	00 00 00 
	b.cnt = 0;
  801b75:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b7c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b7f:	ff 75 0c             	pushl  0xc(%ebp)
  801b82:	ff 75 08             	pushl  0x8(%ebp)
  801b85:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b8b:	50                   	push   %eax
  801b8c:	68 20 1b 80 00       	push   $0x801b20
  801b91:	e8 54 01 00 00       	call   801cea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b96:	83 c4 08             	add    $0x8,%esp
  801b99:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b9f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	e8 fa 09 00 00       	call   8025a5 <sys_cputs>

	return b.cnt;
}
  801bab:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bb9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bbc:	50                   	push   %eax
  801bbd:	ff 75 08             	pushl  0x8(%ebp)
  801bc0:	e8 9d ff ff ff       	call   801b62 <vcprintf>
	va_end(ap);

	return cnt;
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	57                   	push   %edi
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 1c             	sub    $0x1c,%esp
  801bd0:	89 c7                	mov    %eax,%edi
  801bd2:	89 d6                	mov    %edx,%esi
  801bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bda:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bdd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801be0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801be3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801beb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801bee:	39 d3                	cmp    %edx,%ebx
  801bf0:	72 05                	jb     801bf7 <printnum+0x30>
  801bf2:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bf5:	77 45                	ja     801c3c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	ff 75 18             	pushl  0x18(%ebp)
  801bfd:	8b 45 14             	mov    0x14(%ebp),%eax
  801c00:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c03:	53                   	push   %ebx
  801c04:	ff 75 10             	pushl  0x10(%ebp)
  801c07:	83 ec 08             	sub    $0x8,%esp
  801c0a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c0d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c10:	ff 75 dc             	pushl  -0x24(%ebp)
  801c13:	ff 75 d8             	pushl  -0x28(%ebp)
  801c16:	e8 35 1b 00 00       	call   803750 <__udivdi3>
  801c1b:	83 c4 18             	add    $0x18,%esp
  801c1e:	52                   	push   %edx
  801c1f:	50                   	push   %eax
  801c20:	89 f2                	mov    %esi,%edx
  801c22:	89 f8                	mov    %edi,%eax
  801c24:	e8 9e ff ff ff       	call   801bc7 <printnum>
  801c29:	83 c4 20             	add    $0x20,%esp
  801c2c:	eb 18                	jmp    801c46 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	56                   	push   %esi
  801c32:	ff 75 18             	pushl  0x18(%ebp)
  801c35:	ff d7                	call   *%edi
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	eb 03                	jmp    801c3f <printnum+0x78>
  801c3c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c3f:	83 eb 01             	sub    $0x1,%ebx
  801c42:	85 db                	test   %ebx,%ebx
  801c44:	7f e8                	jg     801c2e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	56                   	push   %esi
  801c4a:	83 ec 04             	sub    $0x4,%esp
  801c4d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c50:	ff 75 e0             	pushl  -0x20(%ebp)
  801c53:	ff 75 dc             	pushl  -0x24(%ebp)
  801c56:	ff 75 d8             	pushl  -0x28(%ebp)
  801c59:	e8 22 1c 00 00       	call   803880 <__umoddi3>
  801c5e:	83 c4 14             	add    $0x14,%esp
  801c61:	0f be 80 c7 3f 80 00 	movsbl 0x803fc7(%eax),%eax
  801c68:	50                   	push   %eax
  801c69:	ff d7                	call   *%edi
}
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c79:	83 fa 01             	cmp    $0x1,%edx
  801c7c:	7e 0e                	jle    801c8c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c7e:	8b 10                	mov    (%eax),%edx
  801c80:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c83:	89 08                	mov    %ecx,(%eax)
  801c85:	8b 02                	mov    (%edx),%eax
  801c87:	8b 52 04             	mov    0x4(%edx),%edx
  801c8a:	eb 22                	jmp    801cae <getuint+0x38>
	else if (lflag)
  801c8c:	85 d2                	test   %edx,%edx
  801c8e:	74 10                	je     801ca0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c90:	8b 10                	mov    (%eax),%edx
  801c92:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c95:	89 08                	mov    %ecx,(%eax)
  801c97:	8b 02                	mov    (%edx),%eax
  801c99:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9e:	eb 0e                	jmp    801cae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801ca0:	8b 10                	mov    (%eax),%edx
  801ca2:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ca5:	89 08                	mov    %ecx,(%eax)
  801ca7:	8b 02                	mov    (%edx),%eax
  801ca9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801cb6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801cba:	8b 10                	mov    (%eax),%edx
  801cbc:	3b 50 04             	cmp    0x4(%eax),%edx
  801cbf:	73 0a                	jae    801ccb <sprintputch+0x1b>
		*b->buf++ = ch;
  801cc1:	8d 4a 01             	lea    0x1(%edx),%ecx
  801cc4:	89 08                	mov    %ecx,(%eax)
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	88 02                	mov    %al,(%edx)
}
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801cd3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801cd6:	50                   	push   %eax
  801cd7:	ff 75 10             	pushl  0x10(%ebp)
  801cda:	ff 75 0c             	pushl  0xc(%ebp)
  801cdd:	ff 75 08             	pushl  0x8(%ebp)
  801ce0:	e8 05 00 00 00       	call   801cea <vprintfmt>
	va_end(ap);
}
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	57                   	push   %edi
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	83 ec 2c             	sub    $0x2c,%esp
  801cf3:	8b 75 08             	mov    0x8(%ebp),%esi
  801cf6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cf9:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cfc:	eb 12                	jmp    801d10 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	0f 84 38 04 00 00    	je     80213e <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  801d06:	83 ec 08             	sub    $0x8,%esp
  801d09:	53                   	push   %ebx
  801d0a:	50                   	push   %eax
  801d0b:	ff d6                	call   *%esi
  801d0d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d10:	83 c7 01             	add    $0x1,%edi
  801d13:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d17:	83 f8 25             	cmp    $0x25,%eax
  801d1a:	75 e2                	jne    801cfe <vprintfmt+0x14>
  801d1c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801d20:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d27:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801d2e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d35:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3a:	eb 07                	jmp    801d43 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  801d3f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d43:	8d 47 01             	lea    0x1(%edi),%eax
  801d46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d49:	0f b6 07             	movzbl (%edi),%eax
  801d4c:	0f b6 c8             	movzbl %al,%ecx
  801d4f:	83 e8 23             	sub    $0x23,%eax
  801d52:	3c 55                	cmp    $0x55,%al
  801d54:	0f 87 c9 03 00 00    	ja     802123 <vprintfmt+0x439>
  801d5a:	0f b6 c0             	movzbl %al,%eax
  801d5d:	ff 24 85 00 41 80 00 	jmp    *0x804100(,%eax,4)
  801d64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d67:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d6b:	eb d6                	jmp    801d43 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  801d6d:	c7 05 00 a0 80 00 00 	movl   $0x0,0x80a000
  801d74:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801d7a:	eb 94                	jmp    801d10 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  801d7c:	c7 05 00 a0 80 00 01 	movl   $0x1,0x80a000
  801d83:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801d89:	eb 85                	jmp    801d10 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801d8b:	c7 05 00 a0 80 00 02 	movl   $0x2,0x80a000
  801d92:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801d98:	e9 73 ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  801d9d:	c7 05 00 a0 80 00 03 	movl   $0x3,0x80a000
  801da4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801daa:	e9 61 ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  801daf:	c7 05 00 a0 80 00 04 	movl   $0x4,0x80a000
  801db6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  801dbc:	e9 4f ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  801dc1:	c7 05 00 a0 80 00 05 	movl   $0x5,0x80a000
  801dc8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  801dce:	e9 3d ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801dd3:	c7 05 00 a0 80 00 06 	movl   $0x6,0x80a000
  801dda:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ddd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  801de0:	e9 2b ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801de5:	c7 05 00 a0 80 00 07 	movl   $0x7,0x80a000
  801dec:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801def:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  801df2:	e9 19 ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  801df7:	c7 05 00 a0 80 00 08 	movl   $0x8,0x80a000
  801dfe:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  801e04:	e9 07 ff ff ff       	jmp    801d10 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  801e09:	c7 05 00 a0 80 00 09 	movl   $0x9,0x80a000
  801e10:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  801e16:	e9 f5 fe ff ff       	jmp    801d10 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e1b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801e26:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801e29:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801e2d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801e30:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801e33:	83 fa 09             	cmp    $0x9,%edx
  801e36:	77 3f                	ja     801e77 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801e38:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801e3b:	eb e9                	jmp    801e26 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801e3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e40:	8d 48 04             	lea    0x4(%eax),%ecx
  801e43:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801e46:	8b 00                	mov    (%eax),%eax
  801e48:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801e4e:	eb 2d                	jmp    801e7d <vprintfmt+0x193>
  801e50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e53:	85 c0                	test   %eax,%eax
  801e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e5a:	0f 49 c8             	cmovns %eax,%ecx
  801e5d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e63:	e9 db fe ff ff       	jmp    801d43 <vprintfmt+0x59>
  801e68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801e6b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801e72:	e9 cc fe ff ff       	jmp    801d43 <vprintfmt+0x59>
  801e77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e7a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801e7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e81:	0f 89 bc fe ff ff    	jns    801d43 <vprintfmt+0x59>
				width = precision, precision = -1;
  801e87:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e8d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801e94:	e9 aa fe ff ff       	jmp    801d43 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801e99:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801e9f:	e9 9f fe ff ff       	jmp    801d43 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801ea4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ea7:	8d 50 04             	lea    0x4(%eax),%edx
  801eaa:	89 55 14             	mov    %edx,0x14(%ebp)
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	53                   	push   %ebx
  801eb1:	ff 30                	pushl  (%eax)
  801eb3:	ff d6                	call   *%esi
			break;
  801eb5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801ebb:	e9 50 fe ff ff       	jmp    801d10 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ec0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec3:	8d 50 04             	lea    0x4(%eax),%edx
  801ec6:	89 55 14             	mov    %edx,0x14(%ebp)
  801ec9:	8b 00                	mov    (%eax),%eax
  801ecb:	99                   	cltd   
  801ecc:	31 d0                	xor    %edx,%eax
  801ece:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ed0:	83 f8 0f             	cmp    $0xf,%eax
  801ed3:	7f 0b                	jg     801ee0 <vprintfmt+0x1f6>
  801ed5:	8b 14 85 60 42 80 00 	mov    0x804260(,%eax,4),%edx
  801edc:	85 d2                	test   %edx,%edx
  801ede:	75 18                	jne    801ef8 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  801ee0:	50                   	push   %eax
  801ee1:	68 df 3f 80 00       	push   $0x803fdf
  801ee6:	53                   	push   %ebx
  801ee7:	56                   	push   %esi
  801ee8:	e8 e0 fd ff ff       	call   801ccd <printfmt>
  801eed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ef0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801ef3:	e9 18 fe ff ff       	jmp    801d10 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801ef8:	52                   	push   %edx
  801ef9:	68 2f 3a 80 00       	push   $0x803a2f
  801efe:	53                   	push   %ebx
  801eff:	56                   	push   %esi
  801f00:	e8 c8 fd ff ff       	call   801ccd <printfmt>
  801f05:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f0b:	e9 00 fe ff ff       	jmp    801d10 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801f10:	8b 45 14             	mov    0x14(%ebp),%eax
  801f13:	8d 50 04             	lea    0x4(%eax),%edx
  801f16:	89 55 14             	mov    %edx,0x14(%ebp)
  801f19:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801f1b:	85 ff                	test   %edi,%edi
  801f1d:	b8 d8 3f 80 00       	mov    $0x803fd8,%eax
  801f22:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801f25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801f29:	0f 8e 94 00 00 00    	jle    801fc3 <vprintfmt+0x2d9>
  801f2f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801f33:	0f 84 98 00 00 00    	je     801fd1 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  801f39:	83 ec 08             	sub    $0x8,%esp
  801f3c:	ff 75 d0             	pushl  -0x30(%ebp)
  801f3f:	57                   	push   %edi
  801f40:	e8 81 02 00 00       	call   8021c6 <strnlen>
  801f45:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f48:	29 c1                	sub    %eax,%ecx
  801f4a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801f4d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801f50:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f57:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801f5a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f5c:	eb 0f                	jmp    801f6d <vprintfmt+0x283>
					putch(padc, putdat);
  801f5e:	83 ec 08             	sub    $0x8,%esp
  801f61:	53                   	push   %ebx
  801f62:	ff 75 e0             	pushl  -0x20(%ebp)
  801f65:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f67:	83 ef 01             	sub    $0x1,%edi
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	85 ff                	test   %edi,%edi
  801f6f:	7f ed                	jg     801f5e <vprintfmt+0x274>
  801f71:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801f74:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801f77:	85 c9                	test   %ecx,%ecx
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7e:	0f 49 c1             	cmovns %ecx,%eax
  801f81:	29 c1                	sub    %eax,%ecx
  801f83:	89 75 08             	mov    %esi,0x8(%ebp)
  801f86:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f89:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f8c:	89 cb                	mov    %ecx,%ebx
  801f8e:	eb 4d                	jmp    801fdd <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801f90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801f94:	74 1b                	je     801fb1 <vprintfmt+0x2c7>
  801f96:	0f be c0             	movsbl %al,%eax
  801f99:	83 e8 20             	sub    $0x20,%eax
  801f9c:	83 f8 5e             	cmp    $0x5e,%eax
  801f9f:	76 10                	jbe    801fb1 <vprintfmt+0x2c7>
					putch('?', putdat);
  801fa1:	83 ec 08             	sub    $0x8,%esp
  801fa4:	ff 75 0c             	pushl  0xc(%ebp)
  801fa7:	6a 3f                	push   $0x3f
  801fa9:	ff 55 08             	call   *0x8(%ebp)
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	eb 0d                	jmp    801fbe <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	ff 75 0c             	pushl  0xc(%ebp)
  801fb7:	52                   	push   %edx
  801fb8:	ff 55 08             	call   *0x8(%ebp)
  801fbb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801fbe:	83 eb 01             	sub    $0x1,%ebx
  801fc1:	eb 1a                	jmp    801fdd <vprintfmt+0x2f3>
  801fc3:	89 75 08             	mov    %esi,0x8(%ebp)
  801fc6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801fc9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801fcc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801fcf:	eb 0c                	jmp    801fdd <vprintfmt+0x2f3>
  801fd1:	89 75 08             	mov    %esi,0x8(%ebp)
  801fd4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801fd7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801fda:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801fdd:	83 c7 01             	add    $0x1,%edi
  801fe0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801fe4:	0f be d0             	movsbl %al,%edx
  801fe7:	85 d2                	test   %edx,%edx
  801fe9:	74 23                	je     80200e <vprintfmt+0x324>
  801feb:	85 f6                	test   %esi,%esi
  801fed:	78 a1                	js     801f90 <vprintfmt+0x2a6>
  801fef:	83 ee 01             	sub    $0x1,%esi
  801ff2:	79 9c                	jns    801f90 <vprintfmt+0x2a6>
  801ff4:	89 df                	mov    %ebx,%edi
  801ff6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ffc:	eb 18                	jmp    802016 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	53                   	push   %ebx
  802002:	6a 20                	push   $0x20
  802004:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802006:	83 ef 01             	sub    $0x1,%edi
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	eb 08                	jmp    802016 <vprintfmt+0x32c>
  80200e:	89 df                	mov    %ebx,%edi
  802010:	8b 75 08             	mov    0x8(%ebp),%esi
  802013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802016:	85 ff                	test   %edi,%edi
  802018:	7f e4                	jg     801ffe <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80201a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80201d:	e9 ee fc ff ff       	jmp    801d10 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  802022:	83 fa 01             	cmp    $0x1,%edx
  802025:	7e 16                	jle    80203d <vprintfmt+0x353>
		return va_arg(*ap, long long);
  802027:	8b 45 14             	mov    0x14(%ebp),%eax
  80202a:	8d 50 08             	lea    0x8(%eax),%edx
  80202d:	89 55 14             	mov    %edx,0x14(%ebp)
  802030:	8b 50 04             	mov    0x4(%eax),%edx
  802033:	8b 00                	mov    (%eax),%eax
  802035:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802038:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80203b:	eb 32                	jmp    80206f <vprintfmt+0x385>
	else if (lflag)
  80203d:	85 d2                	test   %edx,%edx
  80203f:	74 18                	je     802059 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  802041:	8b 45 14             	mov    0x14(%ebp),%eax
  802044:	8d 50 04             	lea    0x4(%eax),%edx
  802047:	89 55 14             	mov    %edx,0x14(%ebp)
  80204a:	8b 00                	mov    (%eax),%eax
  80204c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80204f:	89 c1                	mov    %eax,%ecx
  802051:	c1 f9 1f             	sar    $0x1f,%ecx
  802054:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802057:	eb 16                	jmp    80206f <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  802059:	8b 45 14             	mov    0x14(%ebp),%eax
  80205c:	8d 50 04             	lea    0x4(%eax),%edx
  80205f:	89 55 14             	mov    %edx,0x14(%ebp)
  802062:	8b 00                	mov    (%eax),%eax
  802064:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802067:	89 c1                	mov    %eax,%ecx
  802069:	c1 f9 1f             	sar    $0x1f,%ecx
  80206c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80206f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802072:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  802075:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80207a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80207e:	79 6f                	jns    8020ef <vprintfmt+0x405>
				putch('-', putdat);
  802080:	83 ec 08             	sub    $0x8,%esp
  802083:	53                   	push   %ebx
  802084:	6a 2d                	push   $0x2d
  802086:	ff d6                	call   *%esi
				num = -(long long) num;
  802088:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80208b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80208e:	f7 d8                	neg    %eax
  802090:	83 d2 00             	adc    $0x0,%edx
  802093:	f7 da                	neg    %edx
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	eb 55                	jmp    8020ef <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80209a:	8d 45 14             	lea    0x14(%ebp),%eax
  80209d:	e8 d4 fb ff ff       	call   801c76 <getuint>
			base = 10;
  8020a2:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  8020a7:	eb 46                	jmp    8020ef <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8020a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8020ac:	e8 c5 fb ff ff       	call   801c76 <getuint>
			base = 8;
  8020b1:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  8020b6:	eb 37                	jmp    8020ef <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  8020b8:	83 ec 08             	sub    $0x8,%esp
  8020bb:	53                   	push   %ebx
  8020bc:	6a 30                	push   $0x30
  8020be:	ff d6                	call   *%esi
			putch('x', putdat);
  8020c0:	83 c4 08             	add    $0x8,%esp
  8020c3:	53                   	push   %ebx
  8020c4:	6a 78                	push   $0x78
  8020c6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8020c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020cb:	8d 50 04             	lea    0x4(%eax),%edx
  8020ce:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8020d1:	8b 00                	mov    (%eax),%eax
  8020d3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8020d8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8020db:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8020e0:	eb 0d                	jmp    8020ef <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8020e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8020e5:	e8 8c fb ff ff       	call   801c76 <getuint>
			base = 16;
  8020ea:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8020ef:	83 ec 0c             	sub    $0xc,%esp
  8020f2:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8020f6:	51                   	push   %ecx
  8020f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8020fa:	57                   	push   %edi
  8020fb:	52                   	push   %edx
  8020fc:	50                   	push   %eax
  8020fd:	89 da                	mov    %ebx,%edx
  8020ff:	89 f0                	mov    %esi,%eax
  802101:	e8 c1 fa ff ff       	call   801bc7 <printnum>
			break;
  802106:	83 c4 20             	add    $0x20,%esp
  802109:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80210c:	e9 ff fb ff ff       	jmp    801d10 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802111:	83 ec 08             	sub    $0x8,%esp
  802114:	53                   	push   %ebx
  802115:	51                   	push   %ecx
  802116:	ff d6                	call   *%esi
			break;
  802118:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80211b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80211e:	e9 ed fb ff ff       	jmp    801d10 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802123:	83 ec 08             	sub    $0x8,%esp
  802126:	53                   	push   %ebx
  802127:	6a 25                	push   $0x25
  802129:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80212b:	83 c4 10             	add    $0x10,%esp
  80212e:	eb 03                	jmp    802133 <vprintfmt+0x449>
  802130:	83 ef 01             	sub    $0x1,%edi
  802133:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  802137:	75 f7                	jne    802130 <vprintfmt+0x446>
  802139:	e9 d2 fb ff ff       	jmp    801d10 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80213e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802141:	5b                   	pop    %ebx
  802142:	5e                   	pop    %esi
  802143:	5f                   	pop    %edi
  802144:	5d                   	pop    %ebp
  802145:	c3                   	ret    

00802146 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802146:	55                   	push   %ebp
  802147:	89 e5                	mov    %esp,%ebp
  802149:	83 ec 18             	sub    $0x18,%esp
  80214c:	8b 45 08             	mov    0x8(%ebp),%eax
  80214f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802152:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802155:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  802159:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80215c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802163:	85 c0                	test   %eax,%eax
  802165:	74 26                	je     80218d <vsnprintf+0x47>
  802167:	85 d2                	test   %edx,%edx
  802169:	7e 22                	jle    80218d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80216b:	ff 75 14             	pushl  0x14(%ebp)
  80216e:	ff 75 10             	pushl  0x10(%ebp)
  802171:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802174:	50                   	push   %eax
  802175:	68 b0 1c 80 00       	push   $0x801cb0
  80217a:	e8 6b fb ff ff       	call   801cea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80217f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802182:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	eb 05                	jmp    802192 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80218d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802192:	c9                   	leave  
  802193:	c3                   	ret    

00802194 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802194:	55                   	push   %ebp
  802195:	89 e5                	mov    %esp,%ebp
  802197:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80219a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80219d:	50                   	push   %eax
  80219e:	ff 75 10             	pushl  0x10(%ebp)
  8021a1:	ff 75 0c             	pushl  0xc(%ebp)
  8021a4:	ff 75 08             	pushl  0x8(%ebp)
  8021a7:	e8 9a ff ff ff       	call   802146 <vsnprintf>
	va_end(ap);

	return rc;
}
  8021ac:	c9                   	leave  
  8021ad:	c3                   	ret    

008021ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8021b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b9:	eb 03                	jmp    8021be <strlen+0x10>
		n++;
  8021bb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8021be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8021c2:	75 f7                	jne    8021bb <strlen+0xd>
		n++;
	return n;
}
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    

008021c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8021cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d4:	eb 03                	jmp    8021d9 <strnlen+0x13>
		n++;
  8021d6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8021d9:	39 c2                	cmp    %eax,%edx
  8021db:	74 08                	je     8021e5 <strnlen+0x1f>
  8021dd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8021e1:	75 f3                	jne    8021d6 <strnlen+0x10>
  8021e3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    

008021e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	53                   	push   %ebx
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8021f1:	89 c2                	mov    %eax,%edx
  8021f3:	83 c2 01             	add    $0x1,%edx
  8021f6:	83 c1 01             	add    $0x1,%ecx
  8021f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8021fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  802200:	84 db                	test   %bl,%bl
  802202:	75 ef                	jne    8021f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802204:	5b                   	pop    %ebx
  802205:	5d                   	pop    %ebp
  802206:	c3                   	ret    

00802207 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802207:	55                   	push   %ebp
  802208:	89 e5                	mov    %esp,%ebp
  80220a:	53                   	push   %ebx
  80220b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80220e:	53                   	push   %ebx
  80220f:	e8 9a ff ff ff       	call   8021ae <strlen>
  802214:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802217:	ff 75 0c             	pushl  0xc(%ebp)
  80221a:	01 d8                	add    %ebx,%eax
  80221c:	50                   	push   %eax
  80221d:	e8 c5 ff ff ff       	call   8021e7 <strcpy>
	return dst;
}
  802222:	89 d8                	mov    %ebx,%eax
  802224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802227:	c9                   	leave  
  802228:	c3                   	ret    

00802229 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	56                   	push   %esi
  80222d:	53                   	push   %ebx
  80222e:	8b 75 08             	mov    0x8(%ebp),%esi
  802231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802234:	89 f3                	mov    %esi,%ebx
  802236:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802239:	89 f2                	mov    %esi,%edx
  80223b:	eb 0f                	jmp    80224c <strncpy+0x23>
		*dst++ = *src;
  80223d:	83 c2 01             	add    $0x1,%edx
  802240:	0f b6 01             	movzbl (%ecx),%eax
  802243:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802246:	80 39 01             	cmpb   $0x1,(%ecx)
  802249:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80224c:	39 da                	cmp    %ebx,%edx
  80224e:	75 ed                	jne    80223d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802250:	89 f0                	mov    %esi,%eax
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5d                   	pop    %ebp
  802255:	c3                   	ret    

00802256 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	56                   	push   %esi
  80225a:	53                   	push   %ebx
  80225b:	8b 75 08             	mov    0x8(%ebp),%esi
  80225e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802261:	8b 55 10             	mov    0x10(%ebp),%edx
  802264:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802266:	85 d2                	test   %edx,%edx
  802268:	74 21                	je     80228b <strlcpy+0x35>
  80226a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80226e:	89 f2                	mov    %esi,%edx
  802270:	eb 09                	jmp    80227b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802272:	83 c2 01             	add    $0x1,%edx
  802275:	83 c1 01             	add    $0x1,%ecx
  802278:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80227b:	39 c2                	cmp    %eax,%edx
  80227d:	74 09                	je     802288 <strlcpy+0x32>
  80227f:	0f b6 19             	movzbl (%ecx),%ebx
  802282:	84 db                	test   %bl,%bl
  802284:	75 ec                	jne    802272 <strlcpy+0x1c>
  802286:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802288:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80228b:	29 f0                	sub    %esi,%eax
}
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5d                   	pop    %ebp
  802290:	c3                   	ret    

00802291 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802297:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80229a:	eb 06                	jmp    8022a2 <strcmp+0x11>
		p++, q++;
  80229c:	83 c1 01             	add    $0x1,%ecx
  80229f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8022a2:	0f b6 01             	movzbl (%ecx),%eax
  8022a5:	84 c0                	test   %al,%al
  8022a7:	74 04                	je     8022ad <strcmp+0x1c>
  8022a9:	3a 02                	cmp    (%edx),%al
  8022ab:	74 ef                	je     80229c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8022ad:	0f b6 c0             	movzbl %al,%eax
  8022b0:	0f b6 12             	movzbl (%edx),%edx
  8022b3:	29 d0                	sub    %edx,%eax
}
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    

008022b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	53                   	push   %ebx
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c1:	89 c3                	mov    %eax,%ebx
  8022c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8022c6:	eb 06                	jmp    8022ce <strncmp+0x17>
		n--, p++, q++;
  8022c8:	83 c0 01             	add    $0x1,%eax
  8022cb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8022ce:	39 d8                	cmp    %ebx,%eax
  8022d0:	74 15                	je     8022e7 <strncmp+0x30>
  8022d2:	0f b6 08             	movzbl (%eax),%ecx
  8022d5:	84 c9                	test   %cl,%cl
  8022d7:	74 04                	je     8022dd <strncmp+0x26>
  8022d9:	3a 0a                	cmp    (%edx),%cl
  8022db:	74 eb                	je     8022c8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8022dd:	0f b6 00             	movzbl (%eax),%eax
  8022e0:	0f b6 12             	movzbl (%edx),%edx
  8022e3:	29 d0                	sub    %edx,%eax
  8022e5:	eb 05                	jmp    8022ec <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8022e7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8022ec:	5b                   	pop    %ebx
  8022ed:	5d                   	pop    %ebp
  8022ee:	c3                   	ret    

008022ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8022ef:	55                   	push   %ebp
  8022f0:	89 e5                	mov    %esp,%ebp
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022f9:	eb 07                	jmp    802302 <strchr+0x13>
		if (*s == c)
  8022fb:	38 ca                	cmp    %cl,%dl
  8022fd:	74 0f                	je     80230e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8022ff:	83 c0 01             	add    $0x1,%eax
  802302:	0f b6 10             	movzbl (%eax),%edx
  802305:	84 d2                	test   %dl,%dl
  802307:	75 f2                	jne    8022fb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802309:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    

00802310 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	8b 45 08             	mov    0x8(%ebp),%eax
  802316:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80231a:	eb 03                	jmp    80231f <strfind+0xf>
  80231c:	83 c0 01             	add    $0x1,%eax
  80231f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802322:	38 ca                	cmp    %cl,%dl
  802324:	74 04                	je     80232a <strfind+0x1a>
  802326:	84 d2                	test   %dl,%dl
  802328:	75 f2                	jne    80231c <strfind+0xc>
			break;
	return (char *) s;
}
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    

0080232c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	57                   	push   %edi
  802330:	56                   	push   %esi
  802331:	53                   	push   %ebx
  802332:	8b 7d 08             	mov    0x8(%ebp),%edi
  802335:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802338:	85 c9                	test   %ecx,%ecx
  80233a:	74 36                	je     802372 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80233c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802342:	75 28                	jne    80236c <memset+0x40>
  802344:	f6 c1 03             	test   $0x3,%cl
  802347:	75 23                	jne    80236c <memset+0x40>
		c &= 0xFF;
  802349:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80234d:	89 d3                	mov    %edx,%ebx
  80234f:	c1 e3 08             	shl    $0x8,%ebx
  802352:	89 d6                	mov    %edx,%esi
  802354:	c1 e6 18             	shl    $0x18,%esi
  802357:	89 d0                	mov    %edx,%eax
  802359:	c1 e0 10             	shl    $0x10,%eax
  80235c:	09 f0                	or     %esi,%eax
  80235e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802360:	89 d8                	mov    %ebx,%eax
  802362:	09 d0                	or     %edx,%eax
  802364:	c1 e9 02             	shr    $0x2,%ecx
  802367:	fc                   	cld    
  802368:	f3 ab                	rep stos %eax,%es:(%edi)
  80236a:	eb 06                	jmp    802372 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80236c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236f:	fc                   	cld    
  802370:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802372:	89 f8                	mov    %edi,%eax
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    

00802379 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	57                   	push   %edi
  80237d:	56                   	push   %esi
  80237e:	8b 45 08             	mov    0x8(%ebp),%eax
  802381:	8b 75 0c             	mov    0xc(%ebp),%esi
  802384:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802387:	39 c6                	cmp    %eax,%esi
  802389:	73 35                	jae    8023c0 <memmove+0x47>
  80238b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80238e:	39 d0                	cmp    %edx,%eax
  802390:	73 2e                	jae    8023c0 <memmove+0x47>
		s += n;
		d += n;
  802392:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802395:	89 d6                	mov    %edx,%esi
  802397:	09 fe                	or     %edi,%esi
  802399:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80239f:	75 13                	jne    8023b4 <memmove+0x3b>
  8023a1:	f6 c1 03             	test   $0x3,%cl
  8023a4:	75 0e                	jne    8023b4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8023a6:	83 ef 04             	sub    $0x4,%edi
  8023a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8023ac:	c1 e9 02             	shr    $0x2,%ecx
  8023af:	fd                   	std    
  8023b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8023b2:	eb 09                	jmp    8023bd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8023b4:	83 ef 01             	sub    $0x1,%edi
  8023b7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8023ba:	fd                   	std    
  8023bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8023bd:	fc                   	cld    
  8023be:	eb 1d                	jmp    8023dd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	09 c2                	or     %eax,%edx
  8023c4:	f6 c2 03             	test   $0x3,%dl
  8023c7:	75 0f                	jne    8023d8 <memmove+0x5f>
  8023c9:	f6 c1 03             	test   $0x3,%cl
  8023cc:	75 0a                	jne    8023d8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8023ce:	c1 e9 02             	shr    $0x2,%ecx
  8023d1:	89 c7                	mov    %eax,%edi
  8023d3:	fc                   	cld    
  8023d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8023d6:	eb 05                	jmp    8023dd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8023d8:	89 c7                	mov    %eax,%edi
  8023da:	fc                   	cld    
  8023db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8023dd:	5e                   	pop    %esi
  8023de:	5f                   	pop    %edi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8023e4:	ff 75 10             	pushl  0x10(%ebp)
  8023e7:	ff 75 0c             	pushl  0xc(%ebp)
  8023ea:	ff 75 08             	pushl  0x8(%ebp)
  8023ed:	e8 87 ff ff ff       	call   802379 <memmove>
}
  8023f2:	c9                   	leave  
  8023f3:	c3                   	ret    

008023f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8023f4:	55                   	push   %ebp
  8023f5:	89 e5                	mov    %esp,%ebp
  8023f7:	56                   	push   %esi
  8023f8:	53                   	push   %ebx
  8023f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802404:	eb 1a                	jmp    802420 <memcmp+0x2c>
		if (*s1 != *s2)
  802406:	0f b6 08             	movzbl (%eax),%ecx
  802409:	0f b6 1a             	movzbl (%edx),%ebx
  80240c:	38 d9                	cmp    %bl,%cl
  80240e:	74 0a                	je     80241a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802410:	0f b6 c1             	movzbl %cl,%eax
  802413:	0f b6 db             	movzbl %bl,%ebx
  802416:	29 d8                	sub    %ebx,%eax
  802418:	eb 0f                	jmp    802429 <memcmp+0x35>
		s1++, s2++;
  80241a:	83 c0 01             	add    $0x1,%eax
  80241d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802420:	39 f0                	cmp    %esi,%eax
  802422:	75 e2                	jne    802406 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802424:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802429:	5b                   	pop    %ebx
  80242a:	5e                   	pop    %esi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    

0080242d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80242d:	55                   	push   %ebp
  80242e:	89 e5                	mov    %esp,%ebp
  802430:	53                   	push   %ebx
  802431:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802434:	89 c1                	mov    %eax,%ecx
  802436:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802439:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80243d:	eb 0a                	jmp    802449 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80243f:	0f b6 10             	movzbl (%eax),%edx
  802442:	39 da                	cmp    %ebx,%edx
  802444:	74 07                	je     80244d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802446:	83 c0 01             	add    $0x1,%eax
  802449:	39 c8                	cmp    %ecx,%eax
  80244b:	72 f2                	jb     80243f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80244d:	5b                   	pop    %ebx
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

00802450 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	57                   	push   %edi
  802454:	56                   	push   %esi
  802455:	53                   	push   %ebx
  802456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802459:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80245c:	eb 03                	jmp    802461 <strtol+0x11>
		s++;
  80245e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802461:	0f b6 01             	movzbl (%ecx),%eax
  802464:	3c 20                	cmp    $0x20,%al
  802466:	74 f6                	je     80245e <strtol+0xe>
  802468:	3c 09                	cmp    $0x9,%al
  80246a:	74 f2                	je     80245e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80246c:	3c 2b                	cmp    $0x2b,%al
  80246e:	75 0a                	jne    80247a <strtol+0x2a>
		s++;
  802470:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802473:	bf 00 00 00 00       	mov    $0x0,%edi
  802478:	eb 11                	jmp    80248b <strtol+0x3b>
  80247a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80247f:	3c 2d                	cmp    $0x2d,%al
  802481:	75 08                	jne    80248b <strtol+0x3b>
		s++, neg = 1;
  802483:	83 c1 01             	add    $0x1,%ecx
  802486:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80248b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802491:	75 15                	jne    8024a8 <strtol+0x58>
  802493:	80 39 30             	cmpb   $0x30,(%ecx)
  802496:	75 10                	jne    8024a8 <strtol+0x58>
  802498:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80249c:	75 7c                	jne    80251a <strtol+0xca>
		s += 2, base = 16;
  80249e:	83 c1 02             	add    $0x2,%ecx
  8024a1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8024a6:	eb 16                	jmp    8024be <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8024a8:	85 db                	test   %ebx,%ebx
  8024aa:	75 12                	jne    8024be <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8024ac:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8024b4:	75 08                	jne    8024be <strtol+0x6e>
		s++, base = 8;
  8024b6:	83 c1 01             	add    $0x1,%ecx
  8024b9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8024be:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8024c6:	0f b6 11             	movzbl (%ecx),%edx
  8024c9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8024cc:	89 f3                	mov    %esi,%ebx
  8024ce:	80 fb 09             	cmp    $0x9,%bl
  8024d1:	77 08                	ja     8024db <strtol+0x8b>
			dig = *s - '0';
  8024d3:	0f be d2             	movsbl %dl,%edx
  8024d6:	83 ea 30             	sub    $0x30,%edx
  8024d9:	eb 22                	jmp    8024fd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8024db:	8d 72 9f             	lea    -0x61(%edx),%esi
  8024de:	89 f3                	mov    %esi,%ebx
  8024e0:	80 fb 19             	cmp    $0x19,%bl
  8024e3:	77 08                	ja     8024ed <strtol+0x9d>
			dig = *s - 'a' + 10;
  8024e5:	0f be d2             	movsbl %dl,%edx
  8024e8:	83 ea 57             	sub    $0x57,%edx
  8024eb:	eb 10                	jmp    8024fd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8024ed:	8d 72 bf             	lea    -0x41(%edx),%esi
  8024f0:	89 f3                	mov    %esi,%ebx
  8024f2:	80 fb 19             	cmp    $0x19,%bl
  8024f5:	77 16                	ja     80250d <strtol+0xbd>
			dig = *s - 'A' + 10;
  8024f7:	0f be d2             	movsbl %dl,%edx
  8024fa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8024fd:	3b 55 10             	cmp    0x10(%ebp),%edx
  802500:	7d 0b                	jge    80250d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802502:	83 c1 01             	add    $0x1,%ecx
  802505:	0f af 45 10          	imul   0x10(%ebp),%eax
  802509:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80250b:	eb b9                	jmp    8024c6 <strtol+0x76>

	if (endptr)
  80250d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802511:	74 0d                	je     802520 <strtol+0xd0>
		*endptr = (char *) s;
  802513:	8b 75 0c             	mov    0xc(%ebp),%esi
  802516:	89 0e                	mov    %ecx,(%esi)
  802518:	eb 06                	jmp    802520 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80251a:	85 db                	test   %ebx,%ebx
  80251c:	74 98                	je     8024b6 <strtol+0x66>
  80251e:	eb 9e                	jmp    8024be <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802520:	89 c2                	mov    %eax,%edx
  802522:	f7 da                	neg    %edx
  802524:	85 ff                	test   %edi,%edi
  802526:	0f 45 c2             	cmovne %edx,%eax
}
  802529:	5b                   	pop    %ebx
  80252a:	5e                   	pop    %esi
  80252b:	5f                   	pop    %edi
  80252c:	5d                   	pop    %ebp
  80252d:	c3                   	ret    

0080252e <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 04             	sub    $0x4,%esp
  802537:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  80253a:	57                   	push   %edi
  80253b:	e8 6e fc ff ff       	call   8021ae <strlen>
  802540:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  802543:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  802546:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  80254b:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  802550:	eb 46                	jmp    802598 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  802552:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  802556:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802559:	80 f9 09             	cmp    $0x9,%cl
  80255c:	77 08                	ja     802566 <charhex_to_dec+0x38>
			num = s[i] - '0';
  80255e:	0f be d2             	movsbl %dl,%edx
  802561:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802564:	eb 27                	jmp    80258d <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  802566:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  802569:	80 f9 05             	cmp    $0x5,%cl
  80256c:	77 08                	ja     802576 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  80256e:	0f be d2             	movsbl %dl,%edx
  802571:	8d 4a a9             	lea    -0x57(%edx),%ecx
  802574:	eb 17                	jmp    80258d <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  802576:	8d 4a bf             	lea    -0x41(%edx),%ecx
  802579:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  80257c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  802581:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  802585:	77 06                	ja     80258d <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  802587:	0f be d2             	movsbl %dl,%edx
  80258a:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  80258d:	0f af ce             	imul   %esi,%ecx
  802590:	01 c8                	add    %ecx,%eax
		base *= 16;
  802592:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  802595:	83 eb 01             	sub    $0x1,%ebx
  802598:	83 fb 01             	cmp    $0x1,%ebx
  80259b:	7f b5                	jg     802552 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  80259d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a0:	5b                   	pop    %ebx
  8025a1:	5e                   	pop    %esi
  8025a2:	5f                   	pop    %edi
  8025a3:	5d                   	pop    %ebp
  8025a4:	c3                   	ret    

008025a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8025a5:	55                   	push   %ebp
  8025a6:	89 e5                	mov    %esp,%ebp
  8025a8:	57                   	push   %edi
  8025a9:	56                   	push   %esi
  8025aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b6:	89 c3                	mov    %eax,%ebx
  8025b8:	89 c7                	mov    %eax,%edi
  8025ba:	89 c6                	mov    %eax,%esi
  8025bc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8025be:	5b                   	pop    %ebx
  8025bf:	5e                   	pop    %esi
  8025c0:	5f                   	pop    %edi
  8025c1:	5d                   	pop    %ebp
  8025c2:	c3                   	ret    

008025c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8025c3:	55                   	push   %ebp
  8025c4:	89 e5                	mov    %esp,%ebp
  8025c6:	57                   	push   %edi
  8025c7:	56                   	push   %esi
  8025c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8025ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d3:	89 d1                	mov    %edx,%ecx
  8025d5:	89 d3                	mov    %edx,%ebx
  8025d7:	89 d7                	mov    %edx,%edi
  8025d9:	89 d6                	mov    %edx,%esi
  8025db:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8025f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8025f8:	89 cb                	mov    %ecx,%ebx
  8025fa:	89 cf                	mov    %ecx,%edi
  8025fc:	89 ce                	mov    %ecx,%esi
  8025fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802600:	85 c0                	test   %eax,%eax
  802602:	7e 17                	jle    80261b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802604:	83 ec 0c             	sub    $0xc,%esp
  802607:	50                   	push   %eax
  802608:	6a 03                	push   $0x3
  80260a:	68 bf 42 80 00       	push   $0x8042bf
  80260f:	6a 23                	push   $0x23
  802611:	68 dc 42 80 00       	push   $0x8042dc
  802616:	e8 bf f4 ff ff       	call   801ada <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80261b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80261e:	5b                   	pop    %ebx
  80261f:	5e                   	pop    %esi
  802620:	5f                   	pop    %edi
  802621:	5d                   	pop    %ebp
  802622:	c3                   	ret    

00802623 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802623:	55                   	push   %ebp
  802624:	89 e5                	mov    %esp,%ebp
  802626:	57                   	push   %edi
  802627:	56                   	push   %esi
  802628:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802629:	ba 00 00 00 00       	mov    $0x0,%edx
  80262e:	b8 02 00 00 00       	mov    $0x2,%eax
  802633:	89 d1                	mov    %edx,%ecx
  802635:	89 d3                	mov    %edx,%ebx
  802637:	89 d7                	mov    %edx,%edi
  802639:	89 d6                	mov    %edx,%esi
  80263b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5f                   	pop    %edi
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    

00802642 <sys_yield>:

void
sys_yield(void)
{
  802642:	55                   	push   %ebp
  802643:	89 e5                	mov    %esp,%ebp
  802645:	57                   	push   %edi
  802646:	56                   	push   %esi
  802647:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802648:	ba 00 00 00 00       	mov    $0x0,%edx
  80264d:	b8 0b 00 00 00       	mov    $0xb,%eax
  802652:	89 d1                	mov    %edx,%ecx
  802654:	89 d3                	mov    %edx,%ebx
  802656:	89 d7                	mov    %edx,%edi
  802658:	89 d6                	mov    %edx,%esi
  80265a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80265c:	5b                   	pop    %ebx
  80265d:	5e                   	pop    %esi
  80265e:	5f                   	pop    %edi
  80265f:	5d                   	pop    %ebp
  802660:	c3                   	ret    

00802661 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802661:	55                   	push   %ebp
  802662:	89 e5                	mov    %esp,%ebp
  802664:	57                   	push   %edi
  802665:	56                   	push   %esi
  802666:	53                   	push   %ebx
  802667:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80266a:	be 00 00 00 00       	mov    $0x0,%esi
  80266f:	b8 04 00 00 00       	mov    $0x4,%eax
  802674:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802677:	8b 55 08             	mov    0x8(%ebp),%edx
  80267a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80267d:	89 f7                	mov    %esi,%edi
  80267f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802681:	85 c0                	test   %eax,%eax
  802683:	7e 17                	jle    80269c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802685:	83 ec 0c             	sub    $0xc,%esp
  802688:	50                   	push   %eax
  802689:	6a 04                	push   $0x4
  80268b:	68 bf 42 80 00       	push   $0x8042bf
  802690:	6a 23                	push   $0x23
  802692:	68 dc 42 80 00       	push   $0x8042dc
  802697:	e8 3e f4 ff ff       	call   801ada <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80269c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80269f:	5b                   	pop    %ebx
  8026a0:	5e                   	pop    %esi
  8026a1:	5f                   	pop    %edi
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    

008026a4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8026a4:	55                   	push   %ebp
  8026a5:	89 e5                	mov    %esp,%ebp
  8026a7:	57                   	push   %edi
  8026a8:	56                   	push   %esi
  8026a9:	53                   	push   %ebx
  8026aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8026b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8026b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026be:	8b 75 18             	mov    0x18(%ebp),%esi
  8026c1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026c3:	85 c0                	test   %eax,%eax
  8026c5:	7e 17                	jle    8026de <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026c7:	83 ec 0c             	sub    $0xc,%esp
  8026ca:	50                   	push   %eax
  8026cb:	6a 05                	push   $0x5
  8026cd:	68 bf 42 80 00       	push   $0x8042bf
  8026d2:	6a 23                	push   $0x23
  8026d4:	68 dc 42 80 00       	push   $0x8042dc
  8026d9:	e8 fc f3 ff ff       	call   801ada <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8026de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026e1:	5b                   	pop    %ebx
  8026e2:	5e                   	pop    %esi
  8026e3:	5f                   	pop    %edi
  8026e4:	5d                   	pop    %ebp
  8026e5:	c3                   	ret    

008026e6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8026e6:	55                   	push   %ebp
  8026e7:	89 e5                	mov    %esp,%ebp
  8026e9:	57                   	push   %edi
  8026ea:	56                   	push   %esi
  8026eb:	53                   	push   %ebx
  8026ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8026f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ff:	89 df                	mov    %ebx,%edi
  802701:	89 de                	mov    %ebx,%esi
  802703:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802705:	85 c0                	test   %eax,%eax
  802707:	7e 17                	jle    802720 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802709:	83 ec 0c             	sub    $0xc,%esp
  80270c:	50                   	push   %eax
  80270d:	6a 06                	push   $0x6
  80270f:	68 bf 42 80 00       	push   $0x8042bf
  802714:	6a 23                	push   $0x23
  802716:	68 dc 42 80 00       	push   $0x8042dc
  80271b:	e8 ba f3 ff ff       	call   801ada <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802723:	5b                   	pop    %ebx
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    

00802728 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802728:	55                   	push   %ebp
  802729:	89 e5                	mov    %esp,%ebp
  80272b:	57                   	push   %edi
  80272c:	56                   	push   %esi
  80272d:	53                   	push   %ebx
  80272e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802731:	bb 00 00 00 00       	mov    $0x0,%ebx
  802736:	b8 08 00 00 00       	mov    $0x8,%eax
  80273b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80273e:	8b 55 08             	mov    0x8(%ebp),%edx
  802741:	89 df                	mov    %ebx,%edi
  802743:	89 de                	mov    %ebx,%esi
  802745:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802747:	85 c0                	test   %eax,%eax
  802749:	7e 17                	jle    802762 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80274b:	83 ec 0c             	sub    $0xc,%esp
  80274e:	50                   	push   %eax
  80274f:	6a 08                	push   $0x8
  802751:	68 bf 42 80 00       	push   $0x8042bf
  802756:	6a 23                	push   $0x23
  802758:	68 dc 42 80 00       	push   $0x8042dc
  80275d:	e8 78 f3 ff ff       	call   801ada <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802765:	5b                   	pop    %ebx
  802766:	5e                   	pop    %esi
  802767:	5f                   	pop    %edi
  802768:	5d                   	pop    %ebp
  802769:	c3                   	ret    

0080276a <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80276a:	55                   	push   %ebp
  80276b:	89 e5                	mov    %esp,%ebp
  80276d:	57                   	push   %edi
  80276e:	56                   	push   %esi
  80276f:	53                   	push   %ebx
  802770:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802773:	bb 00 00 00 00       	mov    $0x0,%ebx
  802778:	b8 0a 00 00 00       	mov    $0xa,%eax
  80277d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802780:	8b 55 08             	mov    0x8(%ebp),%edx
  802783:	89 df                	mov    %ebx,%edi
  802785:	89 de                	mov    %ebx,%esi
  802787:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802789:	85 c0                	test   %eax,%eax
  80278b:	7e 17                	jle    8027a4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80278d:	83 ec 0c             	sub    $0xc,%esp
  802790:	50                   	push   %eax
  802791:	6a 0a                	push   $0xa
  802793:	68 bf 42 80 00       	push   $0x8042bf
  802798:	6a 23                	push   $0x23
  80279a:	68 dc 42 80 00       	push   $0x8042dc
  80279f:	e8 36 f3 ff ff       	call   801ada <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8027a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027a7:	5b                   	pop    %ebx
  8027a8:	5e                   	pop    %esi
  8027a9:	5f                   	pop    %edi
  8027aa:	5d                   	pop    %ebp
  8027ab:	c3                   	ret    

008027ac <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	57                   	push   %edi
  8027b0:	56                   	push   %esi
  8027b1:	53                   	push   %ebx
  8027b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ba:	b8 09 00 00 00       	mov    $0x9,%eax
  8027bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8027c5:	89 df                	mov    %ebx,%edi
  8027c7:	89 de                	mov    %ebx,%esi
  8027c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027cb:	85 c0                	test   %eax,%eax
  8027cd:	7e 17                	jle    8027e6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027cf:	83 ec 0c             	sub    $0xc,%esp
  8027d2:	50                   	push   %eax
  8027d3:	6a 09                	push   $0x9
  8027d5:	68 bf 42 80 00       	push   $0x8042bf
  8027da:	6a 23                	push   $0x23
  8027dc:	68 dc 42 80 00       	push   $0x8042dc
  8027e1:	e8 f4 f2 ff ff       	call   801ada <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8027e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027e9:	5b                   	pop    %ebx
  8027ea:	5e                   	pop    %esi
  8027eb:	5f                   	pop    %edi
  8027ec:	5d                   	pop    %ebp
  8027ed:	c3                   	ret    

008027ee <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8027ee:	55                   	push   %ebp
  8027ef:	89 e5                	mov    %esp,%ebp
  8027f1:	57                   	push   %edi
  8027f2:	56                   	push   %esi
  8027f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027f4:	be 00 00 00 00       	mov    $0x0,%esi
  8027f9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8027fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802801:	8b 55 08             	mov    0x8(%ebp),%edx
  802804:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802807:	8b 7d 14             	mov    0x14(%ebp),%edi
  80280a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80280c:	5b                   	pop    %ebx
  80280d:	5e                   	pop    %esi
  80280e:	5f                   	pop    %edi
  80280f:	5d                   	pop    %ebp
  802810:	c3                   	ret    

00802811 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802811:	55                   	push   %ebp
  802812:	89 e5                	mov    %esp,%ebp
  802814:	57                   	push   %edi
  802815:	56                   	push   %esi
  802816:	53                   	push   %ebx
  802817:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80281a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80281f:	b8 0d 00 00 00       	mov    $0xd,%eax
  802824:	8b 55 08             	mov    0x8(%ebp),%edx
  802827:	89 cb                	mov    %ecx,%ebx
  802829:	89 cf                	mov    %ecx,%edi
  80282b:	89 ce                	mov    %ecx,%esi
  80282d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80282f:	85 c0                	test   %eax,%eax
  802831:	7e 17                	jle    80284a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802833:	83 ec 0c             	sub    $0xc,%esp
  802836:	50                   	push   %eax
  802837:	6a 0d                	push   $0xd
  802839:	68 bf 42 80 00       	push   $0x8042bf
  80283e:	6a 23                	push   $0x23
  802840:	68 dc 42 80 00       	push   $0x8042dc
  802845:	e8 90 f2 ff ff       	call   801ada <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80284a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80284d:	5b                   	pop    %ebx
  80284e:	5e                   	pop    %esi
  80284f:	5f                   	pop    %edi
  802850:	5d                   	pop    %ebp
  802851:	c3                   	ret    

00802852 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802852:	55                   	push   %ebp
  802853:	89 e5                	mov    %esp,%ebp
  802855:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802858:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  80285f:	75 52                	jne    8028b3 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  802861:	83 ec 04             	sub    $0x4,%esp
  802864:	6a 07                	push   $0x7
  802866:	68 00 f0 bf ee       	push   $0xeebff000
  80286b:	6a 00                	push   $0x0
  80286d:	e8 ef fd ff ff       	call   802661 <sys_page_alloc>
  802872:	83 c4 10             	add    $0x10,%esp
  802875:	85 c0                	test   %eax,%eax
  802877:	79 12                	jns    80288b <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  802879:	50                   	push   %eax
  80287a:	68 64 3d 80 00       	push   $0x803d64
  80287f:	6a 23                	push   $0x23
  802881:	68 ea 42 80 00       	push   $0x8042ea
  802886:	e8 4f f2 ff ff       	call   801ada <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  80288b:	83 ec 08             	sub    $0x8,%esp
  80288e:	68 bd 28 80 00       	push   $0x8028bd
  802893:	6a 00                	push   $0x0
  802895:	e8 12 ff ff ff       	call   8027ac <sys_env_set_pgfault_upcall>
  80289a:	83 c4 10             	add    $0x10,%esp
  80289d:	85 c0                	test   %eax,%eax
  80289f:	79 12                	jns    8028b3 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  8028a1:	50                   	push   %eax
  8028a2:	68 f8 42 80 00       	push   $0x8042f8
  8028a7:	6a 26                	push   $0x26
  8028a9:	68 ea 42 80 00       	push   $0x8042ea
  8028ae:	e8 27 f2 ff ff       	call   801ada <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b6:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  8028bb:	c9                   	leave  
  8028bc:	c3                   	ret    

008028bd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028bd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028be:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  8028c3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028c5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  8028c8:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  8028cc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  8028d1:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  8028d5:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8028d7:	83 c4 08             	add    $0x8,%esp
	popal 
  8028da:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8028db:	83 c4 04             	add    $0x4,%esp
	popfl
  8028de:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8028df:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8028e0:	c3                   	ret    

008028e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028e1:	55                   	push   %ebp
  8028e2:	89 e5                	mov    %esp,%ebp
  8028e4:	56                   	push   %esi
  8028e5:	53                   	push   %ebx
  8028e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8028e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  8028ef:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8028f1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028f6:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  8028f9:	83 ec 0c             	sub    $0xc,%esp
  8028fc:	50                   	push   %eax
  8028fd:	e8 0f ff ff ff       	call   802811 <sys_ipc_recv>
  802902:	83 c4 10             	add    $0x10,%esp
  802905:	85 c0                	test   %eax,%eax
  802907:	79 16                	jns    80291f <ipc_recv+0x3e>
		if(from_env_store != NULL)
  802909:	85 f6                	test   %esi,%esi
  80290b:	74 06                	je     802913 <ipc_recv+0x32>
			*from_env_store = 0;
  80290d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802913:	85 db                	test   %ebx,%ebx
  802915:	74 2c                	je     802943 <ipc_recv+0x62>
			*perm_store = 0;
  802917:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80291d:	eb 24                	jmp    802943 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  80291f:	85 f6                	test   %esi,%esi
  802921:	74 0a                	je     80292d <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  802923:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802928:	8b 40 74             	mov    0x74(%eax),%eax
  80292b:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80292d:	85 db                	test   %ebx,%ebx
  80292f:	74 0a                	je     80293b <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  802931:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802936:	8b 40 78             	mov    0x78(%eax),%eax
  802939:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  80293b:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802940:	8b 40 70             	mov    0x70(%eax),%eax
}
  802943:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802946:	5b                   	pop    %ebx
  802947:	5e                   	pop    %esi
  802948:	5d                   	pop    %ebp
  802949:	c3                   	ret    

0080294a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80294a:	55                   	push   %ebp
  80294b:	89 e5                	mov    %esp,%ebp
  80294d:	57                   	push   %edi
  80294e:	56                   	push   %esi
  80294f:	53                   	push   %ebx
  802950:	83 ec 0c             	sub    $0xc,%esp
  802953:	8b 7d 08             	mov    0x8(%ebp),%edi
  802956:	8b 75 0c             	mov    0xc(%ebp),%esi
  802959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80295c:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80295e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802963:	0f 44 d8             	cmove  %eax,%ebx
  802966:	eb 1e                	jmp    802986 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  802968:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80296b:	74 14                	je     802981 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  80296d:	83 ec 04             	sub    $0x4,%esp
  802970:	68 18 43 80 00       	push   $0x804318
  802975:	6a 44                	push   $0x44
  802977:	68 43 43 80 00       	push   $0x804343
  80297c:	e8 59 f1 ff ff       	call   801ada <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  802981:	e8 bc fc ff ff       	call   802642 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802986:	ff 75 14             	pushl  0x14(%ebp)
  802989:	53                   	push   %ebx
  80298a:	56                   	push   %esi
  80298b:	57                   	push   %edi
  80298c:	e8 5d fe ff ff       	call   8027ee <sys_ipc_try_send>
  802991:	83 c4 10             	add    $0x10,%esp
  802994:	85 c0                	test   %eax,%eax
  802996:	78 d0                	js     802968 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  802998:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80299b:	5b                   	pop    %ebx
  80299c:	5e                   	pop    %esi
  80299d:	5f                   	pop    %edi
  80299e:	5d                   	pop    %ebp
  80299f:	c3                   	ret    

008029a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029ab:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029ae:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029b4:	8b 52 50             	mov    0x50(%edx),%edx
  8029b7:	39 ca                	cmp    %ecx,%edx
  8029b9:	75 0d                	jne    8029c8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8029bb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029c3:	8b 40 48             	mov    0x48(%eax),%eax
  8029c6:	eb 0f                	jmp    8029d7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029c8:	83 c0 01             	add    $0x1,%eax
  8029cb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029d0:	75 d9                	jne    8029ab <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029d7:	5d                   	pop    %ebp
  8029d8:	c3                   	ret    

008029d9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8029d9:	55                   	push   %ebp
  8029da:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8029dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8029df:	05 00 00 00 30       	add    $0x30000000,%eax
  8029e4:	c1 e8 0c             	shr    $0xc,%eax
}
  8029e7:	5d                   	pop    %ebp
  8029e8:	c3                   	ret    

008029e9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8029e9:	55                   	push   %ebp
  8029ea:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8029ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8029f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8029f9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8029fe:	5d                   	pop    %ebp
  8029ff:	c3                   	ret    

00802a00 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a00:	55                   	push   %ebp
  802a01:	89 e5                	mov    %esp,%ebp
  802a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a06:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a0b:	89 c2                	mov    %eax,%edx
  802a0d:	c1 ea 16             	shr    $0x16,%edx
  802a10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a17:	f6 c2 01             	test   $0x1,%dl
  802a1a:	74 11                	je     802a2d <fd_alloc+0x2d>
  802a1c:	89 c2                	mov    %eax,%edx
  802a1e:	c1 ea 0c             	shr    $0xc,%edx
  802a21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a28:	f6 c2 01             	test   $0x1,%dl
  802a2b:	75 09                	jne    802a36 <fd_alloc+0x36>
			*fd_store = fd;
  802a2d:	89 01                	mov    %eax,(%ecx)
			return 0;
  802a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a34:	eb 17                	jmp    802a4d <fd_alloc+0x4d>
  802a36:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802a3b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802a40:	75 c9                	jne    802a0b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802a42:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802a48:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802a4d:	5d                   	pop    %ebp
  802a4e:	c3                   	ret    

00802a4f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802a4f:	55                   	push   %ebp
  802a50:	89 e5                	mov    %esp,%ebp
  802a52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802a55:	83 f8 1f             	cmp    $0x1f,%eax
  802a58:	77 36                	ja     802a90 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802a5a:	c1 e0 0c             	shl    $0xc,%eax
  802a5d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802a62:	89 c2                	mov    %eax,%edx
  802a64:	c1 ea 16             	shr    $0x16,%edx
  802a67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a6e:	f6 c2 01             	test   $0x1,%dl
  802a71:	74 24                	je     802a97 <fd_lookup+0x48>
  802a73:	89 c2                	mov    %eax,%edx
  802a75:	c1 ea 0c             	shr    $0xc,%edx
  802a78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a7f:	f6 c2 01             	test   $0x1,%dl
  802a82:	74 1a                	je     802a9e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a87:	89 02                	mov    %eax,(%edx)
	return 0;
  802a89:	b8 00 00 00 00       	mov    $0x0,%eax
  802a8e:	eb 13                	jmp    802aa3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802a90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a95:	eb 0c                	jmp    802aa3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802a97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a9c:	eb 05                	jmp    802aa3 <fd_lookup+0x54>
  802a9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802aa3:	5d                   	pop    %ebp
  802aa4:	c3                   	ret    

00802aa5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802aa5:	55                   	push   %ebp
  802aa6:	89 e5                	mov    %esp,%ebp
  802aa8:	83 ec 08             	sub    $0x8,%esp
  802aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802aae:	ba cc 43 80 00       	mov    $0x8043cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802ab3:	eb 13                	jmp    802ac8 <dev_lookup+0x23>
  802ab5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802ab8:	39 08                	cmp    %ecx,(%eax)
  802aba:	75 0c                	jne    802ac8 <dev_lookup+0x23>
			*dev = devtab[i];
  802abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802abf:	89 01                	mov    %eax,(%ecx)
			return 0;
  802ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  802ac6:	eb 2e                	jmp    802af6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802ac8:	8b 02                	mov    (%edx),%eax
  802aca:	85 c0                	test   %eax,%eax
  802acc:	75 e7                	jne    802ab5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802ace:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802ad3:	8b 40 48             	mov    0x48(%eax),%eax
  802ad6:	83 ec 04             	sub    $0x4,%esp
  802ad9:	51                   	push   %ecx
  802ada:	50                   	push   %eax
  802adb:	68 50 43 80 00       	push   $0x804350
  802ae0:	e8 ce f0 ff ff       	call   801bb3 <cprintf>
	*dev = 0;
  802ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ae8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802aee:	83 c4 10             	add    $0x10,%esp
  802af1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802af6:	c9                   	leave  
  802af7:	c3                   	ret    

00802af8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802af8:	55                   	push   %ebp
  802af9:	89 e5                	mov    %esp,%ebp
  802afb:	56                   	push   %esi
  802afc:	53                   	push   %ebx
  802afd:	83 ec 10             	sub    $0x10,%esp
  802b00:	8b 75 08             	mov    0x8(%ebp),%esi
  802b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b09:	50                   	push   %eax
  802b0a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802b10:	c1 e8 0c             	shr    $0xc,%eax
  802b13:	50                   	push   %eax
  802b14:	e8 36 ff ff ff       	call   802a4f <fd_lookup>
  802b19:	83 c4 08             	add    $0x8,%esp
  802b1c:	85 c0                	test   %eax,%eax
  802b1e:	78 05                	js     802b25 <fd_close+0x2d>
	    || fd != fd2) 
  802b20:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802b23:	74 0c                	je     802b31 <fd_close+0x39>
		return (must_exist ? r : 0); 
  802b25:	84 db                	test   %bl,%bl
  802b27:	ba 00 00 00 00       	mov    $0x0,%edx
  802b2c:	0f 44 c2             	cmove  %edx,%eax
  802b2f:	eb 41                	jmp    802b72 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802b31:	83 ec 08             	sub    $0x8,%esp
  802b34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b37:	50                   	push   %eax
  802b38:	ff 36                	pushl  (%esi)
  802b3a:	e8 66 ff ff ff       	call   802aa5 <dev_lookup>
  802b3f:	89 c3                	mov    %eax,%ebx
  802b41:	83 c4 10             	add    $0x10,%esp
  802b44:	85 c0                	test   %eax,%eax
  802b46:	78 1a                	js     802b62 <fd_close+0x6a>
		if (dev->dev_close) 
  802b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b4b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  802b4e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  802b53:	85 c0                	test   %eax,%eax
  802b55:	74 0b                	je     802b62 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802b57:	83 ec 0c             	sub    $0xc,%esp
  802b5a:	56                   	push   %esi
  802b5b:	ff d0                	call   *%eax
  802b5d:	89 c3                	mov    %eax,%ebx
  802b5f:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802b62:	83 ec 08             	sub    $0x8,%esp
  802b65:	56                   	push   %esi
  802b66:	6a 00                	push   $0x0
  802b68:	e8 79 fb ff ff       	call   8026e6 <sys_page_unmap>
	return r;
  802b6d:	83 c4 10             	add    $0x10,%esp
  802b70:	89 d8                	mov    %ebx,%eax
}
  802b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b75:	5b                   	pop    %ebx
  802b76:	5e                   	pop    %esi
  802b77:	5d                   	pop    %ebp
  802b78:	c3                   	ret    

00802b79 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802b79:	55                   	push   %ebp
  802b7a:	89 e5                	mov    %esp,%ebp
  802b7c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b82:	50                   	push   %eax
  802b83:	ff 75 08             	pushl  0x8(%ebp)
  802b86:	e8 c4 fe ff ff       	call   802a4f <fd_lookup>
  802b8b:	83 c4 08             	add    $0x8,%esp
  802b8e:	85 c0                	test   %eax,%eax
  802b90:	78 10                	js     802ba2 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  802b92:	83 ec 08             	sub    $0x8,%esp
  802b95:	6a 01                	push   $0x1
  802b97:	ff 75 f4             	pushl  -0xc(%ebp)
  802b9a:	e8 59 ff ff ff       	call   802af8 <fd_close>
  802b9f:	83 c4 10             	add    $0x10,%esp
}
  802ba2:	c9                   	leave  
  802ba3:	c3                   	ret    

00802ba4 <close_all>:

void
close_all(void)
{
  802ba4:	55                   	push   %ebp
  802ba5:	89 e5                	mov    %esp,%ebp
  802ba7:	53                   	push   %ebx
  802ba8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802bab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802bb0:	83 ec 0c             	sub    $0xc,%esp
  802bb3:	53                   	push   %ebx
  802bb4:	e8 c0 ff ff ff       	call   802b79 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802bb9:	83 c3 01             	add    $0x1,%ebx
  802bbc:	83 c4 10             	add    $0x10,%esp
  802bbf:	83 fb 20             	cmp    $0x20,%ebx
  802bc2:	75 ec                	jne    802bb0 <close_all+0xc>
		close(i);
}
  802bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bc7:	c9                   	leave  
  802bc8:	c3                   	ret    

00802bc9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802bc9:	55                   	push   %ebp
  802bca:	89 e5                	mov    %esp,%ebp
  802bcc:	57                   	push   %edi
  802bcd:	56                   	push   %esi
  802bce:	53                   	push   %ebx
  802bcf:	83 ec 2c             	sub    $0x2c,%esp
  802bd2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802bd5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802bd8:	50                   	push   %eax
  802bd9:	ff 75 08             	pushl  0x8(%ebp)
  802bdc:	e8 6e fe ff ff       	call   802a4f <fd_lookup>
  802be1:	83 c4 08             	add    $0x8,%esp
  802be4:	85 c0                	test   %eax,%eax
  802be6:	0f 88 c1 00 00 00    	js     802cad <dup+0xe4>
		return r;
	close(newfdnum);
  802bec:	83 ec 0c             	sub    $0xc,%esp
  802bef:	56                   	push   %esi
  802bf0:	e8 84 ff ff ff       	call   802b79 <close>

	newfd = INDEX2FD(newfdnum);
  802bf5:	89 f3                	mov    %esi,%ebx
  802bf7:	c1 e3 0c             	shl    $0xc,%ebx
  802bfa:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802c00:	83 c4 04             	add    $0x4,%esp
  802c03:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c06:	e8 de fd ff ff       	call   8029e9 <fd2data>
  802c0b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802c0d:	89 1c 24             	mov    %ebx,(%esp)
  802c10:	e8 d4 fd ff ff       	call   8029e9 <fd2data>
  802c15:	83 c4 10             	add    $0x10,%esp
  802c18:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802c1b:	89 f8                	mov    %edi,%eax
  802c1d:	c1 e8 16             	shr    $0x16,%eax
  802c20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c27:	a8 01                	test   $0x1,%al
  802c29:	74 37                	je     802c62 <dup+0x99>
  802c2b:	89 f8                	mov    %edi,%eax
  802c2d:	c1 e8 0c             	shr    $0xc,%eax
  802c30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c37:	f6 c2 01             	test   $0x1,%dl
  802c3a:	74 26                	je     802c62 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802c3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c43:	83 ec 0c             	sub    $0xc,%esp
  802c46:	25 07 0e 00 00       	and    $0xe07,%eax
  802c4b:	50                   	push   %eax
  802c4c:	ff 75 d4             	pushl  -0x2c(%ebp)
  802c4f:	6a 00                	push   $0x0
  802c51:	57                   	push   %edi
  802c52:	6a 00                	push   $0x0
  802c54:	e8 4b fa ff ff       	call   8026a4 <sys_page_map>
  802c59:	89 c7                	mov    %eax,%edi
  802c5b:	83 c4 20             	add    $0x20,%esp
  802c5e:	85 c0                	test   %eax,%eax
  802c60:	78 2e                	js     802c90 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802c62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802c65:	89 d0                	mov    %edx,%eax
  802c67:	c1 e8 0c             	shr    $0xc,%eax
  802c6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c71:	83 ec 0c             	sub    $0xc,%esp
  802c74:	25 07 0e 00 00       	and    $0xe07,%eax
  802c79:	50                   	push   %eax
  802c7a:	53                   	push   %ebx
  802c7b:	6a 00                	push   $0x0
  802c7d:	52                   	push   %edx
  802c7e:	6a 00                	push   $0x0
  802c80:	e8 1f fa ff ff       	call   8026a4 <sys_page_map>
  802c85:	89 c7                	mov    %eax,%edi
  802c87:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802c8a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802c8c:	85 ff                	test   %edi,%edi
  802c8e:	79 1d                	jns    802cad <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802c90:	83 ec 08             	sub    $0x8,%esp
  802c93:	53                   	push   %ebx
  802c94:	6a 00                	push   $0x0
  802c96:	e8 4b fa ff ff       	call   8026e6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802c9b:	83 c4 08             	add    $0x8,%esp
  802c9e:	ff 75 d4             	pushl  -0x2c(%ebp)
  802ca1:	6a 00                	push   $0x0
  802ca3:	e8 3e fa ff ff       	call   8026e6 <sys_page_unmap>
	return r;
  802ca8:	83 c4 10             	add    $0x10,%esp
  802cab:	89 f8                	mov    %edi,%eax
}
  802cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cb0:	5b                   	pop    %ebx
  802cb1:	5e                   	pop    %esi
  802cb2:	5f                   	pop    %edi
  802cb3:	5d                   	pop    %ebp
  802cb4:	c3                   	ret    

00802cb5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802cb5:	55                   	push   %ebp
  802cb6:	89 e5                	mov    %esp,%ebp
  802cb8:	53                   	push   %ebx
  802cb9:	83 ec 14             	sub    $0x14,%esp
  802cbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cc2:	50                   	push   %eax
  802cc3:	53                   	push   %ebx
  802cc4:	e8 86 fd ff ff       	call   802a4f <fd_lookup>
  802cc9:	83 c4 08             	add    $0x8,%esp
  802ccc:	89 c2                	mov    %eax,%edx
  802cce:	85 c0                	test   %eax,%eax
  802cd0:	78 6d                	js     802d3f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cd2:	83 ec 08             	sub    $0x8,%esp
  802cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cd8:	50                   	push   %eax
  802cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cdc:	ff 30                	pushl  (%eax)
  802cde:	e8 c2 fd ff ff       	call   802aa5 <dev_lookup>
  802ce3:	83 c4 10             	add    $0x10,%esp
  802ce6:	85 c0                	test   %eax,%eax
  802ce8:	78 4c                	js     802d36 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802cea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ced:	8b 42 08             	mov    0x8(%edx),%eax
  802cf0:	83 e0 03             	and    $0x3,%eax
  802cf3:	83 f8 01             	cmp    $0x1,%eax
  802cf6:	75 21                	jne    802d19 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802cf8:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802cfd:	8b 40 48             	mov    0x48(%eax),%eax
  802d00:	83 ec 04             	sub    $0x4,%esp
  802d03:	53                   	push   %ebx
  802d04:	50                   	push   %eax
  802d05:	68 91 43 80 00       	push   $0x804391
  802d0a:	e8 a4 ee ff ff       	call   801bb3 <cprintf>
		return -E_INVAL;
  802d0f:	83 c4 10             	add    $0x10,%esp
  802d12:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d17:	eb 26                	jmp    802d3f <read+0x8a>
	}
	if (!dev->dev_read)
  802d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d1c:	8b 40 08             	mov    0x8(%eax),%eax
  802d1f:	85 c0                	test   %eax,%eax
  802d21:	74 17                	je     802d3a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802d23:	83 ec 04             	sub    $0x4,%esp
  802d26:	ff 75 10             	pushl  0x10(%ebp)
  802d29:	ff 75 0c             	pushl  0xc(%ebp)
  802d2c:	52                   	push   %edx
  802d2d:	ff d0                	call   *%eax
  802d2f:	89 c2                	mov    %eax,%edx
  802d31:	83 c4 10             	add    $0x10,%esp
  802d34:	eb 09                	jmp    802d3f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d36:	89 c2                	mov    %eax,%edx
  802d38:	eb 05                	jmp    802d3f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802d3a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802d3f:	89 d0                	mov    %edx,%eax
  802d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d44:	c9                   	leave  
  802d45:	c3                   	ret    

00802d46 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802d46:	55                   	push   %ebp
  802d47:	89 e5                	mov    %esp,%ebp
  802d49:	57                   	push   %edi
  802d4a:	56                   	push   %esi
  802d4b:	53                   	push   %ebx
  802d4c:	83 ec 0c             	sub    $0xc,%esp
  802d4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802d52:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d5a:	eb 21                	jmp    802d7d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d5c:	83 ec 04             	sub    $0x4,%esp
  802d5f:	89 f0                	mov    %esi,%eax
  802d61:	29 d8                	sub    %ebx,%eax
  802d63:	50                   	push   %eax
  802d64:	89 d8                	mov    %ebx,%eax
  802d66:	03 45 0c             	add    0xc(%ebp),%eax
  802d69:	50                   	push   %eax
  802d6a:	57                   	push   %edi
  802d6b:	e8 45 ff ff ff       	call   802cb5 <read>
		if (m < 0)
  802d70:	83 c4 10             	add    $0x10,%esp
  802d73:	85 c0                	test   %eax,%eax
  802d75:	78 10                	js     802d87 <readn+0x41>
			return m;
		if (m == 0)
  802d77:	85 c0                	test   %eax,%eax
  802d79:	74 0a                	je     802d85 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802d7b:	01 c3                	add    %eax,%ebx
  802d7d:	39 f3                	cmp    %esi,%ebx
  802d7f:	72 db                	jb     802d5c <readn+0x16>
  802d81:	89 d8                	mov    %ebx,%eax
  802d83:	eb 02                	jmp    802d87 <readn+0x41>
  802d85:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d8a:	5b                   	pop    %ebx
  802d8b:	5e                   	pop    %esi
  802d8c:	5f                   	pop    %edi
  802d8d:	5d                   	pop    %ebp
  802d8e:	c3                   	ret    

00802d8f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802d8f:	55                   	push   %ebp
  802d90:	89 e5                	mov    %esp,%ebp
  802d92:	53                   	push   %ebx
  802d93:	83 ec 14             	sub    $0x14,%esp
  802d96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d9c:	50                   	push   %eax
  802d9d:	53                   	push   %ebx
  802d9e:	e8 ac fc ff ff       	call   802a4f <fd_lookup>
  802da3:	83 c4 08             	add    $0x8,%esp
  802da6:	89 c2                	mov    %eax,%edx
  802da8:	85 c0                	test   %eax,%eax
  802daa:	78 68                	js     802e14 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802dac:	83 ec 08             	sub    $0x8,%esp
  802daf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802db2:	50                   	push   %eax
  802db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802db6:	ff 30                	pushl  (%eax)
  802db8:	e8 e8 fc ff ff       	call   802aa5 <dev_lookup>
  802dbd:	83 c4 10             	add    $0x10,%esp
  802dc0:	85 c0                	test   %eax,%eax
  802dc2:	78 47                	js     802e0b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802dcb:	75 21                	jne    802dee <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802dcd:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802dd2:	8b 40 48             	mov    0x48(%eax),%eax
  802dd5:	83 ec 04             	sub    $0x4,%esp
  802dd8:	53                   	push   %ebx
  802dd9:	50                   	push   %eax
  802dda:	68 ad 43 80 00       	push   $0x8043ad
  802ddf:	e8 cf ed ff ff       	call   801bb3 <cprintf>
		return -E_INVAL;
  802de4:	83 c4 10             	add    $0x10,%esp
  802de7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802dec:	eb 26                	jmp    802e14 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802df1:	8b 52 0c             	mov    0xc(%edx),%edx
  802df4:	85 d2                	test   %edx,%edx
  802df6:	74 17                	je     802e0f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802df8:	83 ec 04             	sub    $0x4,%esp
  802dfb:	ff 75 10             	pushl  0x10(%ebp)
  802dfe:	ff 75 0c             	pushl  0xc(%ebp)
  802e01:	50                   	push   %eax
  802e02:	ff d2                	call   *%edx
  802e04:	89 c2                	mov    %eax,%edx
  802e06:	83 c4 10             	add    $0x10,%esp
  802e09:	eb 09                	jmp    802e14 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e0b:	89 c2                	mov    %eax,%edx
  802e0d:	eb 05                	jmp    802e14 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802e0f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802e14:	89 d0                	mov    %edx,%eax
  802e16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e19:	c9                   	leave  
  802e1a:	c3                   	ret    

00802e1b <seek>:

int
seek(int fdnum, off_t offset)
{
  802e1b:	55                   	push   %ebp
  802e1c:	89 e5                	mov    %esp,%ebp
  802e1e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e21:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802e24:	50                   	push   %eax
  802e25:	ff 75 08             	pushl  0x8(%ebp)
  802e28:	e8 22 fc ff ff       	call   802a4f <fd_lookup>
  802e2d:	83 c4 08             	add    $0x8,%esp
  802e30:	85 c0                	test   %eax,%eax
  802e32:	78 0e                	js     802e42 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802e34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802e37:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e3a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802e3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e42:	c9                   	leave  
  802e43:	c3                   	ret    

00802e44 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802e44:	55                   	push   %ebp
  802e45:	89 e5                	mov    %esp,%ebp
  802e47:	53                   	push   %ebx
  802e48:	83 ec 14             	sub    $0x14,%esp
  802e4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e51:	50                   	push   %eax
  802e52:	53                   	push   %ebx
  802e53:	e8 f7 fb ff ff       	call   802a4f <fd_lookup>
  802e58:	83 c4 08             	add    $0x8,%esp
  802e5b:	89 c2                	mov    %eax,%edx
  802e5d:	85 c0                	test   %eax,%eax
  802e5f:	78 65                	js     802ec6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e61:	83 ec 08             	sub    $0x8,%esp
  802e64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e67:	50                   	push   %eax
  802e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e6b:	ff 30                	pushl  (%eax)
  802e6d:	e8 33 fc ff ff       	call   802aa5 <dev_lookup>
  802e72:	83 c4 10             	add    $0x10,%esp
  802e75:	85 c0                	test   %eax,%eax
  802e77:	78 44                	js     802ebd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e7c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e80:	75 21                	jne    802ea3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802e82:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802e87:	8b 40 48             	mov    0x48(%eax),%eax
  802e8a:	83 ec 04             	sub    $0x4,%esp
  802e8d:	53                   	push   %ebx
  802e8e:	50                   	push   %eax
  802e8f:	68 70 43 80 00       	push   $0x804370
  802e94:	e8 1a ed ff ff       	call   801bb3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802e99:	83 c4 10             	add    $0x10,%esp
  802e9c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ea1:	eb 23                	jmp    802ec6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802ea3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ea6:	8b 52 18             	mov    0x18(%edx),%edx
  802ea9:	85 d2                	test   %edx,%edx
  802eab:	74 14                	je     802ec1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802ead:	83 ec 08             	sub    $0x8,%esp
  802eb0:	ff 75 0c             	pushl  0xc(%ebp)
  802eb3:	50                   	push   %eax
  802eb4:	ff d2                	call   *%edx
  802eb6:	89 c2                	mov    %eax,%edx
  802eb8:	83 c4 10             	add    $0x10,%esp
  802ebb:	eb 09                	jmp    802ec6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ebd:	89 c2                	mov    %eax,%edx
  802ebf:	eb 05                	jmp    802ec6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802ec1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802ec6:	89 d0                	mov    %edx,%eax
  802ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ecb:	c9                   	leave  
  802ecc:	c3                   	ret    

00802ecd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802ecd:	55                   	push   %ebp
  802ece:	89 e5                	mov    %esp,%ebp
  802ed0:	53                   	push   %ebx
  802ed1:	83 ec 14             	sub    $0x14,%esp
  802ed4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ed7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802eda:	50                   	push   %eax
  802edb:	ff 75 08             	pushl  0x8(%ebp)
  802ede:	e8 6c fb ff ff       	call   802a4f <fd_lookup>
  802ee3:	83 c4 08             	add    $0x8,%esp
  802ee6:	89 c2                	mov    %eax,%edx
  802ee8:	85 c0                	test   %eax,%eax
  802eea:	78 58                	js     802f44 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802eec:	83 ec 08             	sub    $0x8,%esp
  802eef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ef2:	50                   	push   %eax
  802ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ef6:	ff 30                	pushl  (%eax)
  802ef8:	e8 a8 fb ff ff       	call   802aa5 <dev_lookup>
  802efd:	83 c4 10             	add    $0x10,%esp
  802f00:	85 c0                	test   %eax,%eax
  802f02:	78 37                	js     802f3b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f07:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802f0b:	74 32                	je     802f3f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f0d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802f10:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802f17:	00 00 00 
	stat->st_isdir = 0;
  802f1a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f21:	00 00 00 
	stat->st_dev = dev;
  802f24:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802f2a:	83 ec 08             	sub    $0x8,%esp
  802f2d:	53                   	push   %ebx
  802f2e:	ff 75 f0             	pushl  -0x10(%ebp)
  802f31:	ff 50 14             	call   *0x14(%eax)
  802f34:	89 c2                	mov    %eax,%edx
  802f36:	83 c4 10             	add    $0x10,%esp
  802f39:	eb 09                	jmp    802f44 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f3b:	89 c2                	mov    %eax,%edx
  802f3d:	eb 05                	jmp    802f44 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802f3f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802f44:	89 d0                	mov    %edx,%eax
  802f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f49:	c9                   	leave  
  802f4a:	c3                   	ret    

00802f4b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802f4b:	55                   	push   %ebp
  802f4c:	89 e5                	mov    %esp,%ebp
  802f4e:	56                   	push   %esi
  802f4f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802f50:	83 ec 08             	sub    $0x8,%esp
  802f53:	6a 00                	push   $0x0
  802f55:	ff 75 08             	pushl  0x8(%ebp)
  802f58:	e8 2b 02 00 00       	call   803188 <open>
  802f5d:	89 c3                	mov    %eax,%ebx
  802f5f:	83 c4 10             	add    $0x10,%esp
  802f62:	85 c0                	test   %eax,%eax
  802f64:	78 1b                	js     802f81 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802f66:	83 ec 08             	sub    $0x8,%esp
  802f69:	ff 75 0c             	pushl  0xc(%ebp)
  802f6c:	50                   	push   %eax
  802f6d:	e8 5b ff ff ff       	call   802ecd <fstat>
  802f72:	89 c6                	mov    %eax,%esi
	close(fd);
  802f74:	89 1c 24             	mov    %ebx,(%esp)
  802f77:	e8 fd fb ff ff       	call   802b79 <close>
	return r;
  802f7c:	83 c4 10             	add    $0x10,%esp
  802f7f:	89 f0                	mov    %esi,%eax
}
  802f81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f84:	5b                   	pop    %ebx
  802f85:	5e                   	pop    %esi
  802f86:	5d                   	pop    %ebp
  802f87:	c3                   	ret    

00802f88 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802f88:	55                   	push   %ebp
  802f89:	89 e5                	mov    %esp,%ebp
  802f8b:	56                   	push   %esi
  802f8c:	53                   	push   %ebx
  802f8d:	89 c6                	mov    %eax,%esi
  802f8f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802f91:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  802f98:	75 12                	jne    802fac <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802f9a:	83 ec 0c             	sub    $0xc,%esp
  802f9d:	6a 01                	push   $0x1
  802f9f:	e8 fc f9 ff ff       	call   8029a0 <ipc_find_env>
  802fa4:	a3 04 a0 80 00       	mov    %eax,0x80a004
  802fa9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802fac:	6a 07                	push   $0x7
  802fae:	68 00 b0 80 00       	push   $0x80b000
  802fb3:	56                   	push   %esi
  802fb4:	ff 35 04 a0 80 00    	pushl  0x80a004
  802fba:	e8 8b f9 ff ff       	call   80294a <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  802fbf:	83 c4 0c             	add    $0xc,%esp
  802fc2:	6a 00                	push   $0x0
  802fc4:	53                   	push   %ebx
  802fc5:	6a 00                	push   $0x0
  802fc7:	e8 15 f9 ff ff       	call   8028e1 <ipc_recv>
}
  802fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fcf:	5b                   	pop    %ebx
  802fd0:	5e                   	pop    %esi
  802fd1:	5d                   	pop    %ebp
  802fd2:	c3                   	ret    

00802fd3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802fd3:	55                   	push   %ebp
  802fd4:	89 e5                	mov    %esp,%ebp
  802fd6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  802fdc:	8b 40 0c             	mov    0xc(%eax),%eax
  802fdf:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fe7:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802fec:	ba 00 00 00 00       	mov    $0x0,%edx
  802ff1:	b8 02 00 00 00       	mov    $0x2,%eax
  802ff6:	e8 8d ff ff ff       	call   802f88 <fsipc>
}
  802ffb:	c9                   	leave  
  802ffc:	c3                   	ret    

00802ffd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802ffd:	55                   	push   %ebp
  802ffe:	89 e5                	mov    %esp,%ebp
  803000:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803003:	8b 45 08             	mov    0x8(%ebp),%eax
  803006:	8b 40 0c             	mov    0xc(%eax),%eax
  803009:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  80300e:	ba 00 00 00 00       	mov    $0x0,%edx
  803013:	b8 06 00 00 00       	mov    $0x6,%eax
  803018:	e8 6b ff ff ff       	call   802f88 <fsipc>
}
  80301d:	c9                   	leave  
  80301e:	c3                   	ret    

0080301f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80301f:	55                   	push   %ebp
  803020:	89 e5                	mov    %esp,%ebp
  803022:	53                   	push   %ebx
  803023:	83 ec 04             	sub    $0x4,%esp
  803026:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803029:	8b 45 08             	mov    0x8(%ebp),%eax
  80302c:	8b 40 0c             	mov    0xc(%eax),%eax
  80302f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803034:	ba 00 00 00 00       	mov    $0x0,%edx
  803039:	b8 05 00 00 00       	mov    $0x5,%eax
  80303e:	e8 45 ff ff ff       	call   802f88 <fsipc>
  803043:	85 c0                	test   %eax,%eax
  803045:	78 2c                	js     803073 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803047:	83 ec 08             	sub    $0x8,%esp
  80304a:	68 00 b0 80 00       	push   $0x80b000
  80304f:	53                   	push   %ebx
  803050:	e8 92 f1 ff ff       	call   8021e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803055:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80305a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803060:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803065:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80306b:	83 c4 10             	add    $0x10,%esp
  80306e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803076:	c9                   	leave  
  803077:	c3                   	ret    

00803078 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803078:	55                   	push   %ebp
  803079:	89 e5                	mov    %esp,%ebp
  80307b:	53                   	push   %ebx
  80307c:	83 ec 08             	sub    $0x8,%esp
  80307f:	8b 45 10             	mov    0x10(%ebp),%eax
  803082:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  803087:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80308c:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80308f:	8b 45 08             	mov    0x8(%ebp),%eax
  803092:	8b 40 0c             	mov    0xc(%eax),%eax
  803095:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.write.req_n = n;
  80309a:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8030a0:	53                   	push   %ebx
  8030a1:	ff 75 0c             	pushl  0xc(%ebp)
  8030a4:	68 08 b0 80 00       	push   $0x80b008
  8030a9:	e8 cb f2 ff ff       	call   802379 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8030ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8030b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8030b8:	e8 cb fe ff ff       	call   802f88 <fsipc>
  8030bd:	83 c4 10             	add    $0x10,%esp
  8030c0:	85 c0                	test   %eax,%eax
  8030c2:	78 3d                	js     803101 <devfile_write+0x89>
		return r;

	assert(r <= n);
  8030c4:	39 d8                	cmp    %ebx,%eax
  8030c6:	76 19                	jbe    8030e1 <devfile_write+0x69>
  8030c8:	68 dc 43 80 00       	push   $0x8043dc
  8030cd:	68 1d 3a 80 00       	push   $0x803a1d
  8030d2:	68 9f 00 00 00       	push   $0x9f
  8030d7:	68 e3 43 80 00       	push   $0x8043e3
  8030dc:	e8 f9 e9 ff ff       	call   801ada <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  8030e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8030e6:	76 19                	jbe    803101 <devfile_write+0x89>
  8030e8:	68 fc 43 80 00       	push   $0x8043fc
  8030ed:	68 1d 3a 80 00       	push   $0x803a1d
  8030f2:	68 a0 00 00 00       	push   $0xa0
  8030f7:	68 e3 43 80 00       	push   $0x8043e3
  8030fc:	e8 d9 e9 ff ff       	call   801ada <_panic>

	return r;
}
  803101:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803104:	c9                   	leave  
  803105:	c3                   	ret    

00803106 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  803106:	55                   	push   %ebp
  803107:	89 e5                	mov    %esp,%ebp
  803109:	56                   	push   %esi
  80310a:	53                   	push   %ebx
  80310b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80310e:	8b 45 08             	mov    0x8(%ebp),%eax
  803111:	8b 40 0c             	mov    0xc(%eax),%eax
  803114:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803119:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80311f:	ba 00 00 00 00       	mov    $0x0,%edx
  803124:	b8 03 00 00 00       	mov    $0x3,%eax
  803129:	e8 5a fe ff ff       	call   802f88 <fsipc>
  80312e:	89 c3                	mov    %eax,%ebx
  803130:	85 c0                	test   %eax,%eax
  803132:	78 4b                	js     80317f <devfile_read+0x79>
		return r;
	assert(r <= n);
  803134:	39 c6                	cmp    %eax,%esi
  803136:	73 16                	jae    80314e <devfile_read+0x48>
  803138:	68 dc 43 80 00       	push   $0x8043dc
  80313d:	68 1d 3a 80 00       	push   $0x803a1d
  803142:	6a 7e                	push   $0x7e
  803144:	68 e3 43 80 00       	push   $0x8043e3
  803149:	e8 8c e9 ff ff       	call   801ada <_panic>
	assert(r <= PGSIZE);
  80314e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803153:	7e 16                	jle    80316b <devfile_read+0x65>
  803155:	68 ee 43 80 00       	push   $0x8043ee
  80315a:	68 1d 3a 80 00       	push   $0x803a1d
  80315f:	6a 7f                	push   $0x7f
  803161:	68 e3 43 80 00       	push   $0x8043e3
  803166:	e8 6f e9 ff ff       	call   801ada <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80316b:	83 ec 04             	sub    $0x4,%esp
  80316e:	50                   	push   %eax
  80316f:	68 00 b0 80 00       	push   $0x80b000
  803174:	ff 75 0c             	pushl  0xc(%ebp)
  803177:	e8 fd f1 ff ff       	call   802379 <memmove>
	return r;
  80317c:	83 c4 10             	add    $0x10,%esp
}
  80317f:	89 d8                	mov    %ebx,%eax
  803181:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803184:	5b                   	pop    %ebx
  803185:	5e                   	pop    %esi
  803186:	5d                   	pop    %ebp
  803187:	c3                   	ret    

00803188 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803188:	55                   	push   %ebp
  803189:	89 e5                	mov    %esp,%ebp
  80318b:	53                   	push   %ebx
  80318c:	83 ec 20             	sub    $0x20,%esp
  80318f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  803192:	53                   	push   %ebx
  803193:	e8 16 f0 ff ff       	call   8021ae <strlen>
  803198:	83 c4 10             	add    $0x10,%esp
  80319b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8031a0:	7f 67                	jg     803209 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8031a2:	83 ec 0c             	sub    $0xc,%esp
  8031a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031a8:	50                   	push   %eax
  8031a9:	e8 52 f8 ff ff       	call   802a00 <fd_alloc>
  8031ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8031b1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8031b3:	85 c0                	test   %eax,%eax
  8031b5:	78 57                	js     80320e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8031b7:	83 ec 08             	sub    $0x8,%esp
  8031ba:	53                   	push   %ebx
  8031bb:	68 00 b0 80 00       	push   $0x80b000
  8031c0:	e8 22 f0 ff ff       	call   8021e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8031c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031c8:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8031cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8031d5:	e8 ae fd ff ff       	call   802f88 <fsipc>
  8031da:	89 c3                	mov    %eax,%ebx
  8031dc:	83 c4 10             	add    $0x10,%esp
  8031df:	85 c0                	test   %eax,%eax
  8031e1:	79 14                	jns    8031f7 <open+0x6f>
		fd_close(fd, 0);
  8031e3:	83 ec 08             	sub    $0x8,%esp
  8031e6:	6a 00                	push   $0x0
  8031e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8031eb:	e8 08 f9 ff ff       	call   802af8 <fd_close>
		return r;
  8031f0:	83 c4 10             	add    $0x10,%esp
  8031f3:	89 da                	mov    %ebx,%edx
  8031f5:	eb 17                	jmp    80320e <open+0x86>
	}

	return fd2num(fd);
  8031f7:	83 ec 0c             	sub    $0xc,%esp
  8031fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8031fd:	e8 d7 f7 ff ff       	call   8029d9 <fd2num>
  803202:	89 c2                	mov    %eax,%edx
  803204:	83 c4 10             	add    $0x10,%esp
  803207:	eb 05                	jmp    80320e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  803209:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80320e:	89 d0                	mov    %edx,%eax
  803210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803213:	c9                   	leave  
  803214:	c3                   	ret    

00803215 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  803215:	55                   	push   %ebp
  803216:	89 e5                	mov    %esp,%ebp
  803218:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80321b:	ba 00 00 00 00       	mov    $0x0,%edx
  803220:	b8 08 00 00 00       	mov    $0x8,%eax
  803225:	e8 5e fd ff ff       	call   802f88 <fsipc>
}
  80322a:	c9                   	leave  
  80322b:	c3                   	ret    

0080322c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80322c:	55                   	push   %ebp
  80322d:	89 e5                	mov    %esp,%ebp
  80322f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803232:	89 d0                	mov    %edx,%eax
  803234:	c1 e8 16             	shr    $0x16,%eax
  803237:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80323e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803243:	f6 c1 01             	test   $0x1,%cl
  803246:	74 1d                	je     803265 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803248:	c1 ea 0c             	shr    $0xc,%edx
  80324b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803252:	f6 c2 01             	test   $0x1,%dl
  803255:	74 0e                	je     803265 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803257:	c1 ea 0c             	shr    $0xc,%edx
  80325a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803261:	ef 
  803262:	0f b7 c0             	movzwl %ax,%eax
}
  803265:	5d                   	pop    %ebp
  803266:	c3                   	ret    

00803267 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803267:	55                   	push   %ebp
  803268:	89 e5                	mov    %esp,%ebp
  80326a:	56                   	push   %esi
  80326b:	53                   	push   %ebx
  80326c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80326f:	83 ec 0c             	sub    $0xc,%esp
  803272:	ff 75 08             	pushl  0x8(%ebp)
  803275:	e8 6f f7 ff ff       	call   8029e9 <fd2data>
  80327a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80327c:	83 c4 08             	add    $0x8,%esp
  80327f:	68 2c 44 80 00       	push   $0x80442c
  803284:	53                   	push   %ebx
  803285:	e8 5d ef ff ff       	call   8021e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80328a:	8b 46 04             	mov    0x4(%esi),%eax
  80328d:	2b 06                	sub    (%esi),%eax
  80328f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803295:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80329c:	00 00 00 
	stat->st_dev = &devpipe;
  80329f:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8032a6:	90 80 00 
	return 0;
}
  8032a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8032ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032b1:	5b                   	pop    %ebx
  8032b2:	5e                   	pop    %esi
  8032b3:	5d                   	pop    %ebp
  8032b4:	c3                   	ret    

008032b5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8032b5:	55                   	push   %ebp
  8032b6:	89 e5                	mov    %esp,%ebp
  8032b8:	53                   	push   %ebx
  8032b9:	83 ec 0c             	sub    $0xc,%esp
  8032bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8032bf:	53                   	push   %ebx
  8032c0:	6a 00                	push   $0x0
  8032c2:	e8 1f f4 ff ff       	call   8026e6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8032c7:	89 1c 24             	mov    %ebx,(%esp)
  8032ca:	e8 1a f7 ff ff       	call   8029e9 <fd2data>
  8032cf:	83 c4 08             	add    $0x8,%esp
  8032d2:	50                   	push   %eax
  8032d3:	6a 00                	push   $0x0
  8032d5:	e8 0c f4 ff ff       	call   8026e6 <sys_page_unmap>
}
  8032da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032dd:	c9                   	leave  
  8032de:	c3                   	ret    

008032df <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8032df:	55                   	push   %ebp
  8032e0:	89 e5                	mov    %esp,%ebp
  8032e2:	57                   	push   %edi
  8032e3:	56                   	push   %esi
  8032e4:	53                   	push   %ebx
  8032e5:	83 ec 1c             	sub    $0x1c,%esp
  8032e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8032eb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8032ed:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8032f2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8032f5:	83 ec 0c             	sub    $0xc,%esp
  8032f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8032fb:	e8 2c ff ff ff       	call   80322c <pageref>
  803300:	89 c3                	mov    %eax,%ebx
  803302:	89 3c 24             	mov    %edi,(%esp)
  803305:	e8 22 ff ff ff       	call   80322c <pageref>
  80330a:	83 c4 10             	add    $0x10,%esp
  80330d:	39 c3                	cmp    %eax,%ebx
  80330f:	0f 94 c1             	sete   %cl
  803312:	0f b6 c9             	movzbl %cl,%ecx
  803315:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  803318:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  80331e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803321:	39 ce                	cmp    %ecx,%esi
  803323:	74 1b                	je     803340 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803325:	39 c3                	cmp    %eax,%ebx
  803327:	75 c4                	jne    8032ed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803329:	8b 42 58             	mov    0x58(%edx),%eax
  80332c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80332f:	50                   	push   %eax
  803330:	56                   	push   %esi
  803331:	68 33 44 80 00       	push   $0x804433
  803336:	e8 78 e8 ff ff       	call   801bb3 <cprintf>
  80333b:	83 c4 10             	add    $0x10,%esp
  80333e:	eb ad                	jmp    8032ed <_pipeisclosed+0xe>
	}
}
  803340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803346:	5b                   	pop    %ebx
  803347:	5e                   	pop    %esi
  803348:	5f                   	pop    %edi
  803349:	5d                   	pop    %ebp
  80334a:	c3                   	ret    

0080334b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80334b:	55                   	push   %ebp
  80334c:	89 e5                	mov    %esp,%ebp
  80334e:	57                   	push   %edi
  80334f:	56                   	push   %esi
  803350:	53                   	push   %ebx
  803351:	83 ec 28             	sub    $0x28,%esp
  803354:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803357:	56                   	push   %esi
  803358:	e8 8c f6 ff ff       	call   8029e9 <fd2data>
  80335d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80335f:	83 c4 10             	add    $0x10,%esp
  803362:	bf 00 00 00 00       	mov    $0x0,%edi
  803367:	eb 4b                	jmp    8033b4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803369:	89 da                	mov    %ebx,%edx
  80336b:	89 f0                	mov    %esi,%eax
  80336d:	e8 6d ff ff ff       	call   8032df <_pipeisclosed>
  803372:	85 c0                	test   %eax,%eax
  803374:	75 48                	jne    8033be <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803376:	e8 c7 f2 ff ff       	call   802642 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80337b:	8b 43 04             	mov    0x4(%ebx),%eax
  80337e:	8b 0b                	mov    (%ebx),%ecx
  803380:	8d 51 20             	lea    0x20(%ecx),%edx
  803383:	39 d0                	cmp    %edx,%eax
  803385:	73 e2                	jae    803369 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80338a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80338e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803391:	89 c2                	mov    %eax,%edx
  803393:	c1 fa 1f             	sar    $0x1f,%edx
  803396:	89 d1                	mov    %edx,%ecx
  803398:	c1 e9 1b             	shr    $0x1b,%ecx
  80339b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80339e:	83 e2 1f             	and    $0x1f,%edx
  8033a1:	29 ca                	sub    %ecx,%edx
  8033a3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8033a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8033ab:	83 c0 01             	add    $0x1,%eax
  8033ae:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8033b1:	83 c7 01             	add    $0x1,%edi
  8033b4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8033b7:	75 c2                	jne    80337b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8033b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8033bc:	eb 05                	jmp    8033c3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8033be:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8033c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033c6:	5b                   	pop    %ebx
  8033c7:	5e                   	pop    %esi
  8033c8:	5f                   	pop    %edi
  8033c9:	5d                   	pop    %ebp
  8033ca:	c3                   	ret    

008033cb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8033cb:	55                   	push   %ebp
  8033cc:	89 e5                	mov    %esp,%ebp
  8033ce:	57                   	push   %edi
  8033cf:	56                   	push   %esi
  8033d0:	53                   	push   %ebx
  8033d1:	83 ec 18             	sub    $0x18,%esp
  8033d4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8033d7:	57                   	push   %edi
  8033d8:	e8 0c f6 ff ff       	call   8029e9 <fd2data>
  8033dd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8033df:	83 c4 10             	add    $0x10,%esp
  8033e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8033e7:	eb 3d                	jmp    803426 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8033e9:	85 db                	test   %ebx,%ebx
  8033eb:	74 04                	je     8033f1 <devpipe_read+0x26>
				return i;
  8033ed:	89 d8                	mov    %ebx,%eax
  8033ef:	eb 44                	jmp    803435 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8033f1:	89 f2                	mov    %esi,%edx
  8033f3:	89 f8                	mov    %edi,%eax
  8033f5:	e8 e5 fe ff ff       	call   8032df <_pipeisclosed>
  8033fa:	85 c0                	test   %eax,%eax
  8033fc:	75 32                	jne    803430 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8033fe:	e8 3f f2 ff ff       	call   802642 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803403:	8b 06                	mov    (%esi),%eax
  803405:	3b 46 04             	cmp    0x4(%esi),%eax
  803408:	74 df                	je     8033e9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80340a:	99                   	cltd   
  80340b:	c1 ea 1b             	shr    $0x1b,%edx
  80340e:	01 d0                	add    %edx,%eax
  803410:	83 e0 1f             	and    $0x1f,%eax
  803413:	29 d0                	sub    %edx,%eax
  803415:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80341a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80341d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803420:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803423:	83 c3 01             	add    $0x1,%ebx
  803426:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803429:	75 d8                	jne    803403 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80342b:	8b 45 10             	mov    0x10(%ebp),%eax
  80342e:	eb 05                	jmp    803435 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803430:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803435:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803438:	5b                   	pop    %ebx
  803439:	5e                   	pop    %esi
  80343a:	5f                   	pop    %edi
  80343b:	5d                   	pop    %ebp
  80343c:	c3                   	ret    

0080343d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80343d:	55                   	push   %ebp
  80343e:	89 e5                	mov    %esp,%ebp
  803440:	56                   	push   %esi
  803441:	53                   	push   %ebx
  803442:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803448:	50                   	push   %eax
  803449:	e8 b2 f5 ff ff       	call   802a00 <fd_alloc>
  80344e:	83 c4 10             	add    $0x10,%esp
  803451:	89 c2                	mov    %eax,%edx
  803453:	85 c0                	test   %eax,%eax
  803455:	0f 88 2c 01 00 00    	js     803587 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80345b:	83 ec 04             	sub    $0x4,%esp
  80345e:	68 07 04 00 00       	push   $0x407
  803463:	ff 75 f4             	pushl  -0xc(%ebp)
  803466:	6a 00                	push   $0x0
  803468:	e8 f4 f1 ff ff       	call   802661 <sys_page_alloc>
  80346d:	83 c4 10             	add    $0x10,%esp
  803470:	89 c2                	mov    %eax,%edx
  803472:	85 c0                	test   %eax,%eax
  803474:	0f 88 0d 01 00 00    	js     803587 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80347a:	83 ec 0c             	sub    $0xc,%esp
  80347d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803480:	50                   	push   %eax
  803481:	e8 7a f5 ff ff       	call   802a00 <fd_alloc>
  803486:	89 c3                	mov    %eax,%ebx
  803488:	83 c4 10             	add    $0x10,%esp
  80348b:	85 c0                	test   %eax,%eax
  80348d:	0f 88 e2 00 00 00    	js     803575 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803493:	83 ec 04             	sub    $0x4,%esp
  803496:	68 07 04 00 00       	push   $0x407
  80349b:	ff 75 f0             	pushl  -0x10(%ebp)
  80349e:	6a 00                	push   $0x0
  8034a0:	e8 bc f1 ff ff       	call   802661 <sys_page_alloc>
  8034a5:	89 c3                	mov    %eax,%ebx
  8034a7:	83 c4 10             	add    $0x10,%esp
  8034aa:	85 c0                	test   %eax,%eax
  8034ac:	0f 88 c3 00 00 00    	js     803575 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8034b2:	83 ec 0c             	sub    $0xc,%esp
  8034b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8034b8:	e8 2c f5 ff ff       	call   8029e9 <fd2data>
  8034bd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034bf:	83 c4 0c             	add    $0xc,%esp
  8034c2:	68 07 04 00 00       	push   $0x407
  8034c7:	50                   	push   %eax
  8034c8:	6a 00                	push   $0x0
  8034ca:	e8 92 f1 ff ff       	call   802661 <sys_page_alloc>
  8034cf:	89 c3                	mov    %eax,%ebx
  8034d1:	83 c4 10             	add    $0x10,%esp
  8034d4:	85 c0                	test   %eax,%eax
  8034d6:	0f 88 89 00 00 00    	js     803565 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034dc:	83 ec 0c             	sub    $0xc,%esp
  8034df:	ff 75 f0             	pushl  -0x10(%ebp)
  8034e2:	e8 02 f5 ff ff       	call   8029e9 <fd2data>
  8034e7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8034ee:	50                   	push   %eax
  8034ef:	6a 00                	push   $0x0
  8034f1:	56                   	push   %esi
  8034f2:	6a 00                	push   $0x0
  8034f4:	e8 ab f1 ff ff       	call   8026a4 <sys_page_map>
  8034f9:	89 c3                	mov    %eax,%ebx
  8034fb:	83 c4 20             	add    $0x20,%esp
  8034fe:	85 c0                	test   %eax,%eax
  803500:	78 55                	js     803557 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803502:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80350b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80350d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803510:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803517:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80351d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803520:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803525:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80352c:	83 ec 0c             	sub    $0xc,%esp
  80352f:	ff 75 f4             	pushl  -0xc(%ebp)
  803532:	e8 a2 f4 ff ff       	call   8029d9 <fd2num>
  803537:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80353a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80353c:	83 c4 04             	add    $0x4,%esp
  80353f:	ff 75 f0             	pushl  -0x10(%ebp)
  803542:	e8 92 f4 ff ff       	call   8029d9 <fd2num>
  803547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80354a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80354d:	83 c4 10             	add    $0x10,%esp
  803550:	ba 00 00 00 00       	mov    $0x0,%edx
  803555:	eb 30                	jmp    803587 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803557:	83 ec 08             	sub    $0x8,%esp
  80355a:	56                   	push   %esi
  80355b:	6a 00                	push   $0x0
  80355d:	e8 84 f1 ff ff       	call   8026e6 <sys_page_unmap>
  803562:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803565:	83 ec 08             	sub    $0x8,%esp
  803568:	ff 75 f0             	pushl  -0x10(%ebp)
  80356b:	6a 00                	push   $0x0
  80356d:	e8 74 f1 ff ff       	call   8026e6 <sys_page_unmap>
  803572:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803575:	83 ec 08             	sub    $0x8,%esp
  803578:	ff 75 f4             	pushl  -0xc(%ebp)
  80357b:	6a 00                	push   $0x0
  80357d:	e8 64 f1 ff ff       	call   8026e6 <sys_page_unmap>
  803582:	83 c4 10             	add    $0x10,%esp
  803585:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803587:	89 d0                	mov    %edx,%eax
  803589:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80358c:	5b                   	pop    %ebx
  80358d:	5e                   	pop    %esi
  80358e:	5d                   	pop    %ebp
  80358f:	c3                   	ret    

00803590 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803590:	55                   	push   %ebp
  803591:	89 e5                	mov    %esp,%ebp
  803593:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803596:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803599:	50                   	push   %eax
  80359a:	ff 75 08             	pushl  0x8(%ebp)
  80359d:	e8 ad f4 ff ff       	call   802a4f <fd_lookup>
  8035a2:	83 c4 10             	add    $0x10,%esp
  8035a5:	85 c0                	test   %eax,%eax
  8035a7:	78 18                	js     8035c1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8035a9:	83 ec 0c             	sub    $0xc,%esp
  8035ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8035af:	e8 35 f4 ff ff       	call   8029e9 <fd2data>
	return _pipeisclosed(fd, p);
  8035b4:	89 c2                	mov    %eax,%edx
  8035b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035b9:	e8 21 fd ff ff       	call   8032df <_pipeisclosed>
  8035be:	83 c4 10             	add    $0x10,%esp
}
  8035c1:	c9                   	leave  
  8035c2:	c3                   	ret    

008035c3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8035c3:	55                   	push   %ebp
  8035c4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8035c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8035cb:	5d                   	pop    %ebp
  8035cc:	c3                   	ret    

008035cd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8035cd:	55                   	push   %ebp
  8035ce:	89 e5                	mov    %esp,%ebp
  8035d0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8035d3:	68 4b 44 80 00       	push   $0x80444b
  8035d8:	ff 75 0c             	pushl  0xc(%ebp)
  8035db:	e8 07 ec ff ff       	call   8021e7 <strcpy>
	return 0;
}
  8035e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8035e5:	c9                   	leave  
  8035e6:	c3                   	ret    

008035e7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8035e7:	55                   	push   %ebp
  8035e8:	89 e5                	mov    %esp,%ebp
  8035ea:	57                   	push   %edi
  8035eb:	56                   	push   %esi
  8035ec:	53                   	push   %ebx
  8035ed:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8035f3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8035f8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8035fe:	eb 2d                	jmp    80362d <devcons_write+0x46>
		m = n - tot;
  803600:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803603:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803605:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803608:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80360d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803610:	83 ec 04             	sub    $0x4,%esp
  803613:	53                   	push   %ebx
  803614:	03 45 0c             	add    0xc(%ebp),%eax
  803617:	50                   	push   %eax
  803618:	57                   	push   %edi
  803619:	e8 5b ed ff ff       	call   802379 <memmove>
		sys_cputs(buf, m);
  80361e:	83 c4 08             	add    $0x8,%esp
  803621:	53                   	push   %ebx
  803622:	57                   	push   %edi
  803623:	e8 7d ef ff ff       	call   8025a5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803628:	01 de                	add    %ebx,%esi
  80362a:	83 c4 10             	add    $0x10,%esp
  80362d:	89 f0                	mov    %esi,%eax
  80362f:	3b 75 10             	cmp    0x10(%ebp),%esi
  803632:	72 cc                	jb     803600 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803634:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803637:	5b                   	pop    %ebx
  803638:	5e                   	pop    %esi
  803639:	5f                   	pop    %edi
  80363a:	5d                   	pop    %ebp
  80363b:	c3                   	ret    

0080363c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80363c:	55                   	push   %ebp
  80363d:	89 e5                	mov    %esp,%ebp
  80363f:	83 ec 08             	sub    $0x8,%esp
  803642:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803647:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80364b:	74 2a                	je     803677 <devcons_read+0x3b>
  80364d:	eb 05                	jmp    803654 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80364f:	e8 ee ef ff ff       	call   802642 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803654:	e8 6a ef ff ff       	call   8025c3 <sys_cgetc>
  803659:	85 c0                	test   %eax,%eax
  80365b:	74 f2                	je     80364f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80365d:	85 c0                	test   %eax,%eax
  80365f:	78 16                	js     803677 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803661:	83 f8 04             	cmp    $0x4,%eax
  803664:	74 0c                	je     803672 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803666:	8b 55 0c             	mov    0xc(%ebp),%edx
  803669:	88 02                	mov    %al,(%edx)
	return 1;
  80366b:	b8 01 00 00 00       	mov    $0x1,%eax
  803670:	eb 05                	jmp    803677 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803672:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803677:	c9                   	leave  
  803678:	c3                   	ret    

00803679 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803679:	55                   	push   %ebp
  80367a:	89 e5                	mov    %esp,%ebp
  80367c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80367f:	8b 45 08             	mov    0x8(%ebp),%eax
  803682:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803685:	6a 01                	push   $0x1
  803687:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80368a:	50                   	push   %eax
  80368b:	e8 15 ef ff ff       	call   8025a5 <sys_cputs>
}
  803690:	83 c4 10             	add    $0x10,%esp
  803693:	c9                   	leave  
  803694:	c3                   	ret    

00803695 <getchar>:

int
getchar(void)
{
  803695:	55                   	push   %ebp
  803696:	89 e5                	mov    %esp,%ebp
  803698:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80369b:	6a 01                	push   $0x1
  80369d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036a0:	50                   	push   %eax
  8036a1:	6a 00                	push   $0x0
  8036a3:	e8 0d f6 ff ff       	call   802cb5 <read>
	if (r < 0)
  8036a8:	83 c4 10             	add    $0x10,%esp
  8036ab:	85 c0                	test   %eax,%eax
  8036ad:	78 0f                	js     8036be <getchar+0x29>
		return r;
	if (r < 1)
  8036af:	85 c0                	test   %eax,%eax
  8036b1:	7e 06                	jle    8036b9 <getchar+0x24>
		return -E_EOF;
	return c;
  8036b3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8036b7:	eb 05                	jmp    8036be <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8036b9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8036be:	c9                   	leave  
  8036bf:	c3                   	ret    

008036c0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8036c0:	55                   	push   %ebp
  8036c1:	89 e5                	mov    %esp,%ebp
  8036c3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8036c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036c9:	50                   	push   %eax
  8036ca:	ff 75 08             	pushl  0x8(%ebp)
  8036cd:	e8 7d f3 ff ff       	call   802a4f <fd_lookup>
  8036d2:	83 c4 10             	add    $0x10,%esp
  8036d5:	85 c0                	test   %eax,%eax
  8036d7:	78 11                	js     8036ea <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8036d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036dc:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8036e2:	39 10                	cmp    %edx,(%eax)
  8036e4:	0f 94 c0             	sete   %al
  8036e7:	0f b6 c0             	movzbl %al,%eax
}
  8036ea:	c9                   	leave  
  8036eb:	c3                   	ret    

008036ec <opencons>:

int
opencons(void)
{
  8036ec:	55                   	push   %ebp
  8036ed:	89 e5                	mov    %esp,%ebp
  8036ef:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8036f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036f5:	50                   	push   %eax
  8036f6:	e8 05 f3 ff ff       	call   802a00 <fd_alloc>
  8036fb:	83 c4 10             	add    $0x10,%esp
		return r;
  8036fe:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803700:	85 c0                	test   %eax,%eax
  803702:	78 3e                	js     803742 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803704:	83 ec 04             	sub    $0x4,%esp
  803707:	68 07 04 00 00       	push   $0x407
  80370c:	ff 75 f4             	pushl  -0xc(%ebp)
  80370f:	6a 00                	push   $0x0
  803711:	e8 4b ef ff ff       	call   802661 <sys_page_alloc>
  803716:	83 c4 10             	add    $0x10,%esp
		return r;
  803719:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80371b:	85 c0                	test   %eax,%eax
  80371d:	78 23                	js     803742 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80371f:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803728:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80372a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80372d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803734:	83 ec 0c             	sub    $0xc,%esp
  803737:	50                   	push   %eax
  803738:	e8 9c f2 ff ff       	call   8029d9 <fd2num>
  80373d:	89 c2                	mov    %eax,%edx
  80373f:	83 c4 10             	add    $0x10,%esp
}
  803742:	89 d0                	mov    %edx,%eax
  803744:	c9                   	leave  
  803745:	c3                   	ret    
  803746:	66 90                	xchg   %ax,%ax
  803748:	66 90                	xchg   %ax,%ax
  80374a:	66 90                	xchg   %ax,%ax
  80374c:	66 90                	xchg   %ax,%ax
  80374e:	66 90                	xchg   %ax,%ax

00803750 <__udivdi3>:
  803750:	55                   	push   %ebp
  803751:	57                   	push   %edi
  803752:	56                   	push   %esi
  803753:	53                   	push   %ebx
  803754:	83 ec 1c             	sub    $0x1c,%esp
  803757:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80375b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80375f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803763:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803767:	85 f6                	test   %esi,%esi
  803769:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80376d:	89 ca                	mov    %ecx,%edx
  80376f:	89 f8                	mov    %edi,%eax
  803771:	75 3d                	jne    8037b0 <__udivdi3+0x60>
  803773:	39 cf                	cmp    %ecx,%edi
  803775:	0f 87 c5 00 00 00    	ja     803840 <__udivdi3+0xf0>
  80377b:	85 ff                	test   %edi,%edi
  80377d:	89 fd                	mov    %edi,%ebp
  80377f:	75 0b                	jne    80378c <__udivdi3+0x3c>
  803781:	b8 01 00 00 00       	mov    $0x1,%eax
  803786:	31 d2                	xor    %edx,%edx
  803788:	f7 f7                	div    %edi
  80378a:	89 c5                	mov    %eax,%ebp
  80378c:	89 c8                	mov    %ecx,%eax
  80378e:	31 d2                	xor    %edx,%edx
  803790:	f7 f5                	div    %ebp
  803792:	89 c1                	mov    %eax,%ecx
  803794:	89 d8                	mov    %ebx,%eax
  803796:	89 cf                	mov    %ecx,%edi
  803798:	f7 f5                	div    %ebp
  80379a:	89 c3                	mov    %eax,%ebx
  80379c:	89 d8                	mov    %ebx,%eax
  80379e:	89 fa                	mov    %edi,%edx
  8037a0:	83 c4 1c             	add    $0x1c,%esp
  8037a3:	5b                   	pop    %ebx
  8037a4:	5e                   	pop    %esi
  8037a5:	5f                   	pop    %edi
  8037a6:	5d                   	pop    %ebp
  8037a7:	c3                   	ret    
  8037a8:	90                   	nop
  8037a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037b0:	39 ce                	cmp    %ecx,%esi
  8037b2:	77 74                	ja     803828 <__udivdi3+0xd8>
  8037b4:	0f bd fe             	bsr    %esi,%edi
  8037b7:	83 f7 1f             	xor    $0x1f,%edi
  8037ba:	0f 84 98 00 00 00    	je     803858 <__udivdi3+0x108>
  8037c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8037c5:	89 f9                	mov    %edi,%ecx
  8037c7:	89 c5                	mov    %eax,%ebp
  8037c9:	29 fb                	sub    %edi,%ebx
  8037cb:	d3 e6                	shl    %cl,%esi
  8037cd:	89 d9                	mov    %ebx,%ecx
  8037cf:	d3 ed                	shr    %cl,%ebp
  8037d1:	89 f9                	mov    %edi,%ecx
  8037d3:	d3 e0                	shl    %cl,%eax
  8037d5:	09 ee                	or     %ebp,%esi
  8037d7:	89 d9                	mov    %ebx,%ecx
  8037d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8037dd:	89 d5                	mov    %edx,%ebp
  8037df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8037e3:	d3 ed                	shr    %cl,%ebp
  8037e5:	89 f9                	mov    %edi,%ecx
  8037e7:	d3 e2                	shl    %cl,%edx
  8037e9:	89 d9                	mov    %ebx,%ecx
  8037eb:	d3 e8                	shr    %cl,%eax
  8037ed:	09 c2                	or     %eax,%edx
  8037ef:	89 d0                	mov    %edx,%eax
  8037f1:	89 ea                	mov    %ebp,%edx
  8037f3:	f7 f6                	div    %esi
  8037f5:	89 d5                	mov    %edx,%ebp
  8037f7:	89 c3                	mov    %eax,%ebx
  8037f9:	f7 64 24 0c          	mull   0xc(%esp)
  8037fd:	39 d5                	cmp    %edx,%ebp
  8037ff:	72 10                	jb     803811 <__udivdi3+0xc1>
  803801:	8b 74 24 08          	mov    0x8(%esp),%esi
  803805:	89 f9                	mov    %edi,%ecx
  803807:	d3 e6                	shl    %cl,%esi
  803809:	39 c6                	cmp    %eax,%esi
  80380b:	73 07                	jae    803814 <__udivdi3+0xc4>
  80380d:	39 d5                	cmp    %edx,%ebp
  80380f:	75 03                	jne    803814 <__udivdi3+0xc4>
  803811:	83 eb 01             	sub    $0x1,%ebx
  803814:	31 ff                	xor    %edi,%edi
  803816:	89 d8                	mov    %ebx,%eax
  803818:	89 fa                	mov    %edi,%edx
  80381a:	83 c4 1c             	add    $0x1c,%esp
  80381d:	5b                   	pop    %ebx
  80381e:	5e                   	pop    %esi
  80381f:	5f                   	pop    %edi
  803820:	5d                   	pop    %ebp
  803821:	c3                   	ret    
  803822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803828:	31 ff                	xor    %edi,%edi
  80382a:	31 db                	xor    %ebx,%ebx
  80382c:	89 d8                	mov    %ebx,%eax
  80382e:	89 fa                	mov    %edi,%edx
  803830:	83 c4 1c             	add    $0x1c,%esp
  803833:	5b                   	pop    %ebx
  803834:	5e                   	pop    %esi
  803835:	5f                   	pop    %edi
  803836:	5d                   	pop    %ebp
  803837:	c3                   	ret    
  803838:	90                   	nop
  803839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803840:	89 d8                	mov    %ebx,%eax
  803842:	f7 f7                	div    %edi
  803844:	31 ff                	xor    %edi,%edi
  803846:	89 c3                	mov    %eax,%ebx
  803848:	89 d8                	mov    %ebx,%eax
  80384a:	89 fa                	mov    %edi,%edx
  80384c:	83 c4 1c             	add    $0x1c,%esp
  80384f:	5b                   	pop    %ebx
  803850:	5e                   	pop    %esi
  803851:	5f                   	pop    %edi
  803852:	5d                   	pop    %ebp
  803853:	c3                   	ret    
  803854:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803858:	39 ce                	cmp    %ecx,%esi
  80385a:	72 0c                	jb     803868 <__udivdi3+0x118>
  80385c:	31 db                	xor    %ebx,%ebx
  80385e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803862:	0f 87 34 ff ff ff    	ja     80379c <__udivdi3+0x4c>
  803868:	bb 01 00 00 00       	mov    $0x1,%ebx
  80386d:	e9 2a ff ff ff       	jmp    80379c <__udivdi3+0x4c>
  803872:	66 90                	xchg   %ax,%ax
  803874:	66 90                	xchg   %ax,%ax
  803876:	66 90                	xchg   %ax,%ax
  803878:	66 90                	xchg   %ax,%ax
  80387a:	66 90                	xchg   %ax,%ax
  80387c:	66 90                	xchg   %ax,%ax
  80387e:	66 90                	xchg   %ax,%ax

00803880 <__umoddi3>:
  803880:	55                   	push   %ebp
  803881:	57                   	push   %edi
  803882:	56                   	push   %esi
  803883:	53                   	push   %ebx
  803884:	83 ec 1c             	sub    $0x1c,%esp
  803887:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80388b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80388f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803893:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803897:	85 d2                	test   %edx,%edx
  803899:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80389d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8038a1:	89 f3                	mov    %esi,%ebx
  8038a3:	89 3c 24             	mov    %edi,(%esp)
  8038a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8038aa:	75 1c                	jne    8038c8 <__umoddi3+0x48>
  8038ac:	39 f7                	cmp    %esi,%edi
  8038ae:	76 50                	jbe    803900 <__umoddi3+0x80>
  8038b0:	89 c8                	mov    %ecx,%eax
  8038b2:	89 f2                	mov    %esi,%edx
  8038b4:	f7 f7                	div    %edi
  8038b6:	89 d0                	mov    %edx,%eax
  8038b8:	31 d2                	xor    %edx,%edx
  8038ba:	83 c4 1c             	add    $0x1c,%esp
  8038bd:	5b                   	pop    %ebx
  8038be:	5e                   	pop    %esi
  8038bf:	5f                   	pop    %edi
  8038c0:	5d                   	pop    %ebp
  8038c1:	c3                   	ret    
  8038c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8038c8:	39 f2                	cmp    %esi,%edx
  8038ca:	89 d0                	mov    %edx,%eax
  8038cc:	77 52                	ja     803920 <__umoddi3+0xa0>
  8038ce:	0f bd ea             	bsr    %edx,%ebp
  8038d1:	83 f5 1f             	xor    $0x1f,%ebp
  8038d4:	75 5a                	jne    803930 <__umoddi3+0xb0>
  8038d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8038da:	0f 82 e0 00 00 00    	jb     8039c0 <__umoddi3+0x140>
  8038e0:	39 0c 24             	cmp    %ecx,(%esp)
  8038e3:	0f 86 d7 00 00 00    	jbe    8039c0 <__umoddi3+0x140>
  8038e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8038ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8038f1:	83 c4 1c             	add    $0x1c,%esp
  8038f4:	5b                   	pop    %ebx
  8038f5:	5e                   	pop    %esi
  8038f6:	5f                   	pop    %edi
  8038f7:	5d                   	pop    %ebp
  8038f8:	c3                   	ret    
  8038f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803900:	85 ff                	test   %edi,%edi
  803902:	89 fd                	mov    %edi,%ebp
  803904:	75 0b                	jne    803911 <__umoddi3+0x91>
  803906:	b8 01 00 00 00       	mov    $0x1,%eax
  80390b:	31 d2                	xor    %edx,%edx
  80390d:	f7 f7                	div    %edi
  80390f:	89 c5                	mov    %eax,%ebp
  803911:	89 f0                	mov    %esi,%eax
  803913:	31 d2                	xor    %edx,%edx
  803915:	f7 f5                	div    %ebp
  803917:	89 c8                	mov    %ecx,%eax
  803919:	f7 f5                	div    %ebp
  80391b:	89 d0                	mov    %edx,%eax
  80391d:	eb 99                	jmp    8038b8 <__umoddi3+0x38>
  80391f:	90                   	nop
  803920:	89 c8                	mov    %ecx,%eax
  803922:	89 f2                	mov    %esi,%edx
  803924:	83 c4 1c             	add    $0x1c,%esp
  803927:	5b                   	pop    %ebx
  803928:	5e                   	pop    %esi
  803929:	5f                   	pop    %edi
  80392a:	5d                   	pop    %ebp
  80392b:	c3                   	ret    
  80392c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803930:	8b 34 24             	mov    (%esp),%esi
  803933:	bf 20 00 00 00       	mov    $0x20,%edi
  803938:	89 e9                	mov    %ebp,%ecx
  80393a:	29 ef                	sub    %ebp,%edi
  80393c:	d3 e0                	shl    %cl,%eax
  80393e:	89 f9                	mov    %edi,%ecx
  803940:	89 f2                	mov    %esi,%edx
  803942:	d3 ea                	shr    %cl,%edx
  803944:	89 e9                	mov    %ebp,%ecx
  803946:	09 c2                	or     %eax,%edx
  803948:	89 d8                	mov    %ebx,%eax
  80394a:	89 14 24             	mov    %edx,(%esp)
  80394d:	89 f2                	mov    %esi,%edx
  80394f:	d3 e2                	shl    %cl,%edx
  803951:	89 f9                	mov    %edi,%ecx
  803953:	89 54 24 04          	mov    %edx,0x4(%esp)
  803957:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80395b:	d3 e8                	shr    %cl,%eax
  80395d:	89 e9                	mov    %ebp,%ecx
  80395f:	89 c6                	mov    %eax,%esi
  803961:	d3 e3                	shl    %cl,%ebx
  803963:	89 f9                	mov    %edi,%ecx
  803965:	89 d0                	mov    %edx,%eax
  803967:	d3 e8                	shr    %cl,%eax
  803969:	89 e9                	mov    %ebp,%ecx
  80396b:	09 d8                	or     %ebx,%eax
  80396d:	89 d3                	mov    %edx,%ebx
  80396f:	89 f2                	mov    %esi,%edx
  803971:	f7 34 24             	divl   (%esp)
  803974:	89 d6                	mov    %edx,%esi
  803976:	d3 e3                	shl    %cl,%ebx
  803978:	f7 64 24 04          	mull   0x4(%esp)
  80397c:	39 d6                	cmp    %edx,%esi
  80397e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803982:	89 d1                	mov    %edx,%ecx
  803984:	89 c3                	mov    %eax,%ebx
  803986:	72 08                	jb     803990 <__umoddi3+0x110>
  803988:	75 11                	jne    80399b <__umoddi3+0x11b>
  80398a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80398e:	73 0b                	jae    80399b <__umoddi3+0x11b>
  803990:	2b 44 24 04          	sub    0x4(%esp),%eax
  803994:	1b 14 24             	sbb    (%esp),%edx
  803997:	89 d1                	mov    %edx,%ecx
  803999:	89 c3                	mov    %eax,%ebx
  80399b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80399f:	29 da                	sub    %ebx,%edx
  8039a1:	19 ce                	sbb    %ecx,%esi
  8039a3:	89 f9                	mov    %edi,%ecx
  8039a5:	89 f0                	mov    %esi,%eax
  8039a7:	d3 e0                	shl    %cl,%eax
  8039a9:	89 e9                	mov    %ebp,%ecx
  8039ab:	d3 ea                	shr    %cl,%edx
  8039ad:	89 e9                	mov    %ebp,%ecx
  8039af:	d3 ee                	shr    %cl,%esi
  8039b1:	09 d0                	or     %edx,%eax
  8039b3:	89 f2                	mov    %esi,%edx
  8039b5:	83 c4 1c             	add    $0x1c,%esp
  8039b8:	5b                   	pop    %ebx
  8039b9:	5e                   	pop    %esi
  8039ba:	5f                   	pop    %edi
  8039bb:	5d                   	pop    %ebp
  8039bc:	c3                   	ret    
  8039bd:	8d 76 00             	lea    0x0(%esi),%esi
  8039c0:	29 f9                	sub    %edi,%ecx
  8039c2:	19 d6                	sbb    %edx,%esi
  8039c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8039c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8039cc:	e9 18 ff ff ff       	jmp    8038e9 <__umoddi3+0x69>
