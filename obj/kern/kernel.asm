
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 ae 21 f0 00 	cmpl   $0x0,0xf021ae80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 ae 21 f0    	mov    %esi,0xf021ae80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 31 63 00 00       	call   f0106392 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 6a 10 f0       	push   $0xf0106a20
f010006d:	e8 03 3c 00 00       	call   f0103c75 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 d3 3b 00 00       	call   f0103c4f <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 ff 7d 10 f0 	movl   $0xf0107dff,(%esp)
f0100083:	e8 ed 3b 00 00       	call   f0103c75 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 da 0c 00 00       	call   f0100d6f <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 10             	sub    $0x10,%esp
	cprintf("1\n");
f01000a1:	68 8c 6a 10 f0       	push   $0xf0106a8c
f01000a6:	e8 ca 3b 00 00       	call   f0103c75 <cprintf>
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000ab:	83 c4 0c             	add    $0xc,%esp
f01000ae:	b8 08 c0 25 f0       	mov    $0xf025c008,%eax
f01000b3:	2d 34 91 21 f0       	sub    $0xf0219134,%eax
f01000b8:	50                   	push   %eax
f01000b9:	6a 00                	push   $0x0
f01000bb:	68 34 91 21 f0       	push   $0xf0219134
f01000c0:	e8 34 5c 00 00       	call   f0105cf9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 96 05 00 00       	call   f0100660 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	83 c4 08             	add    $0x8,%esp
f01000cd:	68 ac 1a 00 00       	push   $0x1aac
f01000d2:	68 8f 6a 10 f0       	push   $0xf0106a8f
f01000d7:	e8 99 3b 00 00       	call   f0103c75 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000dc:	e8 86 17 00 00       	call   f0101867 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000e1:	e8 e5 33 00 00       	call   f01034cb <env_init>
	trap_init();
f01000e6:	e8 81 3c 00 00       	call   f0103d6c <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000eb:	e8 98 5f 00 00       	call   f0106088 <mp_init>
	lapic_init();
f01000f0:	e8 b8 62 00 00       	call   f01063ad <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000f5:	e8 99 3a 00 00       	call   f0103b93 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000fa:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100101:	e8 fa 64 00 00       	call   f0106600 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100106:	83 c4 10             	add    $0x10,%esp
f0100109:	83 3d 88 ae 21 f0 07 	cmpl   $0x7,0xf021ae88
f0100110:	77 16                	ja     f0100128 <i386_init+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100112:	68 00 70 00 00       	push   $0x7000
f0100117:	68 44 6a 10 f0       	push   $0xf0106a44
f010011c:	6a 5a                	push   $0x5a
f010011e:	68 aa 6a 10 f0       	push   $0xf0106aaa
f0100123:	e8 18 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100128:	83 ec 04             	sub    $0x4,%esp
f010012b:	b8 ee 5f 10 f0       	mov    $0xf0105fee,%eax
f0100130:	2d 74 5f 10 f0       	sub    $0xf0105f74,%eax
f0100135:	50                   	push   %eax
f0100136:	68 74 5f 10 f0       	push   $0xf0105f74
f010013b:	68 00 70 00 f0       	push   $0xf0007000
f0100140:	e8 01 5c 00 00       	call   f0105d46 <memmove>
f0100145:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100148:	bb 20 b0 21 f0       	mov    $0xf021b020,%ebx
f010014d:	eb 4d                	jmp    f010019c <i386_init+0x102>
		if (c == cpus + cpunum())  // We've started already.
f010014f:	e8 3e 62 00 00       	call   f0106392 <cpunum>
f0100154:	6b c0 74             	imul   $0x74,%eax,%eax
f0100157:	05 20 b0 21 f0       	add    $0xf021b020,%eax
f010015c:	39 c3                	cmp    %eax,%ebx
f010015e:	74 39                	je     f0100199 <i386_init+0xff>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100160:	89 d8                	mov    %ebx,%eax
f0100162:	2d 20 b0 21 f0       	sub    $0xf021b020,%eax
f0100167:	c1 f8 02             	sar    $0x2,%eax
f010016a:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100170:	c1 e0 0f             	shl    $0xf,%eax
f0100173:	05 00 40 22 f0       	add    $0xf0224000,%eax
f0100178:	a3 84 ae 21 f0       	mov    %eax,0xf021ae84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017d:	83 ec 08             	sub    $0x8,%esp
f0100180:	68 00 70 00 00       	push   $0x7000
f0100185:	0f b6 03             	movzbl (%ebx),%eax
f0100188:	50                   	push   %eax
f0100189:	e8 6d 63 00 00       	call   f01064fb <lapic_startap>
f010018e:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100191:	8b 43 04             	mov    0x4(%ebx),%eax
f0100194:	83 f8 01             	cmp    $0x1,%eax
f0100197:	75 f8                	jne    f0100191 <i386_init+0xf7>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100199:	83 c3 74             	add    $0x74,%ebx
f010019c:	6b 05 c4 b3 21 f0 74 	imul   $0x74,0xf021b3c4,%eax
f01001a3:	05 20 b0 21 f0       	add    $0xf021b020,%eax
f01001a8:	39 c3                	cmp    %eax,%ebx
f01001aa:	72 a3                	jb     f010014f <i386_init+0xb5>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001ac:	83 ec 08             	sub    $0x8,%esp
f01001af:	6a 01                	push   $0x1
f01001b1:	68 78 23 1d f0       	push   $0xf01d2378
f01001b6:	e8 c7 34 00 00       	call   f0103682 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f01001bb:	83 c4 08             	add    $0x8,%esp
f01001be:	6a 00                	push   $0x0
f01001c0:	68 d8 d4 1c f0       	push   $0xf01cd4d8
f01001c5:	e8 b8 34 00 00       	call   f0103682 <env_create>
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001ca:	e8 35 04 00 00       	call   f0100604 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001cf:	e8 23 48 00 00       	call   f01049f7 <sched_yield>

f01001d4 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001d4:	55                   	push   %ebp
f01001d5:	89 e5                	mov    %esp,%ebp
f01001d7:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001da:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001e4:	77 12                	ja     f01001f8 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001e6:	50                   	push   %eax
f01001e7:	68 68 6a 10 f0       	push   $0xf0106a68
f01001ec:	6a 71                	push   $0x71
f01001ee:	68 aa 6a 10 f0       	push   $0xf0106aaa
f01001f3:	e8 48 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001f8:	05 00 00 00 10       	add    $0x10000000,%eax
f01001fd:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100200:	e8 8d 61 00 00       	call   f0106392 <cpunum>
f0100205:	83 ec 08             	sub    $0x8,%esp
f0100208:	50                   	push   %eax
f0100209:	68 b6 6a 10 f0       	push   $0xf0106ab6
f010020e:	e8 62 3a 00 00       	call   f0103c75 <cprintf>

	lapic_init();
f0100213:	e8 95 61 00 00       	call   f01063ad <lapic_init>
	env_init_percpu();
f0100218:	e8 7e 32 00 00       	call   f010349b <env_init_percpu>
	trap_init_percpu();
f010021d:	e8 67 3a 00 00       	call   f0103c89 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100222:	e8 6b 61 00 00       	call   f0106392 <cpunum>
f0100227:	6b d0 74             	imul   $0x74,%eax,%edx
f010022a:	81 c2 20 b0 21 f0    	add    $0xf021b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100230:	b8 01 00 00 00       	mov    $0x1,%eax
f0100235:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100239:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100240:	e8 bb 63 00 00       	call   f0106600 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100245:	e8 ad 47 00 00       	call   f01049f7 <sched_yield>

f010024a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010024a:	55                   	push   %ebp
f010024b:	89 e5                	mov    %esp,%ebp
f010024d:	53                   	push   %ebx
f010024e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100251:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100254:	ff 75 0c             	pushl  0xc(%ebp)
f0100257:	ff 75 08             	pushl  0x8(%ebp)
f010025a:	68 cc 6a 10 f0       	push   $0xf0106acc
f010025f:	e8 11 3a 00 00       	call   f0103c75 <cprintf>
	vcprintf(fmt, ap);
f0100264:	83 c4 08             	add    $0x8,%esp
f0100267:	53                   	push   %ebx
f0100268:	ff 75 10             	pushl  0x10(%ebp)
f010026b:	e8 df 39 00 00       	call   f0103c4f <vcprintf>
	cprintf("\n");
f0100270:	c7 04 24 ff 7d 10 f0 	movl   $0xf0107dff,(%esp)
f0100277:	e8 f9 39 00 00       	call   f0103c75 <cprintf>
	va_end(ap);
}
f010027c:	83 c4 10             	add    $0x10,%esp
f010027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100282:	c9                   	leave  
f0100283:	c3                   	ret    

f0100284 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100284:	55                   	push   %ebp
f0100285:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100287:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010028c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010028d:	a8 01                	test   $0x1,%al
f010028f:	74 0b                	je     f010029c <serial_proc_data+0x18>
f0100291:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100296:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100297:	0f b6 c0             	movzbl %al,%eax
f010029a:	eb 05                	jmp    f01002a1 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010029c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002a1:	5d                   	pop    %ebp
f01002a2:	c3                   	ret    

f01002a3 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002a3:	55                   	push   %ebp
f01002a4:	89 e5                	mov    %esp,%ebp
f01002a6:	53                   	push   %ebx
f01002a7:	83 ec 04             	sub    $0x4,%esp
f01002aa:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002ac:	eb 2b                	jmp    f01002d9 <cons_intr+0x36>
		if (c == 0)
f01002ae:	85 c0                	test   %eax,%eax
f01002b0:	74 27                	je     f01002d9 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002b2:	8b 0d 24 a2 21 f0    	mov    0xf021a224,%ecx
f01002b8:	8d 51 01             	lea    0x1(%ecx),%edx
f01002bb:	89 15 24 a2 21 f0    	mov    %edx,0xf021a224
f01002c1:	88 81 20 a0 21 f0    	mov    %al,-0xfde5fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002c7:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002cd:	75 0a                	jne    f01002d9 <cons_intr+0x36>
			cons.wpos = 0;
f01002cf:	c7 05 24 a2 21 f0 00 	movl   $0x0,0xf021a224
f01002d6:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d9:	ff d3                	call   *%ebx
f01002db:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002de:	75 ce                	jne    f01002ae <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002e0:	83 c4 04             	add    $0x4,%esp
f01002e3:	5b                   	pop    %ebx
f01002e4:	5d                   	pop    %ebp
f01002e5:	c3                   	ret    

f01002e6 <kbd_proc_data>:
f01002e6:	ba 64 00 00 00       	mov    $0x64,%edx
f01002eb:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002ec:	a8 01                	test   $0x1,%al
f01002ee:	0f 84 f8 00 00 00    	je     f01003ec <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002f4:	a8 20                	test   $0x20,%al
f01002f6:	0f 85 f6 00 00 00    	jne    f01003f2 <kbd_proc_data+0x10c>
f01002fc:	ba 60 00 00 00       	mov    $0x60,%edx
f0100301:	ec                   	in     (%dx),%al
f0100302:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100304:	3c e0                	cmp    $0xe0,%al
f0100306:	75 0d                	jne    f0100315 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100308:	83 0d 00 a0 21 f0 40 	orl    $0x40,0xf021a000
		return 0;
f010030f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100314:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100315:	55                   	push   %ebp
f0100316:	89 e5                	mov    %esp,%ebp
f0100318:	53                   	push   %ebx
f0100319:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010031c:	84 c0                	test   %al,%al
f010031e:	79 36                	jns    f0100356 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100320:	8b 0d 00 a0 21 f0    	mov    0xf021a000,%ecx
f0100326:	89 cb                	mov    %ecx,%ebx
f0100328:	83 e3 40             	and    $0x40,%ebx
f010032b:	83 e0 7f             	and    $0x7f,%eax
f010032e:	85 db                	test   %ebx,%ebx
f0100330:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100333:	0f b6 d2             	movzbl %dl,%edx
f0100336:	0f b6 82 40 6c 10 f0 	movzbl -0xfef93c0(%edx),%eax
f010033d:	83 c8 40             	or     $0x40,%eax
f0100340:	0f b6 c0             	movzbl %al,%eax
f0100343:	f7 d0                	not    %eax
f0100345:	21 c8                	and    %ecx,%eax
f0100347:	a3 00 a0 21 f0       	mov    %eax,0xf021a000
		return 0;
f010034c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100351:	e9 a4 00 00 00       	jmp    f01003fa <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100356:	8b 0d 00 a0 21 f0    	mov    0xf021a000,%ecx
f010035c:	f6 c1 40             	test   $0x40,%cl
f010035f:	74 0e                	je     f010036f <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100361:	83 c8 80             	or     $0xffffff80,%eax
f0100364:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100366:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100369:	89 0d 00 a0 21 f0    	mov    %ecx,0xf021a000
	}

	shift |= shiftcode[data];
f010036f:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100372:	0f b6 82 40 6c 10 f0 	movzbl -0xfef93c0(%edx),%eax
f0100379:	0b 05 00 a0 21 f0    	or     0xf021a000,%eax
f010037f:	0f b6 8a 40 6b 10 f0 	movzbl -0xfef94c0(%edx),%ecx
f0100386:	31 c8                	xor    %ecx,%eax
f0100388:	a3 00 a0 21 f0       	mov    %eax,0xf021a000

	c = charcode[shift & (CTL | SHIFT)][data];
f010038d:	89 c1                	mov    %eax,%ecx
f010038f:	83 e1 03             	and    $0x3,%ecx
f0100392:	8b 0c 8d 20 6b 10 f0 	mov    -0xfef94e0(,%ecx,4),%ecx
f0100399:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010039d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003a0:	a8 08                	test   $0x8,%al
f01003a2:	74 1b                	je     f01003bf <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01003a4:	89 da                	mov    %ebx,%edx
f01003a6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003a9:	83 f9 19             	cmp    $0x19,%ecx
f01003ac:	77 05                	ja     f01003b3 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003ae:	83 eb 20             	sub    $0x20,%ebx
f01003b1:	eb 0c                	jmp    f01003bf <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003b3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003b6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003b9:	83 fa 19             	cmp    $0x19,%edx
f01003bc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003bf:	f7 d0                	not    %eax
f01003c1:	a8 06                	test   $0x6,%al
f01003c3:	75 33                	jne    f01003f8 <kbd_proc_data+0x112>
f01003c5:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003cb:	75 2b                	jne    f01003f8 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003cd:	83 ec 0c             	sub    $0xc,%esp
f01003d0:	68 e6 6a 10 f0       	push   $0xf0106ae6
f01003d5:	e8 9b 38 00 00       	call   f0103c75 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003da:	ba 92 00 00 00       	mov    $0x92,%edx
f01003df:	b8 03 00 00 00       	mov    $0x3,%eax
f01003e4:	ee                   	out    %al,(%dx)
f01003e5:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003e8:	89 d8                	mov    %ebx,%eax
f01003ea:	eb 0e                	jmp    f01003fa <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003f1:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003f7:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f8:	89 d8                	mov    %ebx,%eax
}
f01003fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003fd:	c9                   	leave  
f01003fe:	c3                   	ret    

f01003ff <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003ff:	55                   	push   %ebp
f0100400:	89 e5                	mov    %esp,%ebp
f0100402:	57                   	push   %edi
f0100403:	56                   	push   %esi
f0100404:	53                   	push   %ebx
f0100405:	83 ec 1c             	sub    $0x1c,%esp
f0100408:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010040a:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040f:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100414:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100419:	eb 09                	jmp    f0100424 <cons_putc+0x25>
f010041b:	89 ca                	mov    %ecx,%edx
f010041d:	ec                   	in     (%dx),%al
f010041e:	ec                   	in     (%dx),%al
f010041f:	ec                   	in     (%dx),%al
f0100420:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100421:	83 c3 01             	add    $0x1,%ebx
f0100424:	89 f2                	mov    %esi,%edx
f0100426:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100427:	a8 20                	test   $0x20,%al
f0100429:	75 08                	jne    f0100433 <cons_putc+0x34>
f010042b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100431:	7e e8                	jle    f010041b <cons_putc+0x1c>
f0100433:	89 f8                	mov    %edi,%eax
f0100435:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100438:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010043d:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010043e:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100443:	be 79 03 00 00       	mov    $0x379,%esi
f0100448:	b9 84 00 00 00       	mov    $0x84,%ecx
f010044d:	eb 09                	jmp    f0100458 <cons_putc+0x59>
f010044f:	89 ca                	mov    %ecx,%edx
f0100451:	ec                   	in     (%dx),%al
f0100452:	ec                   	in     (%dx),%al
f0100453:	ec                   	in     (%dx),%al
f0100454:	ec                   	in     (%dx),%al
f0100455:	83 c3 01             	add    $0x1,%ebx
f0100458:	89 f2                	mov    %esi,%edx
f010045a:	ec                   	in     (%dx),%al
f010045b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100461:	7f 04                	jg     f0100467 <cons_putc+0x68>
f0100463:	84 c0                	test   %al,%al
f0100465:	79 e8                	jns    f010044f <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100467:	ba 78 03 00 00       	mov    $0x378,%edx
f010046c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100470:	ee                   	out    %al,(%dx)
f0100471:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100476:	b8 0d 00 00 00       	mov    $0xd,%eax
f010047b:	ee                   	out    %al,(%dx)
f010047c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100481:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100482:	89 fa                	mov    %edi,%edx
f0100484:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010048a:	89 f8                	mov    %edi,%eax
f010048c:	80 cc 07             	or     $0x7,%ah
f010048f:	85 d2                	test   %edx,%edx
f0100491:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100494:	89 f8                	mov    %edi,%eax
f0100496:	0f b6 c0             	movzbl %al,%eax
f0100499:	83 f8 09             	cmp    $0x9,%eax
f010049c:	74 74                	je     f0100512 <cons_putc+0x113>
f010049e:	83 f8 09             	cmp    $0x9,%eax
f01004a1:	7f 0a                	jg     f01004ad <cons_putc+0xae>
f01004a3:	83 f8 08             	cmp    $0x8,%eax
f01004a6:	74 14                	je     f01004bc <cons_putc+0xbd>
f01004a8:	e9 99 00 00 00       	jmp    f0100546 <cons_putc+0x147>
f01004ad:	83 f8 0a             	cmp    $0xa,%eax
f01004b0:	74 3a                	je     f01004ec <cons_putc+0xed>
f01004b2:	83 f8 0d             	cmp    $0xd,%eax
f01004b5:	74 3d                	je     f01004f4 <cons_putc+0xf5>
f01004b7:	e9 8a 00 00 00       	jmp    f0100546 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004bc:	0f b7 05 28 a2 21 f0 	movzwl 0xf021a228,%eax
f01004c3:	66 85 c0             	test   %ax,%ax
f01004c6:	0f 84 e6 00 00 00    	je     f01005b2 <cons_putc+0x1b3>
			crt_pos--;
f01004cc:	83 e8 01             	sub    $0x1,%eax
f01004cf:	66 a3 28 a2 21 f0    	mov    %ax,0xf021a228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004d5:	0f b7 c0             	movzwl %ax,%eax
f01004d8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004dd:	83 cf 20             	or     $0x20,%edi
f01004e0:	8b 15 2c a2 21 f0    	mov    0xf021a22c,%edx
f01004e6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004ea:	eb 78                	jmp    f0100564 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004ec:	66 83 05 28 a2 21 f0 	addw   $0x50,0xf021a228
f01004f3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004f4:	0f b7 05 28 a2 21 f0 	movzwl 0xf021a228,%eax
f01004fb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100501:	c1 e8 16             	shr    $0x16,%eax
f0100504:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100507:	c1 e0 04             	shl    $0x4,%eax
f010050a:	66 a3 28 a2 21 f0    	mov    %ax,0xf021a228
f0100510:	eb 52                	jmp    f0100564 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100512:	b8 20 00 00 00       	mov    $0x20,%eax
f0100517:	e8 e3 fe ff ff       	call   f01003ff <cons_putc>
		cons_putc(' ');
f010051c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100521:	e8 d9 fe ff ff       	call   f01003ff <cons_putc>
		cons_putc(' ');
f0100526:	b8 20 00 00 00       	mov    $0x20,%eax
f010052b:	e8 cf fe ff ff       	call   f01003ff <cons_putc>
		cons_putc(' ');
f0100530:	b8 20 00 00 00       	mov    $0x20,%eax
f0100535:	e8 c5 fe ff ff       	call   f01003ff <cons_putc>
		cons_putc(' ');
f010053a:	b8 20 00 00 00       	mov    $0x20,%eax
f010053f:	e8 bb fe ff ff       	call   f01003ff <cons_putc>
f0100544:	eb 1e                	jmp    f0100564 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100546:	0f b7 05 28 a2 21 f0 	movzwl 0xf021a228,%eax
f010054d:	8d 50 01             	lea    0x1(%eax),%edx
f0100550:	66 89 15 28 a2 21 f0 	mov    %dx,0xf021a228
f0100557:	0f b7 c0             	movzwl %ax,%eax
f010055a:	8b 15 2c a2 21 f0    	mov    0xf021a22c,%edx
f0100560:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100564:	66 81 3d 28 a2 21 f0 	cmpw   $0x7cf,0xf021a228
f010056b:	cf 07 
f010056d:	76 43                	jbe    f01005b2 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010056f:	a1 2c a2 21 f0       	mov    0xf021a22c,%eax
f0100574:	83 ec 04             	sub    $0x4,%esp
f0100577:	68 00 0f 00 00       	push   $0xf00
f010057c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100582:	52                   	push   %edx
f0100583:	50                   	push   %eax
f0100584:	e8 bd 57 00 00       	call   f0105d46 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100589:	8b 15 2c a2 21 f0    	mov    0xf021a22c,%edx
f010058f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100595:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010059b:	83 c4 10             	add    $0x10,%esp
f010059e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005a3:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a6:	39 d0                	cmp    %edx,%eax
f01005a8:	75 f4                	jne    f010059e <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005aa:	66 83 2d 28 a2 21 f0 	subw   $0x50,0xf021a228
f01005b1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005b2:	8b 0d 30 a2 21 f0    	mov    0xf021a230,%ecx
f01005b8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005bd:	89 ca                	mov    %ecx,%edx
f01005bf:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005c0:	0f b7 1d 28 a2 21 f0 	movzwl 0xf021a228,%ebx
f01005c7:	8d 71 01             	lea    0x1(%ecx),%esi
f01005ca:	89 d8                	mov    %ebx,%eax
f01005cc:	66 c1 e8 08          	shr    $0x8,%ax
f01005d0:	89 f2                	mov    %esi,%edx
f01005d2:	ee                   	out    %al,(%dx)
f01005d3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d8:	89 ca                	mov    %ecx,%edx
f01005da:	ee                   	out    %al,(%dx)
f01005db:	89 d8                	mov    %ebx,%eax
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005e3:	5b                   	pop    %ebx
f01005e4:	5e                   	pop    %esi
f01005e5:	5f                   	pop    %edi
f01005e6:	5d                   	pop    %ebp
f01005e7:	c3                   	ret    

f01005e8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005e8:	80 3d 34 a2 21 f0 00 	cmpb   $0x0,0xf021a234
f01005ef:	74 11                	je     f0100602 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005f1:	55                   	push   %ebp
f01005f2:	89 e5                	mov    %esp,%ebp
f01005f4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005f7:	b8 84 02 10 f0       	mov    $0xf0100284,%eax
f01005fc:	e8 a2 fc ff ff       	call   f01002a3 <cons_intr>
}
f0100601:	c9                   	leave  
f0100602:	f3 c3                	repz ret 

f0100604 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010060a:	b8 e6 02 10 f0       	mov    $0xf01002e6,%eax
f010060f:	e8 8f fc ff ff       	call   f01002a3 <cons_intr>
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
f0100619:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010061c:	e8 c7 ff ff ff       	call   f01005e8 <serial_intr>
	kbd_intr();
f0100621:	e8 de ff ff ff       	call   f0100604 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100626:	a1 20 a2 21 f0       	mov    0xf021a220,%eax
f010062b:	3b 05 24 a2 21 f0    	cmp    0xf021a224,%eax
f0100631:	74 26                	je     f0100659 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100633:	8d 50 01             	lea    0x1(%eax),%edx
f0100636:	89 15 20 a2 21 f0    	mov    %edx,0xf021a220
f010063c:	0f b6 88 20 a0 21 f0 	movzbl -0xfde5fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100643:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100645:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010064b:	75 11                	jne    f010065e <cons_getc+0x48>
			cons.rpos = 0;
f010064d:	c7 05 20 a2 21 f0 00 	movl   $0x0,0xf021a220
f0100654:	00 00 00 
f0100657:	eb 05                	jmp    f010065e <cons_getc+0x48>
		return c;
	}
	return 0;
f0100659:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010065e:	c9                   	leave  
f010065f:	c3                   	ret    

f0100660 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
f0100663:	57                   	push   %edi
f0100664:	56                   	push   %esi
f0100665:	53                   	push   %ebx
f0100666:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100669:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100670:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100677:	5a a5 
	if (*cp != 0xA55A) {
f0100679:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100680:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100684:	74 11                	je     f0100697 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100686:	c7 05 30 a2 21 f0 b4 	movl   $0x3b4,0xf021a230
f010068d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100690:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100695:	eb 16                	jmp    f01006ad <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100697:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069e:	c7 05 30 a2 21 f0 d4 	movl   $0x3d4,0xf021a230
f01006a5:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a8:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006ad:	8b 3d 30 a2 21 f0    	mov    0xf021a230,%edi
f01006b3:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006b8:	89 fa                	mov    %edi,%edx
f01006ba:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006bb:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006be:	89 da                	mov    %ebx,%edx
f01006c0:	ec                   	in     (%dx),%al
f01006c1:	0f b6 c8             	movzbl %al,%ecx
f01006c4:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006cc:	89 fa                	mov    %edi,%edx
f01006ce:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cf:	89 da                	mov    %ebx,%edx
f01006d1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006d2:	89 35 2c a2 21 f0    	mov    %esi,0xf021a22c
	crt_pos = pos;
f01006d8:	0f b6 c0             	movzbl %al,%eax
f01006db:	09 c8                	or     %ecx,%eax
f01006dd:	66 a3 28 a2 21 f0    	mov    %ax,0xf021a228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006e3:	e8 1c ff ff ff       	call   f0100604 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006e8:	83 ec 0c             	sub    $0xc,%esp
f01006eb:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006f2:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006f7:	50                   	push   %eax
f01006f8:	e8 1e 34 00 00       	call   f0103b1b <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006fd:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100702:	b8 00 00 00 00       	mov    $0x0,%eax
f0100707:	89 f2                	mov    %esi,%edx
f0100709:	ee                   	out    %al,(%dx)
f010070a:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010070f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100714:	ee                   	out    %al,(%dx)
f0100715:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010071a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010071f:	89 da                	mov    %ebx,%edx
f0100721:	ee                   	out    %al,(%dx)
f0100722:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100727:	b8 00 00 00 00       	mov    $0x0,%eax
f010072c:	ee                   	out    %al,(%dx)
f010072d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100732:	b8 03 00 00 00       	mov    $0x3,%eax
f0100737:	ee                   	out    %al,(%dx)
f0100738:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010073d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100742:	ee                   	out    %al,(%dx)
f0100743:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100753:	ec                   	in     (%dx),%al
f0100754:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100756:	83 c4 10             	add    $0x10,%esp
f0100759:	3c ff                	cmp    $0xff,%al
f010075b:	0f 95 05 34 a2 21 f0 	setne  0xf021a234
f0100762:	89 f2                	mov    %esi,%edx
f0100764:	ec                   	in     (%dx),%al
f0100765:	89 da                	mov    %ebx,%edx
f0100767:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100768:	80 f9 ff             	cmp    $0xff,%cl
f010076b:	74 21                	je     f010078e <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f010076d:	83 ec 0c             	sub    $0xc,%esp
f0100770:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0100777:	25 ef ff 00 00       	and    $0xffef,%eax
f010077c:	50                   	push   %eax
f010077d:	e8 99 33 00 00       	call   f0103b1b <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100782:	83 c4 10             	add    $0x10,%esp
f0100785:	80 3d 34 a2 21 f0 00 	cmpb   $0x0,0xf021a234
f010078c:	75 10                	jne    f010079e <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010078e:	83 ec 0c             	sub    $0xc,%esp
f0100791:	68 f2 6a 10 f0       	push   $0xf0106af2
f0100796:	e8 da 34 00 00       	call   f0103c75 <cprintf>
f010079b:	83 c4 10             	add    $0x10,%esp
}
f010079e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a1:	5b                   	pop    %ebx
f01007a2:	5e                   	pop    %esi
f01007a3:	5f                   	pop    %edi
f01007a4:	5d                   	pop    %ebp
f01007a5:	c3                   	ret    

f01007a6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a6:	55                   	push   %ebp
f01007a7:	89 e5                	mov    %esp,%ebp
f01007a9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01007af:	e8 4b fc ff ff       	call   f01003ff <cons_putc>
}
f01007b4:	c9                   	leave  
f01007b5:	c3                   	ret    

f01007b6 <getchar>:

int
getchar(void)
{
f01007b6:	55                   	push   %ebp
f01007b7:	89 e5                	mov    %esp,%ebp
f01007b9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007bc:	e8 55 fe ff ff       	call   f0100616 <cons_getc>
f01007c1:	85 c0                	test   %eax,%eax
f01007c3:	74 f7                	je     f01007bc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c5:	c9                   	leave  
f01007c6:	c3                   	ret    

f01007c7 <iscons>:

int
iscons(int fdnum)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01007cf:	5d                   	pop    %ebp
f01007d0:	c3                   	ret    

f01007d1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007d1:	55                   	push   %ebp
f01007d2:	89 e5                	mov    %esp,%ebp
f01007d4:	56                   	push   %esi
f01007d5:	53                   	push   %ebx
f01007d6:	bb 64 71 10 f0       	mov    $0xf0107164,%ebx
f01007db:	be ac 71 10 f0       	mov    $0xf01071ac,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007e0:	83 ec 04             	sub    $0x4,%esp
f01007e3:	ff 33                	pushl  (%ebx)
f01007e5:	ff 73 fc             	pushl  -0x4(%ebx)
f01007e8:	68 40 6d 10 f0       	push   $0xf0106d40
f01007ed:	e8 83 34 00 00       	call   f0103c75 <cprintf>
f01007f2:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01007f5:	83 c4 10             	add    $0x10,%esp
f01007f8:	39 f3                	cmp    %esi,%ebx
f01007fa:	75 e4                	jne    f01007e0 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100801:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100804:	5b                   	pop    %ebx
f0100805:	5e                   	pop    %esi
f0100806:	5d                   	pop    %ebp
f0100807:	c3                   	ret    

f0100808 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100808:	55                   	push   %ebp
f0100809:	89 e5                	mov    %esp,%ebp
f010080b:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080e:	68 49 6d 10 f0       	push   $0xf0106d49
f0100813:	e8 5d 34 00 00       	call   f0103c75 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100818:	83 c4 08             	add    $0x8,%esp
f010081b:	68 0c 00 10 00       	push   $0x10000c
f0100820:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0100825:	e8 4b 34 00 00       	call   f0103c75 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082a:	83 c4 0c             	add    $0xc,%esp
f010082d:	68 0c 00 10 00       	push   $0x10000c
f0100832:	68 0c 00 10 f0       	push   $0xf010000c
f0100837:	68 e8 6e 10 f0       	push   $0xf0106ee8
f010083c:	e8 34 34 00 00       	call   f0103c75 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100841:	83 c4 0c             	add    $0xc,%esp
f0100844:	68 11 6a 10 00       	push   $0x106a11
f0100849:	68 11 6a 10 f0       	push   $0xf0106a11
f010084e:	68 0c 6f 10 f0       	push   $0xf0106f0c
f0100853:	e8 1d 34 00 00       	call   f0103c75 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100858:	83 c4 0c             	add    $0xc,%esp
f010085b:	68 34 91 21 00       	push   $0x219134
f0100860:	68 34 91 21 f0       	push   $0xf0219134
f0100865:	68 30 6f 10 f0       	push   $0xf0106f30
f010086a:	e8 06 34 00 00       	call   f0103c75 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086f:	83 c4 0c             	add    $0xc,%esp
f0100872:	68 08 c0 25 00       	push   $0x25c008
f0100877:	68 08 c0 25 f0       	push   $0xf025c008
f010087c:	68 54 6f 10 f0       	push   $0xf0106f54
f0100881:	e8 ef 33 00 00       	call   f0103c75 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100886:	b8 07 c4 25 f0       	mov    $0xf025c407,%eax
f010088b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100890:	83 c4 08             	add    $0x8,%esp
f0100893:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100898:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010089e:	85 c0                	test   %eax,%eax
f01008a0:	0f 48 c2             	cmovs  %edx,%eax
f01008a3:	c1 f8 0a             	sar    $0xa,%eax
f01008a6:	50                   	push   %eax
f01008a7:	68 78 6f 10 f0       	push   $0xf0106f78
f01008ac:	e8 c4 33 00 00       	call   f0103c75 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b6:	c9                   	leave  
f01008b7:	c3                   	ret    

f01008b8 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b8:	55                   	push   %ebp
f01008b9:	89 e5                	mov    %esp,%ebp
f01008bb:	57                   	push   %edi
f01008bc:	56                   	push   %esi
f01008bd:	53                   	push   %ebx
f01008be:	81 ec a8 00 00 00    	sub    $0xa8,%esp
	cprintf("Stack backtrace:\n");
f01008c4:	68 62 6d 10 f0       	push   $0xf0106d62
f01008c9:	e8 a7 33 00 00       	call   f0103c75 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ce:	89 ee                	mov    %ebp,%esi
	uint32_t ebp = read_ebp();
	while(ebp != 0)
f01008d0:	83 c4 10             	add    $0x10,%esp
f01008d3:	e9 c9 00 00 00       	jmp    f01009a1 <mon_backtrace+0xe9>
	{
		cprintf("  ebp %08x", ebp);
f01008d8:	83 ec 08             	sub    $0x8,%esp
f01008db:	56                   	push   %esi
f01008dc:	68 74 6d 10 f0       	push   $0xf0106d74
f01008e1:	e8 8f 33 00 00       	call   f0103c75 <cprintf>
		uint32_t addr = ebp + 4;
f01008e6:	8d 5e 04             	lea    0x4(%esi),%ebx
		uint32_t eip = *(int *)addr;
f01008e9:	8b 46 04             	mov    0x4(%esi),%eax
f01008ec:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		cprintf("  eip %08x", eip);
f01008f2:	83 c4 08             	add    $0x8,%esp
f01008f5:	50                   	push   %eax
f01008f6:	68 7f 6d 10 f0       	push   $0xf0106d7f
f01008fb:	e8 75 33 00 00       	call   f0103c75 <cprintf>
		cprintf("  args");
f0100900:	c7 04 24 8a 6d 10 f0 	movl   $0xf0106d8a,(%esp)
f0100907:	e8 69 33 00 00       	call   f0103c75 <cprintf>
f010090c:	8d 7e 18             	lea    0x18(%esi),%edi
f010090f:	83 c4 10             	add    $0x10,%esp
		for(int i = 0; i < 5; ++i)
		{
			addr = addr + 4;
f0100912:	83 c3 04             	add    $0x4,%ebx
			cprintf(" %08x", *(int *)addr);
f0100915:	83 ec 08             	sub    $0x8,%esp
f0100918:	ff 33                	pushl  (%ebx)
f010091a:	68 79 6d 10 f0       	push   $0xf0106d79
f010091f:	e8 51 33 00 00       	call   f0103c75 <cprintf>
		cprintf("  ebp %08x", ebp);
		uint32_t addr = ebp + 4;
		uint32_t eip = *(int *)addr;
		cprintf("  eip %08x", eip);
		cprintf("  args");
		for(int i = 0; i < 5; ++i)
f0100924:	83 c4 10             	add    $0x10,%esp
f0100927:	39 fb                	cmp    %edi,%ebx
f0100929:	75 e7                	jne    f0100912 <mon_backtrace+0x5a>
		{
			addr = addr + 4;
			cprintf(" %08x", *(int *)addr);
		}
		cprintf("\n");
f010092b:	83 ec 0c             	sub    $0xc,%esp
f010092e:	68 ff 7d 10 f0       	push   $0xf0107dff
f0100933:	e8 3d 33 00 00       	call   f0103c75 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100938:	83 c4 08             	add    $0x8,%esp
f010093b:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f0100941:	50                   	push   %eax
f0100942:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
f0100948:	e8 61 48 00 00       	call   f01051ae <debuginfo_eip>
		char funcname[100];
		int l = 0;
		for(; info.eip_fn_name[l] != ':'; ++l)
f010094d:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
f0100953:	83 c4 10             	add    $0x10,%esp
		}
		cprintf("\n");
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
		char funcname[100];
		int l = 0;
f0100956:	b8 00 00 00 00       	mov    $0x0,%eax
		for(; info.eip_fn_name[l] != ':'; ++l)
f010095b:	eb 07                	jmp    f0100964 <mon_backtrace+0xac>
			funcname[l] = info.eip_fn_name[l];
f010095d:	88 54 05 84          	mov    %dl,-0x7c(%ebp,%eax,1)
		cprintf("\n");
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
		char funcname[100];
		int l = 0;
		for(; info.eip_fn_name[l] != ':'; ++l)
f0100961:	83 c0 01             	add    $0x1,%eax
f0100964:	0f b6 14 01          	movzbl (%ecx,%eax,1),%edx
f0100968:	80 fa 3a             	cmp    $0x3a,%dl
f010096b:	75 f0                	jne    f010095d <mon_backtrace+0xa5>
			funcname[l] = info.eip_fn_name[l];
		funcname[l] = '\0';
f010096d:	c6 44 05 84 00       	movb   $0x0,-0x7c(%ebp,%eax,1)
		cprintf("         %s:%d: %s+%d\n", info.eip_file, info.eip_line, funcname, eip-info.eip_fn_addr);
f0100972:	83 ec 0c             	sub    $0xc,%esp
f0100975:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
f010097b:	2b 85 7c ff ff ff    	sub    -0x84(%ebp),%eax
f0100981:	50                   	push   %eax
f0100982:	8d 45 84             	lea    -0x7c(%ebp),%eax
f0100985:	50                   	push   %eax
f0100986:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
f010098c:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
f0100992:	68 91 6d 10 f0       	push   $0xf0106d91
f0100997:	e8 d9 32 00 00       	call   f0103c75 <cprintf>
		ebp = *(int *)ebp;
f010099c:	8b 36                	mov    (%esi),%esi
f010099e:	83 c4 20             	add    $0x20,%esp
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t ebp = read_ebp();
	while(ebp != 0)
f01009a1:	85 f6                	test   %esi,%esi
f01009a3:	0f 85 2f ff ff ff    	jne    f01008d8 <mon_backtrace+0x20>
		funcname[l] = '\0';
		cprintf("         %s:%d: %s+%d\n", info.eip_file, info.eip_line, funcname, eip-info.eip_fn_addr);
		ebp = *(int *)ebp;
	}
	return 0;
}
f01009a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009b1:	5b                   	pop    %ebx
f01009b2:	5e                   	pop    %esi
f01009b3:	5f                   	pop    %edi
f01009b4:	5d                   	pop    %ebp
f01009b5:	c3                   	ret    

f01009b6 <mon_showmappings>:


/* lab2 challenge */
int 
mon_showmappings(int argc, char **argv, struct Trapframe *tf) 
{
f01009b6:	55                   	push   %ebp
f01009b7:	89 e5                	mov    %esp,%ebp
f01009b9:	57                   	push   %edi
f01009ba:	56                   	push   %esi
f01009bb:	53                   	push   %ebx
f01009bc:	83 ec 18             	sub    $0x18,%esp
f01009bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t *kern_pgdir;

	uintptr_t begin_addr = ROUNDDOWN(charhex_to_dec(argv[1]), PGSIZE);
f01009c2:	ff 76 04             	pushl  0x4(%esi)
f01009c5:	e8 31 55 00 00       	call   f0105efb <charhex_to_dec>
f01009ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009cf:	89 c3                	mov    %eax,%ebx
	uintptr_t end_addr = ROUNDDOWN(charhex_to_dec(argv[2]), PGSIZE);
f01009d1:	83 c4 04             	add    $0x4,%esp
f01009d4:	ff 76 08             	pushl  0x8(%esi)
f01009d7:	e8 1f 55 00 00       	call   f0105efb <charhex_to_dec>
f01009dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e1:	89 c7                	mov    %eax,%edi


	for(uintptr_t addr = begin_addr; addr <= end_addr; addr += PGSIZE) {
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	e9 bf 00 00 00       	jmp    f0100aaa <mon_showmappings+0xf4>
		pte_t *page_table_entry = pgdir_walk(kern_pgdir, (void *)addr, 0);
f01009eb:	83 ec 04             	sub    $0x4,%esp
f01009ee:	6a 00                	push   $0x0
f01009f0:	53                   	push   %ebx
f01009f1:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01009f7:	e8 4e 0b 00 00       	call   f010154a <pgdir_walk>
f01009fc:	89 c6                	mov    %eax,%esi

		if(page_table_entry == NULL) 
f01009fe:	83 c4 10             	add    $0x10,%esp
f0100a01:	85 c0                	test   %eax,%eax
f0100a03:	75 16                	jne    f0100a1b <mon_showmappings+0x65>
			cprintf("va: 0x%08x    not been mapped\n", addr);
f0100a05:	83 ec 08             	sub    $0x8,%esp
f0100a08:	53                   	push   %ebx
f0100a09:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0100a0e:	e8 62 32 00 00       	call   f0103c75 <cprintf>
f0100a13:	83 c4 10             	add    $0x10,%esp
f0100a16:	e9 89 00 00 00       	jmp    f0100aa4 <mon_showmappings+0xee>
		else if(!(*page_table_entry & PTE_P))
f0100a1b:	8b 00                	mov    (%eax),%eax
f0100a1d:	a8 01                	test   $0x1,%al
f0100a1f:	75 13                	jne    f0100a34 <mon_showmappings+0x7e>
			cprintf("va: 0x%08x    not been mapped\n", addr);
f0100a21:	83 ec 08             	sub    $0x8,%esp
f0100a24:	53                   	push   %ebx
f0100a25:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0100a2a:	e8 46 32 00 00       	call   f0103c75 <cprintf>
f0100a2f:	83 c4 10             	add    $0x10,%esp
f0100a32:	eb 70                	jmp    f0100aa4 <mon_showmappings+0xee>
		else {
			cprintf("va: 0x%08x    pa: 0x%08x    perm: ", addr, *page_table_entry & 0xFFFFF000);	
f0100a34:	83 ec 04             	sub    $0x4,%esp
f0100a37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a3c:	50                   	push   %eax
f0100a3d:	53                   	push   %ebx
f0100a3e:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0100a43:	e8 2d 32 00 00       	call   f0103c75 <cprintf>
			if((*page_table_entry & PTE_U) && !(*page_table_entry & PTE_W))
f0100a48:	8b 06                	mov    (%esi),%eax
f0100a4a:	83 e0 06             	and    $0x6,%eax
f0100a4d:	83 c4 10             	add    $0x10,%esp
f0100a50:	83 f8 04             	cmp    $0x4,%eax
f0100a53:	75 12                	jne    f0100a67 <mon_showmappings+0xb1>
				cprintf("kernel R, usr R\n");
f0100a55:	83 ec 0c             	sub    $0xc,%esp
f0100a58:	68 a8 6d 10 f0       	push   $0xf0106da8
f0100a5d:	e8 13 32 00 00       	call   f0103c75 <cprintf>
f0100a62:	83 c4 10             	add    $0x10,%esp
f0100a65:	eb 3d                	jmp    f0100aa4 <mon_showmappings+0xee>
			else if((*page_table_entry & PTE_U) && (*page_table_entry & PTE_W))
f0100a67:	83 f8 06             	cmp    $0x6,%eax
f0100a6a:	75 12                	jne    f0100a7e <mon_showmappings+0xc8>
				cprintf("kernel RW, usr RW\n");
f0100a6c:	83 ec 0c             	sub    $0xc,%esp
f0100a6f:	68 b9 6d 10 f0       	push   $0xf0106db9
f0100a74:	e8 fc 31 00 00       	call   f0103c75 <cprintf>
f0100a79:	83 c4 10             	add    $0x10,%esp
f0100a7c:	eb 26                	jmp    f0100aa4 <mon_showmappings+0xee>
			else if(!(*page_table_entry & PTE_U) && !(*page_table_entry & PTE_W))
f0100a7e:	85 c0                	test   %eax,%eax
f0100a80:	75 12                	jne    f0100a94 <mon_showmappings+0xde>
				cprintf("kernel R, user none\n");
f0100a82:	83 ec 0c             	sub    $0xc,%esp
f0100a85:	68 cc 6d 10 f0       	push   $0xf0106dcc
f0100a8a:	e8 e6 31 00 00       	call   f0103c75 <cprintf>
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	eb 10                	jmp    f0100aa4 <mon_showmappings+0xee>
			else 
				cprintf("kernel RW, usr none\n");
f0100a94:	83 ec 0c             	sub    $0xc,%esp
f0100a97:	68 e1 6d 10 f0       	push   $0xf0106de1
f0100a9c:	e8 d4 31 00 00       	call   f0103c75 <cprintf>
f0100aa1:	83 c4 10             	add    $0x10,%esp

	uintptr_t begin_addr = ROUNDDOWN(charhex_to_dec(argv[1]), PGSIZE);
	uintptr_t end_addr = ROUNDDOWN(charhex_to_dec(argv[2]), PGSIZE);


	for(uintptr_t addr = begin_addr; addr <= end_addr; addr += PGSIZE) {
f0100aa4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100aaa:	39 fb                	cmp    %edi,%ebx
f0100aac:	0f 86 39 ff ff ff    	jbe    f01009eb <mon_showmappings+0x35>
				cprintf("kernel RW, usr none\n");
		}
	}

	return 0;
}
f0100ab2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aba:	5b                   	pop    %ebx
f0100abb:	5e                   	pop    %esi
f0100abc:	5f                   	pop    %edi
f0100abd:	5d                   	pop    %ebp
f0100abe:	c3                   	ret    

f0100abf <mon_changeperm>:


int
mon_changeperm(int argc, char **argv, struct Trapframe *tf)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
f0100ac2:	57                   	push   %edi
f0100ac3:	56                   	push   %esi
f0100ac4:	53                   	push   %ebx
f0100ac5:	83 ec 0c             	sub    $0xc,%esp
f0100ac8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	extern pde_t *kern_pgdir;

	int perm = 0;
	switch(argv[3][4]) {
f0100acb:	8b 53 0c             	mov    0xc(%ebx),%edx
f0100ace:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0100ad2:	83 e8 41             	sub    $0x41,%eax
f0100ad5:	3c 16                	cmp    $0x16,%al
f0100ad7:	0f 87 c6 00 00 00    	ja     f0100ba3 <mon_changeperm+0xe4>
f0100add:	0f b6 c0             	movzbl %al,%eax
f0100ae0:	ff 24 85 00 71 10 f0 	jmp    *-0xfef8f00(,%eax,4)
			break;
		case 'W':
			perm = PTE_W;
			break;
		case 'U':
			perm = PTE_U;
f0100ae7:	bf 04 00 00 00       	mov    $0x4,%edi
f0100aec:	eb 5a                	jmp    f0100b48 <mon_changeperm+0x89>
	extern pde_t *kern_pgdir;

	int perm = 0;
	switch(argv[3][4]) {
		case 'P':
			if(argv[3][5] == '\0') {
f0100aee:	0f b6 42 05          	movzbl 0x5(%edx),%eax
f0100af2:	84 c0                	test   %al,%al
f0100af4:	75 15                	jne    f0100b0b <mon_changeperm+0x4c>
				cprintf("cannot change PTE_P permission bit\n");
f0100af6:	83 ec 0c             	sub    $0xc,%esp
f0100af9:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0100afe:	e8 72 31 00 00       	call   f0103c75 <cprintf>
				return 0;
f0100b03:	83 c4 10             	add    $0x10,%esp
f0100b06:	e9 98 00 00 00       	jmp    f0100ba3 <mon_changeperm+0xe4>
			}
			else if(argv[3][5] == 'W')
				perm = PTE_PWT;
f0100b0b:	bf 08 00 00 00       	mov    $0x8,%edi
		case 'P':
			if(argv[3][5] == '\0') {
				cprintf("cannot change PTE_P permission bit\n");
				return 0;
			}
			else if(argv[3][5] == 'W')
f0100b10:	3c 57                	cmp    $0x57,%al
f0100b12:	74 34                	je     f0100b48 <mon_changeperm+0x89>
				perm = PTE_PWT;
			else if(argv[3][5] == 'C')
				perm = PTE_PCD;
f0100b14:	bf 10 00 00 00       	mov    $0x10,%edi
				cprintf("cannot change PTE_P permission bit\n");
				return 0;
			}
			else if(argv[3][5] == 'W')
				perm = PTE_PWT;
			else if(argv[3][5] == 'C')
f0100b19:	3c 43                	cmp    $0x43,%al
f0100b1b:	74 2b                	je     f0100b48 <mon_changeperm+0x89>
				perm = PTE_PCD;
			else if(argv[3][5] == 'S')
				perm = PTE_PS;
f0100b1d:	3c 53                	cmp    $0x53,%al
f0100b1f:	b8 80 00 00 00       	mov    $0x80,%eax
f0100b24:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b29:	0f 44 f8             	cmove  %eax,%edi
f0100b2c:	eb 1a                	jmp    f0100b48 <mon_changeperm+0x89>
			break;
		case 'U':
			perm = PTE_U;
			break;
		case 'A':
			perm = PTE_A;
f0100b2e:	bf 20 00 00 00       	mov    $0x20,%edi
			break;
f0100b33:	eb 13                	jmp    f0100b48 <mon_changeperm+0x89>
		case 'D':
			perm = PTE_D;
f0100b35:	bf 40 00 00 00       	mov    $0x40,%edi
			break;
f0100b3a:	eb 0c                	jmp    f0100b48 <mon_changeperm+0x89>
		case 'G':
			perm = PTE_G;
f0100b3c:	bf 00 01 00 00       	mov    $0x100,%edi
			break;
f0100b41:	eb 05                	jmp    f0100b48 <mon_changeperm+0x89>
				perm = PTE_PCD;
			else if(argv[3][5] == 'S')
				perm = PTE_PS;
			break;
		case 'W':
			perm = PTE_W;
f0100b43:	bf 02 00 00 00       	mov    $0x2,%edi
			break;
		default:
			return 0;
	}

	uintptr_t addr = charhex_to_dec(argv[2]);
f0100b48:	83 ec 0c             	sub    $0xc,%esp
f0100b4b:	ff 73 08             	pushl  0x8(%ebx)
f0100b4e:	e8 a8 53 00 00       	call   f0105efb <charhex_to_dec>
	pte_t *page_table_entry = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100b53:	83 c4 0c             	add    $0xc,%esp
f0100b56:	6a 00                	push   $0x0
f0100b58:	50                   	push   %eax
f0100b59:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0100b5f:	e8 e6 09 00 00       	call   f010154a <pgdir_walk>
f0100b64:	89 c6                	mov    %eax,%esi

	if(page_table_entry == NULL)
f0100b66:	83 c4 10             	add    $0x10,%esp
f0100b69:	85 c0                	test   %eax,%eax
f0100b6b:	74 36                	je     f0100ba3 <mon_changeperm+0xe4>
		return 0;
	else {
		if(strcmp(argv[1], "set") == 0)
f0100b6d:	83 ec 08             	sub    $0x8,%esp
f0100b70:	68 f6 6d 10 f0       	push   $0xf0106df6
f0100b75:	ff 73 04             	pushl  0x4(%ebx)
f0100b78:	e8 e1 50 00 00       	call   f0105c5e <strcmp>
f0100b7d:	83 c4 10             	add    $0x10,%esp
f0100b80:	85 c0                	test   %eax,%eax
f0100b82:	75 04                	jne    f0100b88 <mon_changeperm+0xc9>
			*page_table_entry = *page_table_entry | perm;
f0100b84:	09 3e                	or     %edi,(%esi)
f0100b86:	eb 1b                	jmp    f0100ba3 <mon_changeperm+0xe4>
		else if(strcmp(argv[1], "clean") == 0)
f0100b88:	83 ec 08             	sub    $0x8,%esp
f0100b8b:	68 fa 6d 10 f0       	push   $0xf0106dfa
f0100b90:	ff 73 04             	pushl  0x4(%ebx)
f0100b93:	e8 c6 50 00 00       	call   f0105c5e <strcmp>
f0100b98:	83 c4 10             	add    $0x10,%esp
f0100b9b:	85 c0                	test   %eax,%eax
f0100b9d:	75 04                	jne    f0100ba3 <mon_changeperm+0xe4>
			*page_table_entry = *page_table_entry & (~perm);
f0100b9f:	f7 d7                	not    %edi
f0100ba1:	21 3e                	and    %edi,(%esi)
	}
	
	return 0;
}
f0100ba3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bab:	5b                   	pop    %ebx
f0100bac:	5e                   	pop    %esi
f0100bad:	5f                   	pop    %edi
f0100bae:	5d                   	pop    %ebp
f0100baf:	c3                   	ret    

f0100bb0 <mon_dumpmem>:

int 
mon_dumpmem(int argc, char **argv, struct Trapframe *tf)
{
f0100bb0:	55                   	push   %ebp
f0100bb1:	89 e5                	mov    %esp,%ebp
f0100bb3:	57                   	push   %edi
f0100bb4:	56                   	push   %esi
f0100bb5:	53                   	push   %ebx
f0100bb6:	83 ec 34             	sub    $0x34,%esp
f0100bb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	extern pde_t *kern_pgdir;

	if(strcmp(argv[1], "v") == 0) {
f0100bbc:	68 89 80 10 f0       	push   $0xf0108089
f0100bc1:	ff 73 04             	pushl  0x4(%ebx)
f0100bc4:	e8 95 50 00 00       	call   f0105c5e <strcmp>
f0100bc9:	83 c4 10             	add    $0x10,%esp
f0100bcc:	85 c0                	test   %eax,%eax
f0100bce:	0f 85 f3 00 00 00    	jne    f0100cc7 <mon_dumpmem+0x117>
		uintptr_t begin_addr = charhex_to_dec(argv[2]);
f0100bd4:	83 ec 0c             	sub    $0xc,%esp
f0100bd7:	ff 73 08             	pushl  0x8(%ebx)
f0100bda:	e8 1c 53 00 00       	call   f0105efb <charhex_to_dec>
f0100bdf:	89 c7                	mov    %eax,%edi
f0100be1:	89 45 d8             	mov    %eax,-0x28(%ebp)
		uintptr_t end_addr = charhex_to_dec(argv[3]);
f0100be4:	83 c4 04             	add    $0x4,%esp
f0100be7:	ff 73 0c             	pushl  0xc(%ebx)
f0100bea:	e8 0c 53 00 00       	call   f0105efb <charhex_to_dec>
f0100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		for(size_t page = ROUNDDOWN(begin_addr, PGSIZE); page <= ROUNDDOWN(end_addr, PGSIZE); ++page) {
f0100bf2:	89 f9                	mov    %edi,%ecx
f0100bf4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100bfa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bfd:	83 c4 10             	add    $0x10,%esp
f0100c00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c05:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100c08:	e9 a9 00 00 00       	jmp    f0100cb6 <mon_dumpmem+0x106>
			pte_t *page_table_entry = pgdir_walk(kern_pgdir, (void *)page, 0);
f0100c0d:	83 ec 04             	sub    $0x4,%esp
f0100c10:	6a 00                	push   $0x0
f0100c12:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c15:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0100c1b:	e8 2a 09 00 00       	call   f010154a <pgdir_walk>

			if(page_table_entry == NULL || !(*page_table_entry & PTE_P)) {
f0100c20:	83 c4 10             	add    $0x10,%esp
f0100c23:	85 c0                	test   %eax,%eax
f0100c25:	74 05                	je     f0100c2c <mon_dumpmem+0x7c>
f0100c27:	f6 00 01             	testb  $0x1,(%eax)
f0100c2a:	75 15                	jne    f0100c41 <mon_dumpmem+0x91>
				cprintf("virtual page 0x%x has not been mapped", page);
f0100c2c:	83 ec 08             	sub    $0x8,%esp
f0100c2f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c32:	68 0c 70 10 f0       	push   $0xf010700c
f0100c37:	e8 39 30 00 00       	call   f0103c75 <cprintf>
				continue;
f0100c3c:	83 c4 10             	add    $0x10,%esp
f0100c3f:	eb 71                	jmp    f0100cb2 <mon_dumpmem+0x102>
			}

			uintptr_t begin_page = page > begin_addr ? page : begin_addr;
f0100c41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c44:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100c47:	39 c8                	cmp    %ecx,%eax
f0100c49:	89 cf                	mov    %ecx,%edi
f0100c4b:	0f 43 f8             	cmovae %eax,%edi
			uintptr_t end_page = page + PGSIZE - 1 < end_addr ? page + PGSIZE - 1 : end_addr ;
f0100c4e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100c53:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100c56:	39 d0                	cmp    %edx,%eax
f0100c58:	0f 47 c2             	cmova  %edx,%eax
f0100c5b:	89 fe                	mov    %edi,%esi
f0100c5d:	89 c7                	mov    %eax,%edi
			for(uintptr_t addr = begin_page; addr <= end_page; addr += 8) {
f0100c5f:	eb 4d                	jmp    f0100cae <mon_dumpmem+0xfe>
				cprintf("0x%08x: ", addr);
f0100c61:	83 ec 08             	sub    $0x8,%esp
f0100c64:	56                   	push   %esi
f0100c65:	68 00 6e 10 f0       	push   $0xf0106e00
f0100c6a:	e8 06 30 00 00       	call   f0103c75 <cprintf>
				for(uintptr_t i = addr; i < addr + 8; ++i) {
f0100c6f:	83 c4 10             	add    $0x10,%esp
f0100c72:	89 f3                	mov    %esi,%ebx
f0100c74:	83 c6 08             	add    $0x8,%esi
f0100c77:	eb 1b                	jmp    f0100c94 <mon_dumpmem+0xe4>
					cprintf("%02x ", *(uint8_t *)i);
f0100c79:	83 ec 08             	sub    $0x8,%esp
f0100c7c:	0f b6 03             	movzbl (%ebx),%eax
f0100c7f:	50                   	push   %eax
f0100c80:	68 09 6e 10 f0       	push   $0xf0106e09
f0100c85:	e8 eb 2f 00 00       	call   f0103c75 <cprintf>
					if(i == end_page)
f0100c8a:	83 c4 10             	add    $0x10,%esp
f0100c8d:	39 fb                	cmp    %edi,%ebx
f0100c8f:	74 0a                	je     f0100c9b <mon_dumpmem+0xeb>

			uintptr_t begin_page = page > begin_addr ? page : begin_addr;
			uintptr_t end_page = page + PGSIZE - 1 < end_addr ? page + PGSIZE - 1 : end_addr ;
			for(uintptr_t addr = begin_page; addr <= end_page; addr += 8) {
				cprintf("0x%08x: ", addr);
				for(uintptr_t i = addr; i < addr + 8; ++i) {
f0100c91:	83 c3 01             	add    $0x1,%ebx
f0100c94:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100c97:	39 f3                	cmp    %esi,%ebx
f0100c99:	72 de                	jb     f0100c79 <mon_dumpmem+0xc9>
					cprintf("%02x ", *(uint8_t *)i);
					if(i == end_page)
						break;
				}
				cprintf("\n");
f0100c9b:	83 ec 0c             	sub    $0xc,%esp
f0100c9e:	68 ff 7d 10 f0       	push   $0xf0107dff
f0100ca3:	e8 cd 2f 00 00       	call   f0103c75 <cprintf>
f0100ca8:	83 c4 10             	add    $0x10,%esp
f0100cab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				continue;
			}

			uintptr_t begin_page = page > begin_addr ? page : begin_addr;
			uintptr_t end_page = page + PGSIZE - 1 < end_addr ? page + PGSIZE - 1 : end_addr ;
			for(uintptr_t addr = begin_page; addr <= end_page; addr += 8) {
f0100cae:	39 f7                	cmp    %esi,%edi
f0100cb0:	73 af                	jae    f0100c61 <mon_dumpmem+0xb1>

	if(strcmp(argv[1], "v") == 0) {
		uintptr_t begin_addr = charhex_to_dec(argv[2]);
		uintptr_t end_addr = charhex_to_dec(argv[3]);

		for(size_t page = ROUNDDOWN(begin_addr, PGSIZE); page <= ROUNDDOWN(end_addr, PGSIZE); ++page) {
f0100cb2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0100cb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cb9:	39 55 e0             	cmp    %edx,-0x20(%ebp)
f0100cbc:	0f 86 4b ff ff ff    	jbe    f0100c0d <mon_dumpmem+0x5d>
f0100cc2:	e9 9b 00 00 00       	jmp    f0100d62 <mon_dumpmem+0x1b2>
				}
				cprintf("\n");
			}
		}
	}
	else if(strcmp(argv[1], "p") == 0) {
f0100cc7:	83 ec 08             	sub    $0x8,%esp
f0100cca:	68 38 6e 10 f0       	push   $0xf0106e38
f0100ccf:	ff 73 04             	pushl  0x4(%ebx)
f0100cd2:	e8 87 4f 00 00       	call   f0105c5e <strcmp>
f0100cd7:	83 c4 10             	add    $0x10,%esp
f0100cda:	85 c0                	test   %eax,%eax
f0100cdc:	0f 85 80 00 00 00    	jne    f0100d62 <mon_dumpmem+0x1b2>
		physaddr_t begin_addr = charhex_to_dec(argv[2]);
f0100ce2:	83 ec 0c             	sub    $0xc,%esp
f0100ce5:	ff 73 08             	pushl  0x8(%ebx)
f0100ce8:	e8 0e 52 00 00       	call   f0105efb <charhex_to_dec>
f0100ced:	89 c6                	mov    %eax,%esi
		physaddr_t end_addr = charhex_to_dec(argv[3]);
f0100cef:	83 c4 04             	add    $0x4,%esp
f0100cf2:	ff 73 0c             	pushl  0xc(%ebx)
f0100cf5:	e8 01 52 00 00       	call   f0105efb <charhex_to_dec>

		for(uintptr_t addr = begin_addr + KERNBASE; addr <= end_addr + KERNBASE; addr += 8) {
f0100cfa:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0100d00:	83 c4 10             	add    $0x10,%esp
f0100d03:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d09:	eb 53                	jmp    f0100d5e <mon_dumpmem+0x1ae>
			cprintf("0x%08x: ", addr - KERNBASE);
f0100d0b:	83 ec 08             	sub    $0x8,%esp
f0100d0e:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100d14:	50                   	push   %eax
f0100d15:	68 00 6e 10 f0       	push   $0xf0106e00
f0100d1a:	e8 56 2f 00 00       	call   f0103c75 <cprintf>
			for(uintptr_t i = addr; i < addr + 8; ++i) {
f0100d1f:	83 c4 10             	add    $0x10,%esp
f0100d22:	89 f3                	mov    %esi,%ebx
f0100d24:	83 c6 08             	add    $0x8,%esi
f0100d27:	eb 1b                	jmp    f0100d44 <mon_dumpmem+0x194>
				cprintf("%02x ", *(uint8_t *)i);
f0100d29:	83 ec 08             	sub    $0x8,%esp
f0100d2c:	0f b6 03             	movzbl (%ebx),%eax
f0100d2f:	50                   	push   %eax
f0100d30:	68 09 6e 10 f0       	push   $0xf0106e09
f0100d35:	e8 3b 2f 00 00       	call   f0103c75 <cprintf>
				if(i == end_addr + KERNBASE)
f0100d3a:	83 c4 10             	add    $0x10,%esp
f0100d3d:	39 fb                	cmp    %edi,%ebx
f0100d3f:	74 0a                	je     f0100d4b <mon_dumpmem+0x19b>
		physaddr_t begin_addr = charhex_to_dec(argv[2]);
		physaddr_t end_addr = charhex_to_dec(argv[3]);

		for(uintptr_t addr = begin_addr + KERNBASE; addr <= end_addr + KERNBASE; addr += 8) {
			cprintf("0x%08x: ", addr - KERNBASE);
			for(uintptr_t i = addr; i < addr + 8; ++i) {
f0100d41:	83 c3 01             	add    $0x1,%ebx
f0100d44:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100d47:	39 f3                	cmp    %esi,%ebx
f0100d49:	72 de                	jb     f0100d29 <mon_dumpmem+0x179>
				cprintf("%02x ", *(uint8_t *)i);
				if(i == end_addr + KERNBASE)
					break;
			}
			cprintf("\n");
f0100d4b:	83 ec 0c             	sub    $0xc,%esp
f0100d4e:	68 ff 7d 10 f0       	push   $0xf0107dff
f0100d53:	e8 1d 2f 00 00       	call   f0103c75 <cprintf>
f0100d58:	83 c4 10             	add    $0x10,%esp
f0100d5b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	}
	else if(strcmp(argv[1], "p") == 0) {
		physaddr_t begin_addr = charhex_to_dec(argv[2]);
		physaddr_t end_addr = charhex_to_dec(argv[3]);

		for(uintptr_t addr = begin_addr + KERNBASE; addr <= end_addr + KERNBASE; addr += 8) {
f0100d5e:	39 f7                	cmp    %esi,%edi
f0100d60:	73 a9                	jae    f0100d0b <mon_dumpmem+0x15b>
			cprintf("\n");
		}
	}

	return 0;
}
f0100d62:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d6a:	5b                   	pop    %ebx
f0100d6b:	5e                   	pop    %esi
f0100d6c:	5f                   	pop    %edi
f0100d6d:	5d                   	pop    %ebp
f0100d6e:	c3                   	ret    

f0100d6f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100d6f:	55                   	push   %ebp
f0100d70:	89 e5                	mov    %esp,%ebp
f0100d72:	57                   	push   %edi
f0100d73:	56                   	push   %esi
f0100d74:	53                   	push   %ebx
f0100d75:	83 ec 58             	sub    $0x58,%esp

	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100d78:	68 34 70 10 f0       	push   $0xf0107034
f0100d7d:	e8 f3 2e 00 00       	call   f0103c75 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d82:	c7 04 24 58 70 10 f0 	movl   $0xf0107058,(%esp)
f0100d89:	e8 e7 2e 00 00       	call   f0103c75 <cprintf>

	if (tf != NULL) {
f0100d8e:	83 c4 10             	add    $0x10,%esp
f0100d91:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100d95:	74 16                	je     f0100dad <monitor+0x3e>
		/* lab3 challenge */
		tf->tf_eflags |= 0x100;
f0100d97:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d9a:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
		/* lab3 challenge */
		print_trapframe(tf);
f0100da1:	83 ec 0c             	sub    $0xc,%esp
f0100da4:	50                   	push   %eax
f0100da5:	e8 90 34 00 00       	call   f010423a <print_trapframe>
f0100daa:	83 c4 10             	add    $0x10,%esp
	}

	while (1) {
		buf = readline("K> ");
f0100dad:	83 ec 0c             	sub    $0xc,%esp
f0100db0:	68 0f 6e 10 f0       	push   $0xf0106e0f
f0100db5:	e8 d0 4c 00 00       	call   f0105a8a <readline>
f0100dba:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100dbc:	83 c4 10             	add    $0x10,%esp
f0100dbf:	85 c0                	test   %eax,%eax
f0100dc1:	74 ea                	je     f0100dad <monitor+0x3e>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100dc3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100dca:	be 00 00 00 00       	mov    $0x0,%esi
f0100dcf:	eb 0a                	jmp    f0100ddb <monitor+0x6c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100dd1:	c6 03 00             	movb   $0x0,(%ebx)
f0100dd4:	89 f7                	mov    %esi,%edi
f0100dd6:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100dd9:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100ddb:	0f b6 03             	movzbl (%ebx),%eax
f0100dde:	84 c0                	test   %al,%al
f0100de0:	74 63                	je     f0100e45 <monitor+0xd6>
f0100de2:	83 ec 08             	sub    $0x8,%esp
f0100de5:	0f be c0             	movsbl %al,%eax
f0100de8:	50                   	push   %eax
f0100de9:	68 13 6e 10 f0       	push   $0xf0106e13
f0100dee:	e8 c9 4e 00 00       	call   f0105cbc <strchr>
f0100df3:	83 c4 10             	add    $0x10,%esp
f0100df6:	85 c0                	test   %eax,%eax
f0100df8:	75 d7                	jne    f0100dd1 <monitor+0x62>
			*buf++ = 0;
		if (*buf == 0)
f0100dfa:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100dfd:	74 46                	je     f0100e45 <monitor+0xd6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100dff:	83 fe 0f             	cmp    $0xf,%esi
f0100e02:	75 14                	jne    f0100e18 <monitor+0xa9>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e04:	83 ec 08             	sub    $0x8,%esp
f0100e07:	6a 10                	push   $0x10
f0100e09:	68 18 6e 10 f0       	push   $0xf0106e18
f0100e0e:	e8 62 2e 00 00       	call   f0103c75 <cprintf>
f0100e13:	83 c4 10             	add    $0x10,%esp
f0100e16:	eb 95                	jmp    f0100dad <monitor+0x3e>
			return 0;
		}
		argv[argc++] = buf;
f0100e18:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e1b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e1f:	eb 03                	jmp    f0100e24 <monitor+0xb5>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100e21:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e24:	0f b6 03             	movzbl (%ebx),%eax
f0100e27:	84 c0                	test   %al,%al
f0100e29:	74 ae                	je     f0100dd9 <monitor+0x6a>
f0100e2b:	83 ec 08             	sub    $0x8,%esp
f0100e2e:	0f be c0             	movsbl %al,%eax
f0100e31:	50                   	push   %eax
f0100e32:	68 13 6e 10 f0       	push   $0xf0106e13
f0100e37:	e8 80 4e 00 00       	call   f0105cbc <strchr>
f0100e3c:	83 c4 10             	add    $0x10,%esp
f0100e3f:	85 c0                	test   %eax,%eax
f0100e41:	74 de                	je     f0100e21 <monitor+0xb2>
f0100e43:	eb 94                	jmp    f0100dd9 <monitor+0x6a>
			buf++;
	}
	argv[argc] = 0;
f0100e45:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e4c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e4d:	85 f6                	test   %esi,%esi
f0100e4f:	0f 84 58 ff ff ff    	je     f0100dad <monitor+0x3e>
		return 0;

	/* lab3 challenge */
	if(strcmp(argv[0], "step") == 0 || strcmp(argv[0], "s") == 0)
f0100e55:	83 ec 08             	sub    $0x8,%esp
f0100e58:	68 35 6e 10 f0       	push   $0xf0106e35
f0100e5d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e60:	e8 f9 4d 00 00       	call   f0105c5e <strcmp>
f0100e65:	83 c4 10             	add    $0x10,%esp
f0100e68:	85 c0                	test   %eax,%eax
f0100e6a:	0f 84 b7 00 00 00    	je     f0100f27 <monitor+0x1b8>
f0100e70:	83 ec 08             	sub    $0x8,%esp
f0100e73:	68 2a 7b 10 f0       	push   $0xf0107b2a
f0100e78:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e7b:	e8 de 4d 00 00       	call   f0105c5e <strcmp>
f0100e80:	83 c4 10             	add    $0x10,%esp
f0100e83:	85 c0                	test   %eax,%eax
f0100e85:	0f 84 9c 00 00 00    	je     f0100f27 <monitor+0x1b8>
		return -1;
	
	else if(strcmp(argv[0], "run") == 0 || strcmp(argv[0], "r") == 0) {
f0100e8b:	83 ec 08             	sub    $0x8,%esp
f0100e8e:	68 40 81 10 f0       	push   $0xf0108140
f0100e93:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e96:	e8 c3 4d 00 00       	call   f0105c5e <strcmp>
f0100e9b:	83 c4 10             	add    $0x10,%esp
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	74 17                	je     f0100eb9 <monitor+0x14a>
f0100ea2:	83 ec 08             	sub    $0x8,%esp
f0100ea5:	68 70 7f 10 f0       	push   $0xf0107f70
f0100eaa:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ead:	e8 ac 4d 00 00       	call   f0105c5e <strcmp>
f0100eb2:	83 c4 10             	add    $0x10,%esp
f0100eb5:	85 c0                	test   %eax,%eax
f0100eb7:	75 0c                	jne    f0100ec5 <monitor+0x156>
		tf->tf_eflags &= (~0x100);
f0100eb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ebc:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
f0100ec3:	eb 62                	jmp    f0100f27 <monitor+0x1b8>

	/* lab3 challenge */
	if(strcmp(argv[0], "step") == 0 || strcmp(argv[0], "s") == 0)
		return -1;
	
	else if(strcmp(argv[0], "run") == 0 || strcmp(argv[0], "r") == 0) {
f0100ec5:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -1;
	}
	/* lab3 challenge */		

	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100eca:	83 ec 08             	sub    $0x8,%esp
f0100ecd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ed0:	ff 34 85 60 71 10 f0 	pushl  -0xfef8ea0(,%eax,4)
f0100ed7:	ff 75 a8             	pushl  -0x58(%ebp)
f0100eda:	e8 7f 4d 00 00       	call   f0105c5e <strcmp>
f0100edf:	83 c4 10             	add    $0x10,%esp
f0100ee2:	85 c0                	test   %eax,%eax
f0100ee4:	75 21                	jne    f0100f07 <monitor+0x198>
			return commands[i].func(argc, argv, tf);
f0100ee6:	83 ec 04             	sub    $0x4,%esp
f0100ee9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100eec:	ff 75 08             	pushl  0x8(%ebp)
f0100eef:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ef2:	52                   	push   %edx
f0100ef3:	56                   	push   %esi
f0100ef4:	ff 14 85 68 71 10 f0 	call   *-0xfef8e98(,%eax,4)
	}

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0) 
f0100efb:	83 c4 10             	add    $0x10,%esp
f0100efe:	85 c0                	test   %eax,%eax
f0100f00:	78 25                	js     f0100f27 <monitor+0x1b8>
f0100f02:	e9 a6 fe ff ff       	jmp    f0100dad <monitor+0x3e>
		tf->tf_eflags &= (~0x100);
		return -1;
	}
	/* lab3 challenge */		

	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100f07:	83 c3 01             	add    $0x1,%ebx
f0100f0a:	83 fb 06             	cmp    $0x6,%ebx
f0100f0d:	75 bb                	jne    f0100eca <monitor+0x15b>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f0f:	83 ec 08             	sub    $0x8,%esp
f0100f12:	ff 75 a8             	pushl  -0x58(%ebp)
f0100f15:	68 3a 6e 10 f0       	push   $0xf0106e3a
f0100f1a:	e8 56 2d 00 00       	call   f0103c75 <cprintf>
f0100f1f:	83 c4 10             	add    $0x10,%esp
f0100f22:	e9 86 fe ff ff       	jmp    f0100dad <monitor+0x3e>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0) 
				break;
	}
}
f0100f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f2a:	5b                   	pop    %ebx
f0100f2b:	5e                   	pop    %esi
f0100f2c:	5f                   	pop    %edi
f0100f2d:	5d                   	pop    %ebp
f0100f2e:	c3                   	ret    

f0100f2f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f2f:	55                   	push   %ebp
f0100f30:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f32:	83 3d 38 a2 21 f0 00 	cmpl   $0x0,0xf021a238
f0100f39:	75 37                	jne    f0100f72 <boot_alloc+0x43>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f3b:	ba 07 d0 25 f0       	mov    $0xf025d007,%edx
f0100f40:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f46:	89 15 38 a2 21 f0    	mov    %edx,0xf021a238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n == 0) {
f0100f4c:	85 c0                	test   %eax,%eax
f0100f4e:	75 07                	jne    f0100f57 <boot_alloc+0x28>
		return nextfree;
f0100f50:	a1 38 a2 21 f0       	mov    0xf021a238,%eax
f0100f55:	eb 21                	jmp    f0100f78 <boot_alloc+0x49>
	}
	else if(n > 0) {
		char *size = ROUNDUP((char *)n, PGSIZE);
f0100f57:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
		char *addr = nextfree;
f0100f5d:	a1 38 a2 21 f0       	mov    0xf021a238,%eax

		nextfree = (char *)((int)nextfree + (int)size);
f0100f62:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f68:	01 c2                	add    %eax,%edx
f0100f6a:	89 15 38 a2 21 f0    	mov    %edx,0xf021a238
		
		return addr;
f0100f70:	eb 06                	jmp    f0100f78 <boot_alloc+0x49>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n == 0) {
f0100f72:	85 c0                	test   %eax,%eax
f0100f74:	75 e1                	jne    f0100f57 <boot_alloc+0x28>
f0100f76:	eb d8                	jmp    f0100f50 <boot_alloc+0x21>
		
		return addr;
	}

	return NULL;
}
f0100f78:	5d                   	pop    %ebp
f0100f79:	c3                   	ret    

f0100f7a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100f7a:	55                   	push   %ebp
f0100f7b:	89 e5                	mov    %esp,%ebp
f0100f7d:	56                   	push   %esi
f0100f7e:	53                   	push   %ebx
f0100f7f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f81:	83 ec 0c             	sub    $0xc,%esp
f0100f84:	50                   	push   %eax
f0100f85:	e8 63 2b 00 00       	call   f0103aed <mc146818_read>
f0100f8a:	89 c6                	mov    %eax,%esi
f0100f8c:	83 c3 01             	add    $0x1,%ebx
f0100f8f:	89 1c 24             	mov    %ebx,(%esp)
f0100f92:	e8 56 2b 00 00       	call   f0103aed <mc146818_read>
f0100f97:	c1 e0 08             	shl    $0x8,%eax
f0100f9a:	09 f0                	or     %esi,%eax
}
f0100f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f9f:	5b                   	pop    %ebx
f0100fa0:	5e                   	pop    %esi
f0100fa1:	5d                   	pop    %ebp
f0100fa2:	c3                   	ret    

f0100fa3 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100fa3:	89 d1                	mov    %edx,%ecx
f0100fa5:	c1 e9 16             	shr    $0x16,%ecx
f0100fa8:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100fab:	a8 01                	test   $0x1,%al
f0100fad:	74 52                	je     f0101001 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100faf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb4:	89 c1                	mov    %eax,%ecx
f0100fb6:	c1 e9 0c             	shr    $0xc,%ecx
f0100fb9:	3b 0d 88 ae 21 f0    	cmp    0xf021ae88,%ecx
f0100fbf:	72 1b                	jb     f0100fdc <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100fc1:	55                   	push   %ebp
f0100fc2:	89 e5                	mov    %esp,%ebp
f0100fc4:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc7:	50                   	push   %eax
f0100fc8:	68 44 6a 10 f0       	push   $0xf0106a44
f0100fcd:	68 1c 04 00 00       	push   $0x41c
f0100fd2:	68 f1 7a 10 f0       	push   $0xf0107af1
f0100fd7:	e8 64 f0 ff ff       	call   f0100040 <_panic>
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("page table entry = 0x%08x\n", pgdir_walk(pgdir, (void *)va, 0));
	//cprintf("p = 0x%08x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100fdc:	c1 ea 0c             	shr    $0xc,%edx
f0100fdf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fe5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fec:	89 c2                	mov    %eax,%edx
f0100fee:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ff1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ff6:	85 d2                	test   %edx,%edx
f0100ff8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ffd:	0f 44 c2             	cmove  %edx,%eax
f0101000:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0101001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("page table entry = 0x%08x\n", pgdir_walk(pgdir, (void *)va, 0));
	//cprintf("p = 0x%08x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0101006:	c3                   	ret    

f0101007 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101007:	55                   	push   %ebp
f0101008:	89 e5                	mov    %esp,%ebp
f010100a:	57                   	push   %edi
f010100b:	56                   	push   %esi
f010100c:	53                   	push   %ebx
f010100d:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101010:	84 c0                	test   %al,%al
f0101012:	0f 85 a0 02 00 00    	jne    f01012b8 <check_page_free_list+0x2b1>
f0101018:	e9 ad 02 00 00       	jmp    f01012ca <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f010101d:	83 ec 04             	sub    $0x4,%esp
f0101020:	68 a8 71 10 f0       	push   $0xf01071a8
f0101025:	68 4e 03 00 00       	push   $0x34e
f010102a:	68 f1 7a 10 f0       	push   $0xf0107af1
f010102f:	e8 0c f0 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101034:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101037:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010103a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010103d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101040:	89 c2                	mov    %eax,%edx
f0101042:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f0101048:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010104e:	0f 95 c2             	setne  %dl
f0101051:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101054:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101058:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010105a:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010105e:	8b 00                	mov    (%eax),%eax
f0101060:	85 c0                	test   %eax,%eax
f0101062:	75 dc                	jne    f0101040 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101064:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101067:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010106d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101070:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101073:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101075:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101078:	a3 40 a2 21 f0       	mov    %eax,0xf021a240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010107d:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101082:	8b 1d 40 a2 21 f0    	mov    0xf021a240,%ebx
f0101088:	eb 53                	jmp    f01010dd <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010108a:	89 d8                	mov    %ebx,%eax
f010108c:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0101092:	c1 f8 03             	sar    $0x3,%eax
f0101095:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101098:	89 c2                	mov    %eax,%edx
f010109a:	c1 ea 16             	shr    $0x16,%edx
f010109d:	39 f2                	cmp    %esi,%edx
f010109f:	73 3a                	jae    f01010db <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a1:	89 c2                	mov    %eax,%edx
f01010a3:	c1 ea 0c             	shr    $0xc,%edx
f01010a6:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f01010ac:	72 12                	jb     f01010c0 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010ae:	50                   	push   %eax
f01010af:	68 44 6a 10 f0       	push   $0xf0106a44
f01010b4:	6a 58                	push   $0x58
f01010b6:	68 fd 7a 10 f0       	push   $0xf0107afd
f01010bb:	e8 80 ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010c0:	83 ec 04             	sub    $0x4,%esp
f01010c3:	68 80 00 00 00       	push   $0x80
f01010c8:	68 97 00 00 00       	push   $0x97
f01010cd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010d2:	50                   	push   %eax
f01010d3:	e8 21 4c 00 00       	call   f0105cf9 <memset>
f01010d8:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010db:	8b 1b                	mov    (%ebx),%ebx
f01010dd:	85 db                	test   %ebx,%ebx
f01010df:	75 a9                	jne    f010108a <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01010e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e6:	e8 44 fe ff ff       	call   f0100f2f <boot_alloc>
f01010eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010ee:	8b 15 40 a2 21 f0    	mov    0xf021a240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010f4:	8b 0d 90 ae 21 f0    	mov    0xf021ae90,%ecx
		assert(pp < pages + npages);
f01010fa:	a1 88 ae 21 f0       	mov    0xf021ae88,%eax
f01010ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101102:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101105:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101108:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010110b:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101110:	e9 52 01 00 00       	jmp    f0101267 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101115:	39 ca                	cmp    %ecx,%edx
f0101117:	73 19                	jae    f0101132 <check_page_free_list+0x12b>
f0101119:	68 0b 7b 10 f0       	push   $0xf0107b0b
f010111e:	68 17 7b 10 f0       	push   $0xf0107b17
f0101123:	68 68 03 00 00       	push   $0x368
f0101128:	68 f1 7a 10 f0       	push   $0xf0107af1
f010112d:	e8 0e ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101132:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101135:	72 19                	jb     f0101150 <check_page_free_list+0x149>
f0101137:	68 2c 7b 10 f0       	push   $0xf0107b2c
f010113c:	68 17 7b 10 f0       	push   $0xf0107b17
f0101141:	68 69 03 00 00       	push   $0x369
f0101146:	68 f1 7a 10 f0       	push   $0xf0107af1
f010114b:	e8 f0 ee ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101150:	89 d0                	mov    %edx,%eax
f0101152:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101155:	a8 07                	test   $0x7,%al
f0101157:	74 19                	je     f0101172 <check_page_free_list+0x16b>
f0101159:	68 cc 71 10 f0       	push   $0xf01071cc
f010115e:	68 17 7b 10 f0       	push   $0xf0107b17
f0101163:	68 6a 03 00 00       	push   $0x36a
f0101168:	68 f1 7a 10 f0       	push   $0xf0107af1
f010116d:	e8 ce ee ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101172:	c1 f8 03             	sar    $0x3,%eax
f0101175:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101178:	85 c0                	test   %eax,%eax
f010117a:	75 19                	jne    f0101195 <check_page_free_list+0x18e>
f010117c:	68 40 7b 10 f0       	push   $0xf0107b40
f0101181:	68 17 7b 10 f0       	push   $0xf0107b17
f0101186:	68 6d 03 00 00       	push   $0x36d
f010118b:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101190:	e8 ab ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101195:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010119a:	75 19                	jne    f01011b5 <check_page_free_list+0x1ae>
f010119c:	68 51 7b 10 f0       	push   $0xf0107b51
f01011a1:	68 17 7b 10 f0       	push   $0xf0107b17
f01011a6:	68 6e 03 00 00       	push   $0x36e
f01011ab:	68 f1 7a 10 f0       	push   $0xf0107af1
f01011b0:	e8 8b ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011b5:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011ba:	75 19                	jne    f01011d5 <check_page_free_list+0x1ce>
f01011bc:	68 00 72 10 f0       	push   $0xf0107200
f01011c1:	68 17 7b 10 f0       	push   $0xf0107b17
f01011c6:	68 6f 03 00 00       	push   $0x36f
f01011cb:	68 f1 7a 10 f0       	push   $0xf0107af1
f01011d0:	e8 6b ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011d5:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011da:	75 19                	jne    f01011f5 <check_page_free_list+0x1ee>
f01011dc:	68 6a 7b 10 f0       	push   $0xf0107b6a
f01011e1:	68 17 7b 10 f0       	push   $0xf0107b17
f01011e6:	68 70 03 00 00       	push   $0x370
f01011eb:	68 f1 7a 10 f0       	push   $0xf0107af1
f01011f0:	e8 4b ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011f5:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011fa:	0f 86 f1 00 00 00    	jbe    f01012f1 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101200:	89 c7                	mov    %eax,%edi
f0101202:	c1 ef 0c             	shr    $0xc,%edi
f0101205:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101208:	77 12                	ja     f010121c <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010120a:	50                   	push   %eax
f010120b:	68 44 6a 10 f0       	push   $0xf0106a44
f0101210:	6a 58                	push   $0x58
f0101212:	68 fd 7a 10 f0       	push   $0xf0107afd
f0101217:	e8 24 ee ff ff       	call   f0100040 <_panic>
f010121c:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0101222:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101225:	0f 86 b6 00 00 00    	jbe    f01012e1 <check_page_free_list+0x2da>
f010122b:	68 24 72 10 f0       	push   $0xf0107224
f0101230:	68 17 7b 10 f0       	push   $0xf0107b17
f0101235:	68 71 03 00 00       	push   $0x371
f010123a:	68 f1 7a 10 f0       	push   $0xf0107af1
f010123f:	e8 fc ed ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101244:	68 84 7b 10 f0       	push   $0xf0107b84
f0101249:	68 17 7b 10 f0       	push   $0xf0107b17
f010124e:	68 73 03 00 00       	push   $0x373
f0101253:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101258:	e8 e3 ed ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010125d:	83 c6 01             	add    $0x1,%esi
f0101260:	eb 03                	jmp    f0101265 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0101262:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101265:	8b 12                	mov    (%edx),%edx
f0101267:	85 d2                	test   %edx,%edx
f0101269:	0f 85 a6 fe ff ff    	jne    f0101115 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010126f:	85 f6                	test   %esi,%esi
f0101271:	7f 19                	jg     f010128c <check_page_free_list+0x285>
f0101273:	68 a1 7b 10 f0       	push   $0xf0107ba1
f0101278:	68 17 7b 10 f0       	push   $0xf0107b17
f010127d:	68 7b 03 00 00       	push   $0x37b
f0101282:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101287:	e8 b4 ed ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010128c:	85 db                	test   %ebx,%ebx
f010128e:	7f 19                	jg     f01012a9 <check_page_free_list+0x2a2>
f0101290:	68 b3 7b 10 f0       	push   $0xf0107bb3
f0101295:	68 17 7b 10 f0       	push   $0xf0107b17
f010129a:	68 7c 03 00 00       	push   $0x37c
f010129f:	68 f1 7a 10 f0       	push   $0xf0107af1
f01012a4:	e8 97 ed ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01012a9:	83 ec 0c             	sub    $0xc,%esp
f01012ac:	68 6c 72 10 f0       	push   $0xf010726c
f01012b1:	e8 bf 29 00 00       	call   f0103c75 <cprintf>
}
f01012b6:	eb 49                	jmp    f0101301 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01012b8:	a1 40 a2 21 f0       	mov    0xf021a240,%eax
f01012bd:	85 c0                	test   %eax,%eax
f01012bf:	0f 85 6f fd ff ff    	jne    f0101034 <check_page_free_list+0x2d>
f01012c5:	e9 53 fd ff ff       	jmp    f010101d <check_page_free_list+0x16>
f01012ca:	83 3d 40 a2 21 f0 00 	cmpl   $0x0,0xf021a240
f01012d1:	0f 84 46 fd ff ff    	je     f010101d <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012d7:	be 00 04 00 00       	mov    $0x400,%esi
f01012dc:	e9 a1 fd ff ff       	jmp    f0101082 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01012e1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01012e6:	0f 85 76 ff ff ff    	jne    f0101262 <check_page_free_list+0x25b>
f01012ec:	e9 53 ff ff ff       	jmp    f0101244 <check_page_free_list+0x23d>
f01012f1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01012f6:	0f 85 61 ff ff ff    	jne    f010125d <check_page_free_list+0x256>
f01012fc:	e9 43 ff ff ff       	jmp    f0101244 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0101301:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101304:	5b                   	pop    %ebx
f0101305:	5e                   	pop    %esi
f0101306:	5f                   	pop    %edi
f0101307:	5d                   	pop    %ebp
f0101308:	c3                   	ret    

f0101309 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101309:	55                   	push   %ebp
f010130a:	89 e5                	mov    %esp,%ebp
f010130c:	57                   	push   %edi
f010130d:	56                   	push   %esi
f010130e:	53                   	push   %ebx
f010130f:	83 ec 1c             	sub    $0x1c,%esp
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	

	// mark physical page 0 as in use
	pages[0].pp_ref = 1;
f0101312:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f0101317:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

	page_free_list = &pages[1];
f010131d:	83 c0 08             	add    $0x8,%eax
f0101320:	a3 40 a2 21 f0       	mov    %eax,0xf021a240
	
	int next_free = PADDR(boot_alloc(0));
f0101325:	b8 00 00 00 00       	mov    $0x0,%eax
f010132a:	e8 00 fc ff ff       	call   f0100f2f <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010132f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101334:	77 15                	ja     f010134b <page_init+0x42>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101336:	50                   	push   %eax
f0101337:	68 68 6a 10 f0       	push   $0xf0106a68
f010133c:	68 67 01 00 00       	push   $0x167
f0101341:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101346:	e8 f5 ec ff ff       	call   f0100040 <_panic>
f010134b:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi

	size_t i;
	// rest of base memory
	for(i = 1; i < npages_basemem - 1; ++i) {
f0101351:	a1 44 a2 21 f0       	mov    0xf021a244,%eax
f0101356:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101359:	8d 70 ff             	lea    -0x1(%eax),%esi
f010135c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101361:	eb 1f                	jmp    f0101382 <page_init+0x79>
		pages[i].pp_ref = 0;
f0101363:	8b 1d 90 ae 21 f0    	mov    0xf021ae90,%ebx
f0101369:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0101370:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0101373:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = &pages[i+1];
f0101379:	83 c0 01             	add    $0x1,%eax
f010137c:	8d 4c 0b 08          	lea    0x8(%ebx,%ecx,1),%ecx
f0101380:	89 0a                	mov    %ecx,(%edx)
	
	int next_free = PADDR(boot_alloc(0));

	size_t i;
	// rest of base memory
	for(i = 1; i < npages_basemem - 1; ++i) {
f0101382:	39 f0                	cmp    %esi,%eax
f0101384:	72 dd                	jb     f0101363 <page_init+0x5a>
		pages[i].pp_ref = 0;
		pages[i].pp_link = &pages[i+1];
	}
	pages[npages_basemem-1].pp_ref = 0;
f0101386:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f010138b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010138e:	8d 54 f0 f8          	lea    -0x8(%eax,%esi,8),%edx
f0101392:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
	pages[npages_basemem-1].pp_link = &pages[next_free/PGSIZE];
f0101398:	8d 8f ff 0f 00 00    	lea    0xfff(%edi),%ecx
f010139e:	85 ff                	test   %edi,%edi
f01013a0:	0f 48 f9             	cmovs  %ecx,%edi
f01013a3:	c1 ff 0c             	sar    $0xc,%edi
f01013a6:	89 fb                	mov    %edi,%ebx
f01013a8:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f01013af:	01 c8                	add    %ecx,%eax
f01013b1:	89 02                	mov    %eax,(%edx)

	/*************************************************************/
	/********************* Code for lab 4 ************************/
	pages[MPENTRY_PADDR/PGSIZE].pp_ref = 1;
f01013b3:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f01013b8:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
	pages[MPENTRY_PADDR/PGSIZE-1].pp_link = pages[MPENTRY_PADDR/PGSIZE].pp_link;
f01013be:	8b 50 38             	mov    0x38(%eax),%edx
f01013c1:	89 50 30             	mov    %edx,0x30(%eax)
	pages[MPENTRY_PADDR/PGSIZE].pp_link = NULL;
f01013c4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f01013cb:	b8 00 05 00 00       	mov    $0x500,%eax
	/*************************************************************/

	// the IO hole
	for(i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE; ++i) {
		pages[i].pp_ref = 1;
f01013d0:	89 c2                	mov    %eax,%edx
f01013d2:	03 15 90 ae 21 f0    	add    0xf021ae90,%edx
f01013d8:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f01013de:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f01013e4:	83 c0 08             	add    $0x8,%eax
	pages[MPENTRY_PADDR/PGSIZE-1].pp_link = pages[MPENTRY_PADDR/PGSIZE].pp_link;
	pages[MPENTRY_PADDR/PGSIZE].pp_link = NULL;
	/*************************************************************/

	// the IO hole
	for(i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE; ++i) {
f01013e7:	3d 00 08 00 00       	cmp    $0x800,%eax
f01013ec:	75 e2                	jne    f01013d0 <page_init+0xc7>
f01013ee:	b8 00 01 00 00       	mov    $0x100,%eax
f01013f3:	eb 18                	jmp    f010140d <page_init+0x104>
		pages[i].pp_link = NULL;
	}

	// [EXTPHYSMEM, nextfree) is in use
	for(i = EXTPHYSMEM / PGSIZE; i < next_free / PGSIZE; ++i) {
		pages[i].pp_ref = 1;
f01013f5:	8b 15 90 ae 21 f0    	mov    0xf021ae90,%edx
f01013fb:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f01013fe:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0101404:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}

	// [EXTPHYSMEM, nextfree) is in use
	for(i = EXTPHYSMEM / PGSIZE; i < next_free / PGSIZE; ++i) {
f010140a:	83 c0 01             	add    $0x1,%eax
f010140d:	39 d8                	cmp    %ebx,%eax
f010140f:	72 e4                	jb     f01013f5 <page_init+0xec>
f0101411:	eb 16                	jmp    f0101429 <page_init+0x120>
		pages[i].pp_link = NULL;
	}

	// the rest memory is free
	for(i = next_free / PGSIZE; i < npages - 1; ++i) {
		pages[i].pp_ref = 0;
f0101413:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f0101418:	01 c1                	add    %eax,%ecx
f010141a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = &pages[i+1];
f0101420:	83 c3 01             	add    $0x1,%ebx
f0101423:	01 d0                	add    %edx,%eax
f0101425:	89 01                	mov    %eax,(%ecx)
f0101427:	89 d1                	mov    %edx,%ecx
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}

	// the rest memory is free
	for(i = next_free / PGSIZE; i < npages - 1; ++i) {
f0101429:	a1 88 ae 21 f0       	mov    0xf021ae88,%eax
f010142e:	8d 51 08             	lea    0x8(%ecx),%edx
f0101431:	8d 70 ff             	lea    -0x1(%eax),%esi
f0101434:	39 f3                	cmp    %esi,%ebx
f0101436:	72 db                	jb     f0101413 <page_init+0x10a>
		pages[i].pp_ref = 0;
		pages[i].pp_link = &pages[i+1];
	}
	pages[npages-1].pp_ref = 0;
f0101438:	8b 15 90 ae 21 f0    	mov    0xf021ae90,%edx
f010143e:	8d 44 c2 f8          	lea    -0x8(%edx,%eax,8),%eax
f0101442:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pages[npages-1].pp_link = NULL;
f0101448:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010144e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101451:	5b                   	pop    %ebx
f0101452:	5e                   	pop    %esi
f0101453:	5f                   	pop    %edi
f0101454:	5d                   	pop    %ebp
f0101455:	c3                   	ret    

f0101456 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101456:	55                   	push   %ebp
f0101457:	89 e5                	mov    %esp,%ebp
f0101459:	53                   	push   %ebx
f010145a:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list == NULL) {
f010145d:	8b 1d 40 a2 21 f0    	mov    0xf021a240,%ebx
f0101463:	85 db                	test   %ebx,%ebx
f0101465:	74 58                	je     f01014bf <page_alloc+0x69>
		return NULL;
	}
	else {
		struct PageInfo *tmp = page_free_list;
		page_free_list = page_free_list->pp_link;
f0101467:	8b 03                	mov    (%ebx),%eax
f0101469:	a3 40 a2 21 f0       	mov    %eax,0xf021a240
		tmp->pp_link = NULL;
f010146e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(alloc_flags & ALLOC_ZERO) {
f0101474:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101478:	74 45                	je     f01014bf <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010147a:	89 d8                	mov    %ebx,%eax
f010147c:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0101482:	c1 f8 03             	sar    $0x3,%eax
f0101485:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101488:	89 c2                	mov    %eax,%edx
f010148a:	c1 ea 0c             	shr    $0xc,%edx
f010148d:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f0101493:	72 12                	jb     f01014a7 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101495:	50                   	push   %eax
f0101496:	68 44 6a 10 f0       	push   $0xf0106a44
f010149b:	6a 58                	push   $0x58
f010149d:	68 fd 7a 10 f0       	push   $0xf0107afd
f01014a2:	e8 99 eb ff ff       	call   f0100040 <_panic>
			memset(page2kva(tmp), 0, PGSIZE);
f01014a7:	83 ec 04             	sub    $0x4,%esp
f01014aa:	68 00 10 00 00       	push   $0x1000
f01014af:	6a 00                	push   $0x0
f01014b1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014b6:	50                   	push   %eax
f01014b7:	e8 3d 48 00 00       	call   f0105cf9 <memset>
f01014bc:	83 c4 10             	add    $0x10,%esp
		}
		return tmp;
	}
}
f01014bf:	89 d8                	mov    %ebx,%eax
f01014c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014c4:	c9                   	leave  
f01014c5:	c3                   	ret    

f01014c6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01014c6:	55                   	push   %ebp
f01014c7:	89 e5                	mov    %esp,%ebp
f01014c9:	83 ec 08             	sub    $0x8,%esp
f01014cc:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0) {
f01014cf:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014d4:	74 17                	je     f01014ed <page_free+0x27>
		panic("pp->pp_ref is nonzero");
f01014d6:	83 ec 04             	sub    $0x4,%esp
f01014d9:	68 c4 7b 10 f0       	push   $0xf0107bc4
f01014de:	68 b6 01 00 00       	push   $0x1b6
f01014e3:	68 f1 7a 10 f0       	push   $0xf0107af1
f01014e8:	e8 53 eb ff ff       	call   f0100040 <_panic>
	}
	else if(pp->pp_link != NULL) {
f01014ed:	83 38 00             	cmpl   $0x0,(%eax)
f01014f0:	74 17                	je     f0101509 <page_free+0x43>
		panic("pp->pp_link is not NULL");
f01014f2:	83 ec 04             	sub    $0x4,%esp
f01014f5:	68 da 7b 10 f0       	push   $0xf0107bda
f01014fa:	68 b9 01 00 00       	push   $0x1b9
f01014ff:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101504:	e8 37 eb ff ff       	call   f0100040 <_panic>
	}
	else {
		if(page_free_list == NULL) {
f0101509:	8b 15 40 a2 21 f0    	mov    0xf021a240,%edx
f010150f:	85 d2                	test   %edx,%edx
f0101511:	75 07                	jne    f010151a <page_free+0x54>
			page_free_list = pp;
f0101513:	a3 40 a2 21 f0       	mov    %eax,0xf021a240
f0101518:	eb 07                	jmp    f0101521 <page_free+0x5b>
		}
		else {
			pp->pp_link = page_free_list;
f010151a:	89 10                	mov    %edx,(%eax)
			page_free_list = pp;
f010151c:	a3 40 a2 21 f0       	mov    %eax,0xf021a240
		}
	}
}
f0101521:	c9                   	leave  
f0101522:	c3                   	ret    

f0101523 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101523:	55                   	push   %ebp
f0101524:	89 e5                	mov    %esp,%ebp
f0101526:	83 ec 08             	sub    $0x8,%esp
f0101529:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010152c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101530:	83 e8 01             	sub    $0x1,%eax
f0101533:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101537:	66 85 c0             	test   %ax,%ax
f010153a:	75 0c                	jne    f0101548 <page_decref+0x25>
		page_free(pp);
f010153c:	83 ec 0c             	sub    $0xc,%esp
f010153f:	52                   	push   %edx
f0101540:	e8 81 ff ff ff       	call   f01014c6 <page_free>
f0101545:	83 c4 10             	add    $0x10,%esp
}
f0101548:	c9                   	leave  
f0101549:	c3                   	ret    

f010154a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010154a:	55                   	push   %ebp
f010154b:	89 e5                	mov    %esp,%ebp
f010154d:	56                   	push   %esi
f010154e:	53                   	push   %ebx
f010154f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pde_t *page_directory_entry = pgdir + PDX(va);
f0101552:	89 de                	mov    %ebx,%esi
f0101554:	c1 ee 16             	shr    $0x16,%esi
f0101557:	c1 e6 02             	shl    $0x2,%esi
f010155a:	03 75 08             	add    0x8(%ebp),%esi

	// if the page table page exists
	if(*page_directory_entry & PTE_P) {
f010155d:	8b 06                	mov    (%esi),%eax
f010155f:	a8 01                	test   $0x1,%al
f0101561:	74 39                	je     f010159c <pgdir_walk+0x52>
		// find the physical address of page table page and the page table entry 
		physaddr_t P_page_table = *page_directory_entry & 0xFFFFF000;
f0101563:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101568:	89 c2                	mov    %eax,%edx
f010156a:	c1 ea 0c             	shr    $0xc,%edx
f010156d:	39 15 88 ae 21 f0    	cmp    %edx,0xf021ae88
f0101573:	77 15                	ja     f010158a <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101575:	50                   	push   %eax
f0101576:	68 44 6a 10 f0       	push   $0xf0106a44
f010157b:	68 f0 01 00 00       	push   $0x1f0
f0101580:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101585:	e8 b6 ea ff ff       	call   f0100040 <_panic>
		pte_t *page_table = (pte_t *)KADDR(P_page_table);
		pte_t *page_table_entry = page_table + PTX(va);
f010158a:	c1 eb 0a             	shr    $0xa,%ebx
f010158d:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
		
		// turn the physical address into kernel virtual address
		return page_table_entry;
f0101593:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010159a:	eb 6f                	jmp    f010160b <pgdir_walk+0xc1>
	}
	// if the page table page does not exit
	else {
		if(create == false) {
f010159c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015a0:	74 5d                	je     f01015ff <pgdir_walk+0xb5>
			return NULL;
		}
		else {
			struct PageInfo *page_table_page = page_alloc(ALLOC_ZERO);
f01015a2:	83 ec 0c             	sub    $0xc,%esp
f01015a5:	6a 01                	push   $0x1
f01015a7:	e8 aa fe ff ff       	call   f0101456 <page_alloc>
			// no more room to allocate a new page
			if(page_table_page == NULL)
f01015ac:	83 c4 10             	add    $0x10,%esp
f01015af:	85 c0                	test   %eax,%eax
f01015b1:	74 53                	je     f0101606 <pgdir_walk+0xbc>
				return NULL;
			else {
				page_table_page->pp_ref++;
f01015b3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015b8:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f01015be:	c1 f8 03             	sar    $0x3,%eax
f01015c1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015c4:	89 c2                	mov    %eax,%edx
f01015c6:	c1 ea 0c             	shr    $0xc,%edx
f01015c9:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f01015cf:	72 15                	jb     f01015e6 <pgdir_walk+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015d1:	50                   	push   %eax
f01015d2:	68 44 6a 10 f0       	push   $0xf0106a44
f01015d7:	68 05 02 00 00       	push   $0x205
f01015dc:	68 f1 7a 10 f0       	push   $0xf0107af1
f01015e1:	e8 5a ea ff ff       	call   f0100040 <_panic>
				
				// turn the PageInfo * into the physical address of the page table
				physaddr_t P_page_table = page2pa(page_table_page);
				pte_t *page_table = (pte_t *)KADDR(P_page_table);
				pte_t *page_table_entry = page_table + PTX(va);
f01015e6:	c1 eb 0a             	shr    $0xa,%ebx
f01015e9:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
				
				*page_directory_entry = P_page_table | PTE_P; 
f01015ef:	89 c2                	mov    %eax,%edx
f01015f1:	83 ca 01             	or     $0x1,%edx
f01015f4:	89 16                	mov    %edx,(%esi)

				return page_table_entry;
f01015f6:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01015fd:	eb 0c                	jmp    f010160b <pgdir_walk+0xc1>
		return page_table_entry;
	}
	// if the page table page does not exit
	else {
		if(create == false) {
			return NULL;
f01015ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0101604:	eb 05                	jmp    f010160b <pgdir_walk+0xc1>
		}
		else {
			struct PageInfo *page_table_page = page_alloc(ALLOC_ZERO);
			// no more room to allocate a new page
			if(page_table_page == NULL)
				return NULL;
f0101606:	b8 00 00 00 00       	mov    $0x0,%eax

				return page_table_entry;
			}
		}
	}
}
f010160b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010160e:	5b                   	pop    %ebx
f010160f:	5e                   	pop    %esi
f0101610:	5d                   	pop    %ebp
f0101611:	c3                   	ret    

f0101612 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101612:	55                   	push   %ebp
f0101613:	89 e5                	mov    %esp,%ebp
f0101615:	57                   	push   %edi
f0101616:	56                   	push   %esi
f0101617:	53                   	push   %ebx
f0101618:	83 ec 1c             	sub    $0x1c,%esp
f010161b:	89 c7                	mov    %eax,%edi
f010161d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	for(uintptr_t offset = 0; offset < size; offset += PGSIZE) {
f0101620:	89 d3                	mov    %edx,%ebx
f0101622:	be 00 00 00 00       	mov    $0x0,%esi
f0101627:	8b 45 0c             	mov    0xc(%ebp),%eax
f010162a:	83 c8 01             	or     $0x1,%eax
f010162d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101630:	eb 2f                	jmp    f0101661 <boot_map_region+0x4f>
		// find and set the page table entry
		pte_t *page_table_entry = pgdir_walk(pgdir, (void *)(va+offset), true);
f0101632:	83 ec 04             	sub    $0x4,%esp
f0101635:	6a 01                	push   $0x1
f0101637:	53                   	push   %ebx
f0101638:	57                   	push   %edi
f0101639:	e8 0c ff ff ff       	call   f010154a <pgdir_walk>
		*page_table_entry = (pa+offset) | perm | PTE_P;
f010163e:	89 f2                	mov    %esi,%edx
f0101640:	03 55 08             	add    0x8(%ebp),%edx
f0101643:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101646:	09 ca                	or     %ecx,%edx
f0101648:	89 10                	mov    %edx,(%eax)

		//find and set the page dirctory entry
		pde_t *page_directory_entry = pgdir + PDX(va+offset);
f010164a:	89 d8                	mov    %ebx,%eax
f010164c:	c1 e8 16             	shr    $0x16,%eax
		*page_directory_entry = *page_directory_entry | perm | PTE_P;
f010164f:	09 0c 87             	or     %ecx,(%edi,%eax,4)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	for(uintptr_t offset = 0; offset < size; offset += PGSIZE) {
f0101652:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101658:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101664:	72 cc                	jb     f0101632 <boot_map_region+0x20>

		//find and set the page dirctory entry
		pde_t *page_directory_entry = pgdir + PDX(va+offset);
		*page_directory_entry = *page_directory_entry | perm | PTE_P;
	}
}
f0101666:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101669:	5b                   	pop    %ebx
f010166a:	5e                   	pop    %esi
f010166b:	5f                   	pop    %edi
f010166c:	5d                   	pop    %ebp
f010166d:	c3                   	ret    

f010166e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010166e:	55                   	push   %ebp
f010166f:	89 e5                	mov    %esp,%ebp
f0101671:	53                   	push   %ebx
f0101672:	83 ec 08             	sub    $0x8,%esp
f0101675:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *page_table_entry = pgdir_walk(pgdir, va, false);
f0101678:	6a 00                	push   $0x0
f010167a:	ff 75 0c             	pushl  0xc(%ebp)
f010167d:	ff 75 08             	pushl  0x8(%ebp)
f0101680:	e8 c5 fe ff ff       	call   f010154a <pgdir_walk>
	// their is no page table for the virtual address or the entry is invalid
	if(page_table_entry==NULL || !(*page_table_entry&PTE_P))
f0101685:	83 c4 10             	add    $0x10,%esp
f0101688:	85 c0                	test   %eax,%eax
f010168a:	74 3c                	je     f01016c8 <page_lookup+0x5a>
f010168c:	8b 10                	mov    (%eax),%edx
f010168e:	f6 c2 01             	test   $0x1,%dl
f0101691:	74 3c                	je     f01016cf <page_lookup+0x61>
		return NULL;
	else {
		// calculate the physical address
		physaddr_t pa = (physaddr_t)(*page_table_entry) & 0xFFFFF000;
f0101693:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

		if(pte_store != NULL) {
f0101699:	85 db                	test   %ebx,%ebx
f010169b:	74 02                	je     f010169f <page_lookup+0x31>
			// store the address of the pte for this page in pte_store
			*pte_store = page_table_entry;
f010169d:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010169f:	c1 ea 0c             	shr    $0xc,%edx
f01016a2:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f01016a8:	72 14                	jb     f01016be <page_lookup+0x50>
		panic("pa2page called with invalid pa");
f01016aa:	83 ec 04             	sub    $0x4,%esp
f01016ad:	68 90 72 10 f0       	push   $0xf0107290
f01016b2:	6a 51                	push   $0x51
f01016b4:	68 fd 7a 10 f0       	push   $0xf0107afd
f01016b9:	e8 82 e9 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01016be:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f01016c3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		}

		return pa2page(pa);
f01016c6:	eb 0c                	jmp    f01016d4 <page_lookup+0x66>
{
	// Fill this function in
	pte_t *page_table_entry = pgdir_walk(pgdir, va, false);
	// their is no page table for the virtual address or the entry is invalid
	if(page_table_entry==NULL || !(*page_table_entry&PTE_P))
		return NULL;
f01016c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01016cd:	eb 05                	jmp    f01016d4 <page_lookup+0x66>
f01016cf:	b8 00 00 00 00       	mov    $0x0,%eax
			*pte_store = page_table_entry;
		}

		return pa2page(pa);
	}
}
f01016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016d7:	c9                   	leave  
f01016d8:	c3                   	ret    

f01016d9 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01016d9:	55                   	push   %ebp
f01016da:	89 e5                	mov    %esp,%ebp
f01016dc:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01016df:	e8 ae 4c 00 00       	call   f0106392 <cpunum>
f01016e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01016e7:	83 b8 28 b0 21 f0 00 	cmpl   $0x0,-0xfde4fd8(%eax)
f01016ee:	74 16                	je     f0101706 <tlb_invalidate+0x2d>
f01016f0:	e8 9d 4c 00 00       	call   f0106392 <cpunum>
f01016f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01016f8:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f01016fe:	8b 55 08             	mov    0x8(%ebp),%edx
f0101701:	39 50 60             	cmp    %edx,0x60(%eax)
f0101704:	75 06                	jne    f010170c <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101706:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101709:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010170c:	c9                   	leave  
f010170d:	c3                   	ret    

f010170e <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010170e:	55                   	push   %ebp
f010170f:	89 e5                	mov    %esp,%ebp
f0101711:	56                   	push   %esi
f0101712:	53                   	push   %ebx
f0101713:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101716:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo *page = page_lookup(pgdir, va, NULL);
f0101719:	83 ec 04             	sub    $0x4,%esp
f010171c:	6a 00                	push   $0x0
f010171e:	56                   	push   %esi
f010171f:	53                   	push   %ebx
f0101720:	e8 49 ff ff ff       	call   f010166e <page_lookup>

	if(page != NULL) {
f0101725:	83 c4 10             	add    $0x10,%esp
f0101728:	85 c0                	test   %eax,%eax
f010172a:	74 28                	je     f0101754 <page_remove+0x46>
		// decrease the ref count and free the page if it reaches 0
		page_decref(page);
f010172c:	83 ec 0c             	sub    $0xc,%esp
f010172f:	50                   	push   %eax
f0101730:	e8 ee fd ff ff       	call   f0101523 <page_decref>

		// set the pg table entry to 0
		pte_t *page_table_entry = pgdir_walk(pgdir, va, false);
f0101735:	83 c4 0c             	add    $0xc,%esp
f0101738:	6a 00                	push   $0x0
f010173a:	56                   	push   %esi
f010173b:	53                   	push   %ebx
f010173c:	e8 09 fe ff ff       	call   f010154a <pgdir_walk>
		*page_table_entry = 0;
f0101741:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

		// invalid the TLB
		tlb_invalidate(pgdir, va);
f0101747:	83 c4 08             	add    $0x8,%esp
f010174a:	56                   	push   %esi
f010174b:	53                   	push   %ebx
f010174c:	e8 88 ff ff ff       	call   f01016d9 <tlb_invalidate>
f0101751:	83 c4 10             	add    $0x10,%esp
	}
}
f0101754:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101757:	5b                   	pop    %ebx
f0101758:	5e                   	pop    %esi
f0101759:	5d                   	pop    %ebp
f010175a:	c3                   	ret    

f010175b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010175b:	55                   	push   %ebp
f010175c:	89 e5                	mov    %esp,%ebp
f010175e:	57                   	push   %edi
f010175f:	56                   	push   %esi
f0101760:	53                   	push   %ebx
f0101761:	83 ec 20             	sub    $0x20,%esp
f0101764:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101767:	8b 7d 0c             	mov    0xc(%ebp),%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010176a:	89 f8                	mov    %edi,%eax
f010176c:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0101772:	c1 f8 03             	sar    $0x3,%eax
f0101775:	c1 e0 0c             	shl    $0xc,%eax
f0101778:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// the corresponding physical address
	//cprintf("insert page %d\n", pp-pages);
	physaddr_t pa = page2pa(pp);

	// the page table entry for the virtual address
	pte_t *page_table_entry = pgdir_walk(pgdir, va, true);
f010177b:	6a 01                	push   $0x1
f010177d:	ff 75 10             	pushl  0x10(%ebp)
f0101780:	53                   	push   %ebx
f0101781:	e8 c4 fd ff ff       	call   f010154a <pgdir_walk>
	//cprintf("FUNCTION page_insert : page table entry is 0x%08x\n", page_table_entry);

	// page table couldn't be allocted
	if(page_table_entry == NULL) {
f0101786:	83 c4 10             	add    $0x10,%esp
f0101789:	85 c0                	test   %eax,%eax
f010178b:	74 50                	je     f01017dd <page_insert+0x82>
f010178d:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
	}
	// the virtual address has not yet been maped
	else if(!(*page_table_entry & PTE_P)) {
f010178f:	f6 00 01             	testb  $0x1,(%eax)
f0101792:	75 14                	jne    f01017a8 <page_insert+0x4d>
		*page_table_entry = pa | PTE_P | perm;
f0101794:	8b 55 14             	mov    0x14(%ebp),%edx
f0101797:	83 ca 01             	or     $0x1,%edx
f010179a:	89 d0                	mov    %edx,%eax
f010179c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010179f:	89 06                	mov    %eax,(%esi)

		pp->pp_ref++;
f01017a1:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
f01017a6:	eb 1f                	jmp    f01017c7 <page_insert+0x6c>
	}
	// the virtual address has already maped to a physical address
	else {
		pp->pp_ref++;
f01017a8:	66 83 47 04 01       	addw   $0x1,0x4(%edi)

		// remove the physical addresss
		page_remove(pgdir, va);
f01017ad:	83 ec 08             	sub    $0x8,%esp
f01017b0:	ff 75 10             	pushl  0x10(%ebp)
f01017b3:	53                   	push   %ebx
f01017b4:	e8 55 ff ff ff       	call   f010170e <page_remove>

		*page_table_entry = pa | PTE_P | perm;
f01017b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01017bc:	83 c8 01             	or     $0x1,%eax
f01017bf:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01017c2:	89 06                	mov    %eax,(%esi)
f01017c4:	83 c4 10             	add    $0x10,%esp
		
	}

	// change permission of page dirctory entry
	pde_t *page_directory_entry = pgdir + PDX(va);
f01017c7:	8b 45 10             	mov    0x10(%ebp),%eax
f01017ca:	c1 e8 16             	shr    $0x16,%eax
	*page_directory_entry = *page_directory_entry | PTE_P | perm;
f01017cd:	8b 55 14             	mov    0x14(%ebp),%edx
f01017d0:	83 ca 01             	or     $0x1,%edx
f01017d3:	09 14 83             	or     %edx,(%ebx,%eax,4)

	return 0;
f01017d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01017db:	eb 05                	jmp    f01017e2 <page_insert+0x87>
	pte_t *page_table_entry = pgdir_walk(pgdir, va, true);
	//cprintf("FUNCTION page_insert : page table entry is 0x%08x\n", page_table_entry);

	// page table couldn't be allocted
	if(page_table_entry == NULL) {
		return -E_NO_MEM;
f01017dd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pde_t *page_directory_entry = pgdir + PDX(va);
	*page_directory_entry = *page_directory_entry | PTE_P | perm;

	return 0;

}
f01017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01017e5:	5b                   	pop    %ebx
f01017e6:	5e                   	pop    %esi
f01017e7:	5f                   	pop    %edi
f01017e8:	5d                   	pop    %ebp
f01017e9:	c3                   	ret    

f01017ea <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01017ea:	55                   	push   %ebp
f01017eb:	89 e5                	mov    %esp,%ebp
f01017ed:	53                   	push   %ebx
f01017ee:	83 ec 04             	sub    $0x4,%esp
f01017f1:	8b 55 08             	mov    0x8(%ebp),%edx
f01017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	if(size == 0) 
f01017f7:	85 c0                	test   %eax,%eax
f01017f9:	75 07                	jne    f0101802 <mmio_map_region+0x18>
		return (void *)base;
f01017fb:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f0101800:	eb 60                	jmp    f0101862 <mmio_map_region+0x78>

	physaddr_t begin_pa = ROUNDDOWN(pa, PGSIZE);
f0101802:	89 d1                	mov    %edx,%ecx
f0101804:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	physaddr_t end_pa = ROUNDUP(pa+size, PGSIZE);
f010180a:	8d 9c 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%ebx
	size_t aligned_size = (size_t)end_pa - (size_t)begin_pa;
f0101811:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101817:	29 cb                	sub    %ecx,%ebx

	// check whether it would overflow MMIOLIM
	if(base + aligned_size > MMIOLIM)
f0101819:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f010181f:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101822:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101827:	76 17                	jbe    f0101840 <mmio_map_region+0x56>
		panic("this reservation would overflow MMIOLIM");
f0101829:	83 ec 04             	sub    $0x4,%esp
f010182c:	68 b0 72 10 f0       	push   $0xf01072b0
f0101831:	68 e2 02 00 00       	push   $0x2e2
f0101836:	68 f1 7a 10 f0       	push   $0xf0107af1
f010183b:	e8 00 e8 ff ff       	call   f0100040 <_panic>

	// map base to pa
	/*for(size_t i = 0; i < aligned_size; i += PGSIZE) {
		page_insert(curenv->env_pgdir, pa2page(pa+i), (void *)(base+i), PTE_PCD|PTE_PWT|PTE_W);
	}*/
	boot_map_region(kern_pgdir, base, aligned_size, begin_pa, PTE_PCD|PTE_PWT|PTE_W);
f0101840:	83 ec 08             	sub    $0x8,%esp
f0101843:	6a 1a                	push   $0x1a
f0101845:	51                   	push   %ecx
f0101846:	89 d9                	mov    %ebx,%ecx
f0101848:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f010184d:	e8 c0 fd ff ff       	call   f0101612 <boot_map_region>

	// update base
	uintptr_t old_base = base;
f0101852:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base = base + aligned_size;
f0101857:	01 c3                	add    %eax,%ebx
f0101859:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	
	return (void *)old_base;
f010185f:	83 c4 10             	add    $0x10,%esp
}
f0101862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101865:	c9                   	leave  
f0101866:	c3                   	ret    

f0101867 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101867:	55                   	push   %ebp
f0101868:	89 e5                	mov    %esp,%ebp
f010186a:	57                   	push   %edi
f010186b:	56                   	push   %esi
f010186c:	53                   	push   %ebx
f010186d:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101870:	b8 15 00 00 00       	mov    $0x15,%eax
f0101875:	e8 00 f7 ff ff       	call   f0100f7a <nvram_read>
f010187a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010187c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101881:	e8 f4 f6 ff ff       	call   f0100f7a <nvram_read>
f0101886:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101888:	b8 34 00 00 00       	mov    $0x34,%eax
f010188d:	e8 e8 f6 ff ff       	call   f0100f7a <nvram_read>
f0101892:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101895:	85 c0                	test   %eax,%eax
f0101897:	74 07                	je     f01018a0 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101899:	05 00 40 00 00       	add    $0x4000,%eax
f010189e:	eb 0b                	jmp    f01018ab <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01018a0:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01018a6:	85 f6                	test   %esi,%esi
f01018a8:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01018ab:	89 c2                	mov    %eax,%edx
f01018ad:	c1 ea 02             	shr    $0x2,%edx
f01018b0:	89 15 88 ae 21 f0    	mov    %edx,0xf021ae88
	npages_basemem = basemem / (PGSIZE / 1024);
f01018b6:	89 da                	mov    %ebx,%edx
f01018b8:	c1 ea 02             	shr    $0x2,%edx
f01018bb:	89 15 44 a2 21 f0    	mov    %edx,0xf021a244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01018c1:	89 c2                	mov    %eax,%edx
f01018c3:	29 da                	sub    %ebx,%edx
f01018c5:	52                   	push   %edx
f01018c6:	53                   	push   %ebx
f01018c7:	50                   	push   %eax
f01018c8:	68 d8 72 10 f0       	push   $0xf01072d8
f01018cd:	e8 a3 23 00 00       	call   f0103c75 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01018d2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01018d7:	e8 53 f6 ff ff       	call   f0100f2f <boot_alloc>
f01018dc:	a3 8c ae 21 f0       	mov    %eax,0xf021ae8c
	memset(kern_pgdir, 0, PGSIZE);
f01018e1:	83 c4 0c             	add    $0xc,%esp
f01018e4:	68 00 10 00 00       	push   $0x1000
f01018e9:	6a 00                	push   $0x0
f01018eb:	50                   	push   %eax
f01018ec:	e8 08 44 00 00       	call   f0105cf9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018f1:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01018f6:	83 c4 10             	add    $0x10,%esp
f01018f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018fe:	77 15                	ja     f0101915 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101900:	50                   	push   %eax
f0101901:	68 68 6a 10 f0       	push   $0xf0106a68
f0101906:	68 9d 00 00 00       	push   $0x9d
f010190b:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101910:	e8 2b e7 ff ff       	call   f0100040 <_panic>
f0101915:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010191b:	83 ca 05             	or     $0x5,%edx
f010191e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101924:	a1 88 ae 21 f0       	mov    0xf021ae88,%eax
f0101929:	c1 e0 03             	shl    $0x3,%eax
f010192c:	e8 fe f5 ff ff       	call   f0100f2f <boot_alloc>
f0101931:	a3 90 ae 21 f0       	mov    %eax,0xf021ae90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101936:	83 ec 04             	sub    $0x4,%esp
f0101939:	8b 0d 88 ae 21 f0    	mov    0xf021ae88,%ecx
f010193f:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101946:	52                   	push   %edx
f0101947:	6a 00                	push   $0x0
f0101949:	50                   	push   %eax
f010194a:	e8 aa 43 00 00       	call   f0105cf9 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f010194f:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101954:	e8 d6 f5 ff ff       	call   f0100f2f <boot_alloc>
f0101959:	a3 48 a2 21 f0       	mov    %eax,0xf021a248
	memset(envs, 0, NENV * sizeof(struct Env));
f010195e:	83 c4 0c             	add    $0xc,%esp
f0101961:	68 00 f0 01 00       	push   $0x1f000
f0101966:	6a 00                	push   $0x0
f0101968:	50                   	push   %eax
f0101969:	e8 8b 43 00 00       	call   f0105cf9 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010196e:	e8 96 f9 ff ff       	call   f0101309 <page_init>

	check_page_free_list(1);
f0101973:	b8 01 00 00 00       	mov    $0x1,%eax
f0101978:	e8 8a f6 ff ff       	call   f0101007 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010197d:	83 c4 10             	add    $0x10,%esp
f0101980:	83 3d 90 ae 21 f0 00 	cmpl   $0x0,0xf021ae90
f0101987:	75 17                	jne    f01019a0 <mem_init+0x139>
		panic("'pages' is a null pointer!");
f0101989:	83 ec 04             	sub    $0x4,%esp
f010198c:	68 f2 7b 10 f0       	push   $0xf0107bf2
f0101991:	68 8f 03 00 00       	push   $0x38f
f0101996:	68 f1 7a 10 f0       	push   $0xf0107af1
f010199b:	e8 a0 e6 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01019a0:	a1 40 a2 21 f0       	mov    0xf021a240,%eax
f01019a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01019aa:	eb 05                	jmp    f01019b1 <mem_init+0x14a>
		++nfree;
f01019ac:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01019af:	8b 00                	mov    (%eax),%eax
f01019b1:	85 c0                	test   %eax,%eax
f01019b3:	75 f7                	jne    f01019ac <mem_init+0x145>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019b5:	83 ec 0c             	sub    $0xc,%esp
f01019b8:	6a 00                	push   $0x0
f01019ba:	e8 97 fa ff ff       	call   f0101456 <page_alloc>
f01019bf:	89 c7                	mov    %eax,%edi
f01019c1:	83 c4 10             	add    $0x10,%esp
f01019c4:	85 c0                	test   %eax,%eax
f01019c6:	75 19                	jne    f01019e1 <mem_init+0x17a>
f01019c8:	68 0d 7c 10 f0       	push   $0xf0107c0d
f01019cd:	68 17 7b 10 f0       	push   $0xf0107b17
f01019d2:	68 97 03 00 00       	push   $0x397
f01019d7:	68 f1 7a 10 f0       	push   $0xf0107af1
f01019dc:	e8 5f e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019e1:	83 ec 0c             	sub    $0xc,%esp
f01019e4:	6a 00                	push   $0x0
f01019e6:	e8 6b fa ff ff       	call   f0101456 <page_alloc>
f01019eb:	89 c6                	mov    %eax,%esi
f01019ed:	83 c4 10             	add    $0x10,%esp
f01019f0:	85 c0                	test   %eax,%eax
f01019f2:	75 19                	jne    f0101a0d <mem_init+0x1a6>
f01019f4:	68 23 7c 10 f0       	push   $0xf0107c23
f01019f9:	68 17 7b 10 f0       	push   $0xf0107b17
f01019fe:	68 98 03 00 00       	push   $0x398
f0101a03:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101a08:	e8 33 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a0d:	83 ec 0c             	sub    $0xc,%esp
f0101a10:	6a 00                	push   $0x0
f0101a12:	e8 3f fa ff ff       	call   f0101456 <page_alloc>
f0101a17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a1a:	83 c4 10             	add    $0x10,%esp
f0101a1d:	85 c0                	test   %eax,%eax
f0101a1f:	75 19                	jne    f0101a3a <mem_init+0x1d3>
f0101a21:	68 39 7c 10 f0       	push   $0xf0107c39
f0101a26:	68 17 7b 10 f0       	push   $0xf0107b17
f0101a2b:	68 99 03 00 00       	push   $0x399
f0101a30:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101a35:	e8 06 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a3a:	39 f7                	cmp    %esi,%edi
f0101a3c:	75 19                	jne    f0101a57 <mem_init+0x1f0>
f0101a3e:	68 4f 7c 10 f0       	push   $0xf0107c4f
f0101a43:	68 17 7b 10 f0       	push   $0xf0107b17
f0101a48:	68 9c 03 00 00       	push   $0x39c
f0101a4d:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101a52:	e8 e9 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a5a:	39 c6                	cmp    %eax,%esi
f0101a5c:	74 04                	je     f0101a62 <mem_init+0x1fb>
f0101a5e:	39 c7                	cmp    %eax,%edi
f0101a60:	75 19                	jne    f0101a7b <mem_init+0x214>
f0101a62:	68 14 73 10 f0       	push   $0xf0107314
f0101a67:	68 17 7b 10 f0       	push   $0xf0107b17
f0101a6c:	68 9d 03 00 00       	push   $0x39d
f0101a71:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101a76:	e8 c5 e5 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a7b:	8b 0d 90 ae 21 f0    	mov    0xf021ae90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a81:	8b 15 88 ae 21 f0    	mov    0xf021ae88,%edx
f0101a87:	c1 e2 0c             	shl    $0xc,%edx
f0101a8a:	89 f8                	mov    %edi,%eax
f0101a8c:	29 c8                	sub    %ecx,%eax
f0101a8e:	c1 f8 03             	sar    $0x3,%eax
f0101a91:	c1 e0 0c             	shl    $0xc,%eax
f0101a94:	39 d0                	cmp    %edx,%eax
f0101a96:	72 19                	jb     f0101ab1 <mem_init+0x24a>
f0101a98:	68 61 7c 10 f0       	push   $0xf0107c61
f0101a9d:	68 17 7b 10 f0       	push   $0xf0107b17
f0101aa2:	68 9e 03 00 00       	push   $0x39e
f0101aa7:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101aac:	e8 8f e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101ab1:	89 f0                	mov    %esi,%eax
f0101ab3:	29 c8                	sub    %ecx,%eax
f0101ab5:	c1 f8 03             	sar    $0x3,%eax
f0101ab8:	c1 e0 0c             	shl    $0xc,%eax
f0101abb:	39 c2                	cmp    %eax,%edx
f0101abd:	77 19                	ja     f0101ad8 <mem_init+0x271>
f0101abf:	68 7e 7c 10 f0       	push   $0xf0107c7e
f0101ac4:	68 17 7b 10 f0       	push   $0xf0107b17
f0101ac9:	68 9f 03 00 00       	push   $0x39f
f0101ace:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101ad3:	e8 68 e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ad8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101adb:	29 c8                	sub    %ecx,%eax
f0101add:	c1 f8 03             	sar    $0x3,%eax
f0101ae0:	c1 e0 0c             	shl    $0xc,%eax
f0101ae3:	39 c2                	cmp    %eax,%edx
f0101ae5:	77 19                	ja     f0101b00 <mem_init+0x299>
f0101ae7:	68 9b 7c 10 f0       	push   $0xf0107c9b
f0101aec:	68 17 7b 10 f0       	push   $0xf0107b17
f0101af1:	68 a0 03 00 00       	push   $0x3a0
f0101af6:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101afb:	e8 40 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b00:	a1 40 a2 21 f0       	mov    0xf021a240,%eax
f0101b05:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b08:	c7 05 40 a2 21 f0 00 	movl   $0x0,0xf021a240
f0101b0f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b12:	83 ec 0c             	sub    $0xc,%esp
f0101b15:	6a 00                	push   $0x0
f0101b17:	e8 3a f9 ff ff       	call   f0101456 <page_alloc>
f0101b1c:	83 c4 10             	add    $0x10,%esp
f0101b1f:	85 c0                	test   %eax,%eax
f0101b21:	74 19                	je     f0101b3c <mem_init+0x2d5>
f0101b23:	68 b8 7c 10 f0       	push   $0xf0107cb8
f0101b28:	68 17 7b 10 f0       	push   $0xf0107b17
f0101b2d:	68 a7 03 00 00       	push   $0x3a7
f0101b32:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101b37:	e8 04 e5 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101b3c:	83 ec 0c             	sub    $0xc,%esp
f0101b3f:	57                   	push   %edi
f0101b40:	e8 81 f9 ff ff       	call   f01014c6 <page_free>
	page_free(pp1);
f0101b45:	89 34 24             	mov    %esi,(%esp)
f0101b48:	e8 79 f9 ff ff       	call   f01014c6 <page_free>
	page_free(pp2);
f0101b4d:	83 c4 04             	add    $0x4,%esp
f0101b50:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b53:	e8 6e f9 ff ff       	call   f01014c6 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b5f:	e8 f2 f8 ff ff       	call   f0101456 <page_alloc>
f0101b64:	89 c6                	mov    %eax,%esi
f0101b66:	83 c4 10             	add    $0x10,%esp
f0101b69:	85 c0                	test   %eax,%eax
f0101b6b:	75 19                	jne    f0101b86 <mem_init+0x31f>
f0101b6d:	68 0d 7c 10 f0       	push   $0xf0107c0d
f0101b72:	68 17 7b 10 f0       	push   $0xf0107b17
f0101b77:	68 ae 03 00 00       	push   $0x3ae
f0101b7c:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101b81:	e8 ba e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b86:	83 ec 0c             	sub    $0xc,%esp
f0101b89:	6a 00                	push   $0x0
f0101b8b:	e8 c6 f8 ff ff       	call   f0101456 <page_alloc>
f0101b90:	89 c7                	mov    %eax,%edi
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	85 c0                	test   %eax,%eax
f0101b97:	75 19                	jne    f0101bb2 <mem_init+0x34b>
f0101b99:	68 23 7c 10 f0       	push   $0xf0107c23
f0101b9e:	68 17 7b 10 f0       	push   $0xf0107b17
f0101ba3:	68 af 03 00 00       	push   $0x3af
f0101ba8:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101bad:	e8 8e e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bb2:	83 ec 0c             	sub    $0xc,%esp
f0101bb5:	6a 00                	push   $0x0
f0101bb7:	e8 9a f8 ff ff       	call   f0101456 <page_alloc>
f0101bbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bbf:	83 c4 10             	add    $0x10,%esp
f0101bc2:	85 c0                	test   %eax,%eax
f0101bc4:	75 19                	jne    f0101bdf <mem_init+0x378>
f0101bc6:	68 39 7c 10 f0       	push   $0xf0107c39
f0101bcb:	68 17 7b 10 f0       	push   $0xf0107b17
f0101bd0:	68 b0 03 00 00       	push   $0x3b0
f0101bd5:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101bda:	e8 61 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bdf:	39 fe                	cmp    %edi,%esi
f0101be1:	75 19                	jne    f0101bfc <mem_init+0x395>
f0101be3:	68 4f 7c 10 f0       	push   $0xf0107c4f
f0101be8:	68 17 7b 10 f0       	push   $0xf0107b17
f0101bed:	68 b2 03 00 00       	push   $0x3b2
f0101bf2:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101bf7:	e8 44 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bff:	39 c7                	cmp    %eax,%edi
f0101c01:	74 04                	je     f0101c07 <mem_init+0x3a0>
f0101c03:	39 c6                	cmp    %eax,%esi
f0101c05:	75 19                	jne    f0101c20 <mem_init+0x3b9>
f0101c07:	68 14 73 10 f0       	push   $0xf0107314
f0101c0c:	68 17 7b 10 f0       	push   $0xf0107b17
f0101c11:	68 b3 03 00 00       	push   $0x3b3
f0101c16:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101c1b:	e8 20 e4 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101c20:	83 ec 0c             	sub    $0xc,%esp
f0101c23:	6a 00                	push   $0x0
f0101c25:	e8 2c f8 ff ff       	call   f0101456 <page_alloc>
f0101c2a:	83 c4 10             	add    $0x10,%esp
f0101c2d:	85 c0                	test   %eax,%eax
f0101c2f:	74 19                	je     f0101c4a <mem_init+0x3e3>
f0101c31:	68 b8 7c 10 f0       	push   $0xf0107cb8
f0101c36:	68 17 7b 10 f0       	push   $0xf0107b17
f0101c3b:	68 b4 03 00 00       	push   $0x3b4
f0101c40:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101c45:	e8 f6 e3 ff ff       	call   f0100040 <_panic>
f0101c4a:	89 f0                	mov    %esi,%eax
f0101c4c:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0101c52:	c1 f8 03             	sar    $0x3,%eax
f0101c55:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c58:	89 c2                	mov    %eax,%edx
f0101c5a:	c1 ea 0c             	shr    $0xc,%edx
f0101c5d:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f0101c63:	72 12                	jb     f0101c77 <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c65:	50                   	push   %eax
f0101c66:	68 44 6a 10 f0       	push   $0xf0106a44
f0101c6b:	6a 58                	push   $0x58
f0101c6d:	68 fd 7a 10 f0       	push   $0xf0107afd
f0101c72:	e8 c9 e3 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101c77:	83 ec 04             	sub    $0x4,%esp
f0101c7a:	68 00 10 00 00       	push   $0x1000
f0101c7f:	6a 01                	push   $0x1
f0101c81:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c86:	50                   	push   %eax
f0101c87:	e8 6d 40 00 00       	call   f0105cf9 <memset>
	page_free(pp0);
f0101c8c:	89 34 24             	mov    %esi,(%esp)
f0101c8f:	e8 32 f8 ff ff       	call   f01014c6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101c94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101c9b:	e8 b6 f7 ff ff       	call   f0101456 <page_alloc>
f0101ca0:	83 c4 10             	add    $0x10,%esp
f0101ca3:	85 c0                	test   %eax,%eax
f0101ca5:	75 19                	jne    f0101cc0 <mem_init+0x459>
f0101ca7:	68 c7 7c 10 f0       	push   $0xf0107cc7
f0101cac:	68 17 7b 10 f0       	push   $0xf0107b17
f0101cb1:	68 b9 03 00 00       	push   $0x3b9
f0101cb6:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101cbb:	e8 80 e3 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101cc0:	39 c6                	cmp    %eax,%esi
f0101cc2:	74 19                	je     f0101cdd <mem_init+0x476>
f0101cc4:	68 e5 7c 10 f0       	push   $0xf0107ce5
f0101cc9:	68 17 7b 10 f0       	push   $0xf0107b17
f0101cce:	68 ba 03 00 00       	push   $0x3ba
f0101cd3:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101cd8:	e8 63 e3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cdd:	89 f0                	mov    %esi,%eax
f0101cdf:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0101ce5:	c1 f8 03             	sar    $0x3,%eax
f0101ce8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ceb:	89 c2                	mov    %eax,%edx
f0101ced:	c1 ea 0c             	shr    $0xc,%edx
f0101cf0:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f0101cf6:	72 12                	jb     f0101d0a <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cf8:	50                   	push   %eax
f0101cf9:	68 44 6a 10 f0       	push   $0xf0106a44
f0101cfe:	6a 58                	push   $0x58
f0101d00:	68 fd 7a 10 f0       	push   $0xf0107afd
f0101d05:	e8 36 e3 ff ff       	call   f0100040 <_panic>
f0101d0a:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101d10:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101d16:	80 38 00             	cmpb   $0x0,(%eax)
f0101d19:	74 19                	je     f0101d34 <mem_init+0x4cd>
f0101d1b:	68 f5 7c 10 f0       	push   $0xf0107cf5
f0101d20:	68 17 7b 10 f0       	push   $0xf0107b17
f0101d25:	68 bd 03 00 00       	push   $0x3bd
f0101d2a:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101d2f:	e8 0c e3 ff ff       	call   f0100040 <_panic>
f0101d34:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101d37:	39 d0                	cmp    %edx,%eax
f0101d39:	75 db                	jne    f0101d16 <mem_init+0x4af>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101d3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d3e:	a3 40 a2 21 f0       	mov    %eax,0xf021a240

	// free the pages we took
	page_free(pp0);
f0101d43:	83 ec 0c             	sub    $0xc,%esp
f0101d46:	56                   	push   %esi
f0101d47:	e8 7a f7 ff ff       	call   f01014c6 <page_free>
	page_free(pp1);
f0101d4c:	89 3c 24             	mov    %edi,(%esp)
f0101d4f:	e8 72 f7 ff ff       	call   f01014c6 <page_free>
	page_free(pp2);
f0101d54:	83 c4 04             	add    $0x4,%esp
f0101d57:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d5a:	e8 67 f7 ff ff       	call   f01014c6 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d5f:	a1 40 a2 21 f0       	mov    0xf021a240,%eax
f0101d64:	83 c4 10             	add    $0x10,%esp
f0101d67:	eb 05                	jmp    f0101d6e <mem_init+0x507>
		--nfree;
f0101d69:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d6c:	8b 00                	mov    (%eax),%eax
f0101d6e:	85 c0                	test   %eax,%eax
f0101d70:	75 f7                	jne    f0101d69 <mem_init+0x502>
		--nfree;
	assert(nfree == 0);
f0101d72:	85 db                	test   %ebx,%ebx
f0101d74:	74 19                	je     f0101d8f <mem_init+0x528>
f0101d76:	68 ff 7c 10 f0       	push   $0xf0107cff
f0101d7b:	68 17 7b 10 f0       	push   $0xf0107b17
f0101d80:	68 ca 03 00 00       	push   $0x3ca
f0101d85:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101d8a:	e8 b1 e2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101d8f:	83 ec 0c             	sub    $0xc,%esp
f0101d92:	68 34 73 10 f0       	push   $0xf0107334
f0101d97:	e8 d9 1e 00 00       	call   f0103c75 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101da3:	e8 ae f6 ff ff       	call   f0101456 <page_alloc>
f0101da8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101dab:	83 c4 10             	add    $0x10,%esp
f0101dae:	85 c0                	test   %eax,%eax
f0101db0:	75 19                	jne    f0101dcb <mem_init+0x564>
f0101db2:	68 0d 7c 10 f0       	push   $0xf0107c0d
f0101db7:	68 17 7b 10 f0       	push   $0xf0107b17
f0101dbc:	68 33 04 00 00       	push   $0x433
f0101dc1:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101dc6:	e8 75 e2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101dcb:	83 ec 0c             	sub    $0xc,%esp
f0101dce:	6a 00                	push   $0x0
f0101dd0:	e8 81 f6 ff ff       	call   f0101456 <page_alloc>
f0101dd5:	89 c3                	mov    %eax,%ebx
f0101dd7:	83 c4 10             	add    $0x10,%esp
f0101dda:	85 c0                	test   %eax,%eax
f0101ddc:	75 19                	jne    f0101df7 <mem_init+0x590>
f0101dde:	68 23 7c 10 f0       	push   $0xf0107c23
f0101de3:	68 17 7b 10 f0       	push   $0xf0107b17
f0101de8:	68 34 04 00 00       	push   $0x434
f0101ded:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101df2:	e8 49 e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101df7:	83 ec 0c             	sub    $0xc,%esp
f0101dfa:	6a 00                	push   $0x0
f0101dfc:	e8 55 f6 ff ff       	call   f0101456 <page_alloc>
f0101e01:	89 c6                	mov    %eax,%esi
f0101e03:	83 c4 10             	add    $0x10,%esp
f0101e06:	85 c0                	test   %eax,%eax
f0101e08:	75 19                	jne    f0101e23 <mem_init+0x5bc>
f0101e0a:	68 39 7c 10 f0       	push   $0xf0107c39
f0101e0f:	68 17 7b 10 f0       	push   $0xf0107b17
f0101e14:	68 35 04 00 00       	push   $0x435
f0101e19:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101e1e:	e8 1d e2 ff ff       	call   f0100040 <_panic>
	
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e23:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101e26:	75 19                	jne    f0101e41 <mem_init+0x5da>
f0101e28:	68 4f 7c 10 f0       	push   $0xf0107c4f
f0101e2d:	68 17 7b 10 f0       	push   $0xf0107b17
f0101e32:	68 38 04 00 00       	push   $0x438
f0101e37:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101e3c:	e8 ff e1 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e41:	39 c3                	cmp    %eax,%ebx
f0101e43:	74 05                	je     f0101e4a <mem_init+0x5e3>
f0101e45:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e48:	75 19                	jne    f0101e63 <mem_init+0x5fc>
f0101e4a:	68 14 73 10 f0       	push   $0xf0107314
f0101e4f:	68 17 7b 10 f0       	push   $0xf0107b17
f0101e54:	68 39 04 00 00       	push   $0x439
f0101e59:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101e5e:	e8 dd e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e63:	a1 40 a2 21 f0       	mov    0xf021a240,%eax
f0101e68:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101e6b:	c7 05 40 a2 21 f0 00 	movl   $0x0,0xf021a240
f0101e72:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e75:	83 ec 0c             	sub    $0xc,%esp
f0101e78:	6a 00                	push   $0x0
f0101e7a:	e8 d7 f5 ff ff       	call   f0101456 <page_alloc>
f0101e7f:	83 c4 10             	add    $0x10,%esp
f0101e82:	85 c0                	test   %eax,%eax
f0101e84:	74 19                	je     f0101e9f <mem_init+0x638>
f0101e86:	68 b8 7c 10 f0       	push   $0xf0107cb8
f0101e8b:	68 17 7b 10 f0       	push   $0xf0107b17
f0101e90:	68 40 04 00 00       	push   $0x440
f0101e95:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101e9a:	e8 a1 e1 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e9f:	83 ec 04             	sub    $0x4,%esp
f0101ea2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ea5:	50                   	push   %eax
f0101ea6:	6a 00                	push   $0x0
f0101ea8:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0101eae:	e8 bb f7 ff ff       	call   f010166e <page_lookup>
f0101eb3:	83 c4 10             	add    $0x10,%esp
f0101eb6:	85 c0                	test   %eax,%eax
f0101eb8:	74 19                	je     f0101ed3 <mem_init+0x66c>
f0101eba:	68 54 73 10 f0       	push   $0xf0107354
f0101ebf:	68 17 7b 10 f0       	push   $0xf0107b17
f0101ec4:	68 43 04 00 00       	push   $0x443
f0101ec9:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101ece:	e8 6d e1 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ed3:	6a 02                	push   $0x2
f0101ed5:	6a 00                	push   $0x0
f0101ed7:	53                   	push   %ebx
f0101ed8:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0101ede:	e8 78 f8 ff ff       	call   f010175b <page_insert>
f0101ee3:	83 c4 10             	add    $0x10,%esp
f0101ee6:	85 c0                	test   %eax,%eax
f0101ee8:	78 19                	js     f0101f03 <mem_init+0x69c>
f0101eea:	68 8c 73 10 f0       	push   $0xf010738c
f0101eef:	68 17 7b 10 f0       	push   $0xf0107b17
f0101ef4:	68 46 04 00 00       	push   $0x446
f0101ef9:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101efe:	e8 3d e1 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101f03:	83 ec 0c             	sub    $0xc,%esp
f0101f06:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f09:	e8 b8 f5 ff ff       	call   f01014c6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101f0e:	6a 02                	push   $0x2
f0101f10:	6a 00                	push   $0x0
f0101f12:	53                   	push   %ebx
f0101f13:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0101f19:	e8 3d f8 ff ff       	call   f010175b <page_insert>
f0101f1e:	83 c4 20             	add    $0x20,%esp
f0101f21:	85 c0                	test   %eax,%eax
f0101f23:	74 19                	je     f0101f3e <mem_init+0x6d7>
f0101f25:	68 bc 73 10 f0       	push   $0xf01073bc
f0101f2a:	68 17 7b 10 f0       	push   $0xf0107b17
f0101f2f:	68 4a 04 00 00       	push   $0x44a
f0101f34:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101f39:	e8 02 e1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f3e:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f44:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f0101f49:	89 c1                	mov    %eax,%ecx
f0101f4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f4e:	8b 17                	mov    (%edi),%edx
f0101f50:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f59:	29 c8                	sub    %ecx,%eax
f0101f5b:	c1 f8 03             	sar    $0x3,%eax
f0101f5e:	c1 e0 0c             	shl    $0xc,%eax
f0101f61:	39 c2                	cmp    %eax,%edx
f0101f63:	74 19                	je     f0101f7e <mem_init+0x717>
f0101f65:	68 ec 73 10 f0       	push   $0xf01073ec
f0101f6a:	68 17 7b 10 f0       	push   $0xf0107b17
f0101f6f:	68 4b 04 00 00       	push   $0x44b
f0101f74:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101f79:	e8 c2 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101f7e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f83:	89 f8                	mov    %edi,%eax
f0101f85:	e8 19 f0 ff ff       	call   f0100fa3 <check_va2pa>
f0101f8a:	89 da                	mov    %ebx,%edx
f0101f8c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101f8f:	c1 fa 03             	sar    $0x3,%edx
f0101f92:	c1 e2 0c             	shl    $0xc,%edx
f0101f95:	39 d0                	cmp    %edx,%eax
f0101f97:	74 19                	je     f0101fb2 <mem_init+0x74b>
f0101f99:	68 14 74 10 f0       	push   $0xf0107414
f0101f9e:	68 17 7b 10 f0       	push   $0xf0107b17
f0101fa3:	68 4c 04 00 00       	push   $0x44c
f0101fa8:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101fad:	e8 8e e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fb2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fb7:	74 19                	je     f0101fd2 <mem_init+0x76b>
f0101fb9:	68 0a 7d 10 f0       	push   $0xf0107d0a
f0101fbe:	68 17 7b 10 f0       	push   $0xf0107b17
f0101fc3:	68 4d 04 00 00       	push   $0x44d
f0101fc8:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101fcd:	e8 6e e0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101fd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fda:	74 19                	je     f0101ff5 <mem_init+0x78e>
f0101fdc:	68 1b 7d 10 f0       	push   $0xf0107d1b
f0101fe1:	68 17 7b 10 f0       	push   $0xf0107b17
f0101fe6:	68 4e 04 00 00       	push   $0x44e
f0101feb:	68 f1 7a 10 f0       	push   $0xf0107af1
f0101ff0:	e8 4b e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ff5:	6a 02                	push   $0x2
f0101ff7:	68 00 10 00 00       	push   $0x1000
f0101ffc:	56                   	push   %esi
f0101ffd:	57                   	push   %edi
f0101ffe:	e8 58 f7 ff ff       	call   f010175b <page_insert>
f0102003:	83 c4 10             	add    $0x10,%esp
f0102006:	85 c0                	test   %eax,%eax
f0102008:	74 19                	je     f0102023 <mem_init+0x7bc>
f010200a:	68 44 74 10 f0       	push   $0xf0107444
f010200f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102014:	68 51 04 00 00       	push   $0x451
f0102019:	68 f1 7a 10 f0       	push   $0xf0107af1
f010201e:	e8 1d e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102023:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102028:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f010202d:	e8 71 ef ff ff       	call   f0100fa3 <check_va2pa>
f0102032:	89 f2                	mov    %esi,%edx
f0102034:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f010203a:	c1 fa 03             	sar    $0x3,%edx
f010203d:	c1 e2 0c             	shl    $0xc,%edx
f0102040:	39 d0                	cmp    %edx,%eax
f0102042:	74 19                	je     f010205d <mem_init+0x7f6>
f0102044:	68 80 74 10 f0       	push   $0xf0107480
f0102049:	68 17 7b 10 f0       	push   $0xf0107b17
f010204e:	68 52 04 00 00       	push   $0x452
f0102053:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102058:	e8 e3 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010205d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102062:	74 19                	je     f010207d <mem_init+0x816>
f0102064:	68 2c 7d 10 f0       	push   $0xf0107d2c
f0102069:	68 17 7b 10 f0       	push   $0xf0107b17
f010206e:	68 53 04 00 00       	push   $0x453
f0102073:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102078:	e8 c3 df ff ff       	call   f0100040 <_panic>
	// should be no free memory
	assert(!page_alloc(0));
f010207d:	83 ec 0c             	sub    $0xc,%esp
f0102080:	6a 00                	push   $0x0
f0102082:	e8 cf f3 ff ff       	call   f0101456 <page_alloc>
f0102087:	83 c4 10             	add    $0x10,%esp
f010208a:	85 c0                	test   %eax,%eax
f010208c:	74 19                	je     f01020a7 <mem_init+0x840>
f010208e:	68 b8 7c 10 f0       	push   $0xf0107cb8
f0102093:	68 17 7b 10 f0       	push   $0xf0107b17
f0102098:	68 55 04 00 00       	push   $0x455
f010209d:	68 f1 7a 10 f0       	push   $0xf0107af1
f01020a2:	e8 99 df ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020a7:	6a 02                	push   $0x2
f01020a9:	68 00 10 00 00       	push   $0x1000
f01020ae:	56                   	push   %esi
f01020af:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01020b5:	e8 a1 f6 ff ff       	call   f010175b <page_insert>
f01020ba:	83 c4 10             	add    $0x10,%esp
f01020bd:	85 c0                	test   %eax,%eax
f01020bf:	74 19                	je     f01020da <mem_init+0x873>
f01020c1:	68 44 74 10 f0       	push   $0xf0107444
f01020c6:	68 17 7b 10 f0       	push   $0xf0107b17
f01020cb:	68 58 04 00 00       	push   $0x458
f01020d0:	68 f1 7a 10 f0       	push   $0xf0107af1
f01020d5:	e8 66 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020da:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020df:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f01020e4:	e8 ba ee ff ff       	call   f0100fa3 <check_va2pa>
f01020e9:	89 f2                	mov    %esi,%edx
f01020eb:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f01020f1:	c1 fa 03             	sar    $0x3,%edx
f01020f4:	c1 e2 0c             	shl    $0xc,%edx
f01020f7:	39 d0                	cmp    %edx,%eax
f01020f9:	74 19                	je     f0102114 <mem_init+0x8ad>
f01020fb:	68 80 74 10 f0       	push   $0xf0107480
f0102100:	68 17 7b 10 f0       	push   $0xf0107b17
f0102105:	68 59 04 00 00       	push   $0x459
f010210a:	68 f1 7a 10 f0       	push   $0xf0107af1
f010210f:	e8 2c df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102114:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102119:	74 19                	je     f0102134 <mem_init+0x8cd>
f010211b:	68 2c 7d 10 f0       	push   $0xf0107d2c
f0102120:	68 17 7b 10 f0       	push   $0xf0107b17
f0102125:	68 5a 04 00 00       	push   $0x45a
f010212a:	68 f1 7a 10 f0       	push   $0xf0107af1
f010212f:	e8 0c df ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102134:	83 ec 0c             	sub    $0xc,%esp
f0102137:	6a 00                	push   $0x0
f0102139:	e8 18 f3 ff ff       	call   f0101456 <page_alloc>
f010213e:	83 c4 10             	add    $0x10,%esp
f0102141:	85 c0                	test   %eax,%eax
f0102143:	74 19                	je     f010215e <mem_init+0x8f7>
f0102145:	68 b8 7c 10 f0       	push   $0xf0107cb8
f010214a:	68 17 7b 10 f0       	push   $0xf0107b17
f010214f:	68 5e 04 00 00       	push   $0x45e
f0102154:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102159:	e8 e2 de ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010215e:	8b 15 8c ae 21 f0    	mov    0xf021ae8c,%edx
f0102164:	8b 02                	mov    (%edx),%eax
f0102166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010216b:	89 c1                	mov    %eax,%ecx
f010216d:	c1 e9 0c             	shr    $0xc,%ecx
f0102170:	3b 0d 88 ae 21 f0    	cmp    0xf021ae88,%ecx
f0102176:	72 15                	jb     f010218d <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102178:	50                   	push   %eax
f0102179:	68 44 6a 10 f0       	push   $0xf0106a44
f010217e:	68 61 04 00 00       	push   $0x461
f0102183:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102188:	e8 b3 de ff ff       	call   f0100040 <_panic>
f010218d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102192:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102195:	83 ec 04             	sub    $0x4,%esp
f0102198:	6a 00                	push   $0x0
f010219a:	68 00 10 00 00       	push   $0x1000
f010219f:	52                   	push   %edx
f01021a0:	e8 a5 f3 ff ff       	call   f010154a <pgdir_walk>
f01021a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01021a8:	8d 51 04             	lea    0x4(%ecx),%edx
f01021ab:	83 c4 10             	add    $0x10,%esp
f01021ae:	39 d0                	cmp    %edx,%eax
f01021b0:	74 19                	je     f01021cb <mem_init+0x964>
f01021b2:	68 b0 74 10 f0       	push   $0xf01074b0
f01021b7:	68 17 7b 10 f0       	push   $0xf0107b17
f01021bc:	68 62 04 00 00       	push   $0x462
f01021c1:	68 f1 7a 10 f0       	push   $0xf0107af1
f01021c6:	e8 75 de ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01021cb:	6a 06                	push   $0x6
f01021cd:	68 00 10 00 00       	push   $0x1000
f01021d2:	56                   	push   %esi
f01021d3:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01021d9:	e8 7d f5 ff ff       	call   f010175b <page_insert>
f01021de:	83 c4 10             	add    $0x10,%esp
f01021e1:	85 c0                	test   %eax,%eax
f01021e3:	74 19                	je     f01021fe <mem_init+0x997>
f01021e5:	68 f0 74 10 f0       	push   $0xf01074f0
f01021ea:	68 17 7b 10 f0       	push   $0xf0107b17
f01021ef:	68 65 04 00 00       	push   $0x465
f01021f4:	68 f1 7a 10 f0       	push   $0xf0107af1
f01021f9:	e8 42 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021fe:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi
f0102204:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102209:	89 f8                	mov    %edi,%eax
f010220b:	e8 93 ed ff ff       	call   f0100fa3 <check_va2pa>
f0102210:	89 f2                	mov    %esi,%edx
f0102212:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f0102218:	c1 fa 03             	sar    $0x3,%edx
f010221b:	c1 e2 0c             	shl    $0xc,%edx
f010221e:	39 d0                	cmp    %edx,%eax
f0102220:	74 19                	je     f010223b <mem_init+0x9d4>
f0102222:	68 80 74 10 f0       	push   $0xf0107480
f0102227:	68 17 7b 10 f0       	push   $0xf0107b17
f010222c:	68 66 04 00 00       	push   $0x466
f0102231:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102236:	e8 05 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010223b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102240:	74 19                	je     f010225b <mem_init+0x9f4>
f0102242:	68 2c 7d 10 f0       	push   $0xf0107d2c
f0102247:	68 17 7b 10 f0       	push   $0xf0107b17
f010224c:	68 67 04 00 00       	push   $0x467
f0102251:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102256:	e8 e5 dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010225b:	83 ec 04             	sub    $0x4,%esp
f010225e:	6a 00                	push   $0x0
f0102260:	68 00 10 00 00       	push   $0x1000
f0102265:	57                   	push   %edi
f0102266:	e8 df f2 ff ff       	call   f010154a <pgdir_walk>
f010226b:	83 c4 10             	add    $0x10,%esp
f010226e:	f6 00 04             	testb  $0x4,(%eax)
f0102271:	75 19                	jne    f010228c <mem_init+0xa25>
f0102273:	68 30 75 10 f0       	push   $0xf0107530
f0102278:	68 17 7b 10 f0       	push   $0xf0107b17
f010227d:	68 68 04 00 00       	push   $0x468
f0102282:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102287:	e8 b4 dd ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010228c:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102291:	f6 00 04             	testb  $0x4,(%eax)
f0102294:	75 19                	jne    f01022af <mem_init+0xa48>
f0102296:	68 3d 7d 10 f0       	push   $0xf0107d3d
f010229b:	68 17 7b 10 f0       	push   $0xf0107b17
f01022a0:	68 69 04 00 00       	push   $0x469
f01022a5:	68 f1 7a 10 f0       	push   $0xf0107af1
f01022aa:	e8 91 dd ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022af:	6a 02                	push   $0x2
f01022b1:	68 00 10 00 00       	push   $0x1000
f01022b6:	56                   	push   %esi
f01022b7:	50                   	push   %eax
f01022b8:	e8 9e f4 ff ff       	call   f010175b <page_insert>
f01022bd:	83 c4 10             	add    $0x10,%esp
f01022c0:	85 c0                	test   %eax,%eax
f01022c2:	74 19                	je     f01022dd <mem_init+0xa76>
f01022c4:	68 44 74 10 f0       	push   $0xf0107444
f01022c9:	68 17 7b 10 f0       	push   $0xf0107b17
f01022ce:	68 6c 04 00 00       	push   $0x46c
f01022d3:	68 f1 7a 10 f0       	push   $0xf0107af1
f01022d8:	e8 63 dd ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01022dd:	83 ec 04             	sub    $0x4,%esp
f01022e0:	6a 00                	push   $0x0
f01022e2:	68 00 10 00 00       	push   $0x1000
f01022e7:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01022ed:	e8 58 f2 ff ff       	call   f010154a <pgdir_walk>
f01022f2:	83 c4 10             	add    $0x10,%esp
f01022f5:	f6 00 02             	testb  $0x2,(%eax)
f01022f8:	75 19                	jne    f0102313 <mem_init+0xaac>
f01022fa:	68 64 75 10 f0       	push   $0xf0107564
f01022ff:	68 17 7b 10 f0       	push   $0xf0107b17
f0102304:	68 6d 04 00 00       	push   $0x46d
f0102309:	68 f1 7a 10 f0       	push   $0xf0107af1
f010230e:	e8 2d dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102313:	83 ec 04             	sub    $0x4,%esp
f0102316:	6a 00                	push   $0x0
f0102318:	68 00 10 00 00       	push   $0x1000
f010231d:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102323:	e8 22 f2 ff ff       	call   f010154a <pgdir_walk>
f0102328:	83 c4 10             	add    $0x10,%esp
f010232b:	f6 00 04             	testb  $0x4,(%eax)
f010232e:	74 19                	je     f0102349 <mem_init+0xae2>
f0102330:	68 98 75 10 f0       	push   $0xf0107598
f0102335:	68 17 7b 10 f0       	push   $0xf0107b17
f010233a:	68 6e 04 00 00       	push   $0x46e
f010233f:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102344:	e8 f7 dc ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102349:	6a 02                	push   $0x2
f010234b:	68 00 00 40 00       	push   $0x400000
f0102350:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102353:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102359:	e8 fd f3 ff ff       	call   f010175b <page_insert>
f010235e:	83 c4 10             	add    $0x10,%esp
f0102361:	85 c0                	test   %eax,%eax
f0102363:	78 19                	js     f010237e <mem_init+0xb17>
f0102365:	68 d0 75 10 f0       	push   $0xf01075d0
f010236a:	68 17 7b 10 f0       	push   $0xf0107b17
f010236f:	68 71 04 00 00       	push   $0x471
f0102374:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102379:	e8 c2 dc ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010237e:	6a 02                	push   $0x2
f0102380:	68 00 10 00 00       	push   $0x1000
f0102385:	53                   	push   %ebx
f0102386:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f010238c:	e8 ca f3 ff ff       	call   f010175b <page_insert>
f0102391:	83 c4 10             	add    $0x10,%esp
f0102394:	85 c0                	test   %eax,%eax
f0102396:	74 19                	je     f01023b1 <mem_init+0xb4a>
f0102398:	68 08 76 10 f0       	push   $0xf0107608
f010239d:	68 17 7b 10 f0       	push   $0xf0107b17
f01023a2:	68 74 04 00 00       	push   $0x474
f01023a7:	68 f1 7a 10 f0       	push   $0xf0107af1
f01023ac:	e8 8f dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023b1:	83 ec 04             	sub    $0x4,%esp
f01023b4:	6a 00                	push   $0x0
f01023b6:	68 00 10 00 00       	push   $0x1000
f01023bb:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01023c1:	e8 84 f1 ff ff       	call   f010154a <pgdir_walk>
f01023c6:	83 c4 10             	add    $0x10,%esp
f01023c9:	f6 00 04             	testb  $0x4,(%eax)
f01023cc:	74 19                	je     f01023e7 <mem_init+0xb80>
f01023ce:	68 98 75 10 f0       	push   $0xf0107598
f01023d3:	68 17 7b 10 f0       	push   $0xf0107b17
f01023d8:	68 75 04 00 00       	push   $0x475
f01023dd:	68 f1 7a 10 f0       	push   $0xf0107af1
f01023e2:	e8 59 dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01023e7:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi
f01023ed:	ba 00 00 00 00       	mov    $0x0,%edx
f01023f2:	89 f8                	mov    %edi,%eax
f01023f4:	e8 aa eb ff ff       	call   f0100fa3 <check_va2pa>
f01023f9:	89 c1                	mov    %eax,%ecx
f01023fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023fe:	89 d8                	mov    %ebx,%eax
f0102400:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0102406:	c1 f8 03             	sar    $0x3,%eax
f0102409:	c1 e0 0c             	shl    $0xc,%eax
f010240c:	39 c1                	cmp    %eax,%ecx
f010240e:	74 19                	je     f0102429 <mem_init+0xbc2>
f0102410:	68 44 76 10 f0       	push   $0xf0107644
f0102415:	68 17 7b 10 f0       	push   $0xf0107b17
f010241a:	68 78 04 00 00       	push   $0x478
f010241f:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102424:	e8 17 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102429:	ba 00 10 00 00       	mov    $0x1000,%edx
f010242e:	89 f8                	mov    %edi,%eax
f0102430:	e8 6e eb ff ff       	call   f0100fa3 <check_va2pa>
f0102435:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102438:	74 19                	je     f0102453 <mem_init+0xbec>
f010243a:	68 70 76 10 f0       	push   $0xf0107670
f010243f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102444:	68 79 04 00 00       	push   $0x479
f0102449:	68 f1 7a 10 f0       	push   $0xf0107af1
f010244e:	e8 ed db ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102453:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102458:	74 19                	je     f0102473 <mem_init+0xc0c>
f010245a:	68 53 7d 10 f0       	push   $0xf0107d53
f010245f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102464:	68 7b 04 00 00       	push   $0x47b
f0102469:	68 f1 7a 10 f0       	push   $0xf0107af1
f010246e:	e8 cd db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102473:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102478:	74 19                	je     f0102493 <mem_init+0xc2c>
f010247a:	68 64 7d 10 f0       	push   $0xf0107d64
f010247f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102484:	68 7c 04 00 00       	push   $0x47c
f0102489:	68 f1 7a 10 f0       	push   $0xf0107af1
f010248e:	e8 ad db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102493:	83 ec 0c             	sub    $0xc,%esp
f0102496:	6a 00                	push   $0x0
f0102498:	e8 b9 ef ff ff       	call   f0101456 <page_alloc>
f010249d:	83 c4 10             	add    $0x10,%esp
f01024a0:	85 c0                	test   %eax,%eax
f01024a2:	74 04                	je     f01024a8 <mem_init+0xc41>
f01024a4:	39 c6                	cmp    %eax,%esi
f01024a6:	74 19                	je     f01024c1 <mem_init+0xc5a>
f01024a8:	68 a0 76 10 f0       	push   $0xf01076a0
f01024ad:	68 17 7b 10 f0       	push   $0xf0107b17
f01024b2:	68 7f 04 00 00       	push   $0x47f
f01024b7:	68 f1 7a 10 f0       	push   $0xf0107af1
f01024bc:	e8 7f db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01024c1:	83 ec 08             	sub    $0x8,%esp
f01024c4:	6a 00                	push   $0x0
f01024c6:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01024cc:	e8 3d f2 ff ff       	call   f010170e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024d1:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi
f01024d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01024dc:	89 f8                	mov    %edi,%eax
f01024de:	e8 c0 ea ff ff       	call   f0100fa3 <check_va2pa>
f01024e3:	83 c4 10             	add    $0x10,%esp
f01024e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024e9:	74 19                	je     f0102504 <mem_init+0xc9d>
f01024eb:	68 c4 76 10 f0       	push   $0xf01076c4
f01024f0:	68 17 7b 10 f0       	push   $0xf0107b17
f01024f5:	68 83 04 00 00       	push   $0x483
f01024fa:	68 f1 7a 10 f0       	push   $0xf0107af1
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102504:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102509:	89 f8                	mov    %edi,%eax
f010250b:	e8 93 ea ff ff       	call   f0100fa3 <check_va2pa>
f0102510:	89 da                	mov    %ebx,%edx
f0102512:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f0102518:	c1 fa 03             	sar    $0x3,%edx
f010251b:	c1 e2 0c             	shl    $0xc,%edx
f010251e:	39 d0                	cmp    %edx,%eax
f0102520:	74 19                	je     f010253b <mem_init+0xcd4>
f0102522:	68 70 76 10 f0       	push   $0xf0107670
f0102527:	68 17 7b 10 f0       	push   $0xf0107b17
f010252c:	68 84 04 00 00       	push   $0x484
f0102531:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102536:	e8 05 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010253b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102540:	74 19                	je     f010255b <mem_init+0xcf4>
f0102542:	68 0a 7d 10 f0       	push   $0xf0107d0a
f0102547:	68 17 7b 10 f0       	push   $0xf0107b17
f010254c:	68 85 04 00 00       	push   $0x485
f0102551:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102556:	e8 e5 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010255b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102560:	74 19                	je     f010257b <mem_init+0xd14>
f0102562:	68 64 7d 10 f0       	push   $0xf0107d64
f0102567:	68 17 7b 10 f0       	push   $0xf0107b17
f010256c:	68 86 04 00 00       	push   $0x486
f0102571:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102576:	e8 c5 da ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010257b:	6a 00                	push   $0x0
f010257d:	68 00 10 00 00       	push   $0x1000
f0102582:	53                   	push   %ebx
f0102583:	57                   	push   %edi
f0102584:	e8 d2 f1 ff ff       	call   f010175b <page_insert>
f0102589:	83 c4 10             	add    $0x10,%esp
f010258c:	85 c0                	test   %eax,%eax
f010258e:	74 19                	je     f01025a9 <mem_init+0xd42>
f0102590:	68 e8 76 10 f0       	push   $0xf01076e8
f0102595:	68 17 7b 10 f0       	push   $0xf0107b17
f010259a:	68 89 04 00 00       	push   $0x489
f010259f:	68 f1 7a 10 f0       	push   $0xf0107af1
f01025a4:	e8 97 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025a9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025ae:	75 19                	jne    f01025c9 <mem_init+0xd62>
f01025b0:	68 75 7d 10 f0       	push   $0xf0107d75
f01025b5:	68 17 7b 10 f0       	push   $0xf0107b17
f01025ba:	68 8a 04 00 00       	push   $0x48a
f01025bf:	68 f1 7a 10 f0       	push   $0xf0107af1
f01025c4:	e8 77 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025c9:	83 3b 00             	cmpl   $0x0,(%ebx)
f01025cc:	74 19                	je     f01025e7 <mem_init+0xd80>
f01025ce:	68 81 7d 10 f0       	push   $0xf0107d81
f01025d3:	68 17 7b 10 f0       	push   $0xf0107b17
f01025d8:	68 8b 04 00 00       	push   $0x48b
f01025dd:	68 f1 7a 10 f0       	push   $0xf0107af1
f01025e2:	e8 59 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025e7:	83 ec 08             	sub    $0x8,%esp
f01025ea:	68 00 10 00 00       	push   $0x1000
f01025ef:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01025f5:	e8 14 f1 ff ff       	call   f010170e <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025fa:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi
f0102600:	ba 00 00 00 00       	mov    $0x0,%edx
f0102605:	89 f8                	mov    %edi,%eax
f0102607:	e8 97 e9 ff ff       	call   f0100fa3 <check_va2pa>
f010260c:	83 c4 10             	add    $0x10,%esp
f010260f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102612:	74 19                	je     f010262d <mem_init+0xdc6>
f0102614:	68 c4 76 10 f0       	push   $0xf01076c4
f0102619:	68 17 7b 10 f0       	push   $0xf0107b17
f010261e:	68 8f 04 00 00       	push   $0x48f
f0102623:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102628:	e8 13 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010262d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102632:	89 f8                	mov    %edi,%eax
f0102634:	e8 6a e9 ff ff       	call   f0100fa3 <check_va2pa>
f0102639:	83 f8 ff             	cmp    $0xffffffff,%eax
f010263c:	74 19                	je     f0102657 <mem_init+0xdf0>
f010263e:	68 20 77 10 f0       	push   $0xf0107720
f0102643:	68 17 7b 10 f0       	push   $0xf0107b17
f0102648:	68 90 04 00 00       	push   $0x490
f010264d:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102652:	e8 e9 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102657:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010265c:	74 19                	je     f0102677 <mem_init+0xe10>
f010265e:	68 96 7d 10 f0       	push   $0xf0107d96
f0102663:	68 17 7b 10 f0       	push   $0xf0107b17
f0102668:	68 91 04 00 00       	push   $0x491
f010266d:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102672:	e8 c9 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102677:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010267c:	74 19                	je     f0102697 <mem_init+0xe30>
f010267e:	68 64 7d 10 f0       	push   $0xf0107d64
f0102683:	68 17 7b 10 f0       	push   $0xf0107b17
f0102688:	68 92 04 00 00       	push   $0x492
f010268d:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102692:	e8 a9 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102697:	83 ec 0c             	sub    $0xc,%esp
f010269a:	6a 00                	push   $0x0
f010269c:	e8 b5 ed ff ff       	call   f0101456 <page_alloc>
f01026a1:	83 c4 10             	add    $0x10,%esp
f01026a4:	39 c3                	cmp    %eax,%ebx
f01026a6:	75 04                	jne    f01026ac <mem_init+0xe45>
f01026a8:	85 c0                	test   %eax,%eax
f01026aa:	75 19                	jne    f01026c5 <mem_init+0xe5e>
f01026ac:	68 48 77 10 f0       	push   $0xf0107748
f01026b1:	68 17 7b 10 f0       	push   $0xf0107b17
f01026b6:	68 95 04 00 00       	push   $0x495
f01026bb:	68 f1 7a 10 f0       	push   $0xf0107af1
f01026c0:	e8 7b d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026c5:	83 ec 0c             	sub    $0xc,%esp
f01026c8:	6a 00                	push   $0x0
f01026ca:	e8 87 ed ff ff       	call   f0101456 <page_alloc>
f01026cf:	83 c4 10             	add    $0x10,%esp
f01026d2:	85 c0                	test   %eax,%eax
f01026d4:	74 19                	je     f01026ef <mem_init+0xe88>
f01026d6:	68 b8 7c 10 f0       	push   $0xf0107cb8
f01026db:	68 17 7b 10 f0       	push   $0xf0107b17
f01026e0:	68 98 04 00 00       	push   $0x498
f01026e5:	68 f1 7a 10 f0       	push   $0xf0107af1
f01026ea:	e8 51 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026ef:	8b 0d 8c ae 21 f0    	mov    0xf021ae8c,%ecx
f01026f5:	8b 11                	mov    (%ecx),%edx
f01026f7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102700:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0102706:	c1 f8 03             	sar    $0x3,%eax
f0102709:	c1 e0 0c             	shl    $0xc,%eax
f010270c:	39 c2                	cmp    %eax,%edx
f010270e:	74 19                	je     f0102729 <mem_init+0xec2>
f0102710:	68 ec 73 10 f0       	push   $0xf01073ec
f0102715:	68 17 7b 10 f0       	push   $0xf0107b17
f010271a:	68 9b 04 00 00       	push   $0x49b
f010271f:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102724:	e8 17 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102729:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010272f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102732:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102737:	74 19                	je     f0102752 <mem_init+0xeeb>
f0102739:	68 1b 7d 10 f0       	push   $0xf0107d1b
f010273e:	68 17 7b 10 f0       	push   $0xf0107b17
f0102743:	68 9d 04 00 00       	push   $0x49d
f0102748:	68 f1 7a 10 f0       	push   $0xf0107af1
f010274d:	e8 ee d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102752:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102755:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010275b:	83 ec 0c             	sub    $0xc,%esp
f010275e:	50                   	push   %eax
f010275f:	e8 62 ed ff ff       	call   f01014c6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102764:	83 c4 0c             	add    $0xc,%esp
f0102767:	6a 01                	push   $0x1
f0102769:	68 00 10 40 00       	push   $0x401000
f010276e:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102774:	e8 d1 ed ff ff       	call   f010154a <pgdir_walk>
f0102779:	89 c7                	mov    %eax,%edi
f010277b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010277e:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102783:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102786:	8b 40 04             	mov    0x4(%eax),%eax
f0102789:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010278e:	8b 0d 88 ae 21 f0    	mov    0xf021ae88,%ecx
f0102794:	89 c2                	mov    %eax,%edx
f0102796:	c1 ea 0c             	shr    $0xc,%edx
f0102799:	83 c4 10             	add    $0x10,%esp
f010279c:	39 ca                	cmp    %ecx,%edx
f010279e:	72 15                	jb     f01027b5 <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027a0:	50                   	push   %eax
f01027a1:	68 44 6a 10 f0       	push   $0xf0106a44
f01027a6:	68 a4 04 00 00       	push   $0x4a4
f01027ab:	68 f1 7a 10 f0       	push   $0xf0107af1
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027b5:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01027ba:	39 c7                	cmp    %eax,%edi
f01027bc:	74 19                	je     f01027d7 <mem_init+0xf70>
f01027be:	68 a7 7d 10 f0       	push   $0xf0107da7
f01027c3:	68 17 7b 10 f0       	push   $0xf0107b17
f01027c8:	68 a5 04 00 00       	push   $0x4a5
f01027cd:	68 f1 7a 10 f0       	push   $0xf0107af1
f01027d2:	e8 69 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027d7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027da:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01027e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027e4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027ea:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f01027f0:	c1 f8 03             	sar    $0x3,%eax
f01027f3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027f6:	89 c2                	mov    %eax,%edx
f01027f8:	c1 ea 0c             	shr    $0xc,%edx
f01027fb:	39 d1                	cmp    %edx,%ecx
f01027fd:	77 12                	ja     f0102811 <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ff:	50                   	push   %eax
f0102800:	68 44 6a 10 f0       	push   $0xf0106a44
f0102805:	6a 58                	push   $0x58
f0102807:	68 fd 7a 10 f0       	push   $0xf0107afd
f010280c:	e8 2f d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102811:	83 ec 04             	sub    $0x4,%esp
f0102814:	68 00 10 00 00       	push   $0x1000
f0102819:	68 ff 00 00 00       	push   $0xff
f010281e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102823:	50                   	push   %eax
f0102824:	e8 d0 34 00 00       	call   f0105cf9 <memset>
	page_free(pp0);
f0102829:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010282c:	89 3c 24             	mov    %edi,(%esp)
f010282f:	e8 92 ec ff ff       	call   f01014c6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102834:	83 c4 0c             	add    $0xc,%esp
f0102837:	6a 01                	push   $0x1
f0102839:	6a 00                	push   $0x0
f010283b:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102841:	e8 04 ed ff ff       	call   f010154a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102846:	89 fa                	mov    %edi,%edx
f0102848:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f010284e:	c1 fa 03             	sar    $0x3,%edx
f0102851:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102854:	89 d0                	mov    %edx,%eax
f0102856:	c1 e8 0c             	shr    $0xc,%eax
f0102859:	83 c4 10             	add    $0x10,%esp
f010285c:	3b 05 88 ae 21 f0    	cmp    0xf021ae88,%eax
f0102862:	72 12                	jb     f0102876 <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102864:	52                   	push   %edx
f0102865:	68 44 6a 10 f0       	push   $0xf0106a44
f010286a:	6a 58                	push   $0x58
f010286c:	68 fd 7a 10 f0       	push   $0xf0107afd
f0102871:	e8 ca d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102876:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010287c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010287f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102885:	f6 00 01             	testb  $0x1,(%eax)
f0102888:	74 19                	je     f01028a3 <mem_init+0x103c>
f010288a:	68 bf 7d 10 f0       	push   $0xf0107dbf
f010288f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102894:	68 af 04 00 00       	push   $0x4af
f0102899:	68 f1 7a 10 f0       	push   $0xf0107af1
f010289e:	e8 9d d7 ff ff       	call   f0100040 <_panic>
f01028a3:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028a6:	39 d0                	cmp    %edx,%eax
f01028a8:	75 db                	jne    f0102885 <mem_init+0x101e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028aa:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f01028af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028b8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01028be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01028c1:	89 0d 40 a2 21 f0    	mov    %ecx,0xf021a240

	// free the pages we took
	page_free(pp0);
f01028c7:	83 ec 0c             	sub    $0xc,%esp
f01028ca:	50                   	push   %eax
f01028cb:	e8 f6 eb ff ff       	call   f01014c6 <page_free>
	page_free(pp1);
f01028d0:	89 1c 24             	mov    %ebx,(%esp)
f01028d3:	e8 ee eb ff ff       	call   f01014c6 <page_free>
	page_free(pp2);
f01028d8:	89 34 24             	mov    %esi,(%esp)
f01028db:	e8 e6 eb ff ff       	call   f01014c6 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028e0:	83 c4 08             	add    $0x8,%esp
f01028e3:	68 01 10 00 00       	push   $0x1001
f01028e8:	6a 00                	push   $0x0
f01028ea:	e8 fb ee ff ff       	call   f01017ea <mmio_map_region>
f01028ef:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028f1:	83 c4 08             	add    $0x8,%esp
f01028f4:	68 00 10 00 00       	push   $0x1000
f01028f9:	6a 00                	push   $0x0
f01028fb:	e8 ea ee ff ff       	call   f01017ea <mmio_map_region>
f0102900:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102902:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102908:	83 c4 10             	add    $0x10,%esp
f010290b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102911:	76 07                	jbe    f010291a <mem_init+0x10b3>
f0102913:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102918:	76 19                	jbe    f0102933 <mem_init+0x10cc>
f010291a:	68 6c 77 10 f0       	push   $0xf010776c
f010291f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102924:	68 bf 04 00 00       	push   $0x4bf
f0102929:	68 f1 7a 10 f0       	push   $0xf0107af1
f010292e:	e8 0d d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102933:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102939:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010293f:	77 08                	ja     f0102949 <mem_init+0x10e2>
f0102941:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102947:	77 19                	ja     f0102962 <mem_init+0x10fb>
f0102949:	68 94 77 10 f0       	push   $0xf0107794
f010294e:	68 17 7b 10 f0       	push   $0xf0107b17
f0102953:	68 c0 04 00 00       	push   $0x4c0
f0102958:	68 f1 7a 10 f0       	push   $0xf0107af1
f010295d:	e8 de d6 ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102962:	89 da                	mov    %ebx,%edx
f0102964:	09 f2                	or     %esi,%edx
f0102966:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010296c:	74 19                	je     f0102987 <mem_init+0x1120>
f010296e:	68 bc 77 10 f0       	push   $0xf01077bc
f0102973:	68 17 7b 10 f0       	push   $0xf0107b17
f0102978:	68 c2 04 00 00       	push   $0x4c2
f010297d:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102982:	e8 b9 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102987:	39 c6                	cmp    %eax,%esi
f0102989:	73 19                	jae    f01029a4 <mem_init+0x113d>
f010298b:	68 d6 7d 10 f0       	push   $0xf0107dd6
f0102990:	68 17 7b 10 f0       	push   $0xf0107b17
f0102995:	68 c4 04 00 00       	push   $0x4c4
f010299a:	68 f1 7a 10 f0       	push   $0xf0107af1
f010299f:	e8 9c d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029a4:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi
f01029aa:	89 da                	mov    %ebx,%edx
f01029ac:	89 f8                	mov    %edi,%eax
f01029ae:	e8 f0 e5 ff ff       	call   f0100fa3 <check_va2pa>
f01029b3:	85 c0                	test   %eax,%eax
f01029b5:	74 19                	je     f01029d0 <mem_init+0x1169>
f01029b7:	68 e4 77 10 f0       	push   $0xf01077e4
f01029bc:	68 17 7b 10 f0       	push   $0xf0107b17
f01029c1:	68 c6 04 00 00       	push   $0x4c6
f01029c6:	68 f1 7a 10 f0       	push   $0xf0107af1
f01029cb:	e8 70 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01029d0:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01029d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029d9:	89 c2                	mov    %eax,%edx
f01029db:	89 f8                	mov    %edi,%eax
f01029dd:	e8 c1 e5 ff ff       	call   f0100fa3 <check_va2pa>
f01029e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029e7:	74 19                	je     f0102a02 <mem_init+0x119b>
f01029e9:	68 08 78 10 f0       	push   $0xf0107808
f01029ee:	68 17 7b 10 f0       	push   $0xf0107b17
f01029f3:	68 c7 04 00 00       	push   $0x4c7
f01029f8:	68 f1 7a 10 f0       	push   $0xf0107af1
f01029fd:	e8 3e d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a02:	89 f2                	mov    %esi,%edx
f0102a04:	89 f8                	mov    %edi,%eax
f0102a06:	e8 98 e5 ff ff       	call   f0100fa3 <check_va2pa>
f0102a0b:	85 c0                	test   %eax,%eax
f0102a0d:	74 19                	je     f0102a28 <mem_init+0x11c1>
f0102a0f:	68 38 78 10 f0       	push   $0xf0107838
f0102a14:	68 17 7b 10 f0       	push   $0xf0107b17
f0102a19:	68 c8 04 00 00       	push   $0x4c8
f0102a1e:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102a23:	e8 18 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a28:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a2e:	89 f8                	mov    %edi,%eax
f0102a30:	e8 6e e5 ff ff       	call   f0100fa3 <check_va2pa>
f0102a35:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a38:	74 19                	je     f0102a53 <mem_init+0x11ec>
f0102a3a:	68 5c 78 10 f0       	push   $0xf010785c
f0102a3f:	68 17 7b 10 f0       	push   $0xf0107b17
f0102a44:	68 c9 04 00 00       	push   $0x4c9
f0102a49:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102a4e:	e8 ed d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102a53:	83 ec 04             	sub    $0x4,%esp
f0102a56:	6a 00                	push   $0x0
f0102a58:	53                   	push   %ebx
f0102a59:	57                   	push   %edi
f0102a5a:	e8 eb ea ff ff       	call   f010154a <pgdir_walk>
f0102a5f:	83 c4 10             	add    $0x10,%esp
f0102a62:	f6 00 1a             	testb  $0x1a,(%eax)
f0102a65:	75 19                	jne    f0102a80 <mem_init+0x1219>
f0102a67:	68 88 78 10 f0       	push   $0xf0107888
f0102a6c:	68 17 7b 10 f0       	push   $0xf0107b17
f0102a71:	68 cb 04 00 00       	push   $0x4cb
f0102a76:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102a7b:	e8 c0 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a80:	83 ec 04             	sub    $0x4,%esp
f0102a83:	6a 00                	push   $0x0
f0102a85:	53                   	push   %ebx
f0102a86:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102a8c:	e8 b9 ea ff ff       	call   f010154a <pgdir_walk>
f0102a91:	8b 00                	mov    (%eax),%eax
f0102a93:	83 c4 10             	add    $0x10,%esp
f0102a96:	83 e0 04             	and    $0x4,%eax
f0102a99:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102a9c:	74 19                	je     f0102ab7 <mem_init+0x1250>
f0102a9e:	68 cc 78 10 f0       	push   $0xf01078cc
f0102aa3:	68 17 7b 10 f0       	push   $0xf0107b17
f0102aa8:	68 cc 04 00 00       	push   $0x4cc
f0102aad:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102ab2:	e8 89 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102ab7:	83 ec 04             	sub    $0x4,%esp
f0102aba:	6a 00                	push   $0x0
f0102abc:	53                   	push   %ebx
f0102abd:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102ac3:	e8 82 ea ff ff       	call   f010154a <pgdir_walk>
f0102ac8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102ace:	83 c4 0c             	add    $0xc,%esp
f0102ad1:	6a 00                	push   $0x0
f0102ad3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102ad6:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102adc:	e8 69 ea ff ff       	call   f010154a <pgdir_walk>
f0102ae1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102ae7:	83 c4 0c             	add    $0xc,%esp
f0102aea:	6a 00                	push   $0x0
f0102aec:	56                   	push   %esi
f0102aed:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0102af3:	e8 52 ea ff ff       	call   f010154a <pgdir_walk>
f0102af8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102afe:	c7 04 24 e8 7d 10 f0 	movl   $0xf0107de8,(%esp)
f0102b05:	e8 6b 11 00 00       	call   f0103c75 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	size = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b0a:	a1 88 ae 21 f0       	mov    0xf021ae88,%eax
f0102b0f:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102b16:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	/*for(uint32_t i = 0; i < n; i += PGSIZE) {
		page_insert(kern_pgdir, pa2page(PADDR(pages)+i), (void *)(UPAGES+i), PTE_U | PTE_P);
	}*/
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), PTE_U);
f0102b1c:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b21:	83 c4 10             	add    $0x10,%esp
f0102b24:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b29:	77 15                	ja     f0102b40 <mem_init+0x12d9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2b:	50                   	push   %eax
f0102b2c:	68 68 6a 10 f0       	push   $0xf0106a68
f0102b31:	68 c9 00 00 00       	push   $0xc9
f0102b36:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102b3b:	e8 00 d5 ff ff       	call   f0100040 <_panic>
f0102b40:	83 ec 08             	sub    $0x8,%esp
f0102b43:	6a 04                	push   $0x4
f0102b45:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b4a:	50                   	push   %eax
f0102b4b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b50:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102b55:	e8 b8 ea ff ff       	call   f0101612 <boot_map_region>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for(uint32_t i = 0; i < n; i += PGSIZE) {
		page_insert(kern_pgdir, pa2page(PADDR(envs)+i), (void *)(UENVS+i), PTE_U | PTE_P);
	}*/
    size = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
    boot_map_region(kern_pgdir, UENVS, size, PADDR(envs), PTE_U);
f0102b5a:	a1 48 a2 21 f0       	mov    0xf021a248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b5f:	83 c4 10             	add    $0x10,%esp
f0102b62:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b67:	77 15                	ja     f0102b7e <mem_init+0x1317>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b69:	50                   	push   %eax
f0102b6a:	68 68 6a 10 f0       	push   $0xf0106a68
f0102b6f:	68 d8 00 00 00       	push   $0xd8
f0102b74:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102b79:	e8 c2 d4 ff ff       	call   f0100040 <_panic>
f0102b7e:	83 ec 08             	sub    $0x8,%esp
f0102b81:	6a 04                	push   $0x4
f0102b83:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b88:	50                   	push   %eax
f0102b89:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102b8e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b93:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102b98:	e8 75 ea ff ff       	call   f0101612 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b9d:	83 c4 10             	add    $0x10,%esp
f0102ba0:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102ba5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102baa:	77 15                	ja     f0102bc1 <mem_init+0x135a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bac:	50                   	push   %eax
f0102bad:	68 68 6a 10 f0       	push   $0xf0106a68
f0102bb2:	68 ec 00 00 00       	push   $0xec
f0102bb7:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102bbc:	e8 7f d4 ff ff       	call   f0100040 <_panic>
	for(uint32_t i = 0; i < KSTKSIZE; i += PGSIZE) {
		page_insert(kern_pgdir, pa2page(PADDR(bootstack)+i), (void *)(KSTACKTOP-KSTKSIZE+i), PTE_W | PTE_P);
	}
		}
	*/
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102bc1:	83 ec 08             	sub    $0x8,%esp
f0102bc4:	6a 02                	push   $0x2
f0102bc6:	68 00 70 11 00       	push   $0x117000
f0102bcb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102bd0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102bd5:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102bda:	e8 33 ea ff ff       	call   f0101612 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, 0xFFFFFFFF-KERNBASE+1, 0, PTE_W);
f0102bdf:	83 c4 08             	add    $0x8,%esp
f0102be2:	6a 02                	push   $0x2
f0102be4:	6a 00                	push   $0x0
f0102be6:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102beb:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102bf0:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102bf5:	e8 18 ea ff ff       	call   f0101612 <boot_map_region>
f0102bfa:	c7 45 c4 00 c0 21 f0 	movl   $0xf021c000,-0x3c(%ebp)
f0102c01:	83 c4 10             	add    $0x10,%esp
f0102c04:	bb 00 c0 21 f0       	mov    $0xf021c000,%ebx
f0102c09:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c0e:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102c14:	77 15                	ja     f0102c2b <mem_init+0x13c4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c16:	53                   	push   %ebx
f0102c17:	68 68 6a 10 f0       	push   $0xf0106a68
f0102c1c:	68 37 01 00 00       	push   $0x137
f0102c21:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102c26:	e8 15 d4 ff ff       	call   f0100040 <_panic>
		//if(i == cpunum())  
		//	continue;

		uintptr_t addr_top = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		uintptr_t addr_bottom = addr_top - KSTKSIZE;
		boot_map_region(kern_pgdir, addr_bottom, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102c2b:	83 ec 08             	sub    $0x8,%esp
f0102c2e:	6a 02                	push   $0x2
f0102c30:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102c36:	50                   	push   %eax
f0102c37:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c3c:	89 f2                	mov    %esi,%edx
f0102c3e:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
f0102c43:	e8 ca e9 ff ff       	call   f0101612 <boot_map_region>
f0102c48:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102c4e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for(int i = 0; i < NCPU; ++i) {
f0102c54:	83 c4 10             	add    $0x10,%esp
f0102c57:	b8 00 c0 25 f0       	mov    $0xf025c000,%eax
f0102c5c:	39 d8                	cmp    %ebx,%eax
f0102c5e:	75 ae                	jne    f0102c0e <mem_init+0x13a7>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102c60:	8b 3d 8c ae 21 f0    	mov    0xf021ae8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c66:	a1 88 ae 21 f0       	mov    0xf021ae88,%eax
f0102c6b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102c6e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102c75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102c7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c7d:	8b 35 90 ae 21 f0    	mov    0xf021ae90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c83:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c8b:	eb 55                	jmp    f0102ce2 <mem_init+0x147b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c8d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102c93:	89 f8                	mov    %edi,%eax
f0102c95:	e8 09 e3 ff ff       	call   f0100fa3 <check_va2pa>
f0102c9a:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102ca1:	77 15                	ja     f0102cb8 <mem_init+0x1451>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ca3:	56                   	push   %esi
f0102ca4:	68 68 6a 10 f0       	push   $0xf0106a68
f0102ca9:	68 e2 03 00 00       	push   $0x3e2
f0102cae:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102cb3:	e8 88 d3 ff ff       	call   f0100040 <_panic>
f0102cb8:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102cbf:	39 c2                	cmp    %eax,%edx
f0102cc1:	74 19                	je     f0102cdc <mem_init+0x1475>
f0102cc3:	68 00 79 10 f0       	push   $0xf0107900
f0102cc8:	68 17 7b 10 f0       	push   $0xf0107b17
f0102ccd:	68 e2 03 00 00       	push   $0x3e2
f0102cd2:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102cd7:	e8 64 d3 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102cdc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ce2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102ce5:	77 a6                	ja     f0102c8d <mem_init+0x1426>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ce7:	8b 35 48 a2 21 f0    	mov    0xf021a248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ced:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102cf0:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102cf5:	89 da                	mov    %ebx,%edx
f0102cf7:	89 f8                	mov    %edi,%eax
f0102cf9:	e8 a5 e2 ff ff       	call   f0100fa3 <check_va2pa>
f0102cfe:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102d05:	77 15                	ja     f0102d1c <mem_init+0x14b5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d07:	56                   	push   %esi
f0102d08:	68 68 6a 10 f0       	push   $0xf0106a68
f0102d0d:	68 e7 03 00 00       	push   $0x3e7
f0102d12:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102d17:	e8 24 d3 ff ff       	call   f0100040 <_panic>
f0102d1c:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102d23:	39 d0                	cmp    %edx,%eax
f0102d25:	74 19                	je     f0102d40 <mem_init+0x14d9>
f0102d27:	68 34 79 10 f0       	push   $0xf0107934
f0102d2c:	68 17 7b 10 f0       	push   $0xf0107b17
f0102d31:	68 e7 03 00 00       	push   $0x3e7
f0102d36:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102d3b:	e8 00 d3 ff ff       	call   f0100040 <_panic>
f0102d40:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d46:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102d4c:	75 a7                	jne    f0102cf5 <mem_init+0x148e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d4e:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102d51:	c1 e6 0c             	shl    $0xc,%esi
f0102d54:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102d59:	eb 30                	jmp    f0102d8b <mem_init+0x1524>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d5b:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102d61:	89 f8                	mov    %edi,%eax
f0102d63:	e8 3b e2 ff ff       	call   f0100fa3 <check_va2pa>
f0102d68:	39 c3                	cmp    %eax,%ebx
f0102d6a:	74 19                	je     f0102d85 <mem_init+0x151e>
f0102d6c:	68 68 79 10 f0       	push   $0xf0107968
f0102d71:	68 17 7b 10 f0       	push   $0xf0107b17
f0102d76:	68 eb 03 00 00       	push   $0x3eb
f0102d7b:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102d80:	e8 bb d2 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d8b:	39 f3                	cmp    %esi,%ebx
f0102d8d:	72 cc                	jb     f0102d5b <mem_init+0x14f4>
f0102d8f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102d94:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102d97:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102d9a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102d9d:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102da3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102da6:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102da8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102dab:	05 00 80 00 20       	add    $0x20008000,%eax
f0102db0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102db3:	89 da                	mov    %ebx,%edx
f0102db5:	89 f8                	mov    %edi,%eax
f0102db7:	e8 e7 e1 ff ff       	call   f0100fa3 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dbc:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102dc2:	77 15                	ja     f0102dd9 <mem_init+0x1572>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dc4:	56                   	push   %esi
f0102dc5:	68 68 6a 10 f0       	push   $0xf0106a68
f0102dca:	68 f3 03 00 00       	push   $0x3f3
f0102dcf:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102dd4:	e8 67 d2 ff ff       	call   f0100040 <_panic>
f0102dd9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102ddc:	8d 94 0b 00 c0 21 f0 	lea    -0xfde4000(%ebx,%ecx,1),%edx
f0102de3:	39 d0                	cmp    %edx,%eax
f0102de5:	74 19                	je     f0102e00 <mem_init+0x1599>
f0102de7:	68 90 79 10 f0       	push   $0xf0107990
f0102dec:	68 17 7b 10 f0       	push   $0xf0107b17
f0102df1:	68 f3 03 00 00       	push   $0x3f3
f0102df6:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102dfb:	e8 40 d2 ff ff       	call   f0100040 <_panic>
f0102e00:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
f0102e06:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102e09:	75 a8                	jne    f0102db3 <mem_init+0x154c>
f0102e0b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e0e:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102e14:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102e17:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i); 
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102e19:	89 da                	mov    %ebx,%edx
f0102e1b:	89 f8                	mov    %edi,%eax
f0102e1d:	e8 81 e1 ff ff       	call   f0100fa3 <check_va2pa>
f0102e22:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e25:	74 19                	je     f0102e40 <mem_init+0x15d9>
f0102e27:	68 d8 79 10 f0       	push   $0xf01079d8
f0102e2c:	68 17 7b 10 f0       	push   $0xf0107b17
f0102e31:	68 f5 03 00 00       	push   $0x3f5
f0102e36:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102e3b:	e8 00 d2 ff ff       	call   f0100040 <_panic>
f0102e40:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i); 
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e46:	39 f3                	cmp    %esi,%ebx
f0102e48:	75 cf                	jne    f0102e19 <mem_init+0x15b2>
f0102e4a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102e4d:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102e54:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102e5b:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102e61:	b8 00 c0 25 f0       	mov    $0xf025c000,%eax
f0102e66:	39 f0                	cmp    %esi,%eax
f0102e68:	0f 85 2c ff ff ff    	jne    f0102d9a <mem_init+0x1533>
f0102e6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e73:	eb 2a                	jmp    f0102e9f <mem_init+0x1638>
	}


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102e75:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102e7b:	83 fa 04             	cmp    $0x4,%edx
f0102e7e:	77 1f                	ja     f0102e9f <mem_init+0x1638>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102e80:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102e84:	75 7e                	jne    f0102f04 <mem_init+0x169d>
f0102e86:	68 01 7e 10 f0       	push   $0xf0107e01
f0102e8b:	68 17 7b 10 f0       	push   $0xf0107b17
f0102e90:	68 01 04 00 00       	push   $0x401
f0102e95:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102e9a:	e8 a1 d1 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102e9f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ea4:	76 3f                	jbe    f0102ee5 <mem_init+0x167e>
				assert(pgdir[i] & PTE_P);
f0102ea6:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ea9:	f6 c2 01             	test   $0x1,%dl
f0102eac:	75 19                	jne    f0102ec7 <mem_init+0x1660>
f0102eae:	68 01 7e 10 f0       	push   $0xf0107e01
f0102eb3:	68 17 7b 10 f0       	push   $0xf0107b17
f0102eb8:	68 05 04 00 00       	push   $0x405
f0102ebd:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102ec2:	e8 79 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ec7:	f6 c2 02             	test   $0x2,%dl
f0102eca:	75 38                	jne    f0102f04 <mem_init+0x169d>
f0102ecc:	68 12 7e 10 f0       	push   $0xf0107e12
f0102ed1:	68 17 7b 10 f0       	push   $0xf0107b17
f0102ed6:	68 06 04 00 00       	push   $0x406
f0102edb:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102ee0:	e8 5b d1 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102ee5:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ee9:	74 19                	je     f0102f04 <mem_init+0x169d>
f0102eeb:	68 23 7e 10 f0       	push   $0xf0107e23
f0102ef0:	68 17 7b 10 f0       	push   $0xf0107b17
f0102ef5:	68 08 04 00 00       	push   $0x408
f0102efa:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102eff:	e8 3c d1 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102f04:	83 c0 01             	add    $0x1,%eax
f0102f07:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102f0c:	0f 86 63 ff ff ff    	jbe    f0102e75 <mem_init+0x160e>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f12:	83 ec 0c             	sub    $0xc,%esp
f0102f15:	68 fc 79 10 f0       	push   $0xf01079fc
f0102f1a:	e8 56 0d 00 00       	call   f0103c75 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f1f:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f24:	83 c4 10             	add    $0x10,%esp
f0102f27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f2c:	77 15                	ja     f0102f43 <mem_init+0x16dc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f2e:	50                   	push   %eax
f0102f2f:	68 68 6a 10 f0       	push   $0xf0106a68
f0102f34:	68 0c 01 00 00       	push   $0x10c
f0102f39:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102f3e:	e8 fd d0 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f43:	05 00 00 00 10       	add    $0x10000000,%eax
f0102f48:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102f4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f50:	e8 b2 e0 ff ff       	call   f0101007 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102f55:	0f 20 c0             	mov    %cr0,%eax
f0102f58:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102f5b:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102f60:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f63:	83 ec 0c             	sub    $0xc,%esp
f0102f66:	6a 00                	push   $0x0
f0102f68:	e8 e9 e4 ff ff       	call   f0101456 <page_alloc>
f0102f6d:	89 c3                	mov    %eax,%ebx
f0102f6f:	83 c4 10             	add    $0x10,%esp
f0102f72:	85 c0                	test   %eax,%eax
f0102f74:	75 19                	jne    f0102f8f <mem_init+0x1728>
f0102f76:	68 0d 7c 10 f0       	push   $0xf0107c0d
f0102f7b:	68 17 7b 10 f0       	push   $0xf0107b17
f0102f80:	68 e1 04 00 00       	push   $0x4e1
f0102f85:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102f8a:	e8 b1 d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f8f:	83 ec 0c             	sub    $0xc,%esp
f0102f92:	6a 00                	push   $0x0
f0102f94:	e8 bd e4 ff ff       	call   f0101456 <page_alloc>
f0102f99:	89 c7                	mov    %eax,%edi
f0102f9b:	83 c4 10             	add    $0x10,%esp
f0102f9e:	85 c0                	test   %eax,%eax
f0102fa0:	75 19                	jne    f0102fbb <mem_init+0x1754>
f0102fa2:	68 23 7c 10 f0       	push   $0xf0107c23
f0102fa7:	68 17 7b 10 f0       	push   $0xf0107b17
f0102fac:	68 e2 04 00 00       	push   $0x4e2
f0102fb1:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102fb6:	e8 85 d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fbb:	83 ec 0c             	sub    $0xc,%esp
f0102fbe:	6a 00                	push   $0x0
f0102fc0:	e8 91 e4 ff ff       	call   f0101456 <page_alloc>
f0102fc5:	89 c6                	mov    %eax,%esi
f0102fc7:	83 c4 10             	add    $0x10,%esp
f0102fca:	85 c0                	test   %eax,%eax
f0102fcc:	75 19                	jne    f0102fe7 <mem_init+0x1780>
f0102fce:	68 39 7c 10 f0       	push   $0xf0107c39
f0102fd3:	68 17 7b 10 f0       	push   $0xf0107b17
f0102fd8:	68 e3 04 00 00       	push   $0x4e3
f0102fdd:	68 f1 7a 10 f0       	push   $0xf0107af1
f0102fe2:	e8 59 d0 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102fe7:	83 ec 0c             	sub    $0xc,%esp
f0102fea:	53                   	push   %ebx
f0102feb:	e8 d6 e4 ff ff       	call   f01014c6 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ff0:	89 f8                	mov    %edi,%eax
f0102ff2:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0102ff8:	c1 f8 03             	sar    $0x3,%eax
f0102ffb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ffe:	89 c2                	mov    %eax,%edx
f0103000:	c1 ea 0c             	shr    $0xc,%edx
f0103003:	83 c4 10             	add    $0x10,%esp
f0103006:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f010300c:	72 12                	jb     f0103020 <mem_init+0x17b9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010300e:	50                   	push   %eax
f010300f:	68 44 6a 10 f0       	push   $0xf0106a44
f0103014:	6a 58                	push   $0x58
f0103016:	68 fd 7a 10 f0       	push   $0xf0107afd
f010301b:	e8 20 d0 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103020:	83 ec 04             	sub    $0x4,%esp
f0103023:	68 00 10 00 00       	push   $0x1000
f0103028:	6a 01                	push   $0x1
f010302a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010302f:	50                   	push   %eax
f0103030:	e8 c4 2c 00 00       	call   f0105cf9 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103035:	89 f0                	mov    %esi,%eax
f0103037:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f010303d:	c1 f8 03             	sar    $0x3,%eax
f0103040:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103043:	89 c2                	mov    %eax,%edx
f0103045:	c1 ea 0c             	shr    $0xc,%edx
f0103048:	83 c4 10             	add    $0x10,%esp
f010304b:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f0103051:	72 12                	jb     f0103065 <mem_init+0x17fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103053:	50                   	push   %eax
f0103054:	68 44 6a 10 f0       	push   $0xf0106a44
f0103059:	6a 58                	push   $0x58
f010305b:	68 fd 7a 10 f0       	push   $0xf0107afd
f0103060:	e8 db cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103065:	83 ec 04             	sub    $0x4,%esp
f0103068:	68 00 10 00 00       	push   $0x1000
f010306d:	6a 02                	push   $0x2
f010306f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103074:	50                   	push   %eax
f0103075:	e8 7f 2c 00 00       	call   f0105cf9 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010307a:	6a 02                	push   $0x2
f010307c:	68 00 10 00 00       	push   $0x1000
f0103081:	57                   	push   %edi
f0103082:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f0103088:	e8 ce e6 ff ff       	call   f010175b <page_insert>
	assert(pp1->pp_ref == 1);
f010308d:	83 c4 20             	add    $0x20,%esp
f0103090:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103095:	74 19                	je     f01030b0 <mem_init+0x1849>
f0103097:	68 0a 7d 10 f0       	push   $0xf0107d0a
f010309c:	68 17 7b 10 f0       	push   $0xf0107b17
f01030a1:	68 e8 04 00 00       	push   $0x4e8
f01030a6:	68 f1 7a 10 f0       	push   $0xf0107af1
f01030ab:	e8 90 cf ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030b0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01030b7:	01 01 01 
f01030ba:	74 19                	je     f01030d5 <mem_init+0x186e>
f01030bc:	68 1c 7a 10 f0       	push   $0xf0107a1c
f01030c1:	68 17 7b 10 f0       	push   $0xf0107b17
f01030c6:	68 e9 04 00 00       	push   $0x4e9
f01030cb:	68 f1 7a 10 f0       	push   $0xf0107af1
f01030d0:	e8 6b cf ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01030d5:	6a 02                	push   $0x2
f01030d7:	68 00 10 00 00       	push   $0x1000
f01030dc:	56                   	push   %esi
f01030dd:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01030e3:	e8 73 e6 ff ff       	call   f010175b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030e8:	83 c4 10             	add    $0x10,%esp
f01030eb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01030f2:	02 02 02 
f01030f5:	74 19                	je     f0103110 <mem_init+0x18a9>
f01030f7:	68 40 7a 10 f0       	push   $0xf0107a40
f01030fc:	68 17 7b 10 f0       	push   $0xf0107b17
f0103101:	68 eb 04 00 00       	push   $0x4eb
f0103106:	68 f1 7a 10 f0       	push   $0xf0107af1
f010310b:	e8 30 cf ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103110:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103115:	74 19                	je     f0103130 <mem_init+0x18c9>
f0103117:	68 2c 7d 10 f0       	push   $0xf0107d2c
f010311c:	68 17 7b 10 f0       	push   $0xf0107b17
f0103121:	68 ec 04 00 00       	push   $0x4ec
f0103126:	68 f1 7a 10 f0       	push   $0xf0107af1
f010312b:	e8 10 cf ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103130:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103135:	74 19                	je     f0103150 <mem_init+0x18e9>
f0103137:	68 96 7d 10 f0       	push   $0xf0107d96
f010313c:	68 17 7b 10 f0       	push   $0xf0107b17
f0103141:	68 ed 04 00 00       	push   $0x4ed
f0103146:	68 f1 7a 10 f0       	push   $0xf0107af1
f010314b:	e8 f0 ce ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103150:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103157:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010315a:	89 f0                	mov    %esi,%eax
f010315c:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f0103162:	c1 f8 03             	sar    $0x3,%eax
f0103165:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103168:	89 c2                	mov    %eax,%edx
f010316a:	c1 ea 0c             	shr    $0xc,%edx
f010316d:	3b 15 88 ae 21 f0    	cmp    0xf021ae88,%edx
f0103173:	72 12                	jb     f0103187 <mem_init+0x1920>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103175:	50                   	push   %eax
f0103176:	68 44 6a 10 f0       	push   $0xf0106a44
f010317b:	6a 58                	push   $0x58
f010317d:	68 fd 7a 10 f0       	push   $0xf0107afd
f0103182:	e8 b9 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103187:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010318e:	03 03 03 
f0103191:	74 19                	je     f01031ac <mem_init+0x1945>
f0103193:	68 64 7a 10 f0       	push   $0xf0107a64
f0103198:	68 17 7b 10 f0       	push   $0xf0107b17
f010319d:	68 ef 04 00 00       	push   $0x4ef
f01031a2:	68 f1 7a 10 f0       	push   $0xf0107af1
f01031a7:	e8 94 ce ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01031ac:	83 ec 08             	sub    $0x8,%esp
f01031af:	68 00 10 00 00       	push   $0x1000
f01031b4:	ff 35 8c ae 21 f0    	pushl  0xf021ae8c
f01031ba:	e8 4f e5 ff ff       	call   f010170e <page_remove>
	assert(pp2->pp_ref == 0);
f01031bf:	83 c4 10             	add    $0x10,%esp
f01031c2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01031c7:	74 19                	je     f01031e2 <mem_init+0x197b>
f01031c9:	68 64 7d 10 f0       	push   $0xf0107d64
f01031ce:	68 17 7b 10 f0       	push   $0xf0107b17
f01031d3:	68 f1 04 00 00       	push   $0x4f1
f01031d8:	68 f1 7a 10 f0       	push   $0xf0107af1
f01031dd:	e8 5e ce ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031e2:	8b 0d 8c ae 21 f0    	mov    0xf021ae8c,%ecx
f01031e8:	8b 11                	mov    (%ecx),%edx
f01031ea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01031f0:	89 d8                	mov    %ebx,%eax
f01031f2:	2b 05 90 ae 21 f0    	sub    0xf021ae90,%eax
f01031f8:	c1 f8 03             	sar    $0x3,%eax
f01031fb:	c1 e0 0c             	shl    $0xc,%eax
f01031fe:	39 c2                	cmp    %eax,%edx
f0103200:	74 19                	je     f010321b <mem_init+0x19b4>
f0103202:	68 ec 73 10 f0       	push   $0xf01073ec
f0103207:	68 17 7b 10 f0       	push   $0xf0107b17
f010320c:	68 f4 04 00 00       	push   $0x4f4
f0103211:	68 f1 7a 10 f0       	push   $0xf0107af1
f0103216:	e8 25 ce ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010321b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103221:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103226:	74 19                	je     f0103241 <mem_init+0x19da>
f0103228:	68 1b 7d 10 f0       	push   $0xf0107d1b
f010322d:	68 17 7b 10 f0       	push   $0xf0107b17
f0103232:	68 f6 04 00 00       	push   $0x4f6
f0103237:	68 f1 7a 10 f0       	push   $0xf0107af1
f010323c:	e8 ff cd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103241:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103247:	83 ec 0c             	sub    $0xc,%esp
f010324a:	53                   	push   %ebx
f010324b:	e8 76 e2 ff ff       	call   f01014c6 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103250:	c7 04 24 90 7a 10 f0 	movl   $0xf0107a90,(%esp)
f0103257:	e8 19 0a 00 00       	call   f0103c75 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010325c:	83 c4 10             	add    $0x10,%esp
f010325f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103262:	5b                   	pop    %ebx
f0103263:	5e                   	pop    %esi
f0103264:	5f                   	pop    %edi
f0103265:	5d                   	pop    %ebp
f0103266:	c3                   	ret    

f0103267 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103267:	55                   	push   %ebp
f0103268:	89 e5                	mov    %esp,%ebp
f010326a:	57                   	push   %edi
f010326b:	56                   	push   %esi
f010326c:	53                   	push   %ebx
f010326d:	83 ec 0c             	sub    $0xc,%esp
f0103270:	8b 45 10             	mov    0x10(%ebp),%eax
	// LAB 3: Your code here.
	if((size_t)va + len > ULIM) {
f0103273:	89 c2                	mov    %eax,%edx
f0103275:	03 55 0c             	add    0xc(%ebp),%edx
f0103278:	81 fa 00 00 80 ef    	cmp    $0xef800000,%edx
f010327e:	76 2f                	jbe    f01032af <user_mem_check+0x48>
		if(ULIM < (uintptr_t)va)
f0103280:	81 7d 0c 00 00 80 ef 	cmpl   $0xef800000,0xc(%ebp)
f0103287:	76 12                	jbe    f010329b <user_mem_check+0x34>
			user_mem_check_addr = (uintptr_t)va;
f0103289:	8b 45 0c             	mov    0xc(%ebp),%eax
f010328c:	a3 3c a2 21 f0       	mov    %eax,0xf021a23c
		else 
			user_mem_check_addr = ULIM;
		return -E_FAULT;
f0103291:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103296:	e9 a6 00 00 00       	jmp    f0103341 <user_mem_check+0xda>
	// LAB 3: Your code here.
	if((size_t)va + len > ULIM) {
		if(ULIM < (uintptr_t)va)
			user_mem_check_addr = (uintptr_t)va;
		else 
			user_mem_check_addr = ULIM;
f010329b:	c7 05 3c a2 21 f0 00 	movl   $0xef800000,0xf021a23c
f01032a2:	00 80 ef 
		return -E_FAULT;
f01032a5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01032aa:	e9 92 00 00 00       	jmp    f0103341 <user_mem_check+0xda>
	}

	uintptr_t begin_addr = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f01032af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01032b2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t end_addr = (uintptr_t)ROUNDUP(va+len, PGSIZE);
f01032b8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032bb:	8d bc 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%edi
f01032c2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
			else 
				user_mem_check_addr = addr;
			
			return -E_FAULT;
		}
		else if(((*pte_entry) & (perm | PTE_P)) != (perm | PTE_P)) {
f01032c8:	8b 75 14             	mov    0x14(%ebp),%esi
f01032cb:	83 ce 01             	or     $0x1,%esi
		return -E_FAULT;
	}

	uintptr_t begin_addr = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t end_addr = (uintptr_t)ROUNDUP(va+len, PGSIZE);
	for(uintptr_t addr = begin_addr; addr < end_addr; addr += PGSIZE) {
f01032ce:	eb 68                	jmp    f0103338 <user_mem_check+0xd1>
		pte_t *pte_entry = pgdir_walk(env->env_pgdir, (void *)addr, 0);
f01032d0:	83 ec 04             	sub    $0x4,%esp
f01032d3:	6a 00                	push   $0x0
f01032d5:	53                   	push   %ebx
f01032d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d9:	ff 70 60             	pushl  0x60(%eax)
f01032dc:	e8 69 e2 ff ff       	call   f010154a <pgdir_walk>
		
		if(pte_entry == NULL) {
f01032e1:	83 c4 10             	add    $0x10,%esp
f01032e4:	85 c0                	test   %eax,%eax
f01032e6:	75 21                	jne    f0103309 <user_mem_check+0xa2>
			
			if(addr < (uintptr_t)va)
f01032e8:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01032eb:	73 0f                	jae    f01032fc <user_mem_check+0x95>
				user_mem_check_addr = (uintptr_t)va;
f01032ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032f0:	a3 3c a2 21 f0       	mov    %eax,0xf021a23c
			else 
				user_mem_check_addr = addr;
			
			return -E_FAULT;
f01032f5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01032fa:	eb 45                	jmp    f0103341 <user_mem_check+0xda>
		if(pte_entry == NULL) {
			
			if(addr < (uintptr_t)va)
				user_mem_check_addr = (uintptr_t)va;
			else 
				user_mem_check_addr = addr;
f01032fc:	89 1d 3c a2 21 f0    	mov    %ebx,0xf021a23c
			
			return -E_FAULT;
f0103302:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103307:	eb 38                	jmp    f0103341 <user_mem_check+0xda>
		}
		else if(((*pte_entry) & (perm | PTE_P)) != (perm | PTE_P)) {
f0103309:	89 f1                	mov    %esi,%ecx
f010330b:	23 08                	and    (%eax),%ecx
f010330d:	39 ce                	cmp    %ecx,%esi
f010330f:	74 21                	je     f0103332 <user_mem_check+0xcb>
			
			if(addr < (uintptr_t)va)
f0103311:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103314:	73 0f                	jae    f0103325 <user_mem_check+0xbe>
				user_mem_check_addr = (uintptr_t)va;
f0103316:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103319:	a3 3c a2 21 f0       	mov    %eax,0xf021a23c
			else 
				user_mem_check_addr = addr;
			
			return -E_FAULT;
f010331e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103323:	eb 1c                	jmp    f0103341 <user_mem_check+0xda>
		else if(((*pte_entry) & (perm | PTE_P)) != (perm | PTE_P)) {
			
			if(addr < (uintptr_t)va)
				user_mem_check_addr = (uintptr_t)va;
			else 
				user_mem_check_addr = addr;
f0103325:	89 1d 3c a2 21 f0    	mov    %ebx,0xf021a23c
			
			return -E_FAULT;
f010332b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103330:	eb 0f                	jmp    f0103341 <user_mem_check+0xda>
		return -E_FAULT;
	}

	uintptr_t begin_addr = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t end_addr = (uintptr_t)ROUNDUP(va+len, PGSIZE);
	for(uintptr_t addr = begin_addr; addr < end_addr; addr += PGSIZE) {
f0103332:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103338:	39 fb                	cmp    %edi,%ebx
f010333a:	72 94                	jb     f01032d0 <user_mem_check+0x69>
				user_mem_check_addr = addr;
			
			return -E_FAULT;
		}
	}
	return 0;
f010333c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103341:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103344:	5b                   	pop    %ebx
f0103345:	5e                   	pop    %esi
f0103346:	5f                   	pop    %edi
f0103347:	5d                   	pop    %ebp
f0103348:	c3                   	ret    

f0103349 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103349:	55                   	push   %ebp
f010334a:	89 e5                	mov    %esp,%ebp
f010334c:	53                   	push   %ebx
f010334d:	83 ec 04             	sub    $0x4,%esp
f0103350:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103353:	8b 45 14             	mov    0x14(%ebp),%eax
f0103356:	83 c8 04             	or     $0x4,%eax
f0103359:	50                   	push   %eax
f010335a:	ff 75 10             	pushl  0x10(%ebp)
f010335d:	ff 75 0c             	pushl  0xc(%ebp)
f0103360:	53                   	push   %ebx
f0103361:	e8 01 ff ff ff       	call   f0103267 <user_mem_check>
f0103366:	83 c4 10             	add    $0x10,%esp
f0103369:	85 c0                	test   %eax,%eax
f010336b:	79 21                	jns    f010338e <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f010336d:	83 ec 04             	sub    $0x4,%esp
f0103370:	ff 35 3c a2 21 f0    	pushl  0xf021a23c
f0103376:	ff 73 48             	pushl  0x48(%ebx)
f0103379:	68 bc 7a 10 f0       	push   $0xf0107abc
f010337e:	e8 f2 08 00 00       	call   f0103c75 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103383:	89 1c 24             	mov    %ebx,(%esp)
f0103386:	e8 b7 05 00 00       	call   f0103942 <env_destroy>
f010338b:	83 c4 10             	add    $0x10,%esp
	}
}
f010338e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103391:	c9                   	leave  
f0103392:	c3                   	ret    

f0103393 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103393:	55                   	push   %ebp
f0103394:	89 e5                	mov    %esp,%ebp
f0103396:	57                   	push   %edi
f0103397:	56                   	push   %esi
f0103398:	53                   	push   %ebx
f0103399:	83 ec 0c             	sub    $0xc,%esp
f010339c:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	// the begin and end addresses for the mapped virtual address
	uintptr_t begin_addr = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f010339e:	89 d3                	mov    %edx,%ebx
f01033a0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t end_addr = (uintptr_t)ROUNDUP(va+len, PGSIZE);
f01033a6:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01033ad:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	for(uintptr_t addr = begin_addr; addr < end_addr; addr += PGSIZE) {
f01033b3:	eb 3d                	jmp    f01033f2 <region_alloc+0x5f>
		struct PageInfo *p = NULL;

		// panic if allocation fails
		if(!(p = page_alloc(!ALLOC_ZERO))) 
f01033b5:	83 ec 0c             	sub    $0xc,%esp
f01033b8:	6a 00                	push   $0x0
f01033ba:	e8 97 e0 ff ff       	call   f0101456 <page_alloc>
f01033bf:	83 c4 10             	add    $0x10,%esp
f01033c2:	85 c0                	test   %eax,%eax
f01033c4:	75 17                	jne    f01033dd <region_alloc+0x4a>
			panic("allocation attept fails");
f01033c6:	83 ec 04             	sub    $0x4,%esp
f01033c9:	68 31 7e 10 f0       	push   $0xf0107e31
f01033ce:	68 43 01 00 00       	push   $0x143
f01033d3:	68 49 7e 10 f0       	push   $0xf0107e49
f01033d8:	e8 63 cc ff ff       	call   f0100040 <_panic>

		page_insert(e->env_pgdir, p, (void *)addr, PTE_U | PTE_W);
f01033dd:	6a 06                	push   $0x6
f01033df:	53                   	push   %ebx
f01033e0:	50                   	push   %eax
f01033e1:	ff 77 60             	pushl  0x60(%edi)
f01033e4:	e8 72 e3 ff ff       	call   f010175b <page_insert>

	// the begin and end addresses for the mapped virtual address
	uintptr_t begin_addr = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t end_addr = (uintptr_t)ROUNDUP(va+len, PGSIZE);

	for(uintptr_t addr = begin_addr; addr < end_addr; addr += PGSIZE) {
f01033e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033ef:	83 c4 10             	add    $0x10,%esp
f01033f2:	39 f3                	cmp    %esi,%ebx
f01033f4:	72 bf                	jb     f01033b5 <region_alloc+0x22>
		if(!(p = page_alloc(!ALLOC_ZERO))) 
			panic("allocation attept fails");

		page_insert(e->env_pgdir, p, (void *)addr, PTE_U | PTE_W);
	}
}
f01033f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033f9:	5b                   	pop    %ebx
f01033fa:	5e                   	pop    %esi
f01033fb:	5f                   	pop    %edi
f01033fc:	5d                   	pop    %ebp
f01033fd:	c3                   	ret    

f01033fe <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01033fe:	55                   	push   %ebp
f01033ff:	89 e5                	mov    %esp,%ebp
f0103401:	56                   	push   %esi
f0103402:	53                   	push   %ebx
f0103403:	8b 45 08             	mov    0x8(%ebp),%eax
f0103406:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103409:	85 c0                	test   %eax,%eax
f010340b:	75 1a                	jne    f0103427 <envid2env+0x29>
		*env_store = curenv;
f010340d:	e8 80 2f 00 00       	call   f0106392 <cpunum>
f0103412:	6b c0 74             	imul   $0x74,%eax,%eax
f0103415:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f010341b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010341e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103420:	b8 00 00 00 00       	mov    $0x0,%eax
f0103425:	eb 70                	jmp    f0103497 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103427:	89 c3                	mov    %eax,%ebx
f0103429:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010342f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103432:	03 1d 48 a2 21 f0    	add    0xf021a248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103438:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010343c:	74 05                	je     f0103443 <envid2env+0x45>
f010343e:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103441:	74 10                	je     f0103453 <envid2env+0x55>
		*env_store = 0;
f0103443:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103446:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010344c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103451:	eb 44                	jmp    f0103497 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103453:	84 d2                	test   %dl,%dl
f0103455:	74 36                	je     f010348d <envid2env+0x8f>
f0103457:	e8 36 2f 00 00       	call   f0106392 <cpunum>
f010345c:	6b c0 74             	imul   $0x74,%eax,%eax
f010345f:	3b 98 28 b0 21 f0    	cmp    -0xfde4fd8(%eax),%ebx
f0103465:	74 26                	je     f010348d <envid2env+0x8f>
f0103467:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010346a:	e8 23 2f 00 00       	call   f0106392 <cpunum>
f010346f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103472:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103478:	3b 70 48             	cmp    0x48(%eax),%esi
f010347b:	74 10                	je     f010348d <envid2env+0x8f>
		// if it is a file system environment then we can do that
		// else we cannot 
		if(curenv->env_type != ENV_TYPE_FS) 
		#endif
		{
			*env_store = 0;
f010347d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103480:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return -E_BAD_ENV;
f0103486:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010348b:	eb 0a                	jmp    f0103497 <envid2env+0x99>
		}
	}

	*env_store = e;
f010348d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103490:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103492:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103497:	5b                   	pop    %ebx
f0103498:	5e                   	pop    %esi
f0103499:	5d                   	pop    %ebp
f010349a:	c3                   	ret    

f010349b <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010349b:	55                   	push   %ebp
f010349c:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f010349e:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01034a3:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01034a6:	b8 23 00 00 00       	mov    $0x23,%eax
f01034ab:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01034ad:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01034af:	b8 10 00 00 00       	mov    $0x10,%eax
f01034b4:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01034b6:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01034b8:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01034ba:	ea c1 34 10 f0 08 00 	ljmp   $0x8,$0xf01034c1
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01034c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01034c6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01034c9:	5d                   	pop    %ebp
f01034ca:	c3                   	ret    

f01034cb <env_init>:
{
	// Set up envs array
	// LAB 3: Your code here.

	for(uint32_t i = 0; i < NENV-1; ++i) {
		envs[i].env_id = 0;
f01034cb:	8b 15 48 a2 21 f0    	mov    0xf021a248,%edx
f01034d1:	8d 42 7c             	lea    0x7c(%edx),%eax
f01034d4:	81 c2 00 f0 01 00    	add    $0x1f000,%edx
f01034da:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		envs[i].env_link = &envs[i+1];
f01034e1:	89 40 c8             	mov    %eax,-0x38(%eax)
		envs[i].env_status = ENV_FREE;
f01034e4:	c7 40 d8 00 00 00 00 	movl   $0x0,-0x28(%eax)
f01034eb:	83 c0 7c             	add    $0x7c,%eax
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.

	for(uint32_t i = 0; i < NENV-1; ++i) {
f01034ee:	39 d0                	cmp    %edx,%eax
f01034f0:	75 e8                	jne    f01034da <env_init+0xf>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01034f2:	55                   	push   %ebp
f01034f3:	89 e5                	mov    %esp,%ebp
		envs[i].env_id = 0;
		envs[i].env_link = &envs[i+1];
		envs[i].env_status = ENV_FREE;
	}

	envs[NENV-1].env_id = 0;
f01034f5:	a1 48 a2 21 f0       	mov    0xf021a248,%eax
f01034fa:	c7 80 cc ef 01 00 00 	movl   $0x0,0x1efcc(%eax)
f0103501:	00 00 00 
	envs[NENV-1].env_link = NULL;
f0103504:	c7 80 c8 ef 01 00 00 	movl   $0x0,0x1efc8(%eax)
f010350b:	00 00 00 
	envs[NENV-1].env_status = ENV_FREE;
f010350e:	c7 80 d8 ef 01 00 00 	movl   $0x0,0x1efd8(%eax)
f0103515:	00 00 00 

	env_free_list = envs;
f0103518:	a3 4c a2 21 f0       	mov    %eax,0xf021a24c

	// Per-CPU part of the initialization
	env_init_percpu();
f010351d:	e8 79 ff ff ff       	call   f010349b <env_init_percpu>
}
f0103522:	5d                   	pop    %ebp
f0103523:	c3                   	ret    

f0103524 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103524:	55                   	push   %ebp
f0103525:	89 e5                	mov    %esp,%ebp
f0103527:	56                   	push   %esi
f0103528:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103529:	8b 1d 4c a2 21 f0    	mov    0xf021a24c,%ebx
f010352f:	85 db                	test   %ebx,%ebx
f0103531:	0f 84 38 01 00 00    	je     f010366f <env_alloc+0x14b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103537:	83 ec 0c             	sub    $0xc,%esp
f010353a:	6a 01                	push   $0x1
f010353c:	e8 15 df ff ff       	call   f0101456 <page_alloc>
f0103541:	83 c4 10             	add    $0x10,%esp
f0103544:	85 c0                	test   %eax,%eax
f0103546:	0f 84 2a 01 00 00    	je     f0103676 <env_alloc+0x152>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010354c:	89 c2                	mov    %eax,%edx
f010354e:	2b 15 90 ae 21 f0    	sub    0xf021ae90,%edx
f0103554:	c1 fa 03             	sar    $0x3,%edx
f0103557:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010355a:	89 d1                	mov    %edx,%ecx
f010355c:	c1 e9 0c             	shr    $0xc,%ecx
f010355f:	3b 0d 88 ae 21 f0    	cmp    0xf021ae88,%ecx
f0103565:	72 12                	jb     f0103579 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103567:	52                   	push   %edx
f0103568:	68 44 6a 10 f0       	push   $0xf0106a44
f010356d:	6a 58                	push   $0x58
f010356f:	68 fd 7a 10 f0       	push   $0xf0107afd
f0103574:	e8 c7 ca ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f0103579:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010357f:	89 53 60             	mov    %edx,0x60(%ebx)
f0103582:	ba ec 0e 00 00       	mov    $0xeec,%edx

	for(uint32_t i = PDX(UTOP); i < NPDENTRIES; ++i) {
		e->env_pgdir[i] = kern_pgdir[i];
f0103587:	8b 0d 8c ae 21 f0    	mov    0xf021ae8c,%ecx
f010358d:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f0103590:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103593:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f0103596:	83 c2 04             	add    $0x4,%edx
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);

	for(uint32_t i = PDX(UTOP); i < NPDENTRIES; ++i) {
f0103599:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f010359f:	75 e6                	jne    f0103587 <env_alloc+0x63>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	p->pp_ref += 1;
f01035a1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01035a6:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035ae:	77 15                	ja     f01035c5 <env_alloc+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035b0:	50                   	push   %eax
f01035b1:	68 68 6a 10 f0       	push   $0xf0106a68
f01035b6:	68 d6 00 00 00       	push   $0xd6
f01035bb:	68 49 7e 10 f0       	push   $0xf0107e49
f01035c0:	e8 7b ca ff ff       	call   f0100040 <_panic>
f01035c5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01035cb:	83 ca 05             	or     $0x5,%edx
f01035ce:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01035d4:	8b 43 48             	mov    0x48(%ebx),%eax
f01035d7:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01035dc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01035e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01035e6:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01035e9:	89 da                	mov    %ebx,%edx
f01035eb:	2b 15 48 a2 21 f0    	sub    0xf021a248,%edx
f01035f1:	c1 fa 02             	sar    $0x2,%edx
f01035f4:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01035fa:	09 d0                	or     %edx,%eax
f01035fc:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.s
	e->env_parent_id = parent_id;
f01035ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103602:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103605:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010360c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103613:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010361a:	83 ec 04             	sub    $0x4,%esp
f010361d:	6a 44                	push   $0x44
f010361f:	6a 00                	push   $0x0
f0103621:	53                   	push   %ebx
f0103622:	e8 d2 26 00 00       	call   f0105cf9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103627:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010362d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103633:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103639:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103640:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags = FL_IF; 
f0103646:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)

	#ifdef CHALLENGE
	e->env_exception_upcall = 0;
	#else
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010364d:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	#endif

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103654:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103658:	8b 43 44             	mov    0x44(%ebx),%eax
f010365b:	a3 4c a2 21 f0       	mov    %eax,0xf021a24c
	*newenv_store = e;
f0103660:	8b 45 08             	mov    0x8(%ebp),%eax
f0103663:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103665:	83 c4 10             	add    $0x10,%esp
f0103668:	b8 00 00 00 00       	mov    $0x0,%eax
f010366d:	eb 0c                	jmp    f010367b <env_alloc+0x157>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010366f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103674:	eb 05                	jmp    f010367b <env_alloc+0x157>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103676:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010367b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010367e:	5b                   	pop    %ebx
f010367f:	5e                   	pop    %esi
f0103680:	5d                   	pop    %ebp
f0103681:	c3                   	ret    

f0103682 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103682:	55                   	push   %ebp
f0103683:	89 e5                	mov    %esp,%ebp
f0103685:	57                   	push   %edi
f0103686:	56                   	push   %esi
f0103687:	53                   	push   %ebx
f0103688:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *e = NULL;
f010368b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	// create a new environment successfully
	if(env_alloc(&e, 0) == 0) {
f0103692:	6a 00                	push   $0x0
f0103694:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103697:	50                   	push   %eax
f0103698:	e8 87 fe ff ff       	call   f0103524 <env_alloc>
f010369d:	83 c4 10             	add    $0x10,%esp
f01036a0:	85 c0                	test   %eax,%eax
f01036a2:	0f 85 dc 00 00 00    	jne    f0103784 <env_create+0x102>
		e->env_type = type;
f01036a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01036ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ae:	89 47 50             	mov    %eax,0x50(%edi)

	// LAB 3: Your code here.
	struct Elf *elf_header = (struct Elf *)binary;

	// is this a valid ELF?
	if(elf_header->e_magic != ELF_MAGIC) {
f01036b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b4:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01036ba:	74 17                	je     f01036d3 <env_create+0x51>
		panic("not a valid ELF");
f01036bc:	83 ec 04             	sub    $0x4,%esp
f01036bf:	68 54 7e 10 f0       	push   $0xf0107e54
f01036c4:	68 83 01 00 00       	push   $0x183
f01036c9:	68 49 7e 10 f0       	push   $0xf0107e49
f01036ce:	e8 6d c9 ff ff       	call   f0100040 <_panic>

	// the begin and end of program header in the elf file
	struct Proghdr *ph, *eph;

	// load each program segment
	ph = (struct Proghdr *)(binary + elf_header->e_phoff);
f01036d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d6:	89 c3                	mov    %eax,%ebx
f01036d8:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + elf_header->e_phnum;
f01036db:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01036df:	c1 e6 05             	shl    $0x5,%esi
f01036e2:	01 de                	add    %ebx,%esi

	// switch to its address space
	lcr3(PADDR(e->env_pgdir));
f01036e4:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036ec:	77 15                	ja     f0103703 <env_create+0x81>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ee:	50                   	push   %eax
f01036ef:	68 68 6a 10 f0       	push   $0xf0106a68
f01036f4:	68 8e 01 00 00       	push   $0x18e
f01036f9:	68 49 7e 10 f0       	push   $0xf0107e49
f01036fe:	e8 3d c9 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103703:	05 00 00 00 10       	add    $0x10000000,%eax
f0103708:	0f 22 d8             	mov    %eax,%cr3
f010370b:	eb 59                	jmp    f0103766 <env_create+0xe4>

	for(; ph < eph; ++ph) {
		// only load segments with ph->p_type == ELF_PROG_LOAD
		if(ph->p_type != ELF_PROG_LOAD)
f010370d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103710:	75 51                	jne    f0103763 <env_create+0xe1>
			continue;

		if(ph->p_memsz < ph->p_filesz) {
f0103712:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103715:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f0103718:	73 17                	jae    f0103731 <env_create+0xaf>
			panic("memsize is smaller than filesize");
f010371a:	83 ec 04             	sub    $0x4,%esp
f010371d:	68 70 7e 10 f0       	push   $0xf0107e70
f0103722:	68 96 01 00 00       	push   $0x196
f0103727:	68 49 7e 10 f0       	push   $0xf0107e49
f010372c:	e8 0f c9 ff ff       	call   f0100040 <_panic>
		}

		// map the virtual address
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103731:	8b 53 08             	mov    0x8(%ebx),%edx
f0103734:	89 f8                	mov    %edi,%eax
f0103736:	e8 58 fc ff ff       	call   f0103393 <region_alloc>
		
		// initial the physical memory 
		memset((void *)ph->p_va, 0, ph->p_memsz);
f010373b:	83 ec 04             	sub    $0x4,%esp
f010373e:	ff 73 14             	pushl  0x14(%ebx)
f0103741:	6a 00                	push   $0x0
f0103743:	ff 73 08             	pushl  0x8(%ebx)
f0103746:	e8 ae 25 00 00       	call   f0105cf9 <memset>

		// copy the elf file into va
		memcpy((void *)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
f010374b:	83 c4 0c             	add    $0xc,%esp
f010374e:	ff 73 10             	pushl  0x10(%ebx)
f0103751:	8b 45 08             	mov    0x8(%ebp),%eax
f0103754:	03 43 04             	add    0x4(%ebx),%eax
f0103757:	50                   	push   %eax
f0103758:	ff 73 08             	pushl  0x8(%ebx)
f010375b:	e8 4e 26 00 00       	call   f0105dae <memcpy>
f0103760:	83 c4 10             	add    $0x10,%esp
	eph = ph + elf_header->e_phnum;

	// switch to its address space
	lcr3(PADDR(e->env_pgdir));

	for(; ph < eph; ++ph) {
f0103763:	83 c3 20             	add    $0x20,%ebx
f0103766:	39 de                	cmp    %ebx,%esi
f0103768:	77 a3                	ja     f010370d <env_create+0x8b>
		memset((void *)ph->p_va, 0, ph->p_memsz);

		// copy the elf file into va
		memcpy((void *)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
	}
	e->env_tf.tf_eip = (uintptr_t)elf_header->e_entry;
f010376a:	8b 45 08             	mov    0x8(%ebp),%eax
f010376d:	8b 40 18             	mov    0x18(%eax),%eax
f0103770:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f0103773:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103778:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010377d:	89 f8                	mov    %edi,%eax
f010377f:	e8 0f fc ff ff       	call   f0103393 <region_alloc>
		load_icode(e, binary);
	}

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if(type == ENV_TYPE_FS)
f0103784:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103788:	75 0a                	jne    f0103794 <env_create+0x112>
		e->env_tf.tf_eflags = e->env_tf.tf_eflags | FL_IOPL_MASK;
f010378a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010378d:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)

}
f0103794:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103797:	5b                   	pop    %ebx
f0103798:	5e                   	pop    %esi
f0103799:	5f                   	pop    %edi
f010379a:	5d                   	pop    %ebp
f010379b:	c3                   	ret    

f010379c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010379c:	55                   	push   %ebp
f010379d:	89 e5                	mov    %esp,%ebp
f010379f:	57                   	push   %edi
f01037a0:	56                   	push   %esi
f01037a1:	53                   	push   %ebx
f01037a2:	83 ec 1c             	sub    $0x1c,%esp
f01037a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037a8:	e8 e5 2b 00 00       	call   f0106392 <cpunum>
f01037ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01037b7:	39 b8 28 b0 21 f0    	cmp    %edi,-0xfde4fd8(%eax)
f01037bd:	75 30                	jne    f01037ef <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01037bf:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037c9:	77 15                	ja     f01037e0 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037cb:	50                   	push   %eax
f01037cc:	68 68 6a 10 f0       	push   $0xf0106a68
f01037d1:	68 d5 01 00 00       	push   $0x1d5
f01037d6:	68 49 7e 10 f0       	push   $0xf0107e49
f01037db:	e8 60 c8 ff ff       	call   f0100040 <_panic>
f01037e0:	05 00 00 00 10       	add    $0x10000000,%eax
f01037e5:	0f 22 d8             	mov    %eax,%cr3
f01037e8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01037ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01037f2:	89 d0                	mov    %edx,%eax
f01037f4:	c1 e0 02             	shl    $0x2,%eax
f01037f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01037fa:	8b 47 60             	mov    0x60(%edi),%eax
f01037fd:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103800:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103806:	0f 84 a8 00 00 00    	je     f01038b4 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010380c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103812:	89 f0                	mov    %esi,%eax
f0103814:	c1 e8 0c             	shr    $0xc,%eax
f0103817:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010381a:	39 05 88 ae 21 f0    	cmp    %eax,0xf021ae88
f0103820:	77 15                	ja     f0103837 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103822:	56                   	push   %esi
f0103823:	68 44 6a 10 f0       	push   $0xf0106a44
f0103828:	68 e4 01 00 00       	push   $0x1e4
f010382d:	68 49 7e 10 f0       	push   $0xf0107e49
f0103832:	e8 09 c8 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103837:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010383a:	c1 e0 16             	shl    $0x16,%eax
f010383d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103840:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103845:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010384c:	01 
f010384d:	74 17                	je     f0103866 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010384f:	83 ec 08             	sub    $0x8,%esp
f0103852:	89 d8                	mov    %ebx,%eax
f0103854:	c1 e0 0c             	shl    $0xc,%eax
f0103857:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010385a:	50                   	push   %eax
f010385b:	ff 77 60             	pushl  0x60(%edi)
f010385e:	e8 ab de ff ff       	call   f010170e <page_remove>
f0103863:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103866:	83 c3 01             	add    $0x1,%ebx
f0103869:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010386f:	75 d4                	jne    f0103845 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103871:	8b 47 60             	mov    0x60(%edi),%eax
f0103874:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103877:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010387e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103881:	3b 05 88 ae 21 f0    	cmp    0xf021ae88,%eax
f0103887:	72 14                	jb     f010389d <env_free+0x101>
		panic("pa2page called with invalid pa");
f0103889:	83 ec 04             	sub    $0x4,%esp
f010388c:	68 90 72 10 f0       	push   $0xf0107290
f0103891:	6a 51                	push   $0x51
f0103893:	68 fd 7a 10 f0       	push   $0xf0107afd
f0103898:	e8 a3 c7 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010389d:	83 ec 0c             	sub    $0xc,%esp
f01038a0:	a1 90 ae 21 f0       	mov    0xf021ae90,%eax
f01038a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038a8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01038ab:	50                   	push   %eax
f01038ac:	e8 72 dc ff ff       	call   f0101523 <page_decref>
f01038b1:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038b4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01038b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038bb:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01038c0:	0f 85 29 ff ff ff    	jne    f01037ef <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01038c6:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038ce:	77 15                	ja     f01038e5 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038d0:	50                   	push   %eax
f01038d1:	68 68 6a 10 f0       	push   $0xf0106a68
f01038d6:	68 f2 01 00 00       	push   $0x1f2
f01038db:	68 49 7e 10 f0       	push   $0xf0107e49
f01038e0:	e8 5b c7 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01038e5:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038ec:	05 00 00 00 10       	add    $0x10000000,%eax
f01038f1:	c1 e8 0c             	shr    $0xc,%eax
f01038f4:	3b 05 88 ae 21 f0    	cmp    0xf021ae88,%eax
f01038fa:	72 14                	jb     f0103910 <env_free+0x174>
		panic("pa2page called with invalid pa");
f01038fc:	83 ec 04             	sub    $0x4,%esp
f01038ff:	68 90 72 10 f0       	push   $0xf0107290
f0103904:	6a 51                	push   $0x51
f0103906:	68 fd 7a 10 f0       	push   $0xf0107afd
f010390b:	e8 30 c7 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103910:	83 ec 0c             	sub    $0xc,%esp
f0103913:	8b 15 90 ae 21 f0    	mov    0xf021ae90,%edx
f0103919:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010391c:	50                   	push   %eax
f010391d:	e8 01 dc ff ff       	call   f0101523 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103922:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103929:	a1 4c a2 21 f0       	mov    0xf021a24c,%eax
f010392e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103931:	89 3d 4c a2 21 f0    	mov    %edi,0xf021a24c
}
f0103937:	83 c4 10             	add    $0x10,%esp
f010393a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010393d:	5b                   	pop    %ebx
f010393e:	5e                   	pop    %esi
f010393f:	5f                   	pop    %edi
f0103940:	5d                   	pop    %ebp
f0103941:	c3                   	ret    

f0103942 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103942:	55                   	push   %ebp
f0103943:	89 e5                	mov    %esp,%ebp
f0103945:	53                   	push   %ebx
f0103946:	83 ec 04             	sub    $0x4,%esp
f0103949:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010394c:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103950:	75 19                	jne    f010396b <env_destroy+0x29>
f0103952:	e8 3b 2a 00 00       	call   f0106392 <cpunum>
f0103957:	6b c0 74             	imul   $0x74,%eax,%eax
f010395a:	3b 98 28 b0 21 f0    	cmp    -0xfde4fd8(%eax),%ebx
f0103960:	74 09                	je     f010396b <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103962:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103969:	eb 33                	jmp    f010399e <env_destroy+0x5c>
	}

	env_free(e);
f010396b:	83 ec 0c             	sub    $0xc,%esp
f010396e:	53                   	push   %ebx
f010396f:	e8 28 fe ff ff       	call   f010379c <env_free>

	if (curenv == e) {
f0103974:	e8 19 2a 00 00       	call   f0106392 <cpunum>
f0103979:	6b c0 74             	imul   $0x74,%eax,%eax
f010397c:	83 c4 10             	add    $0x10,%esp
f010397f:	3b 98 28 b0 21 f0    	cmp    -0xfde4fd8(%eax),%ebx
f0103985:	75 17                	jne    f010399e <env_destroy+0x5c>
		curenv = NULL;
f0103987:	e8 06 2a 00 00       	call   f0106392 <cpunum>
f010398c:	6b c0 74             	imul   $0x74,%eax,%eax
f010398f:	c7 80 28 b0 21 f0 00 	movl   $0x0,-0xfde4fd8(%eax)
f0103996:	00 00 00 
		sched_yield();
f0103999:	e8 59 10 00 00       	call   f01049f7 <sched_yield>
	}
}
f010399e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039a1:	c9                   	leave  
f01039a2:	c3                   	ret    

f01039a3 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039a3:	55                   	push   %ebp
f01039a4:	89 e5                	mov    %esp,%ebp
f01039a6:	53                   	push   %ebx
f01039a7:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01039aa:	e8 e3 29 00 00       	call   f0106392 <cpunum>
f01039af:	6b c0 74             	imul   $0x74,%eax,%eax
f01039b2:	8b 98 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%ebx
f01039b8:	e8 d5 29 00 00       	call   f0106392 <cpunum>
f01039bd:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01039c0:	8b 65 08             	mov    0x8(%ebp),%esp
f01039c3:	61                   	popa   
f01039c4:	07                   	pop    %es
f01039c5:	1f                   	pop    %ds
f01039c6:	83 c4 08             	add    $0x8,%esp
f01039c9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01039ca:	83 ec 04             	sub    $0x4,%esp
f01039cd:	68 64 7e 10 f0       	push   $0xf0107e64
f01039d2:	68 29 02 00 00       	push   $0x229
f01039d7:	68 49 7e 10 f0       	push   $0xf0107e49
f01039dc:	e8 5f c6 ff ff       	call   f0100040 <_panic>

f01039e1 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01039e1:	55                   	push   %ebp
f01039e2:	89 e5                	mov    %esp,%ebp
f01039e4:	83 ec 08             	sub    $0x8,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// if this is a context switch
	if(curenv != NULL) {
f01039e7:	e8 a6 29 00 00       	call   f0106392 <cpunum>
f01039ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01039ef:	83 b8 28 b0 21 f0 00 	cmpl   $0x0,-0xfde4fd8(%eax)
f01039f6:	74 63                	je     f0103a5b <env_run+0x7a>
		if(curenv->env_status == ENV_RUNNING)
f01039f8:	e8 95 29 00 00       	call   f0106392 <cpunum>
f01039fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a00:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103a06:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a0a:	75 15                	jne    f0103a21 <env_run+0x40>
			curenv->env_status = ENV_RUNNABLE;
f0103a0c:	e8 81 29 00 00       	call   f0106392 <cpunum>
f0103a11:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a14:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103a1a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0103a21:	e8 6c 29 00 00       	call   f0106392 <cpunum>
f0103a26:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a29:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a2c:	89 90 28 b0 21 f0    	mov    %edx,-0xfde4fd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103a32:	e8 5b 29 00 00       	call   f0106392 <cpunum>
f0103a37:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a3a:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103a40:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs += 1;
f0103a47:	e8 46 29 00 00       	call   f0106392 <cpunum>
f0103a4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a4f:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103a55:	83 40 58 01          	addl   $0x1,0x58(%eax)
f0103a59:	eb 38                	jmp    f0103a93 <env_run+0xb2>
	}
	// if this is the first call 
	else {
		curenv = e;
f0103a5b:	e8 32 29 00 00       	call   f0106392 <cpunum>
f0103a60:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a66:	89 88 28 b0 21 f0    	mov    %ecx,-0xfde4fd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103a6c:	e8 21 29 00 00       	call   f0106392 <cpunum>
f0103a71:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a74:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103a7a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs += 1;
f0103a81:	e8 0c 29 00 00       	call   f0106392 <cpunum>
f0103a86:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a89:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103a8f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	}

	lcr3(PADDR(curenv->env_pgdir));
f0103a93:	e8 fa 28 00 00       	call   f0106392 <cpunum>
f0103a98:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a9b:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0103aa1:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103aa4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103aa9:	77 15                	ja     f0103ac0 <env_run+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103aab:	50                   	push   %eax
f0103aac:	68 68 6a 10 f0       	push   $0xf0106a68
f0103ab1:	68 56 02 00 00       	push   $0x256
f0103ab6:	68 49 7e 10 f0       	push   $0xf0107e49
f0103abb:	e8 80 c5 ff ff       	call   f0100040 <_panic>
f0103ac0:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ac5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ac8:	83 ec 0c             	sub    $0xc,%esp
f0103acb:	68 c0 13 12 f0       	push   $0xf01213c0
f0103ad0:	e8 c8 2b 00 00       	call   f010669d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103ad5:	f3 90                	pause  

	unlock_kernel();
	// restore the environment's registers
	env_pop_tf(&curenv->env_tf);
f0103ad7:	e8 b6 28 00 00       	call   f0106392 <cpunum>
f0103adc:	83 c4 04             	add    $0x4,%esp
f0103adf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae2:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0103ae8:	e8 b6 fe ff ff       	call   f01039a3 <env_pop_tf>

f0103aed <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103aed:	55                   	push   %ebp
f0103aee:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103af0:	ba 70 00 00 00       	mov    $0x70,%edx
f0103af5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103af8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103af9:	ba 71 00 00 00       	mov    $0x71,%edx
f0103afe:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103aff:	0f b6 c0             	movzbl %al,%eax
}
f0103b02:	5d                   	pop    %ebp
f0103b03:	c3                   	ret    

f0103b04 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b04:	55                   	push   %ebp
f0103b05:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b07:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0f:	ee                   	out    %al,(%dx)
f0103b10:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b15:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b18:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b19:	5d                   	pop    %ebp
f0103b1a:	c3                   	ret    

f0103b1b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103b1b:	55                   	push   %ebp
f0103b1c:	89 e5                	mov    %esp,%ebp
f0103b1e:	56                   	push   %esi
f0103b1f:	53                   	push   %ebx
f0103b20:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103b23:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103b29:	80 3d 50 a2 21 f0 00 	cmpb   $0x0,0xf021a250
f0103b30:	74 5a                	je     f0103b8c <irq_setmask_8259A+0x71>
f0103b32:	89 c6                	mov    %eax,%esi
f0103b34:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b39:	ee                   	out    %al,(%dx)
f0103b3a:	66 c1 e8 08          	shr    $0x8,%ax
f0103b3e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103b43:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103b44:	83 ec 0c             	sub    $0xc,%esp
f0103b47:	68 91 7e 10 f0       	push   $0xf0107e91
f0103b4c:	e8 24 01 00 00       	call   f0103c75 <cprintf>
f0103b51:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103b54:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103b59:	0f b7 f6             	movzwl %si,%esi
f0103b5c:	f7 d6                	not    %esi
f0103b5e:	0f a3 de             	bt     %ebx,%esi
f0103b61:	73 11                	jae    f0103b74 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103b63:	83 ec 08             	sub    $0x8,%esp
f0103b66:	53                   	push   %ebx
f0103b67:	68 0b 83 10 f0       	push   $0xf010830b
f0103b6c:	e8 04 01 00 00       	call   f0103c75 <cprintf>
f0103b71:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103b74:	83 c3 01             	add    $0x1,%ebx
f0103b77:	83 fb 10             	cmp    $0x10,%ebx
f0103b7a:	75 e2                	jne    f0103b5e <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103b7c:	83 ec 0c             	sub    $0xc,%esp
f0103b7f:	68 ff 7d 10 f0       	push   $0xf0107dff
f0103b84:	e8 ec 00 00 00       	call   f0103c75 <cprintf>
f0103b89:	83 c4 10             	add    $0x10,%esp
}
f0103b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103b8f:	5b                   	pop    %ebx
f0103b90:	5e                   	pop    %esi
f0103b91:	5d                   	pop    %ebp
f0103b92:	c3                   	ret    

f0103b93 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103b93:	c6 05 50 a2 21 f0 01 	movb   $0x1,0xf021a250
f0103b9a:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ba4:	ee                   	out    %al,(%dx)
f0103ba5:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103baa:	ee                   	out    %al,(%dx)
f0103bab:	ba 20 00 00 00       	mov    $0x20,%edx
f0103bb0:	b8 11 00 00 00       	mov    $0x11,%eax
f0103bb5:	ee                   	out    %al,(%dx)
f0103bb6:	ba 21 00 00 00       	mov    $0x21,%edx
f0103bbb:	b8 20 00 00 00       	mov    $0x20,%eax
f0103bc0:	ee                   	out    %al,(%dx)
f0103bc1:	b8 04 00 00 00       	mov    $0x4,%eax
f0103bc6:	ee                   	out    %al,(%dx)
f0103bc7:	b8 03 00 00 00       	mov    $0x3,%eax
f0103bcc:	ee                   	out    %al,(%dx)
f0103bcd:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103bd2:	b8 11 00 00 00       	mov    $0x11,%eax
f0103bd7:	ee                   	out    %al,(%dx)
f0103bd8:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103bdd:	b8 28 00 00 00       	mov    $0x28,%eax
f0103be2:	ee                   	out    %al,(%dx)
f0103be3:	b8 02 00 00 00       	mov    $0x2,%eax
f0103be8:	ee                   	out    %al,(%dx)
f0103be9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103bee:	ee                   	out    %al,(%dx)
f0103bef:	ba 20 00 00 00       	mov    $0x20,%edx
f0103bf4:	b8 68 00 00 00       	mov    $0x68,%eax
f0103bf9:	ee                   	out    %al,(%dx)
f0103bfa:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103bff:	ee                   	out    %al,(%dx)
f0103c00:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103c05:	b8 68 00 00 00       	mov    $0x68,%eax
f0103c0a:	ee                   	out    %al,(%dx)
f0103c0b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103c10:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103c11:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103c18:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103c1c:	74 13                	je     f0103c31 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103c1e:	55                   	push   %ebp
f0103c1f:	89 e5                	mov    %esp,%ebp
f0103c21:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103c24:	0f b7 c0             	movzwl %ax,%eax
f0103c27:	50                   	push   %eax
f0103c28:	e8 ee fe ff ff       	call   f0103b1b <irq_setmask_8259A>
f0103c2d:	83 c4 10             	add    $0x10,%esp
}
f0103c30:	c9                   	leave  
f0103c31:	f3 c3                	repz ret 

f0103c33 <putch>:
/* my code here */
extern int color;

static void
putch(int ch, int *cnt)
{
f0103c33:	55                   	push   %ebp
f0103c34:	89 e5                	mov    %esp,%ebp
f0103c36:	83 ec 14             	sub    $0x14,%esp
	ch = ch | (color << 8);
	cputchar(ch);
f0103c39:	a1 64 aa 21 f0       	mov    0xf021aa64,%eax
f0103c3e:	c1 e0 08             	shl    $0x8,%eax
f0103c41:	0b 45 08             	or     0x8(%ebp),%eax
f0103c44:	50                   	push   %eax
f0103c45:	e8 5c cb ff ff       	call   f01007a6 <cputchar>
	*cnt++;
}
f0103c4a:	83 c4 10             	add    $0x10,%esp
f0103c4d:	c9                   	leave  
f0103c4e:	c3                   	ret    

f0103c4f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103c4f:	55                   	push   %ebp
f0103c50:	89 e5                	mov    %esp,%ebp
f0103c52:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103c55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103c5c:	ff 75 0c             	pushl  0xc(%ebp)
f0103c5f:	ff 75 08             	pushl  0x8(%ebp)
f0103c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c65:	50                   	push   %eax
f0103c66:	68 33 3c 10 f0       	push   $0xf0103c33
f0103c6b:	e8 56 19 00 00       	call   f01055c6 <vprintfmt>
	return cnt;
}
f0103c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c73:	c9                   	leave  
f0103c74:	c3                   	ret    

f0103c75 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c75:	55                   	push   %ebp
f0103c76:	89 e5                	mov    %esp,%ebp
f0103c78:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103c7b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103c7e:	50                   	push   %eax
f0103c7f:	ff 75 08             	pushl  0x8(%ebp)
f0103c82:	e8 c8 ff ff ff       	call   f0103c4f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c87:	c9                   	leave  
f0103c88:	c3                   	ret    

f0103c89 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c89:	55                   	push   %ebp
f0103c8a:	89 e5                	mov    %esp,%ebp
f0103c8c:	57                   	push   %edi
f0103c8d:	56                   	push   %esi
f0103c8e:	53                   	push   %ebx
f0103c8f:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103c92:	e8 fb 26 00 00       	call   f0106392 <cpunum>
f0103c97:	89 c3                	mov    %eax,%ebx
f0103c99:	e8 f4 26 00 00       	call   f0106392 <cpunum>
f0103c9e:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103ca1:	c1 e0 10             	shl    $0x10,%eax
f0103ca4:	89 c2                	mov    %eax,%edx
f0103ca6:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103cab:	29 d0                	sub    %edx,%eax
f0103cad:	89 83 30 b0 21 f0    	mov    %eax,-0xfde4fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103cb3:	e8 da 26 00 00       	call   f0106392 <cpunum>
f0103cb8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbb:	66 c7 80 34 b0 21 f0 	movw   $0x10,-0xfde4fcc(%eax)
f0103cc2:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103cc4:	e8 c9 26 00 00       	call   f0106392 <cpunum>
f0103cc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ccc:	66 c7 80 92 b0 21 f0 	movw   $0x68,-0xfde4f6e(%eax)
f0103cd3:	68 00 

	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103cd5:	e8 b8 26 00 00       	call   f0106392 <cpunum>
f0103cda:	8d 58 05             	lea    0x5(%eax),%ebx
f0103cdd:	e8 b0 26 00 00       	call   f0106392 <cpunum>
f0103ce2:	89 c7                	mov    %eax,%edi
f0103ce4:	e8 a9 26 00 00       	call   f0106392 <cpunum>
f0103ce9:	89 c6                	mov    %eax,%esi
f0103ceb:	e8 a2 26 00 00       	call   f0106392 <cpunum>
f0103cf0:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f0103cf7:	f0 67 00 
f0103cfa:	6b ff 74             	imul   $0x74,%edi,%edi
f0103cfd:	81 c7 2c b0 21 f0    	add    $0xf021b02c,%edi
f0103d03:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0103d0a:	f0 
f0103d0b:	6b d6 74             	imul   $0x74,%esi,%edx
f0103d0e:	81 c2 2c b0 21 f0    	add    $0xf021b02c,%edx
f0103d14:	c1 ea 10             	shr    $0x10,%edx
f0103d17:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103d1e:	c6 04 dd 45 13 12 f0 	movb   $0x99,-0xfedecbb(,%ebx,8)
f0103d25:	99 
f0103d26:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103d2d:	40 
f0103d2e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d31:	05 2c b0 21 f0       	add    $0xf021b02c,%eax
f0103d36:	c1 e8 18             	shr    $0x18,%eax
f0103d39:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
									sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103d40:	e8 4d 26 00 00       	call   f0106392 <cpunum>
f0103d45:	80 24 c5 6d 13 12 f0 	andb   $0xef,-0xfedec93(,%eax,8)
f0103d4c:	ef 
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;*/

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103d4d:	e8 40 26 00 00       	call   f0106392 <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103d52:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103d59:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103d5c:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103d61:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103d64:	83 c4 0c             	add    $0xc,%esp
f0103d67:	5b                   	pop    %ebx
f0103d68:	5e                   	pop    %esi
f0103d69:	5f                   	pop    %edi
f0103d6a:	5d                   	pop    %ebp
f0103d6b:	c3                   	ret    

f0103d6c <trap_init>:
}


void
trap_init(void)
{
f0103d6c:	55                   	push   %ebp
f0103d6d:	89 e5                	mov    %esp,%ebp
f0103d6f:	83 ec 08             	sub    $0x8,%esp
	void handler36();
	void handler39();
	void handler46();
	void handler51();

	SETGATE(idt[T_DIVIDE], 0, GD_KT, handler0, 0);
f0103d72:	b8 86 48 10 f0       	mov    $0xf0104886,%eax
f0103d77:	66 a3 60 a2 21 f0    	mov    %ax,0xf021a260
f0103d7d:	66 c7 05 62 a2 21 f0 	movw   $0x8,0xf021a262
f0103d84:	08 00 
f0103d86:	c6 05 64 a2 21 f0 00 	movb   $0x0,0xf021a264
f0103d8d:	c6 05 65 a2 21 f0 8e 	movb   $0x8e,0xf021a265
f0103d94:	c1 e8 10             	shr    $0x10,%eax
f0103d97:	66 a3 66 a2 21 f0    	mov    %ax,0xf021a266
	SETGATE(idt[T_DEBUG], 0, GD_KT, handler1, 0);
f0103d9d:	b8 90 48 10 f0       	mov    $0xf0104890,%eax
f0103da2:	66 a3 68 a2 21 f0    	mov    %ax,0xf021a268
f0103da8:	66 c7 05 6a a2 21 f0 	movw   $0x8,0xf021a26a
f0103daf:	08 00 
f0103db1:	c6 05 6c a2 21 f0 00 	movb   $0x0,0xf021a26c
f0103db8:	c6 05 6d a2 21 f0 8e 	movb   $0x8e,0xf021a26d
f0103dbf:	c1 e8 10             	shr    $0x10,%eax
f0103dc2:	66 a3 6e a2 21 f0    	mov    %ax,0xf021a26e
	SETGATE(idt[T_NMI], 0, GD_KT, handler2, 0);
f0103dc8:	b8 96 48 10 f0       	mov    $0xf0104896,%eax
f0103dcd:	66 a3 70 a2 21 f0    	mov    %ax,0xf021a270
f0103dd3:	66 c7 05 72 a2 21 f0 	movw   $0x8,0xf021a272
f0103dda:	08 00 
f0103ddc:	c6 05 74 a2 21 f0 00 	movb   $0x0,0xf021a274
f0103de3:	c6 05 75 a2 21 f0 8e 	movb   $0x8e,0xf021a275
f0103dea:	c1 e8 10             	shr    $0x10,%eax
f0103ded:	66 a3 76 a2 21 f0    	mov    %ax,0xf021a276
	SETGATE(idt[T_BRKPT], 0, GD_KT, handler3, 3);
f0103df3:	b8 9c 48 10 f0       	mov    $0xf010489c,%eax
f0103df8:	66 a3 78 a2 21 f0    	mov    %ax,0xf021a278
f0103dfe:	66 c7 05 7a a2 21 f0 	movw   $0x8,0xf021a27a
f0103e05:	08 00 
f0103e07:	c6 05 7c a2 21 f0 00 	movb   $0x0,0xf021a27c
f0103e0e:	c6 05 7d a2 21 f0 ee 	movb   $0xee,0xf021a27d
f0103e15:	c1 e8 10             	shr    $0x10,%eax
f0103e18:	66 a3 7e a2 21 f0    	mov    %ax,0xf021a27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, handler4, 0);
f0103e1e:	b8 a2 48 10 f0       	mov    $0xf01048a2,%eax
f0103e23:	66 a3 80 a2 21 f0    	mov    %ax,0xf021a280
f0103e29:	66 c7 05 82 a2 21 f0 	movw   $0x8,0xf021a282
f0103e30:	08 00 
f0103e32:	c6 05 84 a2 21 f0 00 	movb   $0x0,0xf021a284
f0103e39:	c6 05 85 a2 21 f0 8e 	movb   $0x8e,0xf021a285
f0103e40:	c1 e8 10             	shr    $0x10,%eax
f0103e43:	66 a3 86 a2 21 f0    	mov    %ax,0xf021a286
	SETGATE(idt[T_BOUND], 0, GD_KT, handler5, 0);
f0103e49:	b8 a8 48 10 f0       	mov    $0xf01048a8,%eax
f0103e4e:	66 a3 88 a2 21 f0    	mov    %ax,0xf021a288
f0103e54:	66 c7 05 8a a2 21 f0 	movw   $0x8,0xf021a28a
f0103e5b:	08 00 
f0103e5d:	c6 05 8c a2 21 f0 00 	movb   $0x0,0xf021a28c
f0103e64:	c6 05 8d a2 21 f0 8e 	movb   $0x8e,0xf021a28d
f0103e6b:	c1 e8 10             	shr    $0x10,%eax
f0103e6e:	66 a3 8e a2 21 f0    	mov    %ax,0xf021a28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, handler6, 0);
f0103e74:	b8 ae 48 10 f0       	mov    $0xf01048ae,%eax
f0103e79:	66 a3 90 a2 21 f0    	mov    %ax,0xf021a290
f0103e7f:	66 c7 05 92 a2 21 f0 	movw   $0x8,0xf021a292
f0103e86:	08 00 
f0103e88:	c6 05 94 a2 21 f0 00 	movb   $0x0,0xf021a294
f0103e8f:	c6 05 95 a2 21 f0 8e 	movb   $0x8e,0xf021a295
f0103e96:	c1 e8 10             	shr    $0x10,%eax
f0103e99:	66 a3 96 a2 21 f0    	mov    %ax,0xf021a296
	SETGATE(idt[T_DEVICE], 0, GD_KT, handler7, 0);
f0103e9f:	b8 b4 48 10 f0       	mov    $0xf01048b4,%eax
f0103ea4:	66 a3 98 a2 21 f0    	mov    %ax,0xf021a298
f0103eaa:	66 c7 05 9a a2 21 f0 	movw   $0x8,0xf021a29a
f0103eb1:	08 00 
f0103eb3:	c6 05 9c a2 21 f0 00 	movb   $0x0,0xf021a29c
f0103eba:	c6 05 9d a2 21 f0 8e 	movb   $0x8e,0xf021a29d
f0103ec1:	c1 e8 10             	shr    $0x10,%eax
f0103ec4:	66 a3 9e a2 21 f0    	mov    %ax,0xf021a29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, handler8, 0);
f0103eca:	b8 ba 48 10 f0       	mov    $0xf01048ba,%eax
f0103ecf:	66 a3 a0 a2 21 f0    	mov    %ax,0xf021a2a0
f0103ed5:	66 c7 05 a2 a2 21 f0 	movw   $0x8,0xf021a2a2
f0103edc:	08 00 
f0103ede:	c6 05 a4 a2 21 f0 00 	movb   $0x0,0xf021a2a4
f0103ee5:	c6 05 a5 a2 21 f0 8e 	movb   $0x8e,0xf021a2a5
f0103eec:	c1 e8 10             	shr    $0x10,%eax
f0103eef:	66 a3 a6 a2 21 f0    	mov    %ax,0xf021a2a6
	SETGATE(idt[T_TSS], 0, GD_KT, handler10, 0);
f0103ef5:	b8 be 48 10 f0       	mov    $0xf01048be,%eax
f0103efa:	66 a3 b0 a2 21 f0    	mov    %ax,0xf021a2b0
f0103f00:	66 c7 05 b2 a2 21 f0 	movw   $0x8,0xf021a2b2
f0103f07:	08 00 
f0103f09:	c6 05 b4 a2 21 f0 00 	movb   $0x0,0xf021a2b4
f0103f10:	c6 05 b5 a2 21 f0 8e 	movb   $0x8e,0xf021a2b5
f0103f17:	c1 e8 10             	shr    $0x10,%eax
f0103f1a:	66 a3 b6 a2 21 f0    	mov    %ax,0xf021a2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, handler11, 0);
f0103f20:	b8 c2 48 10 f0       	mov    $0xf01048c2,%eax
f0103f25:	66 a3 b8 a2 21 f0    	mov    %ax,0xf021a2b8
f0103f2b:	66 c7 05 ba a2 21 f0 	movw   $0x8,0xf021a2ba
f0103f32:	08 00 
f0103f34:	c6 05 bc a2 21 f0 00 	movb   $0x0,0xf021a2bc
f0103f3b:	c6 05 bd a2 21 f0 8e 	movb   $0x8e,0xf021a2bd
f0103f42:	c1 e8 10             	shr    $0x10,%eax
f0103f45:	66 a3 be a2 21 f0    	mov    %ax,0xf021a2be
	SETGATE(idt[T_STACK], 0, GD_KT, handler12, 0);
f0103f4b:	b8 c6 48 10 f0       	mov    $0xf01048c6,%eax
f0103f50:	66 a3 c0 a2 21 f0    	mov    %ax,0xf021a2c0
f0103f56:	66 c7 05 c2 a2 21 f0 	movw   $0x8,0xf021a2c2
f0103f5d:	08 00 
f0103f5f:	c6 05 c4 a2 21 f0 00 	movb   $0x0,0xf021a2c4
f0103f66:	c6 05 c5 a2 21 f0 8e 	movb   $0x8e,0xf021a2c5
f0103f6d:	c1 e8 10             	shr    $0x10,%eax
f0103f70:	66 a3 c6 a2 21 f0    	mov    %ax,0xf021a2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, handler13, 0);
f0103f76:	b8 ca 48 10 f0       	mov    $0xf01048ca,%eax
f0103f7b:	66 a3 c8 a2 21 f0    	mov    %ax,0xf021a2c8
f0103f81:	66 c7 05 ca a2 21 f0 	movw   $0x8,0xf021a2ca
f0103f88:	08 00 
f0103f8a:	c6 05 cc a2 21 f0 00 	movb   $0x0,0xf021a2cc
f0103f91:	c6 05 cd a2 21 f0 8e 	movb   $0x8e,0xf021a2cd
f0103f98:	c1 e8 10             	shr    $0x10,%eax
f0103f9b:	66 a3 ce a2 21 f0    	mov    %ax,0xf021a2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, handler14, 0);
f0103fa1:	b8 ce 48 10 f0       	mov    $0xf01048ce,%eax
f0103fa6:	66 a3 d0 a2 21 f0    	mov    %ax,0xf021a2d0
f0103fac:	66 c7 05 d2 a2 21 f0 	movw   $0x8,0xf021a2d2
f0103fb3:	08 00 
f0103fb5:	c6 05 d4 a2 21 f0 00 	movb   $0x0,0xf021a2d4
f0103fbc:	c6 05 d5 a2 21 f0 8e 	movb   $0x8e,0xf021a2d5
f0103fc3:	c1 e8 10             	shr    $0x10,%eax
f0103fc6:	66 a3 d6 a2 21 f0    	mov    %ax,0xf021a2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, handler16, 0);
f0103fcc:	b8 d2 48 10 f0       	mov    $0xf01048d2,%eax
f0103fd1:	66 a3 e0 a2 21 f0    	mov    %ax,0xf021a2e0
f0103fd7:	66 c7 05 e2 a2 21 f0 	movw   $0x8,0xf021a2e2
f0103fde:	08 00 
f0103fe0:	c6 05 e4 a2 21 f0 00 	movb   $0x0,0xf021a2e4
f0103fe7:	c6 05 e5 a2 21 f0 8e 	movb   $0x8e,0xf021a2e5
f0103fee:	c1 e8 10             	shr    $0x10,%eax
f0103ff1:	66 a3 e6 a2 21 f0    	mov    %ax,0xf021a2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, handler17, 0);
f0103ff7:	b8 d8 48 10 f0       	mov    $0xf01048d8,%eax
f0103ffc:	66 a3 e8 a2 21 f0    	mov    %ax,0xf021a2e8
f0104002:	66 c7 05 ea a2 21 f0 	movw   $0x8,0xf021a2ea
f0104009:	08 00 
f010400b:	c6 05 ec a2 21 f0 00 	movb   $0x0,0xf021a2ec
f0104012:	c6 05 ed a2 21 f0 8e 	movb   $0x8e,0xf021a2ed
f0104019:	c1 e8 10             	shr    $0x10,%eax
f010401c:	66 a3 ee a2 21 f0    	mov    %ax,0xf021a2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, handler18, 0);
f0104022:	b8 dc 48 10 f0       	mov    $0xf01048dc,%eax
f0104027:	66 a3 f0 a2 21 f0    	mov    %ax,0xf021a2f0
f010402d:	66 c7 05 f2 a2 21 f0 	movw   $0x8,0xf021a2f2
f0104034:	08 00 
f0104036:	c6 05 f4 a2 21 f0 00 	movb   $0x0,0xf021a2f4
f010403d:	c6 05 f5 a2 21 f0 8e 	movb   $0x8e,0xf021a2f5
f0104044:	c1 e8 10             	shr    $0x10,%eax
f0104047:	66 a3 f6 a2 21 f0    	mov    %ax,0xf021a2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, handler19, 0);
f010404d:	b8 e2 48 10 f0       	mov    $0xf01048e2,%eax
f0104052:	66 a3 f8 a2 21 f0    	mov    %ax,0xf021a2f8
f0104058:	66 c7 05 fa a2 21 f0 	movw   $0x8,0xf021a2fa
f010405f:	08 00 
f0104061:	c6 05 fc a2 21 f0 00 	movb   $0x0,0xf021a2fc
f0104068:	c6 05 fd a2 21 f0 8e 	movb   $0x8e,0xf021a2fd
f010406f:	c1 e8 10             	shr    $0x10,%eax
f0104072:	66 a3 fe a2 21 f0    	mov    %ax,0xf021a2fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
f0104078:	b8 e8 48 10 f0       	mov    $0xf01048e8,%eax
f010407d:	66 a3 e0 a3 21 f0    	mov    %ax,0xf021a3e0
f0104083:	66 c7 05 e2 a3 21 f0 	movw   $0x8,0xf021a3e2
f010408a:	08 00 
f010408c:	c6 05 e4 a3 21 f0 00 	movb   $0x0,0xf021a3e4
f0104093:	c6 05 e5 a3 21 f0 ee 	movb   $0xee,0xf021a3e5
f010409a:	c1 e8 10             	shr    $0x10,%eax
f010409d:	66 a3 e6 a3 21 f0    	mov    %ax,0xf021a3e6

	SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 0, GD_KT, handler32, 0);
f01040a3:	b8 ee 48 10 f0       	mov    $0xf01048ee,%eax
f01040a8:	66 a3 60 a3 21 f0    	mov    %ax,0xf021a360
f01040ae:	66 c7 05 62 a3 21 f0 	movw   $0x8,0xf021a362
f01040b5:	08 00 
f01040b7:	c6 05 64 a3 21 f0 00 	movb   $0x0,0xf021a364
f01040be:	c6 05 65 a3 21 f0 8e 	movb   $0x8e,0xf021a365
f01040c5:	c1 e8 10             	shr    $0x10,%eax
f01040c8:	66 a3 66 a3 21 f0    	mov    %ax,0xf021a366
	SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 0, GD_KT, handler33, 0);
f01040ce:	b8 f4 48 10 f0       	mov    $0xf01048f4,%eax
f01040d3:	66 a3 68 a3 21 f0    	mov    %ax,0xf021a368
f01040d9:	66 c7 05 6a a3 21 f0 	movw   $0x8,0xf021a36a
f01040e0:	08 00 
f01040e2:	c6 05 6c a3 21 f0 00 	movb   $0x0,0xf021a36c
f01040e9:	c6 05 6d a3 21 f0 8e 	movb   $0x8e,0xf021a36d
f01040f0:	c1 e8 10             	shr    $0x10,%eax
f01040f3:	66 a3 6e a3 21 f0    	mov    %ax,0xf021a36e
	SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, handler36, 0);
f01040f9:	b8 fa 48 10 f0       	mov    $0xf01048fa,%eax
f01040fe:	66 a3 80 a3 21 f0    	mov    %ax,0xf021a380
f0104104:	66 c7 05 82 a3 21 f0 	movw   $0x8,0xf021a382
f010410b:	08 00 
f010410d:	c6 05 84 a3 21 f0 00 	movb   $0x0,0xf021a384
f0104114:	c6 05 85 a3 21 f0 8e 	movb   $0x8e,0xf021a385
f010411b:	c1 e8 10             	shr    $0x10,%eax
f010411e:	66 a3 86 a3 21 f0    	mov    %ax,0xf021a386
	SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS], 0, GD_KT, handler39, 0);
f0104124:	b8 00 49 10 f0       	mov    $0xf0104900,%eax
f0104129:	66 a3 98 a3 21 f0    	mov    %ax,0xf021a398
f010412f:	66 c7 05 9a a3 21 f0 	movw   $0x8,0xf021a39a
f0104136:	08 00 
f0104138:	c6 05 9c a3 21 f0 00 	movb   $0x0,0xf021a39c
f010413f:	c6 05 9d a3 21 f0 8e 	movb   $0x8e,0xf021a39d
f0104146:	c1 e8 10             	shr    $0x10,%eax
f0104149:	66 a3 9e a3 21 f0    	mov    %ax,0xf021a39e
	SETGATE(idt[IRQ_OFFSET+IRQ_IDE], 0, GD_KT, handler46, 0);
f010414f:	b8 06 49 10 f0       	mov    $0xf0104906,%eax
f0104154:	66 a3 d0 a3 21 f0    	mov    %ax,0xf021a3d0
f010415a:	66 c7 05 d2 a3 21 f0 	movw   $0x8,0xf021a3d2
f0104161:	08 00 
f0104163:	c6 05 d4 a3 21 f0 00 	movb   $0x0,0xf021a3d4
f010416a:	c6 05 d5 a3 21 f0 8e 	movb   $0x8e,0xf021a3d5
f0104171:	c1 e8 10             	shr    $0x10,%eax
f0104174:	66 a3 d6 a3 21 f0    	mov    %ax,0xf021a3d6
	SETGATE(idt[IRQ_OFFSET+IRQ_ERROR], 0, GD_KT, handler51, 0);
f010417a:	b8 0c 49 10 f0       	mov    $0xf010490c,%eax
f010417f:	66 a3 f8 a3 21 f0    	mov    %ax,0xf021a3f8
f0104185:	66 c7 05 fa a3 21 f0 	movw   $0x8,0xf021a3fa
f010418c:	08 00 
f010418e:	c6 05 fc a3 21 f0 00 	movb   $0x0,0xf021a3fc
f0104195:	c6 05 fd a3 21 f0 8e 	movb   $0x8e,0xf021a3fd
f010419c:	c1 e8 10             	shr    $0x10,%eax
f010419f:	66 a3 fe a3 21 f0    	mov    %ax,0xf021a3fe



	// Per-CPU setup 
	trap_init_percpu();
f01041a5:	e8 df fa ff ff       	call   f0103c89 <trap_init_percpu>
}
f01041aa:	c9                   	leave  
f01041ab:	c3                   	ret    

f01041ac <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01041ac:	55                   	push   %ebp
f01041ad:	89 e5                	mov    %esp,%ebp
f01041af:	53                   	push   %ebx
f01041b0:	83 ec 0c             	sub    $0xc,%esp
f01041b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01041b6:	ff 33                	pushl  (%ebx)
f01041b8:	68 a5 7e 10 f0       	push   $0xf0107ea5
f01041bd:	e8 b3 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01041c2:	83 c4 08             	add    $0x8,%esp
f01041c5:	ff 73 04             	pushl  0x4(%ebx)
f01041c8:	68 b4 7e 10 f0       	push   $0xf0107eb4
f01041cd:	e8 a3 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01041d2:	83 c4 08             	add    $0x8,%esp
f01041d5:	ff 73 08             	pushl  0x8(%ebx)
f01041d8:	68 c3 7e 10 f0       	push   $0xf0107ec3
f01041dd:	e8 93 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01041e2:	83 c4 08             	add    $0x8,%esp
f01041e5:	ff 73 0c             	pushl  0xc(%ebx)
f01041e8:	68 d2 7e 10 f0       	push   $0xf0107ed2
f01041ed:	e8 83 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01041f2:	83 c4 08             	add    $0x8,%esp
f01041f5:	ff 73 10             	pushl  0x10(%ebx)
f01041f8:	68 e1 7e 10 f0       	push   $0xf0107ee1
f01041fd:	e8 73 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104202:	83 c4 08             	add    $0x8,%esp
f0104205:	ff 73 14             	pushl  0x14(%ebx)
f0104208:	68 f0 7e 10 f0       	push   $0xf0107ef0
f010420d:	e8 63 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104212:	83 c4 08             	add    $0x8,%esp
f0104215:	ff 73 18             	pushl  0x18(%ebx)
f0104218:	68 ff 7e 10 f0       	push   $0xf0107eff
f010421d:	e8 53 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104222:	83 c4 08             	add    $0x8,%esp
f0104225:	ff 73 1c             	pushl  0x1c(%ebx)
f0104228:	68 0e 7f 10 f0       	push   $0xf0107f0e
f010422d:	e8 43 fa ff ff       	call   f0103c75 <cprintf>
}
f0104232:	83 c4 10             	add    $0x10,%esp
f0104235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104238:	c9                   	leave  
f0104239:	c3                   	ret    

f010423a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010423a:	55                   	push   %ebp
f010423b:	89 e5                	mov    %esp,%ebp
f010423d:	56                   	push   %esi
f010423e:	53                   	push   %ebx
f010423f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104242:	e8 4b 21 00 00       	call   f0106392 <cpunum>
f0104247:	83 ec 04             	sub    $0x4,%esp
f010424a:	50                   	push   %eax
f010424b:	53                   	push   %ebx
f010424c:	68 72 7f 10 f0       	push   $0xf0107f72
f0104251:	e8 1f fa ff ff       	call   f0103c75 <cprintf>
	print_regs(&tf->tf_regs);
f0104256:	89 1c 24             	mov    %ebx,(%esp)
f0104259:	e8 4e ff ff ff       	call   f01041ac <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010425e:	83 c4 08             	add    $0x8,%esp
f0104261:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104265:	50                   	push   %eax
f0104266:	68 90 7f 10 f0       	push   $0xf0107f90
f010426b:	e8 05 fa ff ff       	call   f0103c75 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104270:	83 c4 08             	add    $0x8,%esp
f0104273:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104277:	50                   	push   %eax
f0104278:	68 a3 7f 10 f0       	push   $0xf0107fa3
f010427d:	e8 f3 f9 ff ff       	call   f0103c75 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104282:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0104285:	83 c4 10             	add    $0x10,%esp
f0104288:	83 f8 13             	cmp    $0x13,%eax
f010428b:	77 09                	ja     f0104296 <print_trapframe+0x5c>
		return excnames[trapno];
f010428d:	8b 14 85 20 82 10 f0 	mov    -0xfef7de0(,%eax,4),%edx
f0104294:	eb 1f                	jmp    f01042b5 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0104296:	83 f8 30             	cmp    $0x30,%eax
f0104299:	74 15                	je     f01042b0 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010429b:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f010429e:	83 fa 10             	cmp    $0x10,%edx
f01042a1:	b9 3c 7f 10 f0       	mov    $0xf0107f3c,%ecx
f01042a6:	ba 29 7f 10 f0       	mov    $0xf0107f29,%edx
f01042ab:	0f 43 d1             	cmovae %ecx,%edx
f01042ae:	eb 05                	jmp    f01042b5 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01042b0:	ba 1d 7f 10 f0       	mov    $0xf0107f1d,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042b5:	83 ec 04             	sub    $0x4,%esp
f01042b8:	52                   	push   %edx
f01042b9:	50                   	push   %eax
f01042ba:	68 b6 7f 10 f0       	push   $0xf0107fb6
f01042bf:	e8 b1 f9 ff ff       	call   f0103c75 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01042c4:	83 c4 10             	add    $0x10,%esp
f01042c7:	3b 1d 60 aa 21 f0    	cmp    0xf021aa60,%ebx
f01042cd:	75 1a                	jne    f01042e9 <print_trapframe+0xaf>
f01042cf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01042d3:	75 14                	jne    f01042e9 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01042d5:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01042d8:	83 ec 08             	sub    $0x8,%esp
f01042db:	50                   	push   %eax
f01042dc:	68 c8 7f 10 f0       	push   $0xf0107fc8
f01042e1:	e8 8f f9 ff ff       	call   f0103c75 <cprintf>
f01042e6:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01042e9:	83 ec 08             	sub    $0x8,%esp
f01042ec:	ff 73 2c             	pushl  0x2c(%ebx)
f01042ef:	68 d7 7f 10 f0       	push   $0xf0107fd7
f01042f4:	e8 7c f9 ff ff       	call   f0103c75 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01042f9:	83 c4 10             	add    $0x10,%esp
f01042fc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104300:	75 49                	jne    f010434b <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104302:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104305:	89 c2                	mov    %eax,%edx
f0104307:	83 e2 01             	and    $0x1,%edx
f010430a:	ba 56 7f 10 f0       	mov    $0xf0107f56,%edx
f010430f:	b9 4b 7f 10 f0       	mov    $0xf0107f4b,%ecx
f0104314:	0f 44 ca             	cmove  %edx,%ecx
f0104317:	89 c2                	mov    %eax,%edx
f0104319:	83 e2 02             	and    $0x2,%edx
f010431c:	ba 68 7f 10 f0       	mov    $0xf0107f68,%edx
f0104321:	be 62 7f 10 f0       	mov    $0xf0107f62,%esi
f0104326:	0f 45 d6             	cmovne %esi,%edx
f0104329:	83 e0 04             	and    $0x4,%eax
f010432c:	be 9d 80 10 f0       	mov    $0xf010809d,%esi
f0104331:	b8 6d 7f 10 f0       	mov    $0xf0107f6d,%eax
f0104336:	0f 44 c6             	cmove  %esi,%eax
f0104339:	51                   	push   %ecx
f010433a:	52                   	push   %edx
f010433b:	50                   	push   %eax
f010433c:	68 e5 7f 10 f0       	push   $0xf0107fe5
f0104341:	e8 2f f9 ff ff       	call   f0103c75 <cprintf>
f0104346:	83 c4 10             	add    $0x10,%esp
f0104349:	eb 10                	jmp    f010435b <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010434b:	83 ec 0c             	sub    $0xc,%esp
f010434e:	68 ff 7d 10 f0       	push   $0xf0107dff
f0104353:	e8 1d f9 ff ff       	call   f0103c75 <cprintf>
f0104358:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010435b:	83 ec 08             	sub    $0x8,%esp
f010435e:	ff 73 30             	pushl  0x30(%ebx)
f0104361:	68 f4 7f 10 f0       	push   $0xf0107ff4
f0104366:	e8 0a f9 ff ff       	call   f0103c75 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010436b:	83 c4 08             	add    $0x8,%esp
f010436e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104372:	50                   	push   %eax
f0104373:	68 03 80 10 f0       	push   $0xf0108003
f0104378:	e8 f8 f8 ff ff       	call   f0103c75 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010437d:	83 c4 08             	add    $0x8,%esp
f0104380:	ff 73 38             	pushl  0x38(%ebx)
f0104383:	68 16 80 10 f0       	push   $0xf0108016
f0104388:	e8 e8 f8 ff ff       	call   f0103c75 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010438d:	83 c4 10             	add    $0x10,%esp
f0104390:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104394:	74 25                	je     f01043bb <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104396:	83 ec 08             	sub    $0x8,%esp
f0104399:	ff 73 3c             	pushl  0x3c(%ebx)
f010439c:	68 25 80 10 f0       	push   $0xf0108025
f01043a1:	e8 cf f8 ff ff       	call   f0103c75 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01043a6:	83 c4 08             	add    $0x8,%esp
f01043a9:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01043ad:	50                   	push   %eax
f01043ae:	68 34 80 10 f0       	push   $0xf0108034
f01043b3:	e8 bd f8 ff ff       	call   f0103c75 <cprintf>
f01043b8:	83 c4 10             	add    $0x10,%esp
	}
}
f01043bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043be:	5b                   	pop    %ebx
f01043bf:	5e                   	pop    %esi
f01043c0:	5d                   	pop    %ebp
f01043c1:	c3                   	ret    

f01043c2 <page_fault_handler>:
	env_destroy(curenv);
}
#else
void
page_fault_handler(struct Trapframe *tf)
{
f01043c2:	55                   	push   %ebp
f01043c3:	89 e5                	mov    %esp,%ebp
f01043c5:	57                   	push   %edi
f01043c6:	56                   	push   %esi
f01043c7:	53                   	push   %ebx
f01043c8:	83 ec 1c             	sub    $0x1c,%esp
f01043cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01043ce:	0f 20 d0             	mov    %cr2,%eax
f01043d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0) {
f01043d4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01043d8:	75 17                	jne    f01043f1 <page_fault_handler+0x2f>
		// Trapped from kernel mode.
		panic("kernel-mode page faults");
f01043da:	83 ec 04             	sub    $0x4,%esp
f01043dd:	68 47 80 10 f0       	push   $0xf0108047
f01043e2:	68 95 01 00 00       	push   $0x195
f01043e7:	68 5f 80 10 f0       	push   $0xf010805f
f01043ec:	e8 4f bc ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// if there is no page fault upcall
	if(curenv->env_pgfault_upcall == NULL) {
f01043f1:	e8 9c 1f 00 00       	call   f0106392 <cpunum>
f01043f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f9:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f01043ff:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104403:	75 45                	jne    f010444a <page_fault_handler+0x88>
		//cprintf("000000\n");
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104405:	8b 73 30             	mov    0x30(%ebx),%esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104408:	e8 85 1f 00 00       	call   f0106392 <cpunum>
	// LAB 4: Your code here.
	// if there is no page fault upcall
	if(curenv->env_pgfault_upcall == NULL) {
		//cprintf("000000\n");
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010440d:	56                   	push   %esi
f010440e:	ff 75 e4             	pushl  -0x1c(%ebp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104411:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.
	// if there is no page fault upcall
	if(curenv->env_pgfault_upcall == NULL) {
		//cprintf("000000\n");
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104414:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f010441a:	ff 70 48             	pushl  0x48(%eax)
f010441d:	68 e8 81 10 f0       	push   $0xf01081e8
f0104422:	e8 4e f8 ff ff       	call   f0103c75 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0104427:	89 1c 24             	mov    %ebx,(%esp)
f010442a:	e8 0b fe ff ff       	call   f010423a <print_trapframe>
		env_destroy(curenv);
f010442f:	e8 5e 1f 00 00       	call   f0106392 <cpunum>
f0104434:	83 c4 04             	add    $0x4,%esp
f0104437:	6b c0 74             	imul   $0x74,%eax,%eax
f010443a:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104440:	e8 fd f4 ff ff       	call   f0103942 <env_destroy>
			tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
			//cprintf("44444\n");
			env_run(curenv);
		}
	}
}
f0104445:	e9 f5 01 00 00       	jmp    f010463f <page_fault_handler+0x27d>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	}
	else {
		lcr3(PADDR(curenv->env_pgdir));
f010444a:	e8 43 1f 00 00       	call   f0106392 <cpunum>
f010444f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104452:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104458:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010445b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104460:	77 15                	ja     f0104477 <page_fault_handler+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104462:	50                   	push   %eax
f0104463:	68 68 6a 10 f0       	push   $0xf0106a68
f0104468:	68 c3 01 00 00       	push   $0x1c3
f010446d:	68 5f 80 10 f0       	push   $0xf010805f
f0104472:	e8 c9 bb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104477:	05 00 00 00 10       	add    $0x10000000,%eax
f010447c:	0f 22 d8             	mov    %eax,%cr3
		// it is a recursive page fault
		if(tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP) {
f010447f:	8b 7b 3c             	mov    0x3c(%ebx),%edi
f0104482:	8d 87 00 10 40 11    	lea    0x11401000(%edi),%eax
f0104488:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f010448d:	0f 87 cc 00 00 00    	ja     f010455f <page_fault_handler+0x19d>
			// set up a page fault stack frame
			struct UTrapframe *utf = (struct UTrapframe *)(tf->tf_esp - 4) - 1;
f0104493:	8d 77 c8             	lea    -0x38(%edi),%esi
			user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
f0104496:	e8 f7 1e 00 00       	call   f0106392 <cpunum>
f010449b:	6a 03                	push   $0x3
f010449d:	6a 34                	push   $0x34
f010449f:	56                   	push   %esi
f01044a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a3:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f01044a9:	e8 9b ee ff ff       	call   f0103349 <user_mem_assert>

			utf->utf_fault_va = fault_va;
f01044ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044b1:	89 47 c8             	mov    %eax,-0x38(%edi)
			utf->utf_err = tf->tf_err;
f01044b4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01044b7:	89 47 cc             	mov    %eax,-0x34(%edi)
			utf->utf_regs = tf->tf_regs;
f01044ba:	8b 03                	mov    (%ebx),%eax
f01044bc:	89 47 d0             	mov    %eax,-0x30(%edi)
f01044bf:	8b 43 04             	mov    0x4(%ebx),%eax
f01044c2:	89 47 d4             	mov    %eax,-0x2c(%edi)
f01044c5:	8b 43 08             	mov    0x8(%ebx),%eax
f01044c8:	89 47 d8             	mov    %eax,-0x28(%edi)
f01044cb:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044ce:	89 47 dc             	mov    %eax,-0x24(%edi)
f01044d1:	8b 43 10             	mov    0x10(%ebx),%eax
f01044d4:	89 47 e0             	mov    %eax,-0x20(%edi)
f01044d7:	8b 43 14             	mov    0x14(%ebx),%eax
f01044da:	89 47 e4             	mov    %eax,-0x1c(%edi)
f01044dd:	8b 43 18             	mov    0x18(%ebx),%eax
f01044e0:	89 47 e8             	mov    %eax,-0x18(%edi)
f01044e3:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044e6:	89 47 ec             	mov    %eax,-0x14(%edi)
			utf->utf_eip = tf->tf_eip;
f01044e9:	8b 43 30             	mov    0x30(%ebx),%eax
f01044ec:	89 47 f0             	mov    %eax,-0x10(%edi)
			utf->utf_eflags = tf->tf_eflags;
f01044ef:	8b 43 38             	mov    0x38(%ebx),%eax
f01044f2:	89 47 f4             	mov    %eax,-0xc(%edi)
			utf->utf_esp = tf->tf_esp;
f01044f5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01044f8:	89 47 f8             	mov    %eax,-0x8(%edi)
			*(int *)(tf->tf_esp - 4) = 0;
f01044fb:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01044fe:	c7 40 fc 00 00 00 00 	movl   $0x0,-0x4(%eax)

			lcr3(PADDR(kern_pgdir));
f0104505:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010450a:	83 c4 10             	add    $0x10,%esp
f010450d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104512:	77 15                	ja     f0104529 <page_fault_handler+0x167>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104514:	50                   	push   %eax
f0104515:	68 68 6a 10 f0       	push   $0xf0106a68
f010451a:	68 d2 01 00 00       	push   $0x1d2
f010451f:	68 5f 80 10 f0       	push   $0xf010805f
f0104524:	e8 17 bb ff ff       	call   f0100040 <_panic>
f0104529:	05 00 00 00 10       	add    $0x10000000,%eax
f010452e:	0f 22 d8             	mov    %eax,%cr3
			// change curenv state and switch to handler
			tf->tf_esp = tf->tf_esp - 4 - sizeof(struct UTrapframe);
f0104531:	83 6b 3c 38          	subl   $0x38,0x3c(%ebx)
			tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104535:	e8 58 1e 00 00       	call   f0106392 <cpunum>
f010453a:	6b c0 74             	imul   $0x74,%eax,%eax
f010453d:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104543:	8b 40 64             	mov    0x64(%eax),%eax
f0104546:	89 43 30             	mov    %eax,0x30(%ebx)
			env_run(curenv);
f0104549:	e8 44 1e 00 00       	call   f0106392 <cpunum>
f010454e:	83 ec 0c             	sub    $0xc,%esp
f0104551:	6b c0 74             	imul   $0x74,%eax,%eax
f0104554:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f010455a:	e8 82 f4 ff ff       	call   f01039e1 <env_run>
		}
		else {
			//cprintf("33333\n");
			// set up a page fault stack frame
			struct UTrapframe *utf = (struct UTrapframe *)UXSTACKTOP - 1;
			user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_P | PTE_W);
f010455f:	e8 2e 1e 00 00       	call   f0106392 <cpunum>
f0104564:	6a 03                	push   $0x3
f0104566:	6a 34                	push   $0x34
f0104568:	68 cc ff bf ee       	push   $0xeebfffcc
f010456d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104570:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104576:	e8 ce ed ff ff       	call   f0103349 <user_mem_assert>

			utf->utf_fault_va = fault_va;
f010457b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010457e:	a3 cc ff bf ee       	mov    %eax,0xeebfffcc
			utf->utf_err = tf->tf_err;
f0104583:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104586:	a3 d0 ff bf ee       	mov    %eax,0xeebfffd0
			utf->utf_regs = tf->tf_regs;
f010458b:	8b 03                	mov    (%ebx),%eax
f010458d:	a3 d4 ff bf ee       	mov    %eax,0xeebfffd4
f0104592:	8b 43 04             	mov    0x4(%ebx),%eax
f0104595:	a3 d8 ff bf ee       	mov    %eax,0xeebfffd8
f010459a:	8b 43 08             	mov    0x8(%ebx),%eax
f010459d:	a3 dc ff bf ee       	mov    %eax,0xeebfffdc
f01045a2:	8b 43 0c             	mov    0xc(%ebx),%eax
f01045a5:	a3 e0 ff bf ee       	mov    %eax,0xeebfffe0
f01045aa:	8b 43 10             	mov    0x10(%ebx),%eax
f01045ad:	a3 e4 ff bf ee       	mov    %eax,0xeebfffe4
f01045b2:	8b 43 14             	mov    0x14(%ebx),%eax
f01045b5:	a3 e8 ff bf ee       	mov    %eax,0xeebfffe8
f01045ba:	8b 43 18             	mov    0x18(%ebx),%eax
f01045bd:	a3 ec ff bf ee       	mov    %eax,0xeebfffec
f01045c2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01045c5:	a3 f0 ff bf ee       	mov    %eax,0xeebffff0
			utf->utf_eip = tf->tf_eip;
f01045ca:	8b 43 30             	mov    0x30(%ebx),%eax
f01045cd:	a3 f4 ff bf ee       	mov    %eax,0xeebffff4
			utf->utf_eflags = tf->tf_eflags;
f01045d2:	8b 43 38             	mov    0x38(%ebx),%eax
f01045d5:	a3 f8 ff bf ee       	mov    %eax,0xeebffff8
			utf->utf_esp = tf->tf_esp;
f01045da:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045dd:	a3 fc ff bf ee       	mov    %eax,0xeebffffc

			lcr3(PADDR(kern_pgdir));
f01045e2:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01045e7:	83 c4 10             	add    $0x10,%esp
f01045ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01045ef:	77 15                	ja     f0104606 <page_fault_handler+0x244>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01045f1:	50                   	push   %eax
f01045f2:	68 68 6a 10 f0       	push   $0xf0106a68
f01045f7:	68 e5 01 00 00       	push   $0x1e5
f01045fc:	68 5f 80 10 f0       	push   $0xf010805f
f0104601:	e8 3a ba ff ff       	call   f0100040 <_panic>
f0104606:	05 00 00 00 10       	add    $0x10000000,%eax
f010460b:	0f 22 d8             	mov    %eax,%cr3
			// change curenv state and switch to handler
			tf->tf_esp = UXSTACKTOP - sizeof(struct UTrapframe);
f010460e:	c7 43 3c cc ff bf ee 	movl   $0xeebfffcc,0x3c(%ebx)
			tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104615:	e8 78 1d 00 00       	call   f0106392 <cpunum>
f010461a:	6b c0 74             	imul   $0x74,%eax,%eax
f010461d:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104623:	8b 40 64             	mov    0x64(%eax),%eax
f0104626:	89 43 30             	mov    %eax,0x30(%ebx)
			//cprintf("44444\n");
			env_run(curenv);
f0104629:	e8 64 1d 00 00       	call   f0106392 <cpunum>
f010462e:	83 ec 0c             	sub    $0xc,%esp
f0104631:	6b c0 74             	imul   $0x74,%eax,%eax
f0104634:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f010463a:	e8 a2 f3 ff ff       	call   f01039e1 <env_run>
		}
	}
}
f010463f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104642:	5b                   	pop    %ebx
f0104643:	5e                   	pop    %esi
f0104644:	5f                   	pop    %edi
f0104645:	5d                   	pop    %ebp
f0104646:	c3                   	ret    

f0104647 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104647:	55                   	push   %ebp
f0104648:	89 e5                	mov    %esp,%ebp
f010464a:	57                   	push   %edi
f010464b:	56                   	push   %esi
f010464c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010464f:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104650:	83 3d 80 ae 21 f0 00 	cmpl   $0x0,0xf021ae80
f0104657:	74 01                	je     f010465a <trap+0x13>
		asm volatile("hlt");
f0104659:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010465a:	e8 33 1d 00 00       	call   f0106392 <cpunum>
f010465f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104662:	81 c2 20 b0 21 f0    	add    $0xf021b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104668:	b8 01 00 00 00       	mov    $0x1,%eax
f010466d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104671:	83 f8 02             	cmp    $0x2,%eax
f0104674:	75 10                	jne    f0104686 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104676:	83 ec 0c             	sub    $0xc,%esp
f0104679:	68 c0 13 12 f0       	push   $0xf01213c0
f010467e:	e8 7d 1f 00 00       	call   f0106600 <spin_lock>
f0104683:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104686:	9c                   	pushf  
f0104687:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104688:	f6 c4 02             	test   $0x2,%ah
f010468b:	74 19                	je     f01046a6 <trap+0x5f>
f010468d:	68 6b 80 10 f0       	push   $0xf010806b
f0104692:	68 17 7b 10 f0       	push   $0xf0107b17
f0104697:	68 48 01 00 00       	push   $0x148
f010469c:	68 5f 80 10 f0       	push   $0xf010805f
f01046a1:	e8 9a b9 ff ff       	call   f0100040 <_panic>


	//cprintf("exception number: %d\n", tf->tf_trapno);


	if ((tf->tf_cs & 3) == 3) {
f01046a6:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01046aa:	83 e0 03             	and    $0x3,%eax
f01046ad:	66 83 f8 03          	cmp    $0x3,%ax
f01046b1:	0f 85 a0 00 00 00    	jne    f0104757 <trap+0x110>
f01046b7:	83 ec 0c             	sub    $0xc,%esp
f01046ba:	68 c0 13 12 f0       	push   $0xf01213c0
f01046bf:	e8 3c 1f 00 00       	call   f0106600 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f01046c4:	e8 c9 1c 00 00       	call   f0106392 <cpunum>
f01046c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01046cc:	83 c4 10             	add    $0x10,%esp
f01046cf:	83 b8 28 b0 21 f0 00 	cmpl   $0x0,-0xfde4fd8(%eax)
f01046d6:	75 19                	jne    f01046f1 <trap+0xaa>
f01046d8:	68 84 80 10 f0       	push   $0xf0108084
f01046dd:	68 17 7b 10 f0       	push   $0xf0107b17
f01046e2:	68 54 01 00 00       	push   $0x154
f01046e7:	68 5f 80 10 f0       	push   $0xf010805f
f01046ec:	e8 4f b9 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01046f1:	e8 9c 1c 00 00       	call   f0106392 <cpunum>
f01046f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f9:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f01046ff:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104703:	75 2d                	jne    f0104732 <trap+0xeb>
			env_free(curenv);
f0104705:	e8 88 1c 00 00       	call   f0106392 <cpunum>
f010470a:	83 ec 0c             	sub    $0xc,%esp
f010470d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104710:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104716:	e8 81 f0 ff ff       	call   f010379c <env_free>
			curenv = NULL;
f010471b:	e8 72 1c 00 00       	call   f0106392 <cpunum>
f0104720:	6b c0 74             	imul   $0x74,%eax,%eax
f0104723:	c7 80 28 b0 21 f0 00 	movl   $0x0,-0xfde4fd8(%eax)
f010472a:	00 00 00 
			sched_yield();
f010472d:	e8 c5 02 00 00       	call   f01049f7 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104732:	e8 5b 1c 00 00       	call   f0106392 <cpunum>
f0104737:	6b c0 74             	imul   $0x74,%eax,%eax
f010473a:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104740:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104745:	89 c7                	mov    %eax,%edi
f0104747:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104749:	e8 44 1c 00 00       	call   f0106392 <cpunum>
f010474e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104751:	8b b0 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104757:	89 35 60 aa 21 f0    	mov    %esi,0xf021aa60
	}
	else if(tf->tf_trapno == T_PGFLT) {
		page_fault_handler(tf);
	}
	#else
	if(tf->tf_trapno == T_PGFLT) {
f010475d:	8b 46 28             	mov    0x28(%esi),%eax
f0104760:	83 f8 0e             	cmp    $0xe,%eax
f0104763:	75 11                	jne    f0104776 <trap+0x12f>
		page_fault_handler(tf);
f0104765:	83 ec 0c             	sub    $0xc,%esp
f0104768:	56                   	push   %esi
f0104769:	e8 54 fc ff ff       	call   f01043c2 <page_fault_handler>
f010476e:	83 c4 10             	add    $0x10,%esp
f0104771:	e9 cf 00 00 00       	jmp    f0104845 <trap+0x1fe>
	}
	#endif


	else if(tf->tf_trapno == T_BRKPT) {
f0104776:	83 f8 03             	cmp    $0x3,%eax
f0104779:	75 11                	jne    f010478c <trap+0x145>
		monitor(tf);
f010477b:	83 ec 0c             	sub    $0xc,%esp
f010477e:	56                   	push   %esi
f010477f:	e8 eb c5 ff ff       	call   f0100d6f <monitor>
f0104784:	83 c4 10             	add    $0x10,%esp
f0104787:	e9 b9 00 00 00       	jmp    f0104845 <trap+0x1fe>
	}
	else if(tf->tf_trapno == T_SYSCALL) {  
f010478c:	83 f8 30             	cmp    $0x30,%eax
f010478f:	75 24                	jne    f01047b5 <trap+0x16e>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104791:	83 ec 08             	sub    $0x8,%esp
f0104794:	ff 76 04             	pushl  0x4(%esi)
f0104797:	ff 36                	pushl  (%esi)
f0104799:	ff 76 10             	pushl  0x10(%esi)
f010479c:	ff 76 18             	pushl  0x18(%esi)
f010479f:	ff 76 14             	pushl  0x14(%esi)
f01047a2:	ff 76 1c             	pushl  0x1c(%esi)
f01047a5:	e8 1a 03 00 00       	call   f0104ac4 <syscall>
f01047aa:	89 46 1c             	mov    %eax,0x1c(%esi)
f01047ad:	83 c4 20             	add    $0x20,%esp
f01047b0:	e9 90 00 00 00       	jmp    f0104845 <trap+0x1fe>
									tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
	}
	/* lab3 challenge */
	else if(tf->tf_trapno == T_DEBUG) {
f01047b5:	83 f8 01             	cmp    $0x1,%eax
f01047b8:	75 0e                	jne    f01047c8 <trap+0x181>
		monitor(tf);
f01047ba:	83 ec 0c             	sub    $0xc,%esp
f01047bd:	56                   	push   %esi
f01047be:	e8 ac c5 ff ff       	call   f0100d6f <monitor>
f01047c3:	83 c4 10             	add    $0x10,%esp
f01047c6:	eb 7d                	jmp    f0104845 <trap+0x1fe>


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	else if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01047c8:	83 f8 27             	cmp    $0x27,%eax
f01047cb:	75 0e                	jne    f01047db <trap+0x194>
		//cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
f01047cd:	83 ec 0c             	sub    $0xc,%esp
f01047d0:	56                   	push   %esi
f01047d1:	e8 64 fa ff ff       	call   f010423a <print_trapframe>
f01047d6:	83 c4 10             	add    $0x10,%esp
f01047d9:	eb 6a                	jmp    f0104845 <trap+0x1fe>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	else if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01047db:	83 f8 20             	cmp    $0x20,%eax
f01047de:	75 0a                	jne    f01047ea <trap+0x1a3>
		lapic_eoi();
f01047e0:	e8 f8 1c 00 00       	call   f01064dd <lapic_eoi>
		sched_yield();
f01047e5:	e8 0d 02 00 00       	call   f01049f7 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	// keyboard interrupt
	else if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f01047ea:	83 f8 21             	cmp    $0x21,%eax
f01047ed:	75 07                	jne    f01047f6 <trap+0x1af>
		kbd_intr();
f01047ef:	e8 10 be ff ff       	call   f0100604 <kbd_intr>
f01047f4:	eb 4f                	jmp    f0104845 <trap+0x1fe>

	// serial port interrupt
	else if(tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL)
f01047f6:	83 f8 24             	cmp    $0x24,%eax
f01047f9:	75 07                	jne    f0104802 <trap+0x1bb>
		serial_intr();
f01047fb:	e8 e8 bd ff ff       	call   f01005e8 <serial_intr>
f0104800:	eb 43                	jmp    f0104845 <trap+0x1fe>

	// Unexpected trap: The user process or the kernel has a bug.
	else {
		print_trapframe(tf);
f0104802:	83 ec 0c             	sub    $0xc,%esp
f0104805:	56                   	push   %esi
f0104806:	e8 2f fa ff ff       	call   f010423a <print_trapframe>
		if (tf->tf_cs == GD_KT)
f010480b:	83 c4 10             	add    $0x10,%esp
f010480e:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104813:	75 17                	jne    f010482c <trap+0x1e5>
			panic("unhandled trap in kernel");
f0104815:	83 ec 04             	sub    $0x4,%esp
f0104818:	68 8b 80 10 f0       	push   $0xf010808b
f010481d:	68 2d 01 00 00       	push   $0x12d
f0104822:	68 5f 80 10 f0       	push   $0xf010805f
f0104827:	e8 14 b8 ff ff       	call   f0100040 <_panic>
		else {
			env_destroy(curenv);
f010482c:	e8 61 1b 00 00       	call   f0106392 <cpunum>
f0104831:	83 ec 0c             	sub    $0xc,%esp
f0104834:	6b c0 74             	imul   $0x74,%eax,%eax
f0104837:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f010483d:	e8 00 f1 ff ff       	call   f0103942 <env_destroy>
f0104842:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING) 
f0104845:	e8 48 1b 00 00       	call   f0106392 <cpunum>
f010484a:	6b c0 74             	imul   $0x74,%eax,%eax
f010484d:	83 b8 28 b0 21 f0 00 	cmpl   $0x0,-0xfde4fd8(%eax)
f0104854:	74 2a                	je     f0104880 <trap+0x239>
f0104856:	e8 37 1b 00 00       	call   f0106392 <cpunum>
f010485b:	6b c0 74             	imul   $0x74,%eax,%eax
f010485e:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104864:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104868:	75 16                	jne    f0104880 <trap+0x239>
		env_run(curenv);
f010486a:	e8 23 1b 00 00       	call   f0106392 <cpunum>
f010486f:	83 ec 0c             	sub    $0xc,%esp
f0104872:	6b c0 74             	imul   $0x74,%eax,%eax
f0104875:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f010487b:	e8 61 f1 ff ff       	call   f01039e1 <env_run>
	else 
		sched_yield();
f0104880:	e8 72 01 00 00       	call   f01049f7 <sched_yield>
f0104885:	90                   	nop

f0104886 <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

 	TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104886:	6a 00                	push   $0x0
f0104888:	6a 00                	push   $0x0
f010488a:	e9 83 00 00 00       	jmp    f0104912 <_alltraps>
f010488f:	90                   	nop

f0104890 <handler1>:
 	TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104890:	6a 00                	push   $0x0
f0104892:	6a 01                	push   $0x1
f0104894:	eb 7c                	jmp    f0104912 <_alltraps>

f0104896 <handler2>:
 	TRAPHANDLER_NOEC(handler2, T_NMI)
f0104896:	6a 00                	push   $0x0
f0104898:	6a 02                	push   $0x2
f010489a:	eb 76                	jmp    f0104912 <_alltraps>

f010489c <handler3>:
 	TRAPHANDLER_NOEC(handler3, T_BRKPT)
f010489c:	6a 00                	push   $0x0
f010489e:	6a 03                	push   $0x3
f01048a0:	eb 70                	jmp    f0104912 <_alltraps>

f01048a2 <handler4>:
 	TRAPHANDLER_NOEC(handler4, T_OFLOW)
f01048a2:	6a 00                	push   $0x0
f01048a4:	6a 04                	push   $0x4
f01048a6:	eb 6a                	jmp    f0104912 <_alltraps>

f01048a8 <handler5>:
 	TRAPHANDLER_NOEC(handler5, T_BOUND)
f01048a8:	6a 00                	push   $0x0
f01048aa:	6a 05                	push   $0x5
f01048ac:	eb 64                	jmp    f0104912 <_alltraps>

f01048ae <handler6>:
 	TRAPHANDLER_NOEC(handler6, T_ILLOP)
f01048ae:	6a 00                	push   $0x0
f01048b0:	6a 06                	push   $0x6
f01048b2:	eb 5e                	jmp    f0104912 <_alltraps>

f01048b4 <handler7>:
 	TRAPHANDLER_NOEC(handler7, T_DEVICE)
f01048b4:	6a 00                	push   $0x0
f01048b6:	6a 07                	push   $0x7
f01048b8:	eb 58                	jmp    f0104912 <_alltraps>

f01048ba <handler8>:
 	TRAPHANDLER(handler8, T_DBLFLT)
f01048ba:	6a 08                	push   $0x8
f01048bc:	eb 54                	jmp    f0104912 <_alltraps>

f01048be <handler10>:
 	TRAPHANDLER(handler10, T_TSS)
f01048be:	6a 0a                	push   $0xa
f01048c0:	eb 50                	jmp    f0104912 <_alltraps>

f01048c2 <handler11>:
 	TRAPHANDLER(handler11, T_SEGNP)
f01048c2:	6a 0b                	push   $0xb
f01048c4:	eb 4c                	jmp    f0104912 <_alltraps>

f01048c6 <handler12>:
 	TRAPHANDLER(handler12, T_STACK)
f01048c6:	6a 0c                	push   $0xc
f01048c8:	eb 48                	jmp    f0104912 <_alltraps>

f01048ca <handler13>:
 	TRAPHANDLER(handler13, T_GPFLT)
f01048ca:	6a 0d                	push   $0xd
f01048cc:	eb 44                	jmp    f0104912 <_alltraps>

f01048ce <handler14>:
 	TRAPHANDLER(handler14, T_PGFLT)
f01048ce:	6a 0e                	push   $0xe
f01048d0:	eb 40                	jmp    f0104912 <_alltraps>

f01048d2 <handler16>:
 	TRAPHANDLER_NOEC(handler16, T_FPERR)
f01048d2:	6a 00                	push   $0x0
f01048d4:	6a 10                	push   $0x10
f01048d6:	eb 3a                	jmp    f0104912 <_alltraps>

f01048d8 <handler17>:
 	TRAPHANDLER(handler17, T_ALIGN)
f01048d8:	6a 11                	push   $0x11
f01048da:	eb 36                	jmp    f0104912 <_alltraps>

f01048dc <handler18>:
 	TRAPHANDLER_NOEC(handler18, T_MCHK)
f01048dc:	6a 00                	push   $0x0
f01048de:	6a 12                	push   $0x12
f01048e0:	eb 30                	jmp    f0104912 <_alltraps>

f01048e2 <handler19>:
 	TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f01048e2:	6a 00                	push   $0x0
f01048e4:	6a 13                	push   $0x13
f01048e6:	eb 2a                	jmp    f0104912 <_alltraps>

f01048e8 <handler48>:
 	TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f01048e8:	6a 00                	push   $0x0
f01048ea:	6a 30                	push   $0x30
f01048ec:	eb 24                	jmp    f0104912 <_alltraps>

f01048ee <handler32>:

 	// IRQ
 	TRAPHANDLER_NOEC(handler32, IRQ_OFFSET + IRQ_TIMER)
f01048ee:	6a 00                	push   $0x0
f01048f0:	6a 20                	push   $0x20
f01048f2:	eb 1e                	jmp    f0104912 <_alltraps>

f01048f4 <handler33>:
 	TRAPHANDLER_NOEC(handler33, IRQ_OFFSET + IRQ_KBD)
f01048f4:	6a 00                	push   $0x0
f01048f6:	6a 21                	push   $0x21
f01048f8:	eb 18                	jmp    f0104912 <_alltraps>

f01048fa <handler36>:
 	TRAPHANDLER_NOEC(handler36, IRQ_OFFSET + IRQ_SERIAL)
f01048fa:	6a 00                	push   $0x0
f01048fc:	6a 24                	push   $0x24
f01048fe:	eb 12                	jmp    f0104912 <_alltraps>

f0104900 <handler39>:
 	TRAPHANDLER_NOEC(handler39, IRQ_OFFSET + IRQ_SPURIOUS)
f0104900:	6a 00                	push   $0x0
f0104902:	6a 27                	push   $0x27
f0104904:	eb 0c                	jmp    f0104912 <_alltraps>

f0104906 <handler46>:
 	TRAPHANDLER_NOEC(handler46, IRQ_OFFSET + IRQ_IDE)
f0104906:	6a 00                	push   $0x0
f0104908:	6a 2e                	push   $0x2e
f010490a:	eb 06                	jmp    f0104912 <_alltraps>

f010490c <handler51>:
 	TRAPHANDLER_NOEC(handler51, IRQ_OFFSET + IRQ_ERROR)
f010490c:	6a 00                	push   $0x0
f010490e:	6a 33                	push   $0x33
f0104910:	eb 00                	jmp    f0104912 <_alltraps>

f0104912 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 	_alltraps:
 	push %ds
f0104912:	1e                   	push   %ds
 	push %es
f0104913:	06                   	push   %es
 	pushal
f0104914:	60                   	pusha  
 	movw $(GD_KD), %ax
f0104915:	66 b8 10 00          	mov    $0x10,%ax
 	movw %ax, %ds
f0104919:	8e d8                	mov    %eax,%ds
 	movw %ax, %es 
f010491b:	8e c0                	mov    %eax,%es
 	pushl %esp
f010491d:	54                   	push   %esp
 	call trap
f010491e:	e8 24 fd ff ff       	call   f0104647 <trap>

f0104923 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104923:	55                   	push   %ebp
f0104924:	89 e5                	mov    %esp,%ebp
f0104926:	83 ec 08             	sub    $0x8,%esp
f0104929:	a1 48 a2 21 f0       	mov    0xf021a248,%eax
f010492e:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104931:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104936:	8b 02                	mov    (%edx),%eax
f0104938:	83 e8 01             	sub    $0x1,%eax
f010493b:	83 f8 02             	cmp    $0x2,%eax
f010493e:	76 10                	jbe    f0104950 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104940:	83 c1 01             	add    $0x1,%ecx
f0104943:	83 c2 7c             	add    $0x7c,%edx
f0104946:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010494c:	75 e8                	jne    f0104936 <sched_halt+0x13>
f010494e:	eb 08                	jmp    f0104958 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104950:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104956:	75 1f                	jne    f0104977 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104958:	83 ec 0c             	sub    $0xc,%esp
f010495b:	68 70 82 10 f0       	push   $0xf0108270
f0104960:	e8 10 f3 ff ff       	call   f0103c75 <cprintf>
f0104965:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104968:	83 ec 0c             	sub    $0xc,%esp
f010496b:	6a 00                	push   $0x0
f010496d:	e8 fd c3 ff ff       	call   f0100d6f <monitor>
f0104972:	83 c4 10             	add    $0x10,%esp
f0104975:	eb f1                	jmp    f0104968 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104977:	e8 16 1a 00 00       	call   f0106392 <cpunum>
f010497c:	6b c0 74             	imul   $0x74,%eax,%eax
f010497f:	c7 80 28 b0 21 f0 00 	movl   $0x0,-0xfde4fd8(%eax)
f0104986:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104989:	a1 8c ae 21 f0       	mov    0xf021ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010498e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104993:	77 12                	ja     f01049a7 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104995:	50                   	push   %eax
f0104996:	68 68 6a 10 f0       	push   $0xf0106a68
f010499b:	6a 59                	push   $0x59
f010499d:	68 99 82 10 f0       	push   $0xf0108299
f01049a2:	e8 99 b6 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01049a7:	05 00 00 00 10       	add    $0x10000000,%eax
f01049ac:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01049af:	e8 de 19 00 00       	call   f0106392 <cpunum>
f01049b4:	6b d0 74             	imul   $0x74,%eax,%edx
f01049b7:	81 c2 20 b0 21 f0    	add    $0xf021b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01049bd:	b8 02 00 00 00       	mov    $0x2,%eax
f01049c2:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01049c6:	83 ec 0c             	sub    $0xc,%esp
f01049c9:	68 c0 13 12 f0       	push   $0xf01213c0
f01049ce:	e8 ca 1c 00 00       	call   f010669d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01049d3:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01049d5:	e8 b8 19 00 00       	call   f0106392 <cpunum>
f01049da:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01049dd:	8b 80 30 b0 21 f0    	mov    -0xfde4fd0(%eax),%eax
f01049e3:	bd 00 00 00 00       	mov    $0x0,%ebp
f01049e8:	89 c4                	mov    %eax,%esp
f01049ea:	6a 00                	push   $0x0
f01049ec:	6a 00                	push   $0x0
f01049ee:	fb                   	sti    
f01049ef:	f4                   	hlt    
f01049f0:	eb fd                	jmp    f01049ef <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01049f2:	83 c4 10             	add    $0x10,%esp
f01049f5:	c9                   	leave  
f01049f6:	c3                   	ret    

f01049f7 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01049f7:	55                   	push   %ebp
f01049f8:	89 e5                	mov    %esp,%ebp
f01049fa:	53                   	push   %ebx
f01049fb:	83 ec 04             	sub    $0x4,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	//cprintf("thiscpu %d\n", thiscpu->cpu_id);
	if(thiscpu->cpu_env == NULL) {
f01049fe:	e8 8f 19 00 00       	call   f0106392 <cpunum>
f0104a03:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a06:	83 b8 28 b0 21 f0 00 	cmpl   $0x0,-0xfde4fd8(%eax)
f0104a0d:	75 28                	jne    f0104a37 <sched_yield+0x40>
		for(idle = envs; idle < envs + NENV; ++idle) {
f0104a0f:	a1 48 a2 21 f0       	mov    0xf021a248,%eax
f0104a14:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104a1a:	eb 12                	jmp    f0104a2e <sched_yield+0x37>
			if(idle->env_status == ENV_RUNNABLE) {
f0104a1c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a20:	75 09                	jne    f0104a2b <sched_yield+0x34>
				//cprintf("env %d\n", idle - envs);
				env_run(idle);
f0104a22:	83 ec 0c             	sub    $0xc,%esp
f0104a25:	50                   	push   %eax
f0104a26:	e8 b6 ef ff ff       	call   f01039e1 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	//cprintf("thiscpu %d\n", thiscpu->cpu_id);
	if(thiscpu->cpu_env == NULL) {
		for(idle = envs; idle < envs + NENV; ++idle) {
f0104a2b:	83 c0 7c             	add    $0x7c,%eax
f0104a2e:	39 d0                	cmp    %edx,%eax
f0104a30:	75 ea                	jne    f0104a1c <sched_yield+0x25>
f0104a32:	e9 83 00 00 00       	jmp    f0104aba <sched_yield+0xc3>
			}
		}
	}	
		
	else {
		for(idle = thiscpu->cpu_env + 1; idle < envs + NENV; ++idle) {
f0104a37:	e8 56 19 00 00       	call   f0106392 <cpunum>
f0104a3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a3f:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104a45:	83 c0 7c             	add    $0x7c,%eax
f0104a48:	8b 1d 48 a2 21 f0    	mov    0xf021a248,%ebx
f0104a4e:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0104a54:	eb 12                	jmp    f0104a68 <sched_yield+0x71>
			//if(idle == thiscpu->cpu_env) 
			//	continue;
			if(idle->env_status == ENV_RUNNABLE) {
f0104a56:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a5a:	75 09                	jne    f0104a65 <sched_yield+0x6e>
				//cprintf("env %d\n", idle - envs);
				env_run(idle);
f0104a5c:	83 ec 0c             	sub    $0xc,%esp
f0104a5f:	50                   	push   %eax
f0104a60:	e8 7c ef ff ff       	call   f01039e1 <env_run>
			}
		}
	}	
		
	else {
		for(idle = thiscpu->cpu_env + 1; idle < envs + NENV; ++idle) {
f0104a65:	83 c0 7c             	add    $0x7c,%eax
f0104a68:	39 d0                	cmp    %edx,%eax
f0104a6a:	72 ea                	jb     f0104a56 <sched_yield+0x5f>
f0104a6c:	eb 12                	jmp    f0104a80 <sched_yield+0x89>
				env_run(idle);
			}
		}
		
		for(idle = envs; idle < thiscpu->cpu_env; ++idle) {
			if(idle->env_status == ENV_RUNNABLE)
f0104a6e:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104a72:	75 09                	jne    f0104a7d <sched_yield+0x86>
				env_run(idle);
f0104a74:	83 ec 0c             	sub    $0xc,%esp
f0104a77:	53                   	push   %ebx
f0104a78:	e8 64 ef ff ff       	call   f01039e1 <env_run>
				//cprintf("env %d\n", idle - envs);
				env_run(idle);
			}
		}
		
		for(idle = envs; idle < thiscpu->cpu_env; ++idle) {
f0104a7d:	83 c3 7c             	add    $0x7c,%ebx
f0104a80:	e8 0d 19 00 00       	call   f0106392 <cpunum>
f0104a85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a88:	3b 98 28 b0 21 f0    	cmp    -0xfde4fd8(%eax),%ebx
f0104a8e:	72 de                	jb     f0104a6e <sched_yield+0x77>
			if(idle->env_status == ENV_RUNNABLE)
				env_run(idle);
		}
		
		if(thiscpu->cpu_env->env_status == ENV_RUNNING)
f0104a90:	e8 fd 18 00 00       	call   f0106392 <cpunum>
f0104a95:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a98:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104a9e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104aa2:	75 16                	jne    f0104aba <sched_yield+0xc3>
			env_run(thiscpu->cpu_env);
f0104aa4:	e8 e9 18 00 00       	call   f0106392 <cpunum>
f0104aa9:	83 ec 0c             	sub    $0xc,%esp
f0104aac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aaf:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104ab5:	e8 27 ef ff ff       	call   f01039e1 <env_run>
	}
	
	// sched_halt never returns
	sched_halt();
f0104aba:	e8 64 fe ff ff       	call   f0104923 <sched_halt>
}
f0104abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ac2:	c9                   	leave  
f0104ac3:	c3                   	ret    

f0104ac4 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ac4:	55                   	push   %ebp
f0104ac5:	89 e5                	mov    %esp,%ebp
f0104ac7:	56                   	push   %esi
f0104ac8:	53                   	push   %ebx
f0104ac9:	83 ec 10             	sub    $0x10,%esp
f0104acc:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f0104acf:	83 f8 0d             	cmp    $0xd,%eax
f0104ad2:	0f 87 cb 05 00 00    	ja     f01050a3 <syscall+0x5df>
f0104ad8:	ff 24 85 ac 82 10 f0 	jmp    *-0xfef7d54(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, 0);
f0104adf:	e8 ae 18 00 00       	call   f0106392 <cpunum>
f0104ae4:	6a 00                	push   $0x0
f0104ae6:	ff 75 10             	pushl  0x10(%ebp)
f0104ae9:	ff 75 0c             	pushl  0xc(%ebp)
f0104aec:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aef:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104af5:	e8 4f e8 ff ff       	call   f0103349 <user_mem_assert>


	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104afa:	83 c4 0c             	add    $0xc,%esp
f0104afd:	ff 75 0c             	pushl  0xc(%ebp)
f0104b00:	ff 75 10             	pushl  0x10(%ebp)
f0104b03:	68 a6 82 10 f0       	push   $0xf01082a6
f0104b08:	e8 68 f1 ff ff       	call   f0103c75 <cprintf>
f0104b0d:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
f0104b10:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b15:	e9 95 05 00 00       	jmp    f01050af <syscall+0x5eb>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104b1a:	e8 f7 ba ff ff       	call   f0100616 <cons_getc>
f0104b1f:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104b21:	e9 89 05 00 00       	jmp    f01050af <syscall+0x5eb>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104b26:	e8 67 18 00 00       	call   f0106392 <cpunum>
f0104b2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2e:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104b34:	8b 58 48             	mov    0x48(%eax),%ebx
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f0104b37:	e9 73 05 00 00       	jmp    f01050af <syscall+0x5eb>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b3c:	83 ec 04             	sub    $0x4,%esp
f0104b3f:	6a 01                	push   $0x1
f0104b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b44:	50                   	push   %eax
f0104b45:	ff 75 0c             	pushl  0xc(%ebp)
f0104b48:	e8 b1 e8 ff ff       	call   f01033fe <envid2env>
f0104b4d:	83 c4 10             	add    $0x10,%esp
		return r;
f0104b50:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b52:	85 c0                	test   %eax,%eax
f0104b54:	0f 88 55 05 00 00    	js     f01050af <syscall+0x5eb>
		return r;
	env_destroy(e);
f0104b5a:	83 ec 0c             	sub    $0xc,%esp
f0104b5d:	ff 75 f4             	pushl  -0xc(%ebp)
f0104b60:	e8 dd ed ff ff       	call   f0103942 <env_destroy>
f0104b65:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104b68:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b6d:	e9 3d 05 00 00       	jmp    f01050af <syscall+0x5eb>
	//   allocated!

	// LAB 4: Your code here.
	struct Env *given_env;
	// envid does not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
f0104b72:	83 ec 04             	sub    $0x4,%esp
f0104b75:	6a 01                	push   $0x1
f0104b77:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104b7a:	50                   	push   %eax
f0104b7b:	ff 75 0c             	pushl  0xc(%ebp)
f0104b7e:	e8 7b e8 ff ff       	call   f01033fe <envid2env>
f0104b83:	83 c4 10             	add    $0x10,%esp
f0104b86:	85 c0                	test   %eax,%eax
f0104b88:	78 67                	js     f0104bf1 <syscall+0x12d>
		return -E_BAD_ENV;
	// va >= UTOP or is not page-aligned
	else if((uintptr_t)va >= UTOP || (int)va & 0xFFF)
f0104b8a:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b91:	77 68                	ja     f0104bfb <syscall+0x137>
f0104b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104b96:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
f0104b9c:	75 67                	jne    f0104c05 <syscall+0x141>
		return -E_INVAL;
	// permission is inappropriate
	else if(!(perm & PTE_U) || !(perm & PTE_P) || (perm & (~PTE_SYSCALL)) != 0)
f0104b9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ba1:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104ba6:	83 f8 05             	cmp    $0x5,%eax
f0104ba9:	75 64                	jne    f0104c0f <syscall+0x14b>
		return -E_INVAL;

	struct PageInfo *new_page;
	// out of free memory
	if((new_page = page_alloc(ALLOC_ZERO)) == NULL)
f0104bab:	83 ec 0c             	sub    $0xc,%esp
f0104bae:	6a 01                	push   $0x1
f0104bb0:	e8 a1 c8 ff ff       	call   f0101456 <page_alloc>
f0104bb5:	89 c6                	mov    %eax,%esi
f0104bb7:	83 c4 10             	add    $0x10,%esp
f0104bba:	85 c0                	test   %eax,%eax
f0104bbc:	74 5b                	je     f0104c19 <syscall+0x155>
		return -E_NO_MEM;

	// page table could not be allocated
	if(page_insert(given_env->env_pgdir, new_page, va, perm) < 0) {
f0104bbe:	ff 75 14             	pushl  0x14(%ebp)
f0104bc1:	ff 75 10             	pushl  0x10(%ebp)
f0104bc4:	50                   	push   %eax
f0104bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104bc8:	ff 70 60             	pushl  0x60(%eax)
f0104bcb:	e8 8b cb ff ff       	call   f010175b <page_insert>
f0104bd0:	83 c4 10             	add    $0x10,%esp
f0104bd3:	85 c0                	test   %eax,%eax
f0104bd5:	0f 89 d4 04 00 00    	jns    f01050af <syscall+0x5eb>
		page_free(new_page);
f0104bdb:	83 ec 0c             	sub    $0xc,%esp
f0104bde:	56                   	push   %esi
f0104bdf:	e8 e2 c8 ff ff       	call   f01014c6 <page_free>
f0104be4:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104be7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104bec:	e9 be 04 00 00       	jmp    f01050af <syscall+0x5eb>

	// LAB 4: Your code here.
	struct Env *given_env;
	// envid does not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
		return -E_BAD_ENV;
f0104bf1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104bf6:	e9 b4 04 00 00       	jmp    f01050af <syscall+0x5eb>
	// va >= UTOP or is not page-aligned
	else if((uintptr_t)va >= UTOP || (int)va & 0xFFF)
		return -E_INVAL;
f0104bfb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c00:	e9 aa 04 00 00       	jmp    f01050af <syscall+0x5eb>
f0104c05:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c0a:	e9 a0 04 00 00       	jmp    f01050af <syscall+0x5eb>
	// permission is inappropriate
	else if(!(perm & PTE_U) || !(perm & PTE_P) || (perm & (~PTE_SYSCALL)) != 0)
		return -E_INVAL;
f0104c0f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c14:	e9 96 04 00 00       	jmp    f01050af <syscall+0x5eb>

	struct PageInfo *new_page;
	// out of free memory
	if((new_page = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
f0104c19:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
	case SYS_page_alloc:
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104c1e:	e9 8c 04 00 00       	jmp    f01050af <syscall+0x5eb>
	// LAB 4: Your code here.
	struct Env *src_env;
	struct Env *dst_env;

	// envid does not exist or do not have permission
	if(envid2env(srcenvid, &src_env, 1) < 0 || envid2env(dstenvid, &dst_env, 1) < 0)
f0104c23:	83 ec 04             	sub    $0x4,%esp
f0104c26:	6a 01                	push   $0x1
f0104c28:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104c2b:	50                   	push   %eax
f0104c2c:	ff 75 0c             	pushl  0xc(%ebp)
f0104c2f:	e8 ca e7 ff ff       	call   f01033fe <envid2env>
f0104c34:	83 c4 10             	add    $0x10,%esp
f0104c37:	85 c0                	test   %eax,%eax
f0104c39:	0f 88 ae 00 00 00    	js     f0104ced <syscall+0x229>
f0104c3f:	83 ec 04             	sub    $0x4,%esp
f0104c42:	6a 01                	push   $0x1
f0104c44:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104c47:	50                   	push   %eax
f0104c48:	ff 75 14             	pushl  0x14(%ebp)
f0104c4b:	e8 ae e7 ff ff       	call   f01033fe <envid2env>
f0104c50:	83 c4 10             	add    $0x10,%esp
f0104c53:	85 c0                	test   %eax,%eax
f0104c55:	0f 88 9c 00 00 00    	js     f0104cf7 <syscall+0x233>
		return -E_BAD_ENV;
	
	// va >= UTOP or is not page-aligned
	else if((uintptr_t)srcva >= UTOP || (int)srcva & 0xFFF 
f0104c5b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c62:	0f 87 99 00 00 00    	ja     f0104d01 <syscall+0x23d>
		|| (uintptr_t)dstva >= UTOP || (int)dstva & 0xFFF)
f0104c68:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c6f:	0f 85 96 00 00 00    	jne    f0104d0b <syscall+0x247>
f0104c75:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104c7c:	0f 87 89 00 00 00    	ja     f0104d0b <syscall+0x247>
f0104c82:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104c85:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
f0104c8b:	0f 85 84 00 00 00    	jne    f0104d15 <syscall+0x251>
		return -E_INVAL;

	struct PageInfo *src_page;
	pte_t *src_pte;
	// srcva is not mapped in srcenvid's address space
	if((src_page = page_lookup(src_env->env_pgdir, srcva, &src_pte)) == NULL)
f0104c91:	83 ec 04             	sub    $0x4,%esp
f0104c94:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104c97:	50                   	push   %eax
f0104c98:	ff 75 10             	pushl  0x10(%ebp)
f0104c9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c9e:	ff 70 60             	pushl  0x60(%eax)
f0104ca1:	e8 c8 c9 ff ff       	call   f010166e <page_lookup>
f0104ca6:	83 c4 10             	add    $0x10,%esp
f0104ca9:	85 c0                	test   %eax,%eax
f0104cab:	74 72                	je     f0104d1f <syscall+0x25b>
		return -E_INVAL;
	// permission is inappropiate
	else if(!(perm & PTE_U) || !(perm & PTE_P) || (perm & (~PTE_SYSCALL)) != 0)
f0104cad:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104cb0:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f0104cb6:	83 fa 05             	cmp    $0x5,%edx
f0104cb9:	75 6e                	jne    f0104d29 <syscall+0x265>
		return -E_INVAL;
	// grant write access to a read-only page
	else if(perm & PTE_W && !((*src_pte) & PTE_W))
f0104cbb:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104cbf:	74 08                	je     f0104cc9 <syscall+0x205>
f0104cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104cc4:	f6 02 02             	testb  $0x2,(%edx)
f0104cc7:	74 6a                	je     f0104d33 <syscall+0x26f>
		return -E_INVAL;
	// no memory to alloct page tables
	else if(page_insert(dst_env->env_pgdir, src_page, dstva, perm) < 0)
f0104cc9:	ff 75 1c             	pushl  0x1c(%ebp)
f0104ccc:	ff 75 18             	pushl  0x18(%ebp)
f0104ccf:	50                   	push   %eax
f0104cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104cd3:	ff 70 60             	pushl  0x60(%eax)
f0104cd6:	e8 80 ca ff ff       	call   f010175b <page_insert>
f0104cdb:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104cde:	85 c0                	test   %eax,%eax
f0104ce0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104ce5:	0f 48 d8             	cmovs  %eax,%ebx
f0104ce8:	e9 c2 03 00 00       	jmp    f01050af <syscall+0x5eb>
	struct Env *src_env;
	struct Env *dst_env;

	// envid does not exist or do not have permission
	if(envid2env(srcenvid, &src_env, 1) < 0 || envid2env(dstenvid, &dst_env, 1) < 0)
		return -E_BAD_ENV;
f0104ced:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104cf2:	e9 b8 03 00 00       	jmp    f01050af <syscall+0x5eb>
f0104cf7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104cfc:	e9 ae 03 00 00       	jmp    f01050af <syscall+0x5eb>
	
	// va >= UTOP or is not page-aligned
	else if((uintptr_t)srcva >= UTOP || (int)srcva & 0xFFF 
		|| (uintptr_t)dstva >= UTOP || (int)dstva & 0xFFF)
		return -E_INVAL;
f0104d01:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d06:	e9 a4 03 00 00       	jmp    f01050af <syscall+0x5eb>
f0104d0b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d10:	e9 9a 03 00 00       	jmp    f01050af <syscall+0x5eb>
f0104d15:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d1a:	e9 90 03 00 00       	jmp    f01050af <syscall+0x5eb>

	struct PageInfo *src_page;
	pte_t *src_pte;
	// srcva is not mapped in srcenvid's address space
	if((src_page = page_lookup(src_env->env_pgdir, srcva, &src_pte)) == NULL)
		return -E_INVAL;
f0104d1f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d24:	e9 86 03 00 00       	jmp    f01050af <syscall+0x5eb>
	// permission is inappropiate
	else if(!(perm & PTE_U) || !(perm & PTE_P) || (perm & (~PTE_SYSCALL)) != 0)
		return -E_INVAL;
f0104d29:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d2e:	e9 7c 03 00 00       	jmp    f01050af <syscall+0x5eb>
	// grant write access to a read-only page
	else if(perm & PTE_W && !((*src_pte) & PTE_W))
		return -E_INVAL;
f0104d33:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d38:	e9 72 03 00 00       	jmp    f01050af <syscall+0x5eb>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *given_env;
	// envid does not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
f0104d3d:	83 ec 04             	sub    $0x4,%esp
f0104d40:	6a 01                	push   $0x1
f0104d42:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104d45:	50                   	push   %eax
f0104d46:	ff 75 0c             	pushl  0xc(%ebp)
f0104d49:	e8 b0 e6 ff ff       	call   f01033fe <envid2env>
f0104d4e:	83 c4 10             	add    $0x10,%esp
f0104d51:	85 c0                	test   %eax,%eax
f0104d53:	78 2d                	js     f0104d82 <syscall+0x2be>
		return -E_BAD_ENV;
	// va >= UTOP or is not page-aligned
	else if((uintptr_t)va >= UTOP || (int)va & 0xFFF)
f0104d55:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d5c:	77 2e                	ja     f0104d8c <syscall+0x2c8>
f0104d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104d61:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
f0104d67:	75 2d                	jne    f0104d96 <syscall+0x2d2>
		return -E_INVAL;

	page_remove(given_env->env_pgdir, va);
f0104d69:	83 ec 08             	sub    $0x8,%esp
f0104d6c:	ff 75 10             	pushl  0x10(%ebp)
f0104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d72:	ff 70 60             	pushl  0x60(%eax)
f0104d75:	e8 94 c9 ff ff       	call   f010170e <page_remove>
f0104d7a:	83 c4 10             	add    $0x10,%esp
f0104d7d:	e9 2d 03 00 00       	jmp    f01050af <syscall+0x5eb>

	// LAB 4: Your code here.
	struct Env *given_env;
	// envid does not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
		return -E_BAD_ENV;
f0104d82:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104d87:	e9 23 03 00 00       	jmp    f01050af <syscall+0x5eb>
	// va >= UTOP or is not page-aligned
	else if((uintptr_t)va >= UTOP || (int)va & 0xFFF)
		return -E_INVAL;
f0104d8c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d91:	e9 19 03 00 00       	jmp    f01050af <syscall+0x5eb>
f0104d96:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_alloc:
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
	case SYS_page_map:
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
	case SYS_page_unmap:
		return sys_page_unmap((envid_t)a1, (void *)a2);
f0104d9b:	e9 0f 03 00 00       	jmp    f01050af <syscall+0x5eb>

	// LAB 4: Your code here.
	struct Env *new_env;
	int ret_num;
	// envid do not exist or do not have permission
	if((ret_num = env_alloc(&new_env, curenv->env_id)) < 0)
f0104da0:	e8 ed 15 00 00       	call   f0106392 <cpunum>
f0104da5:	83 ec 08             	sub    $0x8,%esp
f0104da8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dab:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104db1:	ff 70 48             	pushl  0x48(%eax)
f0104db4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104db7:	50                   	push   %eax
f0104db8:	e8 67 e7 ff ff       	call   f0103524 <env_alloc>
f0104dbd:	83 c4 10             	add    $0x10,%esp
		return ret_num;
f0104dc0:	89 c3                	mov    %eax,%ebx

	// LAB 4: Your code here.
	struct Env *new_env;
	int ret_num;
	// envid do not exist or do not have permission
	if((ret_num = env_alloc(&new_env, curenv->env_id)) < 0)
f0104dc2:	85 c0                	test   %eax,%eax
f0104dc4:	0f 88 e5 02 00 00    	js     f01050af <syscall+0x5eb>
		return ret_num;

	new_env->env_status = ENV_NOT_RUNNABLE;
f0104dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104dcd:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// copy old environment's register
	memcpy(&new_env->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
f0104dd4:	e8 b9 15 00 00       	call   f0106392 <cpunum>
f0104dd9:	83 ec 04             	sub    $0x4,%esp
f0104ddc:	6a 44                	push   $0x44
f0104dde:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de1:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104de7:	ff 75 f4             	pushl  -0xc(%ebp)
f0104dea:	e8 bf 0f 00 00       	call   f0105dae <memcpy>

	// child environment should return 0
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104def:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104df2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return new_env->env_id;
f0104df9:	8b 58 48             	mov    0x48(%eax),%ebx
f0104dfc:	83 c4 10             	add    $0x10,%esp
f0104dff:	e9 ab 02 00 00       	jmp    f01050af <syscall+0x5eb>
	// envid's status.

	// LAB 4: Your code here.
	struct Env *given_env;
	// envid do not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
f0104e04:	83 ec 04             	sub    $0x4,%esp
f0104e07:	6a 01                	push   $0x1
f0104e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e0c:	50                   	push   %eax
f0104e0d:	ff 75 0c             	pushl  0xc(%ebp)
f0104e10:	e8 e9 e5 ff ff       	call   f01033fe <envid2env>
f0104e15:	83 c4 10             	add    $0x10,%esp
f0104e18:	85 c0                	test   %eax,%eax
f0104e1a:	78 20                	js     f0104e3c <syscall+0x378>
		return -E_BAD_ENV;
	// status is not a valid status
	else if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104e1c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e1f:	83 e8 02             	sub    $0x2,%eax
f0104e22:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104e27:	75 1d                	jne    f0104e46 <syscall+0x382>
		return -E_INVAL;
	else {
		given_env->env_status = status;
f0104e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e2f:	89 48 54             	mov    %ecx,0x54(%eax)
		return 0;
f0104e32:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e37:	e9 73 02 00 00       	jmp    f01050af <syscall+0x5eb>

	// LAB 4: Your code here.
	struct Env *given_env;
	// envid do not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
		return -E_BAD_ENV;
f0104e3c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104e41:	e9 69 02 00 00       	jmp    f01050af <syscall+0x5eb>
	// status is not a valid status
	else if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104e46:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_unmap:
		return sys_page_unmap((envid_t)a1, (void *)a2);
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status((envid_t)a1, (int)a2);
f0104e4b:	e9 5f 02 00 00       	jmp    f01050af <syscall+0x5eb>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *given_env;
	// envid does not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
f0104e50:	83 ec 04             	sub    $0x4,%esp
f0104e53:	6a 01                	push   $0x1
f0104e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e58:	50                   	push   %eax
f0104e59:	ff 75 0c             	pushl  0xc(%ebp)
f0104e5c:	e8 9d e5 ff ff       	call   f01033fe <envid2env>
f0104e61:	83 c4 10             	add    $0x10,%esp
f0104e64:	85 c0                	test   %eax,%eax
f0104e66:	78 13                	js     f0104e7b <syscall+0x3b7>
		return -E_BAD_ENV;

	given_env->env_pgfault_upcall = func;
f0104e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e6e:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f0104e71:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e76:	e9 34 02 00 00       	jmp    f01050af <syscall+0x5eb>
{
	// LAB 4: Your code here.
	struct Env *given_env;
	// envid does not exist or do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
		return -E_BAD_ENV;
f0104e7b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		return sys_env_set_exception_upcall((envid_t)a1, (void *)a2);
	case SYS_env_set_exception_handler:
		return sys_env_set_exception_handler((envid_t)a1, (uint32_t)a2);
	#else
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104e80:	e9 2a 02 00 00       	jmp    f01050af <syscall+0x5eb>
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *given_env;

	// envid do not exist or caller do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
f0104e85:	83 ec 04             	sub    $0x4,%esp
f0104e88:	6a 01                	push   $0x1
f0104e8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104e8d:	50                   	push   %eax
f0104e8e:	ff 75 0c             	pushl  0xc(%ebp)
f0104e91:	e8 68 e5 ff ff       	call   f01033fe <envid2env>
f0104e96:	83 c4 10             	add    $0x10,%esp
f0104e99:	85 c0                	test   %eax,%eax
f0104e9b:	78 4b                	js     f0104ee8 <syscall+0x424>
		return -E_BAD_ENV;

	// check wether it is a good address
	user_mem_assert(curenv, (void *)tf, sizeof(struct Trapframe), 0);
f0104e9d:	e8 f0 14 00 00       	call   f0106392 <cpunum>
f0104ea2:	6a 00                	push   $0x0
f0104ea4:	6a 44                	push   $0x44
f0104ea6:	ff 75 10             	pushl  0x10(%ebp)
f0104ea9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eac:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0104eb2:	e8 92 e4 ff ff       	call   f0103349 <user_mem_assert>

	// set CPL3, interrupts enabled and IOPL of 0
	memcpy(&given_env->env_tf, tf, sizeof(struct Trapframe));
f0104eb7:	83 c4 0c             	add    $0xc,%esp
f0104eba:	6a 44                	push   $0x44
f0104ebc:	ff 75 10             	pushl  0x10(%ebp)
f0104ebf:	ff 75 f4             	pushl  -0xc(%ebp)
f0104ec2:	e8 e7 0e 00 00       	call   f0105dae <memcpy>
	given_env->env_tf.tf_cs |= 3;
f0104ec7:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104eca:	66 83 4a 34 03       	orw    $0x3,0x34(%edx)
	given_env->env_tf.tf_eflags |= FL_IF;
	given_env->env_tf.tf_eflags &= (~FL_IOPL_MASK);
f0104ecf:	8b 42 38             	mov    0x38(%edx),%eax
f0104ed2:	80 e4 cf             	and    $0xcf,%ah
f0104ed5:	80 cc 02             	or     $0x2,%ah
f0104ed8:	89 42 38             	mov    %eax,0x38(%edx)
f0104edb:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104ede:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ee3:	e9 c7 01 00 00       	jmp    f01050af <syscall+0x5eb>
	// address!
	struct Env *given_env;

	// envid do not exist or caller do not have permission
	if(envid2env(envid, &given_env, 1) < 0)
		return -E_BAD_ENV;
f0104ee8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
	case SYS_env_set_pte:
		return sys_env_set_pte((envid_t)a1, (void *)a2, (pte_t)a3);
	#endif

	case SYS_env_set_trapframe:
		return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);	
f0104eed:	e9 bd 01 00 00       	jmp    f01050af <syscall+0x5eb>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104ef2:	e8 00 fb ff ff       	call   f01049f7 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *target_env;
	// envid does not exist 
	if(envid2env(envid, &target_env, 0) < 0)
f0104ef7:	83 ec 04             	sub    $0x4,%esp
f0104efa:	6a 00                	push   $0x0
f0104efc:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104eff:	50                   	push   %eax
f0104f00:	ff 75 0c             	pushl  0xc(%ebp)
f0104f03:	e8 f6 e4 ff ff       	call   f01033fe <envid2env>
f0104f08:	83 c4 10             	add    $0x10,%esp
f0104f0b:	85 c0                	test   %eax,%eax
f0104f0d:	0f 88 fe 00 00 00    	js     f0105011 <syscall+0x54d>
		return -E_BAD_ENV;
	// the target is not blocked
	if(target_env->env_ipc_recving == 0)
f0104f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f16:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104f1a:	0f 84 fb 00 00 00    	je     f010501b <syscall+0x557>
		return -E_IPC_NOT_RECV;
	
	if((uint32_t)srcva < UTOP) {
f0104f20:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104f27:	0f 87 a8 00 00 00    	ja     f0104fd5 <syscall+0x511>
		// srcva is not page-aligned
		if(ROUNDDOWN(srcva, PGSIZE) != srcva)
			return -E_INVAL;
f0104f2d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	if(target_env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
	
	if((uint32_t)srcva < UTOP) {
		// srcva is not page-aligned
		if(ROUNDDOWN(srcva, PGSIZE) != srcva)
f0104f32:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104f39:	0f 85 70 01 00 00    	jne    f01050af <syscall+0x5eb>
			return -E_INVAL;
		// permission is inappropriate
		if(!(perm & PTE_U) || !(perm & PTE_P) || (perm & (~PTE_SYSCALL)) != 0)
f0104f3f:	8b 45 18             	mov    0x18(%ebp),%eax
f0104f42:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104f47:	83 f8 05             	cmp    $0x5,%eax
f0104f4a:	0f 85 5f 01 00 00    	jne    f01050af <syscall+0x5eb>
			return -E_INVAL;

		// the physical page for virtual address srcva	
		pte_t *page_table_entry;
		struct PageInfo *pp;
		pp = page_lookup(curenv->env_pgdir, srcva, &page_table_entry);
f0104f50:	e8 3d 14 00 00       	call   f0106392 <cpunum>
f0104f55:	83 ec 04             	sub    $0x4,%esp
f0104f58:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104f5b:	52                   	push   %edx
f0104f5c:	ff 75 14             	pushl  0x14(%ebp)
f0104f5f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f62:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104f68:	ff 70 60             	pushl  0x60(%eax)
f0104f6b:	e8 fe c6 ff ff       	call   f010166e <page_lookup>

		// srcva is not mapped in the caller's address space
		if(page_table_entry == NULL || !(*page_table_entry & PTE_P))
f0104f70:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104f73:	83 c4 10             	add    $0x10,%esp
f0104f76:	85 d2                	test   %edx,%edx
f0104f78:	74 47                	je     f0104fc1 <syscall+0x4fd>
f0104f7a:	8b 12                	mov    (%edx),%edx
f0104f7c:	f6 c2 01             	test   $0x1,%dl
f0104f7f:	0f 84 2a 01 00 00    	je     f01050af <syscall+0x5eb>
			return -E_INVAL;
		// (perm & PTE_W) but srcva is read-only in the curenv
		if((perm & PTE_W) && !(*page_table_entry & PTE_W))
f0104f85:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104f89:	74 09                	je     f0104f94 <syscall+0x4d0>
f0104f8b:	f6 c2 02             	test   $0x2,%dl
f0104f8e:	0f 84 1b 01 00 00    	je     f01050af <syscall+0x5eb>
			return -E_INVAL;
		// there is not enough memory to map srcva in envid's address space
		if((uint32_t)target_env->env_ipc_dstva < UTOP) {
f0104f94:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104f97:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104f9a:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104fa0:	77 33                	ja     f0104fd5 <syscall+0x511>
			if(page_insert(target_env->env_pgdir, pp, target_env->env_ipc_dstva, 
f0104fa2:	ff 75 18             	pushl  0x18(%ebp)
f0104fa5:	51                   	push   %ecx
f0104fa6:	50                   	push   %eax
f0104fa7:	ff 72 60             	pushl  0x60(%edx)
f0104faa:	e8 ac c7 ff ff       	call   f010175b <page_insert>
f0104faf:	83 c4 10             	add    $0x10,%esp
f0104fb2:	85 c0                	test   %eax,%eax
f0104fb4:	78 15                	js     f0104fcb <syscall+0x507>
				perm) < 0)
				return -E_NO_MEM;
			else
				target_env->env_ipc_perm = perm;
f0104fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fb9:	8b 75 18             	mov    0x18(%ebp),%esi
f0104fbc:	89 70 78             	mov    %esi,0x78(%eax)
f0104fbf:	eb 14                	jmp    f0104fd5 <syscall+0x511>
		struct PageInfo *pp;
		pp = page_lookup(curenv->env_pgdir, srcva, &page_table_entry);

		// srcva is not mapped in the caller's address space
		if(page_table_entry == NULL || !(*page_table_entry & PTE_P))
			return -E_INVAL;
f0104fc1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fc6:	e9 e4 00 00 00       	jmp    f01050af <syscall+0x5eb>
			return -E_INVAL;
		// there is not enough memory to map srcva in envid's address space
		if((uint32_t)target_env->env_ipc_dstva < UTOP) {
			if(page_insert(target_env->env_pgdir, pp, target_env->env_ipc_dstva, 
				perm) < 0)
				return -E_NO_MEM;
f0104fcb:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104fd0:	e9 da 00 00 00       	jmp    f01050af <syscall+0x5eb>
			else
				target_env->env_ipc_perm = perm;
		}
	}

	target_env->env_tf.tf_regs.reg_eax = 0;
f0104fd5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104fd8:	c7 43 1c 00 00 00 00 	movl   $0x0,0x1c(%ebx)
	target_env->env_ipc_recving = 0;
f0104fdf:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	target_env->env_ipc_from = curenv->env_id;
f0104fe3:	e8 aa 13 00 00       	call   f0106392 <cpunum>
f0104fe8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104feb:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0104ff1:	8b 40 48             	mov    0x48(%eax),%eax
f0104ff4:	89 43 74             	mov    %eax,0x74(%ebx)
	target_env->env_ipc_value = value;
f0104ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ffa:	8b 75 10             	mov    0x10(%ebp),%esi
f0104ffd:	89 70 70             	mov    %esi,0x70(%eax)
	target_env->env_status = ENV_RUNNABLE;
f0105000:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f0105007:	bb 00 00 00 00       	mov    $0x0,%ebx
f010500c:	e9 9e 00 00 00       	jmp    f01050af <syscall+0x5eb>
{
	// LAB 4: Your code here.
	struct Env *target_env;
	// envid does not exist 
	if(envid2env(envid, &target_env, 0) < 0)
		return -E_BAD_ENV;
f0105011:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0105016:	e9 94 00 00 00       	jmp    f01050af <syscall+0x5eb>
	// the target is not blocked
	if(target_env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f010501b:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);	
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_ipc_try_send:
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
f0105020:	e9 8a 00 00 00       	jmp    f01050af <syscall+0x5eb>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	
	if((uint32_t)dstva < UTOP) {
f0105025:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010502c:	77 1f                	ja     f010504d <syscall+0x589>
		// dstva is < UTOP but not page-aligned
		if(ROUNDDOWN(dstva, PGSIZE) != dstva) {
f010502e:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105035:	75 73                	jne    f01050aa <syscall+0x5e6>
			return -E_INVAL;
		}
		// it is a valid dstva
		else 
			curenv->env_ipc_dstva = dstva;
f0105037:	e8 56 13 00 00       	call   f0106392 <cpunum>
f010503c:	6b c0 74             	imul   $0x74,%eax,%eax
f010503f:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0105045:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105048:	89 70 6c             	mov    %esi,0x6c(%eax)
f010504b:	eb 15                	jmp    f0105062 <syscall+0x59e>
	}
	else 
		curenv->env_ipc_dstva = (void *)UTOP;
f010504d:	e8 40 13 00 00       	call   f0106392 <cpunum>
f0105052:	6b c0 74             	imul   $0x74,%eax,%eax
f0105055:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f010505b:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)

	curenv->env_ipc_recving = 1;
f0105062:	e8 2b 13 00 00       	call   f0106392 <cpunum>
f0105067:	6b c0 74             	imul   $0x74,%eax,%eax
f010506a:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0105070:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105074:	e8 19 13 00 00       	call   f0106392 <cpunum>
f0105079:	6b c0 74             	imul   $0x74,%eax,%eax
f010507c:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0105082:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_perm = 0;
f0105089:	e8 04 13 00 00       	call   f0106392 <cpunum>
f010508e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105091:	8b 80 28 b0 21 f0    	mov    -0xfde4fd8(%eax),%eax
f0105097:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010509e:	e8 54 f9 ff ff       	call   f01049f7 <sched_yield>
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case NSYSCALLS:
	default:
		return -E_INVAL;
f01050a3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01050a8:	eb 05                	jmp    f01050af <syscall+0x5eb>
		sys_yield();
		return 0;
	case SYS_ipc_try_send:
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
f01050aa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case NSYSCALLS:
	default:
		return -E_INVAL;
	}
}
f01050af:	89 d8                	mov    %ebx,%eax
f01050b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01050b4:	5b                   	pop    %ebx
f01050b5:	5e                   	pop    %esi
f01050b6:	5d                   	pop    %ebp
f01050b7:	c3                   	ret    

f01050b8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01050b8:	55                   	push   %ebp
f01050b9:	89 e5                	mov    %esp,%ebp
f01050bb:	57                   	push   %edi
f01050bc:	56                   	push   %esi
f01050bd:	53                   	push   %ebx
f01050be:	83 ec 14             	sub    $0x14,%esp
f01050c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01050c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01050ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01050cd:	8b 1a                	mov    (%edx),%ebx
f01050cf:	8b 01                	mov    (%ecx),%eax
f01050d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01050d4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01050db:	eb 7f                	jmp    f010515c <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01050dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01050e0:	01 d8                	add    %ebx,%eax
f01050e2:	89 c6                	mov    %eax,%esi
f01050e4:	c1 ee 1f             	shr    $0x1f,%esi
f01050e7:	01 c6                	add    %eax,%esi
f01050e9:	d1 fe                	sar    %esi
f01050eb:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01050ee:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01050f1:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01050f4:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050f6:	eb 03                	jmp    f01050fb <stab_binsearch+0x43>
			m--;
f01050f8:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050fb:	39 c3                	cmp    %eax,%ebx
f01050fd:	7f 0d                	jg     f010510c <stab_binsearch+0x54>
f01050ff:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105103:	83 ea 0c             	sub    $0xc,%edx
f0105106:	39 f9                	cmp    %edi,%ecx
f0105108:	75 ee                	jne    f01050f8 <stab_binsearch+0x40>
f010510a:	eb 05                	jmp    f0105111 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010510c:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010510f:	eb 4b                	jmp    f010515c <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105111:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105114:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105117:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010511b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010511e:	76 11                	jbe    f0105131 <stab_binsearch+0x79>
			*region_left = m;
f0105120:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105123:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105125:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105128:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010512f:	eb 2b                	jmp    f010515c <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105131:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105134:	73 14                	jae    f010514a <stab_binsearch+0x92>
			*region_right = m - 1;
f0105136:	83 e8 01             	sub    $0x1,%eax
f0105139:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010513c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010513f:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105141:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105148:	eb 12                	jmp    f010515c <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010514a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010514d:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010514f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105153:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105155:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010515c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010515f:	0f 8e 78 ff ff ff    	jle    f01050dd <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105165:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105169:	75 0f                	jne    f010517a <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010516b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010516e:	8b 00                	mov    (%eax),%eax
f0105170:	83 e8 01             	sub    $0x1,%eax
f0105173:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105176:	89 06                	mov    %eax,(%esi)
f0105178:	eb 2c                	jmp    f01051a6 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010517a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010517d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010517f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105182:	8b 0e                	mov    (%esi),%ecx
f0105184:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105187:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010518a:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010518d:	eb 03                	jmp    f0105192 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010518f:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105192:	39 c8                	cmp    %ecx,%eax
f0105194:	7e 0b                	jle    f01051a1 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0105196:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010519a:	83 ea 0c             	sub    $0xc,%edx
f010519d:	39 df                	cmp    %ebx,%edi
f010519f:	75 ee                	jne    f010518f <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01051a1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01051a4:	89 06                	mov    %eax,(%esi)
	}
}
f01051a6:	83 c4 14             	add    $0x14,%esp
f01051a9:	5b                   	pop    %ebx
f01051aa:	5e                   	pop    %esi
f01051ab:	5f                   	pop    %edi
f01051ac:	5d                   	pop    %ebp
f01051ad:	c3                   	ret    

f01051ae <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01051ae:	55                   	push   %ebp
f01051af:	89 e5                	mov    %esp,%ebp
f01051b1:	57                   	push   %edi
f01051b2:	56                   	push   %esi
f01051b3:	53                   	push   %ebx
f01051b4:	83 ec 4c             	sub    $0x4c,%esp
f01051b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01051ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01051bd:	c7 03 e4 82 10 f0    	movl   $0xf01082e4,(%ebx)
	info->eip_line = 0;
f01051c3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01051ca:	c7 43 08 e4 82 10 f0 	movl   $0xf01082e4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01051d1:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01051d8:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01051db:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
		// Make sure the STA
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01051e2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01051e8:	0f 87 9a 00 00 00    	ja     f0105288 <debuginfo_eip+0xda>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if((user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U)) < 0)
f01051ee:	e8 9f 11 00 00       	call   f0106392 <cpunum>
f01051f3:	6a 04                	push   $0x4
f01051f5:	6a 10                	push   $0x10
f01051f7:	68 00 00 20 00       	push   $0x200000
f01051fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01051ff:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0105205:	e8 5d e0 ff ff       	call   f0103267 <user_mem_check>
f010520a:	83 c4 10             	add    $0x10,%esp
f010520d:	85 c0                	test   %eax,%eax
f010520f:	0f 88 57 02 00 00    	js     f010546c <debuginfo_eip+0x2be>
			return -1;

		stabs = usd->stabs;
f0105215:	a1 00 00 20 00       	mov    0x200000,%eax
f010521a:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f010521d:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105223:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105229:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f010522c:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105231:	89 45 bc             	mov    %eax,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if((user_mem_check(curenv, stabs, (stab_end-stabs)*sizeof(struct Stab), PTE_U)) < 0)
f0105234:	e8 59 11 00 00       	call   f0106392 <cpunum>
f0105239:	6a 04                	push   $0x4
f010523b:	89 fa                	mov    %edi,%edx
f010523d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105240:	29 ca                	sub    %ecx,%edx
f0105242:	52                   	push   %edx
f0105243:	51                   	push   %ecx
f0105244:	6b c0 74             	imul   $0x74,%eax,%eax
f0105247:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f010524d:	e8 15 e0 ff ff       	call   f0103267 <user_mem_check>
f0105252:	83 c4 10             	add    $0x10,%esp
f0105255:	85 c0                	test   %eax,%eax
f0105257:	0f 88 16 02 00 00    	js     f0105473 <debuginfo_eip+0x2c5>
			return -1;
		if((user_mem_check(curenv, stabstr, (stabstr_end-stabstr)*sizeof(char), PTE_U)) < 0)
f010525d:	e8 30 11 00 00       	call   f0106392 <cpunum>
f0105262:	6a 04                	push   $0x4
f0105264:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105267:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010526a:	29 ca                	sub    %ecx,%edx
f010526c:	52                   	push   %edx
f010526d:	51                   	push   %ecx
f010526e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105271:	ff b0 28 b0 21 f0    	pushl  -0xfde4fd8(%eax)
f0105277:	e8 eb df ff ff       	call   f0103267 <user_mem_check>
f010527c:	83 c4 10             	add    $0x10,%esp
f010527f:	85 c0                	test   %eax,%eax
f0105281:	79 1f                	jns    f01052a2 <debuginfo_eip+0xf4>
f0105283:	e9 f2 01 00 00       	jmp    f010547a <debuginfo_eip+0x2cc>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105288:	c7 45 bc e0 6f 11 f0 	movl   $0xf0116fe0,-0x44(%ebp)
		// Make sure the STA
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010528f:	c7 45 b8 f1 36 11 f0 	movl   $0xf01136f1,-0x48(%ebp)
	info->eip_fn_narg = 0;
		// Make sure the STA
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105296:	bf f0 36 11 f0       	mov    $0xf01136f0,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
		// Make sure the STA
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010529b:	c7 45 c0 90 88 10 f0 	movl   $0xf0108890,-0x40(%ebp)
		if((user_mem_check(curenv, stabstr, (stabstr_end-stabstr)*sizeof(char), PTE_U)) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01052a2:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01052a5:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01052a8:	0f 83 d3 01 00 00    	jae    f0105481 <debuginfo_eip+0x2d3>
f01052ae:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01052b2:	0f 85 d0 01 00 00    	jne    f0105488 <debuginfo_eip+0x2da>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01052b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01052bf:	2b 7d c0             	sub    -0x40(%ebp),%edi
f01052c2:	c1 ff 02             	sar    $0x2,%edi
f01052c5:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01052cb:	83 e8 01             	sub    $0x1,%eax
f01052ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01052d1:	83 ec 08             	sub    $0x8,%esp
f01052d4:	56                   	push   %esi
f01052d5:	6a 64                	push   $0x64
f01052d7:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01052da:	89 d1                	mov    %edx,%ecx
f01052dc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01052df:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01052e2:	89 f8                	mov    %edi,%eax
f01052e4:	e8 cf fd ff ff       	call   f01050b8 <stab_binsearch>
	if (lfile == 0)
f01052e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052ec:	83 c4 10             	add    $0x10,%esp
f01052ef:	85 c0                	test   %eax,%eax
f01052f1:	0f 84 98 01 00 00    	je     f010548f <debuginfo_eip+0x2e1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01052f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01052fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105300:	83 ec 08             	sub    $0x8,%esp
f0105303:	56                   	push   %esi
f0105304:	6a 24                	push   $0x24
f0105306:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0105309:	89 d1                	mov    %edx,%ecx
f010530b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010530e:	89 f8                	mov    %edi,%eax
f0105310:	e8 a3 fd ff ff       	call   f01050b8 <stab_binsearch>

	if (lfun <= rfun) {
f0105315:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105318:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010531b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010531e:	83 c4 10             	add    $0x10,%esp
f0105321:	39 d0                	cmp    %edx,%eax
f0105323:	7f 2b                	jg     f0105350 <debuginfo_eip+0x1a2>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105325:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105328:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010532b:	8b 11                	mov    (%ecx),%edx
f010532d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105330:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0105333:	39 fa                	cmp    %edi,%edx
f0105335:	73 06                	jae    f010533d <debuginfo_eip+0x18f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105337:	03 55 b8             	add    -0x48(%ebp),%edx
f010533a:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010533d:	8b 51 08             	mov    0x8(%ecx),%edx
f0105340:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105343:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105345:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105348:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010534b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010534e:	eb 0f                	jmp    f010535f <debuginfo_eip+0x1b1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105350:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105356:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105359:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010535c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010535f:	83 ec 08             	sub    $0x8,%esp
f0105362:	6a 3a                	push   $0x3a
f0105364:	ff 73 08             	pushl  0x8(%ebx)
f0105367:	e8 71 09 00 00       	call   f0105cdd <strfind>
f010536c:	2b 43 08             	sub    0x8(%ebx),%eax
f010536f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105372:	83 c4 08             	add    $0x8,%esp
f0105375:	56                   	push   %esi
f0105376:	6a 44                	push   $0x44
f0105378:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010537b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010537e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105381:	89 f8                	mov    %edi,%eax
f0105383:	e8 30 fd ff ff       	call   f01050b8 <stab_binsearch>
	if(lfun <= rfun) {
f0105388:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010538b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f010538e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105391:	83 c4 10             	add    $0x10,%esp
f0105394:	39 f0                	cmp    %esi,%eax
f0105396:	7f 10                	jg     f01053a8 <debuginfo_eip+0x1fa>
		info->eip_line = stabs[rline].n_desc;
f0105398:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010539b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010539e:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01053a3:	89 43 04             	mov    %eax,0x4(%ebx)
f01053a6:	eb 07                	jmp    f01053af <debuginfo_eip+0x201>
	}
	else {
		info->eip_line = -1;
f01053a8:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01053af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01053b5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01053b8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01053bb:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f01053be:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01053c2:	89 75 b0             	mov    %esi,-0x50(%ebp)
f01053c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01053c8:	eb 0a                	jmp    f01053d4 <debuginfo_eip+0x226>
f01053ca:	83 e8 01             	sub    $0x1,%eax
f01053cd:	83 ea 0c             	sub    $0xc,%edx
f01053d0:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01053d4:	39 c7                	cmp    %eax,%edi
f01053d6:	7e 08                	jle    f01053e0 <debuginfo_eip+0x232>
f01053d8:	8b 75 b0             	mov    -0x50(%ebp),%esi
f01053db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053de:	eb 4d                	jmp    f010542d <debuginfo_eip+0x27f>
	       && stabs[lline].n_type != N_SOL
f01053e0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01053e4:	80 f9 84             	cmp    $0x84,%cl
f01053e7:	75 11                	jne    f01053fa <debuginfo_eip+0x24c>
f01053e9:	8b 75 b0             	mov    -0x50(%ebp),%esi
f01053ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053ef:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01053f3:	74 1f                	je     f0105414 <debuginfo_eip+0x266>
f01053f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01053f8:	eb 1a                	jmp    f0105414 <debuginfo_eip+0x266>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01053fa:	80 f9 64             	cmp    $0x64,%cl
f01053fd:	75 cb                	jne    f01053ca <debuginfo_eip+0x21c>
f01053ff:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105403:	74 c5                	je     f01053ca <debuginfo_eip+0x21c>
f0105405:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0105408:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010540b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010540f:	74 03                	je     f0105414 <debuginfo_eip+0x266>
f0105411:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105414:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105417:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010541a:	8b 04 87             	mov    (%edi,%eax,4),%eax
f010541d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105420:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105423:	29 fa                	sub    %edi,%edx
f0105425:	39 d0                	cmp    %edx,%eax
f0105427:	73 04                	jae    f010542d <debuginfo_eip+0x27f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105429:	01 f8                	add    %edi,%eax
f010542b:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010542d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105432:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105435:	39 f7                	cmp    %esi,%edi
f0105437:	7d 62                	jge    f010549b <debuginfo_eip+0x2ed>
		for (lline = lfun + 1;
f0105439:	89 fa                	mov    %edi,%edx
f010543b:	83 c2 01             	add    $0x1,%edx
f010543e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105441:	89 d0                	mov    %edx,%eax
f0105443:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105446:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105449:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010544c:	eb 04                	jmp    f0105452 <debuginfo_eip+0x2a4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010544e:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105452:	39 c6                	cmp    %eax,%esi
f0105454:	7e 40                	jle    f0105496 <debuginfo_eip+0x2e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105456:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010545a:	83 c0 01             	add    $0x1,%eax
f010545d:	83 c2 0c             	add    $0xc,%edx
f0105460:	80 f9 a0             	cmp    $0xa0,%cl
f0105463:	74 e9                	je     f010544e <debuginfo_eip+0x2a0>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105465:	b8 00 00 00 00       	mov    $0x0,%eax
f010546a:	eb 2f                	jmp    f010549b <debuginfo_eip+0x2ed>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if((user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U)) < 0)
			return -1;
f010546c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105471:	eb 28                	jmp    f010549b <debuginfo_eip+0x2ed>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if((user_mem_check(curenv, stabs, (stab_end-stabs)*sizeof(struct Stab), PTE_U)) < 0)
			return -1;
f0105473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105478:	eb 21                	jmp    f010549b <debuginfo_eip+0x2ed>
		if((user_mem_check(curenv, stabstr, (stabstr_end-stabstr)*sizeof(char), PTE_U)) < 0)
			return -1;
f010547a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010547f:	eb 1a                	jmp    f010549b <debuginfo_eip+0x2ed>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105486:	eb 13                	jmp    f010549b <debuginfo_eip+0x2ed>
f0105488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010548d:	eb 0c                	jmp    f010549b <debuginfo_eip+0x2ed>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010548f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105494:	eb 05                	jmp    f010549b <debuginfo_eip+0x2ed>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105496:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010549b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010549e:	5b                   	pop    %ebx
f010549f:	5e                   	pop    %esi
f01054a0:	5f                   	pop    %edi
f01054a1:	5d                   	pop    %ebp
f01054a2:	c3                   	ret    

f01054a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01054a3:	55                   	push   %ebp
f01054a4:	89 e5                	mov    %esp,%ebp
f01054a6:	57                   	push   %edi
f01054a7:	56                   	push   %esi
f01054a8:	53                   	push   %ebx
f01054a9:	83 ec 1c             	sub    $0x1c,%esp
f01054ac:	89 c7                	mov    %eax,%edi
f01054ae:	89 d6                	mov    %edx,%esi
f01054b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01054b3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01054bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01054bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01054c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054c7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01054ca:	39 d3                	cmp    %edx,%ebx
f01054cc:	72 05                	jb     f01054d3 <printnum+0x30>
f01054ce:	39 45 10             	cmp    %eax,0x10(%ebp)
f01054d1:	77 45                	ja     f0105518 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01054d3:	83 ec 0c             	sub    $0xc,%esp
f01054d6:	ff 75 18             	pushl  0x18(%ebp)
f01054d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01054dc:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01054df:	53                   	push   %ebx
f01054e0:	ff 75 10             	pushl  0x10(%ebp)
f01054e3:	83 ec 08             	sub    $0x8,%esp
f01054e6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01054e9:	ff 75 e0             	pushl  -0x20(%ebp)
f01054ec:	ff 75 dc             	pushl  -0x24(%ebp)
f01054ef:	ff 75 d8             	pushl  -0x28(%ebp)
f01054f2:	e8 99 12 00 00       	call   f0106790 <__udivdi3>
f01054f7:	83 c4 18             	add    $0x18,%esp
f01054fa:	52                   	push   %edx
f01054fb:	50                   	push   %eax
f01054fc:	89 f2                	mov    %esi,%edx
f01054fe:	89 f8                	mov    %edi,%eax
f0105500:	e8 9e ff ff ff       	call   f01054a3 <printnum>
f0105505:	83 c4 20             	add    $0x20,%esp
f0105508:	eb 18                	jmp    f0105522 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010550a:	83 ec 08             	sub    $0x8,%esp
f010550d:	56                   	push   %esi
f010550e:	ff 75 18             	pushl  0x18(%ebp)
f0105511:	ff d7                	call   *%edi
f0105513:	83 c4 10             	add    $0x10,%esp
f0105516:	eb 03                	jmp    f010551b <printnum+0x78>
f0105518:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010551b:	83 eb 01             	sub    $0x1,%ebx
f010551e:	85 db                	test   %ebx,%ebx
f0105520:	7f e8                	jg     f010550a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105522:	83 ec 08             	sub    $0x8,%esp
f0105525:	56                   	push   %esi
f0105526:	83 ec 04             	sub    $0x4,%esp
f0105529:	ff 75 e4             	pushl  -0x1c(%ebp)
f010552c:	ff 75 e0             	pushl  -0x20(%ebp)
f010552f:	ff 75 dc             	pushl  -0x24(%ebp)
f0105532:	ff 75 d8             	pushl  -0x28(%ebp)
f0105535:	e8 86 13 00 00       	call   f01068c0 <__umoddi3>
f010553a:	83 c4 14             	add    $0x14,%esp
f010553d:	0f be 80 ee 82 10 f0 	movsbl -0xfef7d12(%eax),%eax
f0105544:	50                   	push   %eax
f0105545:	ff d7                	call   *%edi
}
f0105547:	83 c4 10             	add    $0x10,%esp
f010554a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010554d:	5b                   	pop    %ebx
f010554e:	5e                   	pop    %esi
f010554f:	5f                   	pop    %edi
f0105550:	5d                   	pop    %ebp
f0105551:	c3                   	ret    

f0105552 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105552:	55                   	push   %ebp
f0105553:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105555:	83 fa 01             	cmp    $0x1,%edx
f0105558:	7e 0e                	jle    f0105568 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010555a:	8b 10                	mov    (%eax),%edx
f010555c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010555f:	89 08                	mov    %ecx,(%eax)
f0105561:	8b 02                	mov    (%edx),%eax
f0105563:	8b 52 04             	mov    0x4(%edx),%edx
f0105566:	eb 22                	jmp    f010558a <getuint+0x38>
	else if (lflag)
f0105568:	85 d2                	test   %edx,%edx
f010556a:	74 10                	je     f010557c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010556c:	8b 10                	mov    (%eax),%edx
f010556e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105571:	89 08                	mov    %ecx,(%eax)
f0105573:	8b 02                	mov    (%edx),%eax
f0105575:	ba 00 00 00 00       	mov    $0x0,%edx
f010557a:	eb 0e                	jmp    f010558a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010557c:	8b 10                	mov    (%eax),%edx
f010557e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105581:	89 08                	mov    %ecx,(%eax)
f0105583:	8b 02                	mov    (%edx),%eax
f0105585:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010558a:	5d                   	pop    %ebp
f010558b:	c3                   	ret    

f010558c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010558c:	55                   	push   %ebp
f010558d:	89 e5                	mov    %esp,%ebp
f010558f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105592:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105596:	8b 10                	mov    (%eax),%edx
f0105598:	3b 50 04             	cmp    0x4(%eax),%edx
f010559b:	73 0a                	jae    f01055a7 <sprintputch+0x1b>
		*b->buf++ = ch;
f010559d:	8d 4a 01             	lea    0x1(%edx),%ecx
f01055a0:	89 08                	mov    %ecx,(%eax)
f01055a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01055a5:	88 02                	mov    %al,(%edx)
}
f01055a7:	5d                   	pop    %ebp
f01055a8:	c3                   	ret    

f01055a9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01055a9:	55                   	push   %ebp
f01055aa:	89 e5                	mov    %esp,%ebp
f01055ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01055af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01055b2:	50                   	push   %eax
f01055b3:	ff 75 10             	pushl  0x10(%ebp)
f01055b6:	ff 75 0c             	pushl  0xc(%ebp)
f01055b9:	ff 75 08             	pushl  0x8(%ebp)
f01055bc:	e8 05 00 00 00       	call   f01055c6 <vprintfmt>
	va_end(ap);
}
f01055c1:	83 c4 10             	add    $0x10,%esp
f01055c4:	c9                   	leave  
f01055c5:	c3                   	ret    

f01055c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01055c6:	55                   	push   %ebp
f01055c7:	89 e5                	mov    %esp,%ebp
f01055c9:	57                   	push   %edi
f01055ca:	56                   	push   %esi
f01055cb:	53                   	push   %ebx
f01055cc:	83 ec 2c             	sub    $0x2c,%esp
f01055cf:	8b 75 08             	mov    0x8(%ebp),%esi
f01055d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01055d5:	8b 7d 10             	mov    0x10(%ebp),%edi
f01055d8:	eb 12                	jmp    f01055ec <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01055da:	85 c0                	test   %eax,%eax
f01055dc:	0f 84 38 04 00 00    	je     f0105a1a <vprintfmt+0x454>
				return;
			putch(ch, putdat);
f01055e2:	83 ec 08             	sub    $0x8,%esp
f01055e5:	53                   	push   %ebx
f01055e6:	50                   	push   %eax
f01055e7:	ff d6                	call   *%esi
f01055e9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01055ec:	83 c7 01             	add    $0x1,%edi
f01055ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055f3:	83 f8 25             	cmp    $0x25,%eax
f01055f6:	75 e2                	jne    f01055da <vprintfmt+0x14>
f01055f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01055fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105603:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010560a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105611:	ba 00 00 00 00       	mov    $0x0,%edx
f0105616:	eb 07                	jmp    f010561f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
f010561b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010561f:	8d 47 01             	lea    0x1(%edi),%eax
f0105622:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105625:	0f b6 07             	movzbl (%edi),%eax
f0105628:	0f b6 c8             	movzbl %al,%ecx
f010562b:	83 e8 23             	sub    $0x23,%eax
f010562e:	3c 55                	cmp    $0x55,%al
f0105630:	0f 87 c9 03 00 00    	ja     f01059ff <vprintfmt+0x439>
f0105636:	0f b6 c0             	movzbl %al,%eax
f0105639:	ff 24 85 40 84 10 f0 	jmp    *-0xfef7bc0(,%eax,4)
f0105640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105643:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105647:	eb d6                	jmp    f010561f <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
f0105649:	c7 05 64 aa 21 f0 00 	movl   $0x0,0xf021aa64
f0105650:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105653:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
f0105656:	eb 94                	jmp    f01055ec <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
f0105658:	c7 05 64 aa 21 f0 01 	movl   $0x1,0xf021aa64
f010565f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
f0105665:	eb 85                	jmp    f01055ec <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
f0105667:	c7 05 64 aa 21 f0 02 	movl   $0x2,0xf021aa64
f010566e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
f0105674:	e9 73 ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
f0105679:	c7 05 64 aa 21 f0 03 	movl   $0x3,0xf021aa64
f0105680:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
f0105686:	e9 61 ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
f010568b:	c7 05 64 aa 21 f0 04 	movl   $0x4,0xf021aa64
f0105692:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
f0105698:	e9 4f ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
f010569d:	c7 05 64 aa 21 f0 05 	movl   $0x5,0xf021aa64
f01056a4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
f01056aa:	e9 3d ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
f01056af:	c7 05 64 aa 21 f0 06 	movl   $0x6,0xf021aa64
f01056b6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
f01056bc:	e9 2b ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
f01056c1:	c7 05 64 aa 21 f0 07 	movl   $0x7,0xf021aa64
f01056c8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
f01056ce:	e9 19 ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
f01056d3:	c7 05 64 aa 21 f0 08 	movl   $0x8,0xf021aa64
f01056da:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
f01056e0:	e9 07 ff ff ff       	jmp    f01055ec <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
f01056e5:	c7 05 64 aa 21 f0 09 	movl   $0x9,0xf021aa64
f01056ec:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
f01056f2:	e9 f5 fe ff ff       	jmp    f01055ec <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01056fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01056ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105702:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105705:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105709:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010570c:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010570f:	83 fa 09             	cmp    $0x9,%edx
f0105712:	77 3f                	ja     f0105753 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105714:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105717:	eb e9                	jmp    f0105702 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105719:	8b 45 14             	mov    0x14(%ebp),%eax
f010571c:	8d 48 04             	lea    0x4(%eax),%ecx
f010571f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105722:	8b 00                	mov    (%eax),%eax
f0105724:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010572a:	eb 2d                	jmp    f0105759 <vprintfmt+0x193>
f010572c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010572f:	85 c0                	test   %eax,%eax
f0105731:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105736:	0f 49 c8             	cmovns %eax,%ecx
f0105739:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010573c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010573f:	e9 db fe ff ff       	jmp    f010561f <vprintfmt+0x59>
f0105744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105747:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010574e:	e9 cc fe ff ff       	jmp    f010561f <vprintfmt+0x59>
f0105753:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105756:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105759:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010575d:	0f 89 bc fe ff ff    	jns    f010561f <vprintfmt+0x59>
				width = precision, precision = -1;
f0105763:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105766:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105769:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105770:	e9 aa fe ff ff       	jmp    f010561f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105775:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010577b:	e9 9f fe ff ff       	jmp    f010561f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105780:	8b 45 14             	mov    0x14(%ebp),%eax
f0105783:	8d 50 04             	lea    0x4(%eax),%edx
f0105786:	89 55 14             	mov    %edx,0x14(%ebp)
f0105789:	83 ec 08             	sub    $0x8,%esp
f010578c:	53                   	push   %ebx
f010578d:	ff 30                	pushl  (%eax)
f010578f:	ff d6                	call   *%esi
			break;
f0105791:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105797:	e9 50 fe ff ff       	jmp    f01055ec <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010579c:	8b 45 14             	mov    0x14(%ebp),%eax
f010579f:	8d 50 04             	lea    0x4(%eax),%edx
f01057a2:	89 55 14             	mov    %edx,0x14(%ebp)
f01057a5:	8b 00                	mov    (%eax),%eax
f01057a7:	99                   	cltd   
f01057a8:	31 d0                	xor    %edx,%eax
f01057aa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01057ac:	83 f8 0f             	cmp    $0xf,%eax
f01057af:	7f 0b                	jg     f01057bc <vprintfmt+0x1f6>
f01057b1:	8b 14 85 a0 85 10 f0 	mov    -0xfef7a60(,%eax,4),%edx
f01057b8:	85 d2                	test   %edx,%edx
f01057ba:	75 18                	jne    f01057d4 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
f01057bc:	50                   	push   %eax
f01057bd:	68 06 83 10 f0       	push   $0xf0108306
f01057c2:	53                   	push   %ebx
f01057c3:	56                   	push   %esi
f01057c4:	e8 e0 fd ff ff       	call   f01055a9 <printfmt>
f01057c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01057cf:	e9 18 fe ff ff       	jmp    f01055ec <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01057d4:	52                   	push   %edx
f01057d5:	68 29 7b 10 f0       	push   $0xf0107b29
f01057da:	53                   	push   %ebx
f01057db:	56                   	push   %esi
f01057dc:	e8 c8 fd ff ff       	call   f01055a9 <printfmt>
f01057e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01057e7:	e9 00 fe ff ff       	jmp    f01055ec <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01057ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01057ef:	8d 50 04             	lea    0x4(%eax),%edx
f01057f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01057f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01057f7:	85 ff                	test   %edi,%edi
f01057f9:	b8 ff 82 10 f0       	mov    $0xf01082ff,%eax
f01057fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105801:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105805:	0f 8e 94 00 00 00    	jle    f010589f <vprintfmt+0x2d9>
f010580b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010580f:	0f 84 98 00 00 00    	je     f01058ad <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105815:	83 ec 08             	sub    $0x8,%esp
f0105818:	ff 75 d0             	pushl  -0x30(%ebp)
f010581b:	57                   	push   %edi
f010581c:	e8 72 03 00 00       	call   f0105b93 <strnlen>
f0105821:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105824:	29 c1                	sub    %eax,%ecx
f0105826:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105829:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010582c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105830:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105833:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105836:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105838:	eb 0f                	jmp    f0105849 <vprintfmt+0x283>
					putch(padc, putdat);
f010583a:	83 ec 08             	sub    $0x8,%esp
f010583d:	53                   	push   %ebx
f010583e:	ff 75 e0             	pushl  -0x20(%ebp)
f0105841:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105843:	83 ef 01             	sub    $0x1,%edi
f0105846:	83 c4 10             	add    $0x10,%esp
f0105849:	85 ff                	test   %edi,%edi
f010584b:	7f ed                	jg     f010583a <vprintfmt+0x274>
f010584d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105850:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105853:	85 c9                	test   %ecx,%ecx
f0105855:	b8 00 00 00 00       	mov    $0x0,%eax
f010585a:	0f 49 c1             	cmovns %ecx,%eax
f010585d:	29 c1                	sub    %eax,%ecx
f010585f:	89 75 08             	mov    %esi,0x8(%ebp)
f0105862:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105865:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105868:	89 cb                	mov    %ecx,%ebx
f010586a:	eb 4d                	jmp    f01058b9 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010586c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105870:	74 1b                	je     f010588d <vprintfmt+0x2c7>
f0105872:	0f be c0             	movsbl %al,%eax
f0105875:	83 e8 20             	sub    $0x20,%eax
f0105878:	83 f8 5e             	cmp    $0x5e,%eax
f010587b:	76 10                	jbe    f010588d <vprintfmt+0x2c7>
					putch('?', putdat);
f010587d:	83 ec 08             	sub    $0x8,%esp
f0105880:	ff 75 0c             	pushl  0xc(%ebp)
f0105883:	6a 3f                	push   $0x3f
f0105885:	ff 55 08             	call   *0x8(%ebp)
f0105888:	83 c4 10             	add    $0x10,%esp
f010588b:	eb 0d                	jmp    f010589a <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
f010588d:	83 ec 08             	sub    $0x8,%esp
f0105890:	ff 75 0c             	pushl  0xc(%ebp)
f0105893:	52                   	push   %edx
f0105894:	ff 55 08             	call   *0x8(%ebp)
f0105897:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010589a:	83 eb 01             	sub    $0x1,%ebx
f010589d:	eb 1a                	jmp    f01058b9 <vprintfmt+0x2f3>
f010589f:	89 75 08             	mov    %esi,0x8(%ebp)
f01058a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01058a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01058a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01058ab:	eb 0c                	jmp    f01058b9 <vprintfmt+0x2f3>
f01058ad:	89 75 08             	mov    %esi,0x8(%ebp)
f01058b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01058b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01058b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01058b9:	83 c7 01             	add    $0x1,%edi
f01058bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01058c0:	0f be d0             	movsbl %al,%edx
f01058c3:	85 d2                	test   %edx,%edx
f01058c5:	74 23                	je     f01058ea <vprintfmt+0x324>
f01058c7:	85 f6                	test   %esi,%esi
f01058c9:	78 a1                	js     f010586c <vprintfmt+0x2a6>
f01058cb:	83 ee 01             	sub    $0x1,%esi
f01058ce:	79 9c                	jns    f010586c <vprintfmt+0x2a6>
f01058d0:	89 df                	mov    %ebx,%edi
f01058d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01058d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058d8:	eb 18                	jmp    f01058f2 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01058da:	83 ec 08             	sub    $0x8,%esp
f01058dd:	53                   	push   %ebx
f01058de:	6a 20                	push   $0x20
f01058e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01058e2:	83 ef 01             	sub    $0x1,%edi
f01058e5:	83 c4 10             	add    $0x10,%esp
f01058e8:	eb 08                	jmp    f01058f2 <vprintfmt+0x32c>
f01058ea:	89 df                	mov    %ebx,%edi
f01058ec:	8b 75 08             	mov    0x8(%ebp),%esi
f01058ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058f2:	85 ff                	test   %edi,%edi
f01058f4:	7f e4                	jg     f01058da <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01058f9:	e9 ee fc ff ff       	jmp    f01055ec <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01058fe:	83 fa 01             	cmp    $0x1,%edx
f0105901:	7e 16                	jle    f0105919 <vprintfmt+0x353>
		return va_arg(*ap, long long);
f0105903:	8b 45 14             	mov    0x14(%ebp),%eax
f0105906:	8d 50 08             	lea    0x8(%eax),%edx
f0105909:	89 55 14             	mov    %edx,0x14(%ebp)
f010590c:	8b 50 04             	mov    0x4(%eax),%edx
f010590f:	8b 00                	mov    (%eax),%eax
f0105911:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105914:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105917:	eb 32                	jmp    f010594b <vprintfmt+0x385>
	else if (lflag)
f0105919:	85 d2                	test   %edx,%edx
f010591b:	74 18                	je     f0105935 <vprintfmt+0x36f>
		return va_arg(*ap, long);
f010591d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105920:	8d 50 04             	lea    0x4(%eax),%edx
f0105923:	89 55 14             	mov    %edx,0x14(%ebp)
f0105926:	8b 00                	mov    (%eax),%eax
f0105928:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010592b:	89 c1                	mov    %eax,%ecx
f010592d:	c1 f9 1f             	sar    $0x1f,%ecx
f0105930:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105933:	eb 16                	jmp    f010594b <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
f0105935:	8b 45 14             	mov    0x14(%ebp),%eax
f0105938:	8d 50 04             	lea    0x4(%eax),%edx
f010593b:	89 55 14             	mov    %edx,0x14(%ebp)
f010593e:	8b 00                	mov    (%eax),%eax
f0105940:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105943:	89 c1                	mov    %eax,%ecx
f0105945:	c1 f9 1f             	sar    $0x1f,%ecx
f0105948:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010594b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010594e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105951:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105956:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010595a:	79 6f                	jns    f01059cb <vprintfmt+0x405>
				putch('-', putdat);
f010595c:	83 ec 08             	sub    $0x8,%esp
f010595f:	53                   	push   %ebx
f0105960:	6a 2d                	push   $0x2d
f0105962:	ff d6                	call   *%esi
				num = -(long long) num;
f0105964:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105967:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010596a:	f7 d8                	neg    %eax
f010596c:	83 d2 00             	adc    $0x0,%edx
f010596f:	f7 da                	neg    %edx
f0105971:	83 c4 10             	add    $0x10,%esp
f0105974:	eb 55                	jmp    f01059cb <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105976:	8d 45 14             	lea    0x14(%ebp),%eax
f0105979:	e8 d4 fb ff ff       	call   f0105552 <getuint>
			base = 10;
f010597e:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f0105983:	eb 46                	jmp    f01059cb <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105985:	8d 45 14             	lea    0x14(%ebp),%eax
f0105988:	e8 c5 fb ff ff       	call   f0105552 <getuint>
			base = 8;
f010598d:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
f0105992:	eb 37                	jmp    f01059cb <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
f0105994:	83 ec 08             	sub    $0x8,%esp
f0105997:	53                   	push   %ebx
f0105998:	6a 30                	push   $0x30
f010599a:	ff d6                	call   *%esi
			putch('x', putdat);
f010599c:	83 c4 08             	add    $0x8,%esp
f010599f:	53                   	push   %ebx
f01059a0:	6a 78                	push   $0x78
f01059a2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01059a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01059a7:	8d 50 04             	lea    0x4(%eax),%edx
f01059aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01059ad:	8b 00                	mov    (%eax),%eax
f01059af:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01059b4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01059b7:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f01059bc:	eb 0d                	jmp    f01059cb <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01059be:	8d 45 14             	lea    0x14(%ebp),%eax
f01059c1:	e8 8c fb ff ff       	call   f0105552 <getuint>
			base = 16;
f01059c6:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01059cb:	83 ec 0c             	sub    $0xc,%esp
f01059ce:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f01059d2:	51                   	push   %ecx
f01059d3:	ff 75 e0             	pushl  -0x20(%ebp)
f01059d6:	57                   	push   %edi
f01059d7:	52                   	push   %edx
f01059d8:	50                   	push   %eax
f01059d9:	89 da                	mov    %ebx,%edx
f01059db:	89 f0                	mov    %esi,%eax
f01059dd:	e8 c1 fa ff ff       	call   f01054a3 <printnum>
			break;
f01059e2:	83 c4 20             	add    $0x20,%esp
f01059e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059e8:	e9 ff fb ff ff       	jmp    f01055ec <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01059ed:	83 ec 08             	sub    $0x8,%esp
f01059f0:	53                   	push   %ebx
f01059f1:	51                   	push   %ecx
f01059f2:	ff d6                	call   *%esi
			break;
f01059f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01059fa:	e9 ed fb ff ff       	jmp    f01055ec <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01059ff:	83 ec 08             	sub    $0x8,%esp
f0105a02:	53                   	push   %ebx
f0105a03:	6a 25                	push   $0x25
f0105a05:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a07:	83 c4 10             	add    $0x10,%esp
f0105a0a:	eb 03                	jmp    f0105a0f <vprintfmt+0x449>
f0105a0c:	83 ef 01             	sub    $0x1,%edi
f0105a0f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105a13:	75 f7                	jne    f0105a0c <vprintfmt+0x446>
f0105a15:	e9 d2 fb ff ff       	jmp    f01055ec <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a1d:	5b                   	pop    %ebx
f0105a1e:	5e                   	pop    %esi
f0105a1f:	5f                   	pop    %edi
f0105a20:	5d                   	pop    %ebp
f0105a21:	c3                   	ret    

f0105a22 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a22:	55                   	push   %ebp
f0105a23:	89 e5                	mov    %esp,%ebp
f0105a25:	83 ec 18             	sub    $0x18,%esp
f0105a28:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105a2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105a31:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105a35:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105a38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105a3f:	85 c0                	test   %eax,%eax
f0105a41:	74 26                	je     f0105a69 <vsnprintf+0x47>
f0105a43:	85 d2                	test   %edx,%edx
f0105a45:	7e 22                	jle    f0105a69 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105a47:	ff 75 14             	pushl  0x14(%ebp)
f0105a4a:	ff 75 10             	pushl  0x10(%ebp)
f0105a4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105a50:	50                   	push   %eax
f0105a51:	68 8c 55 10 f0       	push   $0xf010558c
f0105a56:	e8 6b fb ff ff       	call   f01055c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a5e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105a64:	83 c4 10             	add    $0x10,%esp
f0105a67:	eb 05                	jmp    f0105a6e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105a69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105a6e:	c9                   	leave  
f0105a6f:	c3                   	ret    

f0105a70 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105a70:	55                   	push   %ebp
f0105a71:	89 e5                	mov    %esp,%ebp
f0105a73:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105a76:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105a79:	50                   	push   %eax
f0105a7a:	ff 75 10             	pushl  0x10(%ebp)
f0105a7d:	ff 75 0c             	pushl  0xc(%ebp)
f0105a80:	ff 75 08             	pushl  0x8(%ebp)
f0105a83:	e8 9a ff ff ff       	call   f0105a22 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105a88:	c9                   	leave  
f0105a89:	c3                   	ret    

f0105a8a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105a8a:	55                   	push   %ebp
f0105a8b:	89 e5                	mov    %esp,%ebp
f0105a8d:	57                   	push   %edi
f0105a8e:	56                   	push   %esi
f0105a8f:	53                   	push   %ebx
f0105a90:	83 ec 0c             	sub    $0xc,%esp
f0105a93:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105a96:	85 c0                	test   %eax,%eax
f0105a98:	74 11                	je     f0105aab <readline+0x21>
		cprintf("%s", prompt);
f0105a9a:	83 ec 08             	sub    $0x8,%esp
f0105a9d:	50                   	push   %eax
f0105a9e:	68 29 7b 10 f0       	push   $0xf0107b29
f0105aa3:	e8 cd e1 ff ff       	call   f0103c75 <cprintf>
f0105aa8:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105aab:	83 ec 0c             	sub    $0xc,%esp
f0105aae:	6a 00                	push   $0x0
f0105ab0:	e8 12 ad ff ff       	call   f01007c7 <iscons>
f0105ab5:	89 c7                	mov    %eax,%edi
f0105ab7:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105aba:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105abf:	e8 f2 ac ff ff       	call   f01007b6 <getchar>
f0105ac4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105ac6:	85 c0                	test   %eax,%eax
f0105ac8:	79 29                	jns    f0105af3 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105aca:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105acf:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105ad2:	0f 84 9b 00 00 00    	je     f0105b73 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105ad8:	83 ec 08             	sub    $0x8,%esp
f0105adb:	53                   	push   %ebx
f0105adc:	68 ff 85 10 f0       	push   $0xf01085ff
f0105ae1:	e8 8f e1 ff ff       	call   f0103c75 <cprintf>
f0105ae6:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105ae9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aee:	e9 80 00 00 00       	jmp    f0105b73 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105af3:	83 f8 08             	cmp    $0x8,%eax
f0105af6:	0f 94 c2             	sete   %dl
f0105af9:	83 f8 7f             	cmp    $0x7f,%eax
f0105afc:	0f 94 c0             	sete   %al
f0105aff:	08 c2                	or     %al,%dl
f0105b01:	74 1a                	je     f0105b1d <readline+0x93>
f0105b03:	85 f6                	test   %esi,%esi
f0105b05:	7e 16                	jle    f0105b1d <readline+0x93>
			if (echoing)
f0105b07:	85 ff                	test   %edi,%edi
f0105b09:	74 0d                	je     f0105b18 <readline+0x8e>
				cputchar('\b');
f0105b0b:	83 ec 0c             	sub    $0xc,%esp
f0105b0e:	6a 08                	push   $0x8
f0105b10:	e8 91 ac ff ff       	call   f01007a6 <cputchar>
f0105b15:	83 c4 10             	add    $0x10,%esp
			i--;
f0105b18:	83 ee 01             	sub    $0x1,%esi
f0105b1b:	eb a2                	jmp    f0105abf <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b1d:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b20:	7e 26                	jle    f0105b48 <readline+0xbe>
f0105b22:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b28:	7f 1e                	jg     f0105b48 <readline+0xbe>
			if (echoing)
f0105b2a:	85 ff                	test   %edi,%edi
f0105b2c:	74 0c                	je     f0105b3a <readline+0xb0>
				cputchar(c);
f0105b2e:	83 ec 0c             	sub    $0xc,%esp
f0105b31:	53                   	push   %ebx
f0105b32:	e8 6f ac ff ff       	call   f01007a6 <cputchar>
f0105b37:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105b3a:	88 9e 80 aa 21 f0    	mov    %bl,-0xfde5580(%esi)
f0105b40:	8d 76 01             	lea    0x1(%esi),%esi
f0105b43:	e9 77 ff ff ff       	jmp    f0105abf <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105b48:	83 fb 0a             	cmp    $0xa,%ebx
f0105b4b:	74 09                	je     f0105b56 <readline+0xcc>
f0105b4d:	83 fb 0d             	cmp    $0xd,%ebx
f0105b50:	0f 85 69 ff ff ff    	jne    f0105abf <readline+0x35>
			if (echoing)
f0105b56:	85 ff                	test   %edi,%edi
f0105b58:	74 0d                	je     f0105b67 <readline+0xdd>
				cputchar('\n');
f0105b5a:	83 ec 0c             	sub    $0xc,%esp
f0105b5d:	6a 0a                	push   $0xa
f0105b5f:	e8 42 ac ff ff       	call   f01007a6 <cputchar>
f0105b64:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105b67:	c6 86 80 aa 21 f0 00 	movb   $0x0,-0xfde5580(%esi)
			return buf;
f0105b6e:	b8 80 aa 21 f0       	mov    $0xf021aa80,%eax
		}
	}
}
f0105b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b76:	5b                   	pop    %ebx
f0105b77:	5e                   	pop    %esi
f0105b78:	5f                   	pop    %edi
f0105b79:	5d                   	pop    %ebp
f0105b7a:	c3                   	ret    

f0105b7b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105b7b:	55                   	push   %ebp
f0105b7c:	89 e5                	mov    %esp,%ebp
f0105b7e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b81:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b86:	eb 03                	jmp    f0105b8b <strlen+0x10>
		n++;
f0105b88:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105b8b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105b8f:	75 f7                	jne    f0105b88 <strlen+0xd>
		n++;
	return n;
}
f0105b91:	5d                   	pop    %ebp
f0105b92:	c3                   	ret    

f0105b93 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105b93:	55                   	push   %ebp
f0105b94:	89 e5                	mov    %esp,%ebp
f0105b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b99:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105b9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ba1:	eb 03                	jmp    f0105ba6 <strnlen+0x13>
		n++;
f0105ba3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ba6:	39 c2                	cmp    %eax,%edx
f0105ba8:	74 08                	je     f0105bb2 <strnlen+0x1f>
f0105baa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105bae:	75 f3                	jne    f0105ba3 <strnlen+0x10>
f0105bb0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105bb2:	5d                   	pop    %ebp
f0105bb3:	c3                   	ret    

f0105bb4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105bb4:	55                   	push   %ebp
f0105bb5:	89 e5                	mov    %esp,%ebp
f0105bb7:	53                   	push   %ebx
f0105bb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105bbe:	89 c2                	mov    %eax,%edx
f0105bc0:	83 c2 01             	add    $0x1,%edx
f0105bc3:	83 c1 01             	add    $0x1,%ecx
f0105bc6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105bca:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105bcd:	84 db                	test   %bl,%bl
f0105bcf:	75 ef                	jne    f0105bc0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105bd1:	5b                   	pop    %ebx
f0105bd2:	5d                   	pop    %ebp
f0105bd3:	c3                   	ret    

f0105bd4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105bd4:	55                   	push   %ebp
f0105bd5:	89 e5                	mov    %esp,%ebp
f0105bd7:	53                   	push   %ebx
f0105bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105bdb:	53                   	push   %ebx
f0105bdc:	e8 9a ff ff ff       	call   f0105b7b <strlen>
f0105be1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105be4:	ff 75 0c             	pushl  0xc(%ebp)
f0105be7:	01 d8                	add    %ebx,%eax
f0105be9:	50                   	push   %eax
f0105bea:	e8 c5 ff ff ff       	call   f0105bb4 <strcpy>
	return dst;
}
f0105bef:	89 d8                	mov    %ebx,%eax
f0105bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105bf4:	c9                   	leave  
f0105bf5:	c3                   	ret    

f0105bf6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105bf6:	55                   	push   %ebp
f0105bf7:	89 e5                	mov    %esp,%ebp
f0105bf9:	56                   	push   %esi
f0105bfa:	53                   	push   %ebx
f0105bfb:	8b 75 08             	mov    0x8(%ebp),%esi
f0105bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c01:	89 f3                	mov    %esi,%ebx
f0105c03:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c06:	89 f2                	mov    %esi,%edx
f0105c08:	eb 0f                	jmp    f0105c19 <strncpy+0x23>
		*dst++ = *src;
f0105c0a:	83 c2 01             	add    $0x1,%edx
f0105c0d:	0f b6 01             	movzbl (%ecx),%eax
f0105c10:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c13:	80 39 01             	cmpb   $0x1,(%ecx)
f0105c16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c19:	39 da                	cmp    %ebx,%edx
f0105c1b:	75 ed                	jne    f0105c0a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105c1d:	89 f0                	mov    %esi,%eax
f0105c1f:	5b                   	pop    %ebx
f0105c20:	5e                   	pop    %esi
f0105c21:	5d                   	pop    %ebp
f0105c22:	c3                   	ret    

f0105c23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c23:	55                   	push   %ebp
f0105c24:	89 e5                	mov    %esp,%ebp
f0105c26:	56                   	push   %esi
f0105c27:	53                   	push   %ebx
f0105c28:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c2e:	8b 55 10             	mov    0x10(%ebp),%edx
f0105c31:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c33:	85 d2                	test   %edx,%edx
f0105c35:	74 21                	je     f0105c58 <strlcpy+0x35>
f0105c37:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105c3b:	89 f2                	mov    %esi,%edx
f0105c3d:	eb 09                	jmp    f0105c48 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105c3f:	83 c2 01             	add    $0x1,%edx
f0105c42:	83 c1 01             	add    $0x1,%ecx
f0105c45:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105c48:	39 c2                	cmp    %eax,%edx
f0105c4a:	74 09                	je     f0105c55 <strlcpy+0x32>
f0105c4c:	0f b6 19             	movzbl (%ecx),%ebx
f0105c4f:	84 db                	test   %bl,%bl
f0105c51:	75 ec                	jne    f0105c3f <strlcpy+0x1c>
f0105c53:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105c55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105c58:	29 f0                	sub    %esi,%eax
}
f0105c5a:	5b                   	pop    %ebx
f0105c5b:	5e                   	pop    %esi
f0105c5c:	5d                   	pop    %ebp
f0105c5d:	c3                   	ret    

f0105c5e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105c5e:	55                   	push   %ebp
f0105c5f:	89 e5                	mov    %esp,%ebp
f0105c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c64:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105c67:	eb 06                	jmp    f0105c6f <strcmp+0x11>
		p++, q++;
f0105c69:	83 c1 01             	add    $0x1,%ecx
f0105c6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105c6f:	0f b6 01             	movzbl (%ecx),%eax
f0105c72:	84 c0                	test   %al,%al
f0105c74:	74 04                	je     f0105c7a <strcmp+0x1c>
f0105c76:	3a 02                	cmp    (%edx),%al
f0105c78:	74 ef                	je     f0105c69 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105c7a:	0f b6 c0             	movzbl %al,%eax
f0105c7d:	0f b6 12             	movzbl (%edx),%edx
f0105c80:	29 d0                	sub    %edx,%eax
}
f0105c82:	5d                   	pop    %ebp
f0105c83:	c3                   	ret    

f0105c84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105c84:	55                   	push   %ebp
f0105c85:	89 e5                	mov    %esp,%ebp
f0105c87:	53                   	push   %ebx
f0105c88:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c8e:	89 c3                	mov    %eax,%ebx
f0105c90:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105c93:	eb 06                	jmp    f0105c9b <strncmp+0x17>
		n--, p++, q++;
f0105c95:	83 c0 01             	add    $0x1,%eax
f0105c98:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105c9b:	39 d8                	cmp    %ebx,%eax
f0105c9d:	74 15                	je     f0105cb4 <strncmp+0x30>
f0105c9f:	0f b6 08             	movzbl (%eax),%ecx
f0105ca2:	84 c9                	test   %cl,%cl
f0105ca4:	74 04                	je     f0105caa <strncmp+0x26>
f0105ca6:	3a 0a                	cmp    (%edx),%cl
f0105ca8:	74 eb                	je     f0105c95 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105caa:	0f b6 00             	movzbl (%eax),%eax
f0105cad:	0f b6 12             	movzbl (%edx),%edx
f0105cb0:	29 d0                	sub    %edx,%eax
f0105cb2:	eb 05                	jmp    f0105cb9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105cb4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105cb9:	5b                   	pop    %ebx
f0105cba:	5d                   	pop    %ebp
f0105cbb:	c3                   	ret    

f0105cbc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105cbc:	55                   	push   %ebp
f0105cbd:	89 e5                	mov    %esp,%ebp
f0105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cc2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105cc6:	eb 07                	jmp    f0105ccf <strchr+0x13>
		if (*s == c)
f0105cc8:	38 ca                	cmp    %cl,%dl
f0105cca:	74 0f                	je     f0105cdb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105ccc:	83 c0 01             	add    $0x1,%eax
f0105ccf:	0f b6 10             	movzbl (%eax),%edx
f0105cd2:	84 d2                	test   %dl,%dl
f0105cd4:	75 f2                	jne    f0105cc8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cdb:	5d                   	pop    %ebp
f0105cdc:	c3                   	ret    

f0105cdd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105cdd:	55                   	push   %ebp
f0105cde:	89 e5                	mov    %esp,%ebp
f0105ce0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ce3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ce7:	eb 03                	jmp    f0105cec <strfind+0xf>
f0105ce9:	83 c0 01             	add    $0x1,%eax
f0105cec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105cef:	38 ca                	cmp    %cl,%dl
f0105cf1:	74 04                	je     f0105cf7 <strfind+0x1a>
f0105cf3:	84 d2                	test   %dl,%dl
f0105cf5:	75 f2                	jne    f0105ce9 <strfind+0xc>
			break;
	return (char *) s;
}
f0105cf7:	5d                   	pop    %ebp
f0105cf8:	c3                   	ret    

f0105cf9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105cf9:	55                   	push   %ebp
f0105cfa:	89 e5                	mov    %esp,%ebp
f0105cfc:	57                   	push   %edi
f0105cfd:	56                   	push   %esi
f0105cfe:	53                   	push   %ebx
f0105cff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d05:	85 c9                	test   %ecx,%ecx
f0105d07:	74 36                	je     f0105d3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d09:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d0f:	75 28                	jne    f0105d39 <memset+0x40>
f0105d11:	f6 c1 03             	test   $0x3,%cl
f0105d14:	75 23                	jne    f0105d39 <memset+0x40>
		c &= 0xFF;
f0105d16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d1a:	89 d3                	mov    %edx,%ebx
f0105d1c:	c1 e3 08             	shl    $0x8,%ebx
f0105d1f:	89 d6                	mov    %edx,%esi
f0105d21:	c1 e6 18             	shl    $0x18,%esi
f0105d24:	89 d0                	mov    %edx,%eax
f0105d26:	c1 e0 10             	shl    $0x10,%eax
f0105d29:	09 f0                	or     %esi,%eax
f0105d2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105d2d:	89 d8                	mov    %ebx,%eax
f0105d2f:	09 d0                	or     %edx,%eax
f0105d31:	c1 e9 02             	shr    $0x2,%ecx
f0105d34:	fc                   	cld    
f0105d35:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d37:	eb 06                	jmp    f0105d3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d3c:	fc                   	cld    
f0105d3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d3f:	89 f8                	mov    %edi,%eax
f0105d41:	5b                   	pop    %ebx
f0105d42:	5e                   	pop    %esi
f0105d43:	5f                   	pop    %edi
f0105d44:	5d                   	pop    %ebp
f0105d45:	c3                   	ret    

f0105d46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d46:	55                   	push   %ebp
f0105d47:	89 e5                	mov    %esp,%ebp
f0105d49:	57                   	push   %edi
f0105d4a:	56                   	push   %esi
f0105d4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d4e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d54:	39 c6                	cmp    %eax,%esi
f0105d56:	73 35                	jae    f0105d8d <memmove+0x47>
f0105d58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d5b:	39 d0                	cmp    %edx,%eax
f0105d5d:	73 2e                	jae    f0105d8d <memmove+0x47>
		s += n;
		d += n;
f0105d5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d62:	89 d6                	mov    %edx,%esi
f0105d64:	09 fe                	or     %edi,%esi
f0105d66:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105d6c:	75 13                	jne    f0105d81 <memmove+0x3b>
f0105d6e:	f6 c1 03             	test   $0x3,%cl
f0105d71:	75 0e                	jne    f0105d81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105d73:	83 ef 04             	sub    $0x4,%edi
f0105d76:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105d79:	c1 e9 02             	shr    $0x2,%ecx
f0105d7c:	fd                   	std    
f0105d7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105d7f:	eb 09                	jmp    f0105d8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105d81:	83 ef 01             	sub    $0x1,%edi
f0105d84:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105d87:	fd                   	std    
f0105d88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105d8a:	fc                   	cld    
f0105d8b:	eb 1d                	jmp    f0105daa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d8d:	89 f2                	mov    %esi,%edx
f0105d8f:	09 c2                	or     %eax,%edx
f0105d91:	f6 c2 03             	test   $0x3,%dl
f0105d94:	75 0f                	jne    f0105da5 <memmove+0x5f>
f0105d96:	f6 c1 03             	test   $0x3,%cl
f0105d99:	75 0a                	jne    f0105da5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105d9b:	c1 e9 02             	shr    $0x2,%ecx
f0105d9e:	89 c7                	mov    %eax,%edi
f0105da0:	fc                   	cld    
f0105da1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105da3:	eb 05                	jmp    f0105daa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105da5:	89 c7                	mov    %eax,%edi
f0105da7:	fc                   	cld    
f0105da8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105daa:	5e                   	pop    %esi
f0105dab:	5f                   	pop    %edi
f0105dac:	5d                   	pop    %ebp
f0105dad:	c3                   	ret    

f0105dae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105dae:	55                   	push   %ebp
f0105daf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105db1:	ff 75 10             	pushl  0x10(%ebp)
f0105db4:	ff 75 0c             	pushl  0xc(%ebp)
f0105db7:	ff 75 08             	pushl  0x8(%ebp)
f0105dba:	e8 87 ff ff ff       	call   f0105d46 <memmove>
}
f0105dbf:	c9                   	leave  
f0105dc0:	c3                   	ret    

f0105dc1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105dc1:	55                   	push   %ebp
f0105dc2:	89 e5                	mov    %esp,%ebp
f0105dc4:	56                   	push   %esi
f0105dc5:	53                   	push   %ebx
f0105dc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105dcc:	89 c6                	mov    %eax,%esi
f0105dce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105dd1:	eb 1a                	jmp    f0105ded <memcmp+0x2c>
		if (*s1 != *s2)
f0105dd3:	0f b6 08             	movzbl (%eax),%ecx
f0105dd6:	0f b6 1a             	movzbl (%edx),%ebx
f0105dd9:	38 d9                	cmp    %bl,%cl
f0105ddb:	74 0a                	je     f0105de7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105ddd:	0f b6 c1             	movzbl %cl,%eax
f0105de0:	0f b6 db             	movzbl %bl,%ebx
f0105de3:	29 d8                	sub    %ebx,%eax
f0105de5:	eb 0f                	jmp    f0105df6 <memcmp+0x35>
		s1++, s2++;
f0105de7:	83 c0 01             	add    $0x1,%eax
f0105dea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ded:	39 f0                	cmp    %esi,%eax
f0105def:	75 e2                	jne    f0105dd3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105df6:	5b                   	pop    %ebx
f0105df7:	5e                   	pop    %esi
f0105df8:	5d                   	pop    %ebp
f0105df9:	c3                   	ret    

f0105dfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105dfa:	55                   	push   %ebp
f0105dfb:	89 e5                	mov    %esp,%ebp
f0105dfd:	53                   	push   %ebx
f0105dfe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105e01:	89 c1                	mov    %eax,%ecx
f0105e03:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e0a:	eb 0a                	jmp    f0105e16 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e0c:	0f b6 10             	movzbl (%eax),%edx
f0105e0f:	39 da                	cmp    %ebx,%edx
f0105e11:	74 07                	je     f0105e1a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e13:	83 c0 01             	add    $0x1,%eax
f0105e16:	39 c8                	cmp    %ecx,%eax
f0105e18:	72 f2                	jb     f0105e0c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105e1a:	5b                   	pop    %ebx
f0105e1b:	5d                   	pop    %ebp
f0105e1c:	c3                   	ret    

f0105e1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e1d:	55                   	push   %ebp
f0105e1e:	89 e5                	mov    %esp,%ebp
f0105e20:	57                   	push   %edi
f0105e21:	56                   	push   %esi
f0105e22:	53                   	push   %ebx
f0105e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e29:	eb 03                	jmp    f0105e2e <strtol+0x11>
		s++;
f0105e2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e2e:	0f b6 01             	movzbl (%ecx),%eax
f0105e31:	3c 20                	cmp    $0x20,%al
f0105e33:	74 f6                	je     f0105e2b <strtol+0xe>
f0105e35:	3c 09                	cmp    $0x9,%al
f0105e37:	74 f2                	je     f0105e2b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105e39:	3c 2b                	cmp    $0x2b,%al
f0105e3b:	75 0a                	jne    f0105e47 <strtol+0x2a>
		s++;
f0105e3d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e40:	bf 00 00 00 00       	mov    $0x0,%edi
f0105e45:	eb 11                	jmp    f0105e58 <strtol+0x3b>
f0105e47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105e4c:	3c 2d                	cmp    $0x2d,%al
f0105e4e:	75 08                	jne    f0105e58 <strtol+0x3b>
		s++, neg = 1;
f0105e50:	83 c1 01             	add    $0x1,%ecx
f0105e53:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105e58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105e5e:	75 15                	jne    f0105e75 <strtol+0x58>
f0105e60:	80 39 30             	cmpb   $0x30,(%ecx)
f0105e63:	75 10                	jne    f0105e75 <strtol+0x58>
f0105e65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105e69:	75 7c                	jne    f0105ee7 <strtol+0xca>
		s += 2, base = 16;
f0105e6b:	83 c1 02             	add    $0x2,%ecx
f0105e6e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105e73:	eb 16                	jmp    f0105e8b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105e75:	85 db                	test   %ebx,%ebx
f0105e77:	75 12                	jne    f0105e8b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105e79:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105e7e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105e81:	75 08                	jne    f0105e8b <strtol+0x6e>
		s++, base = 8;
f0105e83:	83 c1 01             	add    $0x1,%ecx
f0105e86:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105e8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e90:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105e93:	0f b6 11             	movzbl (%ecx),%edx
f0105e96:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105e99:	89 f3                	mov    %esi,%ebx
f0105e9b:	80 fb 09             	cmp    $0x9,%bl
f0105e9e:	77 08                	ja     f0105ea8 <strtol+0x8b>
			dig = *s - '0';
f0105ea0:	0f be d2             	movsbl %dl,%edx
f0105ea3:	83 ea 30             	sub    $0x30,%edx
f0105ea6:	eb 22                	jmp    f0105eca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105ea8:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105eab:	89 f3                	mov    %esi,%ebx
f0105ead:	80 fb 19             	cmp    $0x19,%bl
f0105eb0:	77 08                	ja     f0105eba <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105eb2:	0f be d2             	movsbl %dl,%edx
f0105eb5:	83 ea 57             	sub    $0x57,%edx
f0105eb8:	eb 10                	jmp    f0105eca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105eba:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105ebd:	89 f3                	mov    %esi,%ebx
f0105ebf:	80 fb 19             	cmp    $0x19,%bl
f0105ec2:	77 16                	ja     f0105eda <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105ec4:	0f be d2             	movsbl %dl,%edx
f0105ec7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105eca:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105ecd:	7d 0b                	jge    f0105eda <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105ecf:	83 c1 01             	add    $0x1,%ecx
f0105ed2:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105ed6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105ed8:	eb b9                	jmp    f0105e93 <strtol+0x76>

	if (endptr)
f0105eda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105ede:	74 0d                	je     f0105eed <strtol+0xd0>
		*endptr = (char *) s;
f0105ee0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ee3:	89 0e                	mov    %ecx,(%esi)
f0105ee5:	eb 06                	jmp    f0105eed <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105ee7:	85 db                	test   %ebx,%ebx
f0105ee9:	74 98                	je     f0105e83 <strtol+0x66>
f0105eeb:	eb 9e                	jmp    f0105e8b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105eed:	89 c2                	mov    %eax,%edx
f0105eef:	f7 da                	neg    %edx
f0105ef1:	85 ff                	test   %edi,%edi
f0105ef3:	0f 45 c2             	cmovne %edx,%eax
}
f0105ef6:	5b                   	pop    %ebx
f0105ef7:	5e                   	pop    %esi
f0105ef8:	5f                   	pop    %edi
f0105ef9:	5d                   	pop    %ebp
f0105efa:	c3                   	ret    

f0105efb <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
f0105efb:	55                   	push   %ebp
f0105efc:	89 e5                	mov    %esp,%ebp
f0105efe:	57                   	push   %edi
f0105eff:	56                   	push   %esi
f0105f00:	53                   	push   %ebx
f0105f01:	83 ec 04             	sub    $0x4,%esp
f0105f04:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
f0105f07:	57                   	push   %edi
f0105f08:	e8 6e fc ff ff       	call   f0105b7b <strlen>
f0105f0d:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
f0105f10:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
f0105f13:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
f0105f18:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
f0105f1d:	eb 46                	jmp    f0105f65 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
f0105f1f:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
f0105f23:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105f26:	80 f9 09             	cmp    $0x9,%cl
f0105f29:	77 08                	ja     f0105f33 <charhex_to_dec+0x38>
			num = s[i] - '0';
f0105f2b:	0f be d2             	movsbl %dl,%edx
f0105f2e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105f31:	eb 27                	jmp    f0105f5a <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
f0105f33:	8d 4a 9f             	lea    -0x61(%edx),%ecx
f0105f36:	80 f9 05             	cmp    $0x5,%cl
f0105f39:	77 08                	ja     f0105f43 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
f0105f3b:	0f be d2             	movsbl %dl,%edx
f0105f3e:	8d 4a a9             	lea    -0x57(%edx),%ecx
f0105f41:	eb 17                	jmp    f0105f5a <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
f0105f43:	8d 4a bf             	lea    -0x41(%edx),%ecx
f0105f46:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
f0105f49:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
f0105f4e:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
f0105f52:	77 06                	ja     f0105f5a <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
f0105f54:	0f be d2             	movsbl %dl,%edx
f0105f57:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
f0105f5a:	0f af ce             	imul   %esi,%ecx
f0105f5d:	01 c8                	add    %ecx,%eax
		base *= 16;
f0105f5f:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
f0105f62:	83 eb 01             	sub    $0x1,%ebx
f0105f65:	83 fb 01             	cmp    $0x1,%ebx
f0105f68:	7f b5                	jg     f0105f1f <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
f0105f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f6d:	5b                   	pop    %ebx
f0105f6e:	5e                   	pop    %esi
f0105f6f:	5f                   	pop    %edi
f0105f70:	5d                   	pop    %ebp
f0105f71:	c3                   	ret    
f0105f72:	66 90                	xchg   %ax,%ax

f0105f74 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f74:	fa                   	cli    

	xorw    %ax, %ax
f0105f75:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f77:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f79:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f7b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f7d:	0f 01 16             	lgdtl  (%esi)
f0105f80:	74 70                	je     f0105ff2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105f82:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f85:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f89:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f8c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f92:	08 00                	or     %al,(%eax)

f0105f94 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f94:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f98:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f9a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f9c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f9e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105fa2:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105fa4:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105fa6:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105fab:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105fae:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105fb1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105fb6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105fb9:	8b 25 84 ae 21 f0    	mov    0xf021ae84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105fbf:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105fc4:	b8 d4 01 10 f0       	mov    $0xf01001d4,%eax
	call    *%eax
f0105fc9:	ff d0                	call   *%eax

f0105fcb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105fcb:	eb fe                	jmp    f0105fcb <spin>
f0105fcd:	8d 76 00             	lea    0x0(%esi),%esi

f0105fd0 <gdt>:
	...
f0105fd8:	ff                   	(bad)  
f0105fd9:	ff 00                	incl   (%eax)
f0105fdb:	00 00                	add    %al,(%eax)
f0105fdd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105fe4:	00                   	.byte 0x0
f0105fe5:	92                   	xchg   %eax,%edx
f0105fe6:	cf                   	iret   
	...

f0105fe8 <gdtdesc>:
f0105fe8:	17                   	pop    %ss
f0105fe9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105fee <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105fee:	90                   	nop

f0105fef <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105fef:	55                   	push   %ebp
f0105ff0:	89 e5                	mov    %esp,%ebp
f0105ff2:	57                   	push   %edi
f0105ff3:	56                   	push   %esi
f0105ff4:	53                   	push   %ebx
f0105ff5:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ff8:	8b 0d 88 ae 21 f0    	mov    0xf021ae88,%ecx
f0105ffe:	89 c3                	mov    %eax,%ebx
f0106000:	c1 eb 0c             	shr    $0xc,%ebx
f0106003:	39 cb                	cmp    %ecx,%ebx
f0106005:	72 12                	jb     f0106019 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106007:	50                   	push   %eax
f0106008:	68 44 6a 10 f0       	push   $0xf0106a44
f010600d:	6a 57                	push   $0x57
f010600f:	68 9d 87 10 f0       	push   $0xf010879d
f0106014:	e8 27 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106019:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010601f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106021:	89 c2                	mov    %eax,%edx
f0106023:	c1 ea 0c             	shr    $0xc,%edx
f0106026:	39 ca                	cmp    %ecx,%edx
f0106028:	72 12                	jb     f010603c <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010602a:	50                   	push   %eax
f010602b:	68 44 6a 10 f0       	push   $0xf0106a44
f0106030:	6a 57                	push   $0x57
f0106032:	68 9d 87 10 f0       	push   $0xf010879d
f0106037:	e8 04 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010603c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0106042:	eb 2f                	jmp    f0106073 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106044:	83 ec 04             	sub    $0x4,%esp
f0106047:	6a 04                	push   $0x4
f0106049:	68 ad 87 10 f0       	push   $0xf01087ad
f010604e:	53                   	push   %ebx
f010604f:	e8 6d fd ff ff       	call   f0105dc1 <memcmp>
f0106054:	83 c4 10             	add    $0x10,%esp
f0106057:	85 c0                	test   %eax,%eax
f0106059:	75 15                	jne    f0106070 <mpsearch1+0x81>
f010605b:	89 da                	mov    %ebx,%edx
f010605d:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0106060:	0f b6 0a             	movzbl (%edx),%ecx
f0106063:	01 c8                	add    %ecx,%eax
f0106065:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106068:	39 d7                	cmp    %edx,%edi
f010606a:	75 f4                	jne    f0106060 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010606c:	84 c0                	test   %al,%al
f010606e:	74 0e                	je     f010607e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106070:	83 c3 10             	add    $0x10,%ebx
f0106073:	39 f3                	cmp    %esi,%ebx
f0106075:	72 cd                	jb     f0106044 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106077:	b8 00 00 00 00       	mov    $0x0,%eax
f010607c:	eb 02                	jmp    f0106080 <mpsearch1+0x91>
f010607e:	89 d8                	mov    %ebx,%eax
}
f0106080:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106083:	5b                   	pop    %ebx
f0106084:	5e                   	pop    %esi
f0106085:	5f                   	pop    %edi
f0106086:	5d                   	pop    %ebp
f0106087:	c3                   	ret    

f0106088 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106088:	55                   	push   %ebp
f0106089:	89 e5                	mov    %esp,%ebp
f010608b:	57                   	push   %edi
f010608c:	56                   	push   %esi
f010608d:	53                   	push   %ebx
f010608e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106091:	c7 05 c0 b3 21 f0 20 	movl   $0xf021b020,0xf021b3c0
f0106098:	b0 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010609b:	83 3d 88 ae 21 f0 00 	cmpl   $0x0,0xf021ae88
f01060a2:	75 16                	jne    f01060ba <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060a4:	68 00 04 00 00       	push   $0x400
f01060a9:	68 44 6a 10 f0       	push   $0xf0106a44
f01060ae:	6a 6f                	push   $0x6f
f01060b0:	68 9d 87 10 f0       	push   $0xf010879d
f01060b5:	e8 86 9f ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060ba:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060c1:	85 c0                	test   %eax,%eax
f01060c3:	74 16                	je     f01060db <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01060c5:	c1 e0 04             	shl    $0x4,%eax
f01060c8:	ba 00 04 00 00       	mov    $0x400,%edx
f01060cd:	e8 1d ff ff ff       	call   f0105fef <mpsearch1>
f01060d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060d5:	85 c0                	test   %eax,%eax
f01060d7:	75 3c                	jne    f0106115 <mp_init+0x8d>
f01060d9:	eb 20                	jmp    f01060fb <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01060db:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01060e2:	c1 e0 0a             	shl    $0xa,%eax
f01060e5:	2d 00 04 00 00       	sub    $0x400,%eax
f01060ea:	ba 00 04 00 00       	mov    $0x400,%edx
f01060ef:	e8 fb fe ff ff       	call   f0105fef <mpsearch1>
f01060f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060f7:	85 c0                	test   %eax,%eax
f01060f9:	75 1a                	jne    f0106115 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01060fb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106100:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106105:	e8 e5 fe ff ff       	call   f0105fef <mpsearch1>
f010610a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010610d:	85 c0                	test   %eax,%eax
f010610f:	0f 84 5d 02 00 00    	je     f0106372 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106118:	8b 70 04             	mov    0x4(%eax),%esi
f010611b:	85 f6                	test   %esi,%esi
f010611d:	74 06                	je     f0106125 <mp_init+0x9d>
f010611f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106123:	74 15                	je     f010613a <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0106125:	83 ec 0c             	sub    $0xc,%esp
f0106128:	68 10 86 10 f0       	push   $0xf0108610
f010612d:	e8 43 db ff ff       	call   f0103c75 <cprintf>
f0106132:	83 c4 10             	add    $0x10,%esp
f0106135:	e9 38 02 00 00       	jmp    f0106372 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010613a:	89 f0                	mov    %esi,%eax
f010613c:	c1 e8 0c             	shr    $0xc,%eax
f010613f:	3b 05 88 ae 21 f0    	cmp    0xf021ae88,%eax
f0106145:	72 15                	jb     f010615c <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106147:	56                   	push   %esi
f0106148:	68 44 6a 10 f0       	push   $0xf0106a44
f010614d:	68 90 00 00 00       	push   $0x90
f0106152:	68 9d 87 10 f0       	push   $0xf010879d
f0106157:	e8 e4 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010615c:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106162:	83 ec 04             	sub    $0x4,%esp
f0106165:	6a 04                	push   $0x4
f0106167:	68 b2 87 10 f0       	push   $0xf01087b2
f010616c:	53                   	push   %ebx
f010616d:	e8 4f fc ff ff       	call   f0105dc1 <memcmp>
f0106172:	83 c4 10             	add    $0x10,%esp
f0106175:	85 c0                	test   %eax,%eax
f0106177:	74 15                	je     f010618e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106179:	83 ec 0c             	sub    $0xc,%esp
f010617c:	68 40 86 10 f0       	push   $0xf0108640
f0106181:	e8 ef da ff ff       	call   f0103c75 <cprintf>
f0106186:	83 c4 10             	add    $0x10,%esp
f0106189:	e9 e4 01 00 00       	jmp    f0106372 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010618e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106192:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106196:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106199:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010619e:	b8 00 00 00 00       	mov    $0x0,%eax
f01061a3:	eb 0d                	jmp    f01061b2 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01061a5:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01061ac:	f0 
f01061ad:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061af:	83 c0 01             	add    $0x1,%eax
f01061b2:	39 c7                	cmp    %eax,%edi
f01061b4:	75 ef                	jne    f01061a5 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01061b6:	84 d2                	test   %dl,%dl
f01061b8:	74 15                	je     f01061cf <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061ba:	83 ec 0c             	sub    $0xc,%esp
f01061bd:	68 74 86 10 f0       	push   $0xf0108674
f01061c2:	e8 ae da ff ff       	call   f0103c75 <cprintf>
f01061c7:	83 c4 10             	add    $0x10,%esp
f01061ca:	e9 a3 01 00 00       	jmp    f0106372 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01061cf:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01061d3:	3c 01                	cmp    $0x1,%al
f01061d5:	74 1d                	je     f01061f4 <mp_init+0x16c>
f01061d7:	3c 04                	cmp    $0x4,%al
f01061d9:	74 19                	je     f01061f4 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061db:	83 ec 08             	sub    $0x8,%esp
f01061de:	0f b6 c0             	movzbl %al,%eax
f01061e1:	50                   	push   %eax
f01061e2:	68 98 86 10 f0       	push   $0xf0108698
f01061e7:	e8 89 da ff ff       	call   f0103c75 <cprintf>
f01061ec:	83 c4 10             	add    $0x10,%esp
f01061ef:	e9 7e 01 00 00       	jmp    f0106372 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01061f4:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01061f8:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01061fc:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106201:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0106206:	01 ce                	add    %ecx,%esi
f0106208:	eb 0d                	jmp    f0106217 <mp_init+0x18f>
f010620a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0106211:	f0 
f0106212:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106214:	83 c0 01             	add    $0x1,%eax
f0106217:	39 c7                	cmp    %eax,%edi
f0106219:	75 ef                	jne    f010620a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010621b:	89 d0                	mov    %edx,%eax
f010621d:	02 43 2a             	add    0x2a(%ebx),%al
f0106220:	74 15                	je     f0106237 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106222:	83 ec 0c             	sub    $0xc,%esp
f0106225:	68 b8 86 10 f0       	push   $0xf01086b8
f010622a:	e8 46 da ff ff       	call   f0103c75 <cprintf>
f010622f:	83 c4 10             	add    $0x10,%esp
f0106232:	e9 3b 01 00 00       	jmp    f0106372 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106237:	85 db                	test   %ebx,%ebx
f0106239:	0f 84 33 01 00 00    	je     f0106372 <mp_init+0x2ea>
		return;
	ismp = 1;
f010623f:	c7 05 00 b0 21 f0 01 	movl   $0x1,0xf021b000
f0106246:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106249:	8b 43 24             	mov    0x24(%ebx),%eax
f010624c:	a3 00 c0 25 f0       	mov    %eax,0xf025c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106251:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106254:	be 00 00 00 00       	mov    $0x0,%esi
f0106259:	e9 85 00 00 00       	jmp    f01062e3 <mp_init+0x25b>
		switch (*p) {
f010625e:	0f b6 07             	movzbl (%edi),%eax
f0106261:	84 c0                	test   %al,%al
f0106263:	74 06                	je     f010626b <mp_init+0x1e3>
f0106265:	3c 04                	cmp    $0x4,%al
f0106267:	77 55                	ja     f01062be <mp_init+0x236>
f0106269:	eb 4e                	jmp    f01062b9 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010626b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010626f:	74 11                	je     f0106282 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0106271:	6b 05 c4 b3 21 f0 74 	imul   $0x74,0xf021b3c4,%eax
f0106278:	05 20 b0 21 f0       	add    $0xf021b020,%eax
f010627d:	a3 c0 b3 21 f0       	mov    %eax,0xf021b3c0
			if (ncpu < NCPU) {
f0106282:	a1 c4 b3 21 f0       	mov    0xf021b3c4,%eax
f0106287:	83 f8 07             	cmp    $0x7,%eax
f010628a:	7f 13                	jg     f010629f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f010628c:	6b d0 74             	imul   $0x74,%eax,%edx
f010628f:	88 82 20 b0 21 f0    	mov    %al,-0xfde4fe0(%edx)
				ncpu++;
f0106295:	83 c0 01             	add    $0x1,%eax
f0106298:	a3 c4 b3 21 f0       	mov    %eax,0xf021b3c4
f010629d:	eb 15                	jmp    f01062b4 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010629f:	83 ec 08             	sub    $0x8,%esp
f01062a2:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01062a6:	50                   	push   %eax
f01062a7:	68 e8 86 10 f0       	push   $0xf01086e8
f01062ac:	e8 c4 d9 ff ff       	call   f0103c75 <cprintf>
f01062b1:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01062b4:	83 c7 14             	add    $0x14,%edi
			continue;
f01062b7:	eb 27                	jmp    f01062e0 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01062b9:	83 c7 08             	add    $0x8,%edi
			continue;
f01062bc:	eb 22                	jmp    f01062e0 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01062be:	83 ec 08             	sub    $0x8,%esp
f01062c1:	0f b6 c0             	movzbl %al,%eax
f01062c4:	50                   	push   %eax
f01062c5:	68 10 87 10 f0       	push   $0xf0108710
f01062ca:	e8 a6 d9 ff ff       	call   f0103c75 <cprintf>
			ismp = 0;
f01062cf:	c7 05 00 b0 21 f0 00 	movl   $0x0,0xf021b000
f01062d6:	00 00 00 
			i = conf->entry;
f01062d9:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01062dd:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062e0:	83 c6 01             	add    $0x1,%esi
f01062e3:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01062e7:	39 c6                	cmp    %eax,%esi
f01062e9:	0f 82 6f ff ff ff    	jb     f010625e <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062ef:	a1 c0 b3 21 f0       	mov    0xf021b3c0,%eax
f01062f4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01062fb:	83 3d 00 b0 21 f0 00 	cmpl   $0x0,0xf021b000
f0106302:	75 26                	jne    f010632a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106304:	c7 05 c4 b3 21 f0 01 	movl   $0x1,0xf021b3c4
f010630b:	00 00 00 
		lapicaddr = 0;
f010630e:	c7 05 00 c0 25 f0 00 	movl   $0x0,0xf025c000
f0106315:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106318:	83 ec 0c             	sub    $0xc,%esp
f010631b:	68 30 87 10 f0       	push   $0xf0108730
f0106320:	e8 50 d9 ff ff       	call   f0103c75 <cprintf>
		return;
f0106325:	83 c4 10             	add    $0x10,%esp
f0106328:	eb 48                	jmp    f0106372 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010632a:	83 ec 04             	sub    $0x4,%esp
f010632d:	ff 35 c4 b3 21 f0    	pushl  0xf021b3c4
f0106333:	0f b6 00             	movzbl (%eax),%eax
f0106336:	50                   	push   %eax
f0106337:	68 b7 87 10 f0       	push   $0xf01087b7
f010633c:	e8 34 d9 ff ff       	call   f0103c75 <cprintf>

	if (mp->imcrp) {
f0106341:	83 c4 10             	add    $0x10,%esp
f0106344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106347:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010634b:	74 25                	je     f0106372 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010634d:	83 ec 0c             	sub    $0xc,%esp
f0106350:	68 5c 87 10 f0       	push   $0xf010875c
f0106355:	e8 1b d9 ff ff       	call   f0103c75 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010635a:	ba 22 00 00 00       	mov    $0x22,%edx
f010635f:	b8 70 00 00 00       	mov    $0x70,%eax
f0106364:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106365:	ba 23 00 00 00       	mov    $0x23,%edx
f010636a:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010636b:	83 c8 01             	or     $0x1,%eax
f010636e:	ee                   	out    %al,(%dx)
f010636f:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106372:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106375:	5b                   	pop    %ebx
f0106376:	5e                   	pop    %esi
f0106377:	5f                   	pop    %edi
f0106378:	5d                   	pop    %ebp
f0106379:	c3                   	ret    

f010637a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010637a:	55                   	push   %ebp
f010637b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010637d:	8b 0d 04 c0 25 f0    	mov    0xf025c004,%ecx
f0106383:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106386:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106388:	a1 04 c0 25 f0       	mov    0xf025c004,%eax
f010638d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106390:	5d                   	pop    %ebp
f0106391:	c3                   	ret    

f0106392 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106392:	55                   	push   %ebp
f0106393:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106395:	a1 04 c0 25 f0       	mov    0xf025c004,%eax
f010639a:	85 c0                	test   %eax,%eax
f010639c:	74 08                	je     f01063a6 <cpunum+0x14>
		return lapic[ID] >> 24;
f010639e:	8b 40 20             	mov    0x20(%eax),%eax
f01063a1:	c1 e8 18             	shr    $0x18,%eax
f01063a4:	eb 05                	jmp    f01063ab <cpunum+0x19>
	return 0;
f01063a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063ab:	5d                   	pop    %ebp
f01063ac:	c3                   	ret    

f01063ad <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01063ad:	a1 00 c0 25 f0       	mov    0xf025c000,%eax
f01063b2:	85 c0                	test   %eax,%eax
f01063b4:	0f 84 21 01 00 00    	je     f01064db <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01063ba:	55                   	push   %ebp
f01063bb:	89 e5                	mov    %esp,%ebp
f01063bd:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01063c0:	68 00 10 00 00       	push   $0x1000
f01063c5:	50                   	push   %eax
f01063c6:	e8 1f b4 ff ff       	call   f01017ea <mmio_map_region>
f01063cb:	a3 04 c0 25 f0       	mov    %eax,0xf025c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01063d0:	ba 27 01 00 00       	mov    $0x127,%edx
f01063d5:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01063da:	e8 9b ff ff ff       	call   f010637a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01063df:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063e4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063e9:	e8 8c ff ff ff       	call   f010637a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063ee:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063f3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063f8:	e8 7d ff ff ff       	call   f010637a <lapicw>
	lapicw(TICR, 10000000); 
f01063fd:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106402:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106407:	e8 6e ff ff ff       	call   f010637a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010640c:	e8 81 ff ff ff       	call   f0106392 <cpunum>
f0106411:	6b c0 74             	imul   $0x74,%eax,%eax
f0106414:	05 20 b0 21 f0       	add    $0xf021b020,%eax
f0106419:	83 c4 10             	add    $0x10,%esp
f010641c:	39 05 c0 b3 21 f0    	cmp    %eax,0xf021b3c0
f0106422:	74 0f                	je     f0106433 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0106424:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106429:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010642e:	e8 47 ff ff ff       	call   f010637a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106433:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106438:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010643d:	e8 38 ff ff ff       	call   f010637a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106442:	a1 04 c0 25 f0       	mov    0xf025c004,%eax
f0106447:	8b 40 30             	mov    0x30(%eax),%eax
f010644a:	c1 e8 10             	shr    $0x10,%eax
f010644d:	3c 03                	cmp    $0x3,%al
f010644f:	76 0f                	jbe    f0106460 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0106451:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106456:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010645b:	e8 1a ff ff ff       	call   f010637a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106460:	ba 33 00 00 00       	mov    $0x33,%edx
f0106465:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010646a:	e8 0b ff ff ff       	call   f010637a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010646f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106474:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106479:	e8 fc fe ff ff       	call   f010637a <lapicw>
	lapicw(ESR, 0);
f010647e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106483:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106488:	e8 ed fe ff ff       	call   f010637a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010648d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106492:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106497:	e8 de fe ff ff       	call   f010637a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010649c:	ba 00 00 00 00       	mov    $0x0,%edx
f01064a1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064a6:	e8 cf fe ff ff       	call   f010637a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01064ab:	ba 00 85 08 00       	mov    $0x88500,%edx
f01064b0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064b5:	e8 c0 fe ff ff       	call   f010637a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01064ba:	8b 15 04 c0 25 f0    	mov    0xf025c004,%edx
f01064c0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01064c6:	f6 c4 10             	test   $0x10,%ah
f01064c9:	75 f5                	jne    f01064c0 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01064cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01064d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01064d5:	e8 a0 fe ff ff       	call   f010637a <lapicw>
}
f01064da:	c9                   	leave  
f01064db:	f3 c3                	repz ret 

f01064dd <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01064dd:	83 3d 04 c0 25 f0 00 	cmpl   $0x0,0xf025c004
f01064e4:	74 13                	je     f01064f9 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01064e6:	55                   	push   %ebp
f01064e7:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01064e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01064ee:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064f3:	e8 82 fe ff ff       	call   f010637a <lapicw>
}
f01064f8:	5d                   	pop    %ebp
f01064f9:	f3 c3                	repz ret 

f01064fb <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064fb:	55                   	push   %ebp
f01064fc:	89 e5                	mov    %esp,%ebp
f01064fe:	56                   	push   %esi
f01064ff:	53                   	push   %ebx
f0106500:	8b 75 08             	mov    0x8(%ebp),%esi
f0106503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106506:	ba 70 00 00 00       	mov    $0x70,%edx
f010650b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106510:	ee                   	out    %al,(%dx)
f0106511:	ba 71 00 00 00       	mov    $0x71,%edx
f0106516:	b8 0a 00 00 00       	mov    $0xa,%eax
f010651b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010651c:	83 3d 88 ae 21 f0 00 	cmpl   $0x0,0xf021ae88
f0106523:	75 19                	jne    f010653e <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106525:	68 67 04 00 00       	push   $0x467
f010652a:	68 44 6a 10 f0       	push   $0xf0106a44
f010652f:	68 98 00 00 00       	push   $0x98
f0106534:	68 d4 87 10 f0       	push   $0xf01087d4
f0106539:	e8 02 9b ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010653e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106545:	00 00 
	wrv[1] = addr >> 4;
f0106547:	89 d8                	mov    %ebx,%eax
f0106549:	c1 e8 04             	shr    $0x4,%eax
f010654c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106552:	c1 e6 18             	shl    $0x18,%esi
f0106555:	89 f2                	mov    %esi,%edx
f0106557:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010655c:	e8 19 fe ff ff       	call   f010637a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106561:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106566:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010656b:	e8 0a fe ff ff       	call   f010637a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106570:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106575:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010657a:	e8 fb fd ff ff       	call   f010637a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010657f:	c1 eb 0c             	shr    $0xc,%ebx
f0106582:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106585:	89 f2                	mov    %esi,%edx
f0106587:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010658c:	e8 e9 fd ff ff       	call   f010637a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106591:	89 da                	mov    %ebx,%edx
f0106593:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106598:	e8 dd fd ff ff       	call   f010637a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010659d:	89 f2                	mov    %esi,%edx
f010659f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065a4:	e8 d1 fd ff ff       	call   f010637a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065a9:	89 da                	mov    %ebx,%edx
f01065ab:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065b0:	e8 c5 fd ff ff       	call   f010637a <lapicw>
		microdelay(200);
	}
}
f01065b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01065b8:	5b                   	pop    %ebx
f01065b9:	5e                   	pop    %esi
f01065ba:	5d                   	pop    %ebp
f01065bb:	c3                   	ret    

f01065bc <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01065bc:	55                   	push   %ebp
f01065bd:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01065bf:	8b 55 08             	mov    0x8(%ebp),%edx
f01065c2:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01065c8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065cd:	e8 a8 fd ff ff       	call   f010637a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065d2:	8b 15 04 c0 25 f0    	mov    0xf025c004,%edx
f01065d8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065de:	f6 c4 10             	test   $0x10,%ah
f01065e1:	75 f5                	jne    f01065d8 <lapic_ipi+0x1c>
		;
}
f01065e3:	5d                   	pop    %ebp
f01065e4:	c3                   	ret    

f01065e5 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065e5:	55                   	push   %ebp
f01065e6:	89 e5                	mov    %esp,%ebp
f01065e8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01065f1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01065f4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01065f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01065fe:	5d                   	pop    %ebp
f01065ff:	c3                   	ret    

f0106600 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106600:	55                   	push   %ebp
f0106601:	89 e5                	mov    %esp,%ebp
f0106603:	56                   	push   %esi
f0106604:	53                   	push   %ebx
f0106605:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106608:	83 3b 00             	cmpl   $0x0,(%ebx)
f010660b:	74 14                	je     f0106621 <spin_lock+0x21>
f010660d:	8b 73 08             	mov    0x8(%ebx),%esi
f0106610:	e8 7d fd ff ff       	call   f0106392 <cpunum>
f0106615:	6b c0 74             	imul   $0x74,%eax,%eax
f0106618:	05 20 b0 21 f0       	add    $0xf021b020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010661d:	39 c6                	cmp    %eax,%esi
f010661f:	74 07                	je     f0106628 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106621:	ba 01 00 00 00       	mov    $0x1,%edx
f0106626:	eb 20                	jmp    f0106648 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106628:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010662b:	e8 62 fd ff ff       	call   f0106392 <cpunum>
f0106630:	83 ec 0c             	sub    $0xc,%esp
f0106633:	53                   	push   %ebx
f0106634:	50                   	push   %eax
f0106635:	68 e4 87 10 f0       	push   $0xf01087e4
f010663a:	6a 41                	push   $0x41
f010663c:	68 48 88 10 f0       	push   $0xf0108848
f0106641:	e8 fa 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106646:	f3 90                	pause  
f0106648:	89 d0                	mov    %edx,%eax
f010664a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010664d:	85 c0                	test   %eax,%eax
f010664f:	75 f5                	jne    f0106646 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106651:	e8 3c fd ff ff       	call   f0106392 <cpunum>
f0106656:	6b c0 74             	imul   $0x74,%eax,%eax
f0106659:	05 20 b0 21 f0       	add    $0xf021b020,%eax
f010665e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106661:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106664:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106666:	b8 00 00 00 00       	mov    $0x0,%eax
f010666b:	eb 0b                	jmp    f0106678 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f010666d:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106670:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106673:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106675:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106678:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010667e:	76 11                	jbe    f0106691 <spin_lock+0x91>
f0106680:	83 f8 09             	cmp    $0x9,%eax
f0106683:	7e e8                	jle    f010666d <spin_lock+0x6d>
f0106685:	eb 0a                	jmp    f0106691 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106687:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010668e:	83 c0 01             	add    $0x1,%eax
f0106691:	83 f8 09             	cmp    $0x9,%eax
f0106694:	7e f1                	jle    f0106687 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106696:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106699:	5b                   	pop    %ebx
f010669a:	5e                   	pop    %esi
f010669b:	5d                   	pop    %ebp
f010669c:	c3                   	ret    

f010669d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010669d:	55                   	push   %ebp
f010669e:	89 e5                	mov    %esp,%ebp
f01066a0:	57                   	push   %edi
f01066a1:	56                   	push   %esi
f01066a2:	53                   	push   %ebx
f01066a3:	83 ec 4c             	sub    $0x4c,%esp
f01066a6:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01066a9:	83 3e 00             	cmpl   $0x0,(%esi)
f01066ac:	74 18                	je     f01066c6 <spin_unlock+0x29>
f01066ae:	8b 5e 08             	mov    0x8(%esi),%ebx
f01066b1:	e8 dc fc ff ff       	call   f0106392 <cpunum>
f01066b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01066b9:	05 20 b0 21 f0       	add    $0xf021b020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01066be:	39 c3                	cmp    %eax,%ebx
f01066c0:	0f 84 a5 00 00 00    	je     f010676b <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01066c6:	83 ec 04             	sub    $0x4,%esp
f01066c9:	6a 28                	push   $0x28
f01066cb:	8d 46 0c             	lea    0xc(%esi),%eax
f01066ce:	50                   	push   %eax
f01066cf:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01066d2:	53                   	push   %ebx
f01066d3:	e8 6e f6 ff ff       	call   f0105d46 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01066d8:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01066db:	0f b6 38             	movzbl (%eax),%edi
f01066de:	8b 76 04             	mov    0x4(%esi),%esi
f01066e1:	e8 ac fc ff ff       	call   f0106392 <cpunum>
f01066e6:	57                   	push   %edi
f01066e7:	56                   	push   %esi
f01066e8:	50                   	push   %eax
f01066e9:	68 10 88 10 f0       	push   $0xf0108810
f01066ee:	e8 82 d5 ff ff       	call   f0103c75 <cprintf>
f01066f3:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01066f6:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01066f9:	eb 54                	jmp    f010674f <spin_unlock+0xb2>
f01066fb:	83 ec 08             	sub    $0x8,%esp
f01066fe:	57                   	push   %edi
f01066ff:	50                   	push   %eax
f0106700:	e8 a9 ea ff ff       	call   f01051ae <debuginfo_eip>
f0106705:	83 c4 10             	add    $0x10,%esp
f0106708:	85 c0                	test   %eax,%eax
f010670a:	78 27                	js     f0106733 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010670c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010670e:	83 ec 04             	sub    $0x4,%esp
f0106711:	89 c2                	mov    %eax,%edx
f0106713:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106716:	52                   	push   %edx
f0106717:	ff 75 b0             	pushl  -0x50(%ebp)
f010671a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010671d:	ff 75 ac             	pushl  -0x54(%ebp)
f0106720:	ff 75 a8             	pushl  -0x58(%ebp)
f0106723:	50                   	push   %eax
f0106724:	68 58 88 10 f0       	push   $0xf0108858
f0106729:	e8 47 d5 ff ff       	call   f0103c75 <cprintf>
f010672e:	83 c4 20             	add    $0x20,%esp
f0106731:	eb 12                	jmp    f0106745 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106733:	83 ec 08             	sub    $0x8,%esp
f0106736:	ff 36                	pushl  (%esi)
f0106738:	68 6f 88 10 f0       	push   $0xf010886f
f010673d:	e8 33 d5 ff ff       	call   f0103c75 <cprintf>
f0106742:	83 c4 10             	add    $0x10,%esp
f0106745:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106748:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010674b:	39 c3                	cmp    %eax,%ebx
f010674d:	74 08                	je     f0106757 <spin_unlock+0xba>
f010674f:	89 de                	mov    %ebx,%esi
f0106751:	8b 03                	mov    (%ebx),%eax
f0106753:	85 c0                	test   %eax,%eax
f0106755:	75 a4                	jne    f01066fb <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106757:	83 ec 04             	sub    $0x4,%esp
f010675a:	68 77 88 10 f0       	push   $0xf0108877
f010675f:	6a 67                	push   $0x67
f0106761:	68 48 88 10 f0       	push   $0xf0108848
f0106766:	e8 d5 98 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010676b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106772:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106779:	b8 00 00 00 00       	mov    $0x0,%eax
f010677e:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106781:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106784:	5b                   	pop    %ebx
f0106785:	5e                   	pop    %esi
f0106786:	5f                   	pop    %edi
f0106787:	5d                   	pop    %ebp
f0106788:	c3                   	ret    
f0106789:	66 90                	xchg   %ax,%ax
f010678b:	66 90                	xchg   %ax,%ax
f010678d:	66 90                	xchg   %ax,%ax
f010678f:	90                   	nop

f0106790 <__udivdi3>:
f0106790:	55                   	push   %ebp
f0106791:	57                   	push   %edi
f0106792:	56                   	push   %esi
f0106793:	53                   	push   %ebx
f0106794:	83 ec 1c             	sub    $0x1c,%esp
f0106797:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010679b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010679f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01067a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01067a7:	85 f6                	test   %esi,%esi
f01067a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01067ad:	89 ca                	mov    %ecx,%edx
f01067af:	89 f8                	mov    %edi,%eax
f01067b1:	75 3d                	jne    f01067f0 <__udivdi3+0x60>
f01067b3:	39 cf                	cmp    %ecx,%edi
f01067b5:	0f 87 c5 00 00 00    	ja     f0106880 <__udivdi3+0xf0>
f01067bb:	85 ff                	test   %edi,%edi
f01067bd:	89 fd                	mov    %edi,%ebp
f01067bf:	75 0b                	jne    f01067cc <__udivdi3+0x3c>
f01067c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01067c6:	31 d2                	xor    %edx,%edx
f01067c8:	f7 f7                	div    %edi
f01067ca:	89 c5                	mov    %eax,%ebp
f01067cc:	89 c8                	mov    %ecx,%eax
f01067ce:	31 d2                	xor    %edx,%edx
f01067d0:	f7 f5                	div    %ebp
f01067d2:	89 c1                	mov    %eax,%ecx
f01067d4:	89 d8                	mov    %ebx,%eax
f01067d6:	89 cf                	mov    %ecx,%edi
f01067d8:	f7 f5                	div    %ebp
f01067da:	89 c3                	mov    %eax,%ebx
f01067dc:	89 d8                	mov    %ebx,%eax
f01067de:	89 fa                	mov    %edi,%edx
f01067e0:	83 c4 1c             	add    $0x1c,%esp
f01067e3:	5b                   	pop    %ebx
f01067e4:	5e                   	pop    %esi
f01067e5:	5f                   	pop    %edi
f01067e6:	5d                   	pop    %ebp
f01067e7:	c3                   	ret    
f01067e8:	90                   	nop
f01067e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067f0:	39 ce                	cmp    %ecx,%esi
f01067f2:	77 74                	ja     f0106868 <__udivdi3+0xd8>
f01067f4:	0f bd fe             	bsr    %esi,%edi
f01067f7:	83 f7 1f             	xor    $0x1f,%edi
f01067fa:	0f 84 98 00 00 00    	je     f0106898 <__udivdi3+0x108>
f0106800:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106805:	89 f9                	mov    %edi,%ecx
f0106807:	89 c5                	mov    %eax,%ebp
f0106809:	29 fb                	sub    %edi,%ebx
f010680b:	d3 e6                	shl    %cl,%esi
f010680d:	89 d9                	mov    %ebx,%ecx
f010680f:	d3 ed                	shr    %cl,%ebp
f0106811:	89 f9                	mov    %edi,%ecx
f0106813:	d3 e0                	shl    %cl,%eax
f0106815:	09 ee                	or     %ebp,%esi
f0106817:	89 d9                	mov    %ebx,%ecx
f0106819:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010681d:	89 d5                	mov    %edx,%ebp
f010681f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106823:	d3 ed                	shr    %cl,%ebp
f0106825:	89 f9                	mov    %edi,%ecx
f0106827:	d3 e2                	shl    %cl,%edx
f0106829:	89 d9                	mov    %ebx,%ecx
f010682b:	d3 e8                	shr    %cl,%eax
f010682d:	09 c2                	or     %eax,%edx
f010682f:	89 d0                	mov    %edx,%eax
f0106831:	89 ea                	mov    %ebp,%edx
f0106833:	f7 f6                	div    %esi
f0106835:	89 d5                	mov    %edx,%ebp
f0106837:	89 c3                	mov    %eax,%ebx
f0106839:	f7 64 24 0c          	mull   0xc(%esp)
f010683d:	39 d5                	cmp    %edx,%ebp
f010683f:	72 10                	jb     f0106851 <__udivdi3+0xc1>
f0106841:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106845:	89 f9                	mov    %edi,%ecx
f0106847:	d3 e6                	shl    %cl,%esi
f0106849:	39 c6                	cmp    %eax,%esi
f010684b:	73 07                	jae    f0106854 <__udivdi3+0xc4>
f010684d:	39 d5                	cmp    %edx,%ebp
f010684f:	75 03                	jne    f0106854 <__udivdi3+0xc4>
f0106851:	83 eb 01             	sub    $0x1,%ebx
f0106854:	31 ff                	xor    %edi,%edi
f0106856:	89 d8                	mov    %ebx,%eax
f0106858:	89 fa                	mov    %edi,%edx
f010685a:	83 c4 1c             	add    $0x1c,%esp
f010685d:	5b                   	pop    %ebx
f010685e:	5e                   	pop    %esi
f010685f:	5f                   	pop    %edi
f0106860:	5d                   	pop    %ebp
f0106861:	c3                   	ret    
f0106862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106868:	31 ff                	xor    %edi,%edi
f010686a:	31 db                	xor    %ebx,%ebx
f010686c:	89 d8                	mov    %ebx,%eax
f010686e:	89 fa                	mov    %edi,%edx
f0106870:	83 c4 1c             	add    $0x1c,%esp
f0106873:	5b                   	pop    %ebx
f0106874:	5e                   	pop    %esi
f0106875:	5f                   	pop    %edi
f0106876:	5d                   	pop    %ebp
f0106877:	c3                   	ret    
f0106878:	90                   	nop
f0106879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106880:	89 d8                	mov    %ebx,%eax
f0106882:	f7 f7                	div    %edi
f0106884:	31 ff                	xor    %edi,%edi
f0106886:	89 c3                	mov    %eax,%ebx
f0106888:	89 d8                	mov    %ebx,%eax
f010688a:	89 fa                	mov    %edi,%edx
f010688c:	83 c4 1c             	add    $0x1c,%esp
f010688f:	5b                   	pop    %ebx
f0106890:	5e                   	pop    %esi
f0106891:	5f                   	pop    %edi
f0106892:	5d                   	pop    %ebp
f0106893:	c3                   	ret    
f0106894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106898:	39 ce                	cmp    %ecx,%esi
f010689a:	72 0c                	jb     f01068a8 <__udivdi3+0x118>
f010689c:	31 db                	xor    %ebx,%ebx
f010689e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01068a2:	0f 87 34 ff ff ff    	ja     f01067dc <__udivdi3+0x4c>
f01068a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01068ad:	e9 2a ff ff ff       	jmp    f01067dc <__udivdi3+0x4c>
f01068b2:	66 90                	xchg   %ax,%ax
f01068b4:	66 90                	xchg   %ax,%ax
f01068b6:	66 90                	xchg   %ax,%ax
f01068b8:	66 90                	xchg   %ax,%ax
f01068ba:	66 90                	xchg   %ax,%ax
f01068bc:	66 90                	xchg   %ax,%ax
f01068be:	66 90                	xchg   %ax,%ax

f01068c0 <__umoddi3>:
f01068c0:	55                   	push   %ebp
f01068c1:	57                   	push   %edi
f01068c2:	56                   	push   %esi
f01068c3:	53                   	push   %ebx
f01068c4:	83 ec 1c             	sub    $0x1c,%esp
f01068c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01068cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01068cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01068d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01068d7:	85 d2                	test   %edx,%edx
f01068d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01068dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01068e1:	89 f3                	mov    %esi,%ebx
f01068e3:	89 3c 24             	mov    %edi,(%esp)
f01068e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01068ea:	75 1c                	jne    f0106908 <__umoddi3+0x48>
f01068ec:	39 f7                	cmp    %esi,%edi
f01068ee:	76 50                	jbe    f0106940 <__umoddi3+0x80>
f01068f0:	89 c8                	mov    %ecx,%eax
f01068f2:	89 f2                	mov    %esi,%edx
f01068f4:	f7 f7                	div    %edi
f01068f6:	89 d0                	mov    %edx,%eax
f01068f8:	31 d2                	xor    %edx,%edx
f01068fa:	83 c4 1c             	add    $0x1c,%esp
f01068fd:	5b                   	pop    %ebx
f01068fe:	5e                   	pop    %esi
f01068ff:	5f                   	pop    %edi
f0106900:	5d                   	pop    %ebp
f0106901:	c3                   	ret    
f0106902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106908:	39 f2                	cmp    %esi,%edx
f010690a:	89 d0                	mov    %edx,%eax
f010690c:	77 52                	ja     f0106960 <__umoddi3+0xa0>
f010690e:	0f bd ea             	bsr    %edx,%ebp
f0106911:	83 f5 1f             	xor    $0x1f,%ebp
f0106914:	75 5a                	jne    f0106970 <__umoddi3+0xb0>
f0106916:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010691a:	0f 82 e0 00 00 00    	jb     f0106a00 <__umoddi3+0x140>
f0106920:	39 0c 24             	cmp    %ecx,(%esp)
f0106923:	0f 86 d7 00 00 00    	jbe    f0106a00 <__umoddi3+0x140>
f0106929:	8b 44 24 08          	mov    0x8(%esp),%eax
f010692d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106931:	83 c4 1c             	add    $0x1c,%esp
f0106934:	5b                   	pop    %ebx
f0106935:	5e                   	pop    %esi
f0106936:	5f                   	pop    %edi
f0106937:	5d                   	pop    %ebp
f0106938:	c3                   	ret    
f0106939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106940:	85 ff                	test   %edi,%edi
f0106942:	89 fd                	mov    %edi,%ebp
f0106944:	75 0b                	jne    f0106951 <__umoddi3+0x91>
f0106946:	b8 01 00 00 00       	mov    $0x1,%eax
f010694b:	31 d2                	xor    %edx,%edx
f010694d:	f7 f7                	div    %edi
f010694f:	89 c5                	mov    %eax,%ebp
f0106951:	89 f0                	mov    %esi,%eax
f0106953:	31 d2                	xor    %edx,%edx
f0106955:	f7 f5                	div    %ebp
f0106957:	89 c8                	mov    %ecx,%eax
f0106959:	f7 f5                	div    %ebp
f010695b:	89 d0                	mov    %edx,%eax
f010695d:	eb 99                	jmp    f01068f8 <__umoddi3+0x38>
f010695f:	90                   	nop
f0106960:	89 c8                	mov    %ecx,%eax
f0106962:	89 f2                	mov    %esi,%edx
f0106964:	83 c4 1c             	add    $0x1c,%esp
f0106967:	5b                   	pop    %ebx
f0106968:	5e                   	pop    %esi
f0106969:	5f                   	pop    %edi
f010696a:	5d                   	pop    %ebp
f010696b:	c3                   	ret    
f010696c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106970:	8b 34 24             	mov    (%esp),%esi
f0106973:	bf 20 00 00 00       	mov    $0x20,%edi
f0106978:	89 e9                	mov    %ebp,%ecx
f010697a:	29 ef                	sub    %ebp,%edi
f010697c:	d3 e0                	shl    %cl,%eax
f010697e:	89 f9                	mov    %edi,%ecx
f0106980:	89 f2                	mov    %esi,%edx
f0106982:	d3 ea                	shr    %cl,%edx
f0106984:	89 e9                	mov    %ebp,%ecx
f0106986:	09 c2                	or     %eax,%edx
f0106988:	89 d8                	mov    %ebx,%eax
f010698a:	89 14 24             	mov    %edx,(%esp)
f010698d:	89 f2                	mov    %esi,%edx
f010698f:	d3 e2                	shl    %cl,%edx
f0106991:	89 f9                	mov    %edi,%ecx
f0106993:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106997:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010699b:	d3 e8                	shr    %cl,%eax
f010699d:	89 e9                	mov    %ebp,%ecx
f010699f:	89 c6                	mov    %eax,%esi
f01069a1:	d3 e3                	shl    %cl,%ebx
f01069a3:	89 f9                	mov    %edi,%ecx
f01069a5:	89 d0                	mov    %edx,%eax
f01069a7:	d3 e8                	shr    %cl,%eax
f01069a9:	89 e9                	mov    %ebp,%ecx
f01069ab:	09 d8                	or     %ebx,%eax
f01069ad:	89 d3                	mov    %edx,%ebx
f01069af:	89 f2                	mov    %esi,%edx
f01069b1:	f7 34 24             	divl   (%esp)
f01069b4:	89 d6                	mov    %edx,%esi
f01069b6:	d3 e3                	shl    %cl,%ebx
f01069b8:	f7 64 24 04          	mull   0x4(%esp)
f01069bc:	39 d6                	cmp    %edx,%esi
f01069be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069c2:	89 d1                	mov    %edx,%ecx
f01069c4:	89 c3                	mov    %eax,%ebx
f01069c6:	72 08                	jb     f01069d0 <__umoddi3+0x110>
f01069c8:	75 11                	jne    f01069db <__umoddi3+0x11b>
f01069ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01069ce:	73 0b                	jae    f01069db <__umoddi3+0x11b>
f01069d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01069d4:	1b 14 24             	sbb    (%esp),%edx
f01069d7:	89 d1                	mov    %edx,%ecx
f01069d9:	89 c3                	mov    %eax,%ebx
f01069db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01069df:	29 da                	sub    %ebx,%edx
f01069e1:	19 ce                	sbb    %ecx,%esi
f01069e3:	89 f9                	mov    %edi,%ecx
f01069e5:	89 f0                	mov    %esi,%eax
f01069e7:	d3 e0                	shl    %cl,%eax
f01069e9:	89 e9                	mov    %ebp,%ecx
f01069eb:	d3 ea                	shr    %cl,%edx
f01069ed:	89 e9                	mov    %ebp,%ecx
f01069ef:	d3 ee                	shr    %cl,%esi
f01069f1:	09 d0                	or     %edx,%eax
f01069f3:	89 f2                	mov    %esi,%edx
f01069f5:	83 c4 1c             	add    $0x1c,%esp
f01069f8:	5b                   	pop    %ebx
f01069f9:	5e                   	pop    %esi
f01069fa:	5f                   	pop    %edi
f01069fb:	5d                   	pop    %ebp
f01069fc:	c3                   	ret    
f01069fd:	8d 76 00             	lea    0x0(%esi),%esi
f0106a00:	29 f9                	sub    %edi,%ecx
f0106a02:	19 d6                	sbb    %edx,%esi
f0106a04:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106a08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a0c:	e9 18 ff ff ff       	jmp    f0106929 <__umoddi3+0x69>
