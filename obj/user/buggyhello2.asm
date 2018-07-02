
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 38 1f 80 00       	push   $0x801f38
  800118:	6a 23                	push   $0x23
  80011a:	68 55 1f 80 00       	push   $0x801f55
  80011f:	e8 69 0f 00 00       	call   80108d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 38 1f 80 00       	push   $0x801f38
  800199:	6a 23                	push   $0x23
  80019b:	68 55 1f 80 00       	push   $0x801f55
  8001a0:	e8 e8 0e 00 00       	call   80108d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 38 1f 80 00       	push   $0x801f38
  8001db:	6a 23                	push   $0x23
  8001dd:	68 55 1f 80 00       	push   $0x801f55
  8001e2:	e8 a6 0e 00 00       	call   80108d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 38 1f 80 00       	push   $0x801f38
  80021d:	6a 23                	push   $0x23
  80021f:	68 55 1f 80 00       	push   $0x801f55
  800224:	e8 64 0e 00 00       	call   80108d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 38 1f 80 00       	push   $0x801f38
  80025f:	6a 23                	push   $0x23
  800261:	68 55 1f 80 00       	push   $0x801f55
  800266:	e8 22 0e 00 00       	call   80108d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 0a 00 00 00       	mov    $0xa,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 0a                	push   $0xa
  80029c:	68 38 1f 80 00       	push   $0x801f38
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 55 1f 80 00       	push   $0x801f55
  8002a8:	e8 e0 0d 00 00       	call   80108d <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 09                	push   $0x9
  8002de:	68 38 1f 80 00       	push   $0x801f38
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 55 1f 80 00       	push   $0x801f55
  8002ea:	e8 9e 0d 00 00       	call   80108d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 38 1f 80 00       	push   $0x801f38
  800347:	6a 23                	push   $0x23
  800349:	68 55 1f 80 00       	push   $0x801f55
  80034e:	e8 3a 0d 00 00       	call   80108d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba e0 1f 80 00       	mov    $0x801fe0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 08 40 80 00       	mov    0x804008,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 64 1f 80 00       	push   $0x801f64
  800462:	e8 ff 0c 00 00       	call   801166 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2) 
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0); 
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close) 
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 08 40 80 00       	mov    0x804008,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 a5 1f 80 00       	push   $0x801fa5
  80068c:	e8 d5 0a 00 00       	call   801166 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 08 40 80 00       	mov    0x804008,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 c1 1f 80 00       	push   $0x801fc1
  800761:	e8 00 0a 00 00       	call   801166 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 84 1f 80 00       	push   $0x801f84
  800816:	e8 4b 09 00 00       	call   801166 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 2b 02 00 00       	call   800b0a <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 f1 12 00 00       	call   801c17 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 80 12 00 00       	call   801bc1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 0a 12 00 00       	call   801b58 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 c3 0d 00 00       	call   80179a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	8b 45 10             	mov    0x10(%ebp),%eax
  800a04:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a09:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a0e:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 40 0c             	mov    0xc(%eax),%eax
  800a17:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a1c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a22:	53                   	push   %ebx
  800a23:	ff 75 0c             	pushl  0xc(%ebp)
  800a26:	68 08 50 80 00       	push   $0x805008
  800a2b:	e8 fc 0e 00 00       	call   80192c <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
  800a35:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3a:	e8 cb fe ff ff       	call   80090a <fsipc>
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	85 c0                	test   %eax,%eax
  800a44:	78 3d                	js     800a83 <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a46:	39 d8                	cmp    %ebx,%eax
  800a48:	76 19                	jbe    800a63 <devfile_write+0x69>
  800a4a:	68 f0 1f 80 00       	push   $0x801ff0
  800a4f:	68 f7 1f 80 00       	push   $0x801ff7
  800a54:	68 9f 00 00 00       	push   $0x9f
  800a59:	68 0c 20 80 00       	push   $0x80200c
  800a5e:	e8 2a 06 00 00       	call   80108d <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a63:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a68:	76 19                	jbe    800a83 <devfile_write+0x89>
  800a6a:	68 24 20 80 00       	push   $0x802024
  800a6f:	68 f7 1f 80 00       	push   $0x801ff7
  800a74:	68 a0 00 00 00       	push   $0xa0
  800a79:	68 0c 20 80 00       	push   $0x80200c
  800a7e:	e8 0a 06 00 00       	call   80108d <_panic>

	return r;
}
  800a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 40 0c             	mov    0xc(%eax),%eax
  800a96:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a9b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aab:	e8 5a fe ff ff       	call   80090a <fsipc>
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	78 4b                	js     800b01 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 16                	jae    800ad0 <devfile_read+0x48>
  800aba:	68 f0 1f 80 00       	push   $0x801ff0
  800abf:	68 f7 1f 80 00       	push   $0x801ff7
  800ac4:	6a 7e                	push   $0x7e
  800ac6:	68 0c 20 80 00       	push   $0x80200c
  800acb:	e8 bd 05 00 00       	call   80108d <_panic>
	assert(r <= PGSIZE);
  800ad0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad5:	7e 16                	jle    800aed <devfile_read+0x65>
  800ad7:	68 17 20 80 00       	push   $0x802017
  800adc:	68 f7 1f 80 00       	push   $0x801ff7
  800ae1:	6a 7f                	push   $0x7f
  800ae3:	68 0c 20 80 00       	push   $0x80200c
  800ae8:	e8 a0 05 00 00       	call   80108d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aed:	83 ec 04             	sub    $0x4,%esp
  800af0:	50                   	push   %eax
  800af1:	68 00 50 80 00       	push   $0x805000
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	e8 2e 0e 00 00       	call   80192c <memmove>
	return r;
  800afe:	83 c4 10             	add    $0x10,%esp
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 20             	sub    $0x20,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b14:	53                   	push   %ebx
  800b15:	e8 47 0c 00 00       	call   801761 <strlen>
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b22:	7f 67                	jg     800b8b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	e8 52 f8 ff ff       	call   800382 <fd_alloc>
  800b30:	83 c4 10             	add    $0x10,%esp
		return r;
  800b33:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	78 57                	js     800b90 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b39:	83 ec 08             	sub    $0x8,%esp
  800b3c:	53                   	push   %ebx
  800b3d:	68 00 50 80 00       	push   $0x805000
  800b42:	e8 53 0c 00 00       	call   80179a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	e8 ae fd ff ff       	call   80090a <fsipc>
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	85 c0                	test   %eax,%eax
  800b63:	79 14                	jns    800b79 <open+0x6f>
		fd_close(fd, 0);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6d:	e8 08 f9 ff ff       	call   80047a <fd_close>
		return r;
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	89 da                	mov    %ebx,%edx
  800b77:	eb 17                	jmp    800b90 <open+0x86>
	}

	return fd2num(fd);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7f:	e8 d7 f7 ff ff       	call   80035b <fd2num>
  800b84:	89 c2                	mov    %eax,%edx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 05                	jmp    800b90 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b8b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b90:	89 d0                	mov    %edx,%eax
  800b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba7:	e8 5e fd ff ff       	call   80090a <fsipc>
}
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	ff 75 08             	pushl  0x8(%ebp)
  800bbc:	e8 aa f7 ff ff       	call   80036b <fd2data>
  800bc1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc3:	83 c4 08             	add    $0x8,%esp
  800bc6:	68 51 20 80 00       	push   $0x802051
  800bcb:	53                   	push   %ebx
  800bcc:	e8 c9 0b 00 00       	call   80179a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd1:	8b 46 04             	mov    0x4(%esi),%eax
  800bd4:	2b 06                	sub    (%esi),%eax
  800bd6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bdc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be3:	00 00 00 
	stat->st_dev = &devpipe;
  800be6:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bed:	30 80 00 
	return 0;
}
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c06:	53                   	push   %ebx
  800c07:	6a 00                	push   $0x0
  800c09:	e8 e1 f5 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c0e:	89 1c 24             	mov    %ebx,(%esp)
  800c11:	e8 55 f7 ff ff       	call   80036b <fd2data>
  800c16:	83 c4 08             	add    $0x8,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 00                	push   $0x0
  800c1c:	e8 ce f5 ff ff       	call   8001ef <sys_page_unmap>
}
  800c21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 1c             	sub    $0x1c,%esp
  800c2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c32:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c34:	a1 08 40 80 00       	mov    0x804008,%eax
  800c39:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	ff 75 e0             	pushl  -0x20(%ebp)
  800c42:	e8 09 10 00 00       	call   801c50 <pageref>
  800c47:	89 c3                	mov    %eax,%ebx
  800c49:	89 3c 24             	mov    %edi,(%esp)
  800c4c:	e8 ff 0f 00 00       	call   801c50 <pageref>
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	39 c3                	cmp    %eax,%ebx
  800c56:	0f 94 c1             	sete   %cl
  800c59:	0f b6 c9             	movzbl %cl,%ecx
  800c5c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c5f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c65:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c68:	39 ce                	cmp    %ecx,%esi
  800c6a:	74 1b                	je     800c87 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c6c:	39 c3                	cmp    %eax,%ebx
  800c6e:	75 c4                	jne    800c34 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c70:	8b 42 58             	mov    0x58(%edx),%eax
  800c73:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c76:	50                   	push   %eax
  800c77:	56                   	push   %esi
  800c78:	68 58 20 80 00       	push   $0x802058
  800c7d:	e8 e4 04 00 00       	call   801166 <cprintf>
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	eb ad                	jmp    800c34 <_pipeisclosed+0xe>
	}
}
  800c87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 28             	sub    $0x28,%esp
  800c9b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9e:	56                   	push   %esi
  800c9f:	e8 c7 f6 ff ff       	call   80036b <fd2data>
  800ca4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cae:	eb 4b                	jmp    800cfb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cb0:	89 da                	mov    %ebx,%edx
  800cb2:	89 f0                	mov    %esi,%eax
  800cb4:	e8 6d ff ff ff       	call   800c26 <_pipeisclosed>
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	75 48                	jne    800d05 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cbd:	e8 89 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cc2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc5:	8b 0b                	mov    (%ebx),%ecx
  800cc7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cca:	39 d0                	cmp    %edx,%eax
  800ccc:	73 e2                	jae    800cb0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	c1 fa 1f             	sar    $0x1f,%edx
  800cdd:	89 d1                	mov    %edx,%ecx
  800cdf:	c1 e9 1b             	shr    $0x1b,%ecx
  800ce2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce5:	83 e2 1f             	and    $0x1f,%edx
  800ce8:	29 ca                	sub    %ecx,%edx
  800cea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf8:	83 c7 01             	add    $0x1,%edi
  800cfb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cfe:	75 c2                	jne    800cc2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d00:	8b 45 10             	mov    0x10(%ebp),%eax
  800d03:	eb 05                	jmp    800d0a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 18             	sub    $0x18,%esp
  800d1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1e:	57                   	push   %edi
  800d1f:	e8 47 f6 ff ff       	call   80036b <fd2data>
  800d24:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d26:	83 c4 10             	add    $0x10,%esp
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	eb 3d                	jmp    800d6d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d30:	85 db                	test   %ebx,%ebx
  800d32:	74 04                	je     800d38 <devpipe_read+0x26>
				return i;
  800d34:	89 d8                	mov    %ebx,%eax
  800d36:	eb 44                	jmp    800d7c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	89 f8                	mov    %edi,%eax
  800d3c:	e8 e5 fe ff ff       	call   800c26 <_pipeisclosed>
  800d41:	85 c0                	test   %eax,%eax
  800d43:	75 32                	jne    800d77 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d45:	e8 01 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d4a:	8b 06                	mov    (%esi),%eax
  800d4c:	3b 46 04             	cmp    0x4(%esi),%eax
  800d4f:	74 df                	je     800d30 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d51:	99                   	cltd   
  800d52:	c1 ea 1b             	shr    $0x1b,%edx
  800d55:	01 d0                	add    %edx,%eax
  800d57:	83 e0 1f             	and    $0x1f,%eax
  800d5a:	29 d0                	sub    %edx,%eax
  800d5c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d67:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d6a:	83 c3 01             	add    $0x1,%ebx
  800d6d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d70:	75 d8                	jne    800d4a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d72:	8b 45 10             	mov    0x10(%ebp),%eax
  800d75:	eb 05                	jmp    800d7c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8f:	50                   	push   %eax
  800d90:	e8 ed f5 ff ff       	call   800382 <fd_alloc>
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	89 c2                	mov    %eax,%edx
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	0f 88 2c 01 00 00    	js     800ece <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da2:	83 ec 04             	sub    $0x4,%esp
  800da5:	68 07 04 00 00       	push   $0x407
  800daa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dad:	6a 00                	push   $0x0
  800daf:	e8 b6 f3 ff ff       	call   80016a <sys_page_alloc>
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 0d 01 00 00    	js     800ece <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc7:	50                   	push   %eax
  800dc8:	e8 b5 f5 ff ff       	call   800382 <fd_alloc>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	0f 88 e2 00 00 00    	js     800ebc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	68 07 04 00 00       	push   $0x407
  800de2:	ff 75 f0             	pushl  -0x10(%ebp)
  800de5:	6a 00                	push   $0x0
  800de7:	e8 7e f3 ff ff       	call   80016a <sys_page_alloc>
  800dec:	89 c3                	mov    %eax,%ebx
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	0f 88 c3 00 00 00    	js     800ebc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	ff 75 f4             	pushl  -0xc(%ebp)
  800dff:	e8 67 f5 ff ff       	call   80036b <fd2data>
  800e04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e06:	83 c4 0c             	add    $0xc,%esp
  800e09:	68 07 04 00 00       	push   $0x407
  800e0e:	50                   	push   %eax
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 54 f3 ff ff       	call   80016a <sys_page_alloc>
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	0f 88 89 00 00 00    	js     800eac <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f0             	pushl  -0x10(%ebp)
  800e29:	e8 3d f5 ff ff       	call   80036b <fd2data>
  800e2e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e35:	50                   	push   %eax
  800e36:	6a 00                	push   $0x0
  800e38:	56                   	push   %esi
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 6d f3 ff ff       	call   8001ad <sys_page_map>
  800e40:	89 c3                	mov    %eax,%ebx
  800e42:	83 c4 20             	add    $0x20,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	78 55                	js     800e9e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e49:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	ff 75 f4             	pushl  -0xc(%ebp)
  800e79:	e8 dd f4 ff ff       	call   80035b <fd2num>
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e83:	83 c4 04             	add    $0x4,%esp
  800e86:	ff 75 f0             	pushl  -0x10(%ebp)
  800e89:	e8 cd f4 ff ff       	call   80035b <fd2num>
  800e8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e91:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	eb 30                	jmp    800ece <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	56                   	push   %esi
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 46 f3 ff ff       	call   8001ef <sys_page_unmap>
  800ea9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 36 f3 ff ff       	call   8001ef <sys_page_unmap>
  800eb9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 26 f3 ff ff       	call   8001ef <sys_page_unmap>
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ece:	89 d0                	mov    %edx,%eax
  800ed0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800edd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee0:	50                   	push   %eax
  800ee1:	ff 75 08             	pushl  0x8(%ebp)
  800ee4:	e8 e8 f4 ff ff       	call   8003d1 <fd_lookup>
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 18                	js     800f08 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef6:	e8 70 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800efb:	89 c2                	mov    %eax,%edx
  800efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f00:	e8 21 fd ff ff       	call   800c26 <_pipeisclosed>
  800f05:	83 c4 10             	add    $0x10,%esp
}
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f1a:	68 70 20 80 00       	push   $0x802070
  800f1f:	ff 75 0c             	pushl  0xc(%ebp)
  800f22:	e8 73 08 00 00       	call   80179a <strcpy>
	return 0;
}
  800f27:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f45:	eb 2d                	jmp    800f74 <devcons_write+0x46>
		m = n - tot;
  800f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f4c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f4f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f54:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	03 45 0c             	add    0xc(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	57                   	push   %edi
  800f60:	e8 c7 09 00 00       	call   80192c <memmove>
		sys_cputs(buf, m);
  800f65:	83 c4 08             	add    $0x8,%esp
  800f68:	53                   	push   %ebx
  800f69:	57                   	push   %edi
  800f6a:	e8 3f f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6f:	01 de                	add    %ebx,%esi
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	89 f0                	mov    %esi,%eax
  800f76:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f79:	72 cc                	jb     800f47 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f92:	74 2a                	je     800fbe <devcons_read+0x3b>
  800f94:	eb 05                	jmp    800f9b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f96:	e8 b0 f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f9b:	e8 2c f1 ff ff       	call   8000cc <sys_cgetc>
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	74 f2                	je     800f96 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 16                	js     800fbe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa8:	83 f8 04             	cmp    $0x4,%eax
  800fab:	74 0c                	je     800fb9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb0:	88 02                	mov    %al,(%edx)
	return 1;
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	eb 05                	jmp    800fbe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fcc:	6a 01                	push   $0x1
  800fce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	e8 d7 f0 ff ff       	call   8000ae <sys_cputs>
}
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <getchar>:

int
getchar(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fe2:	6a 01                	push   $0x1
  800fe4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 48 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 0f                	js     801005 <getchar+0x29>
		return r;
	if (r < 1)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 06                	jle    801000 <getchar+0x24>
		return -E_EOF;
	return c;
  800ffa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ffe:	eb 05                	jmp    801005 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801000:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 b8 f3 ff ff       	call   8003d1 <fd_lookup>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 11                	js     801031 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801029:	39 10                	cmp    %edx,(%eax)
  80102b:	0f 94 c0             	sete   %al
  80102e:	0f b6 c0             	movzbl %al,%eax
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <opencons>:

int
opencons(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	e8 40 f3 ff ff       	call   800382 <fd_alloc>
  801042:	83 c4 10             	add    $0x10,%esp
		return r;
  801045:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801047:	85 c0                	test   %eax,%eax
  801049:	78 3e                	js     801089 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 07 04 00 00       	push   $0x407
  801053:	ff 75 f4             	pushl  -0xc(%ebp)
  801056:	6a 00                	push   $0x0
  801058:	e8 0d f1 ff ff       	call   80016a <sys_page_alloc>
  80105d:	83 c4 10             	add    $0x10,%esp
		return r;
  801060:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	78 23                	js     801089 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801066:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80106c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	50                   	push   %eax
  80107f:	e8 d7 f2 ff ff       	call   80035b <fd2num>
  801084:	89 c2                	mov    %eax,%edx
  801086:	83 c4 10             	add    $0x10,%esp
}
  801089:	89 d0                	mov    %edx,%eax
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801092:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801095:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80109b:	e8 8c f0 ff ff       	call   80012c <sys_getenvid>
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	ff 75 0c             	pushl  0xc(%ebp)
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	56                   	push   %esi
  8010aa:	50                   	push   %eax
  8010ab:	68 7c 20 80 00       	push   $0x80207c
  8010b0:	e8 b1 00 00 00       	call   801166 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b5:	83 c4 18             	add    $0x18,%esp
  8010b8:	53                   	push   %ebx
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	e8 54 00 00 00       	call   801115 <vcprintf>
	cprintf("\n");
  8010c1:	c7 04 24 69 20 80 00 	movl   $0x802069,(%esp)
  8010c8:	e8 99 00 00 00       	call   801166 <cprintf>
  8010cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010d0:	cc                   	int3   
  8010d1:	eb fd                	jmp    8010d0 <_panic+0x43>

008010d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010dd:	8b 13                	mov    (%ebx),%edx
  8010df:	8d 42 01             	lea    0x1(%edx),%eax
  8010e2:	89 03                	mov    %eax,(%ebx)
  8010e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010f0:	75 1a                	jne    80110c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	68 ff 00 00 00       	push   $0xff
  8010fa:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 ab ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801103:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801109:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80110c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801110:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801125:	00 00 00 
	b.cnt = 0;
  801128:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801132:	ff 75 0c             	pushl  0xc(%ebp)
  801135:	ff 75 08             	pushl  0x8(%ebp)
  801138:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	68 d3 10 80 00       	push   $0x8010d3
  801144:	e8 54 01 00 00       	call   80129d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801158:	50                   	push   %eax
  801159:	e8 50 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80115e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80116c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116f:	50                   	push   %eax
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 9d ff ff ff       	call   801115 <vcprintf>
	va_end(ap);

	return cnt;
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 1c             	sub    $0x1c,%esp
  801183:	89 c7                	mov    %eax,%edi
  801185:	89 d6                	mov    %edx,%esi
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801190:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801193:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801196:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011a1:	39 d3                	cmp    %edx,%ebx
  8011a3:	72 05                	jb     8011aa <printnum+0x30>
  8011a5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a8:	77 45                	ja     8011ef <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	ff 75 18             	pushl  0x18(%ebp)
  8011b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8011b3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b6:	53                   	push   %ebx
  8011b7:	ff 75 10             	pushl  0x10(%ebp)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c9:	e8 c2 0a 00 00       	call   801c90 <__udivdi3>
  8011ce:	83 c4 18             	add    $0x18,%esp
  8011d1:	52                   	push   %edx
  8011d2:	50                   	push   %eax
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	e8 9e ff ff ff       	call   80117a <printnum>
  8011dc:	83 c4 20             	add    $0x20,%esp
  8011df:	eb 18                	jmp    8011f9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	56                   	push   %esi
  8011e5:	ff 75 18             	pushl  0x18(%ebp)
  8011e8:	ff d7                	call   *%edi
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	eb 03                	jmp    8011f2 <printnum+0x78>
  8011ef:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011f2:	83 eb 01             	sub    $0x1,%ebx
  8011f5:	85 db                	test   %ebx,%ebx
  8011f7:	7f e8                	jg     8011e1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	ff 75 e4             	pushl  -0x1c(%ebp)
  801203:	ff 75 e0             	pushl  -0x20(%ebp)
  801206:	ff 75 dc             	pushl  -0x24(%ebp)
  801209:	ff 75 d8             	pushl  -0x28(%ebp)
  80120c:	e8 af 0b 00 00       	call   801dc0 <__umoddi3>
  801211:	83 c4 14             	add    $0x14,%esp
  801214:	0f be 80 9f 20 80 00 	movsbl 0x80209f(%eax),%eax
  80121b:	50                   	push   %eax
  80121c:	ff d7                	call   *%edi
}
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80122c:	83 fa 01             	cmp    $0x1,%edx
  80122f:	7e 0e                	jle    80123f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801231:	8b 10                	mov    (%eax),%edx
  801233:	8d 4a 08             	lea    0x8(%edx),%ecx
  801236:	89 08                	mov    %ecx,(%eax)
  801238:	8b 02                	mov    (%edx),%eax
  80123a:	8b 52 04             	mov    0x4(%edx),%edx
  80123d:	eb 22                	jmp    801261 <getuint+0x38>
	else if (lflag)
  80123f:	85 d2                	test   %edx,%edx
  801241:	74 10                	je     801253 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801243:	8b 10                	mov    (%eax),%edx
  801245:	8d 4a 04             	lea    0x4(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
  801251:	eb 0e                	jmp    801261 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801253:	8b 10                	mov    (%eax),%edx
  801255:	8d 4a 04             	lea    0x4(%edx),%ecx
  801258:	89 08                	mov    %ecx,(%eax)
  80125a:	8b 02                	mov    (%edx),%eax
  80125c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	3b 50 04             	cmp    0x4(%eax),%edx
  801272:	73 0a                	jae    80127e <sprintputch+0x1b>
		*b->buf++ = ch;
  801274:	8d 4a 01             	lea    0x1(%edx),%ecx
  801277:	89 08                	mov    %ecx,(%eax)
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	88 02                	mov    %al,(%edx)
}
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801286:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801289:	50                   	push   %eax
  80128a:	ff 75 10             	pushl  0x10(%ebp)
  80128d:	ff 75 0c             	pushl  0xc(%ebp)
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 05 00 00 00       	call   80129d <vprintfmt>
	va_end(ap);
}
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 2c             	sub    $0x2c,%esp
  8012a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012af:	eb 12                	jmp    8012c3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	0f 84 38 04 00 00    	je     8016f1 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	50                   	push   %eax
  8012be:	ff d6                	call   *%esi
  8012c0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012c3:	83 c7 01             	add    $0x1,%edi
  8012c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ca:	83 f8 25             	cmp    $0x25,%eax
  8012cd:	75 e2                	jne    8012b1 <vprintfmt+0x14>
  8012cf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012d3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ed:	eb 07                	jmp    8012f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	8d 47 01             	lea    0x1(%edi),%eax
  8012f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fc:	0f b6 07             	movzbl (%edi),%eax
  8012ff:	0f b6 c8             	movzbl %al,%ecx
  801302:	83 e8 23             	sub    $0x23,%eax
  801305:	3c 55                	cmp    $0x55,%al
  801307:	0f 87 c9 03 00 00    	ja     8016d6 <vprintfmt+0x439>
  80130d:	0f b6 c0             	movzbl %al,%eax
  801310:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80131a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131e:	eb d6                	jmp    8012f6 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  801320:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801327:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80132d:	eb 94                	jmp    8012c3 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80132f:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801336:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  80133c:	eb 85                	jmp    8012c3 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80133e:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  801345:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  80134b:	e9 73 ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  801350:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801357:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80135d:	e9 61 ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  801362:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801369:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80136f:	e9 4f ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  801374:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  80137b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  801381:	e9 3d ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801386:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  80138d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  801393:	e9 2b ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801398:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  80139f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8013a5:	e9 19 ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8013aa:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013b1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013b7:	e9 07 ff ff ff       	jmp    8012c3 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013bc:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013c3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013c9:	e9 f5 fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013e6:	83 fa 09             	cmp    $0x9,%edx
  8013e9:	77 3f                	ja     80142a <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013ee:	eb e9                	jmp    8013d9 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8013f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013f9:	8b 00                	mov    (%eax),%eax
  8013fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801401:	eb 2d                	jmp    801430 <vprintfmt+0x193>
  801403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801406:	85 c0                	test   %eax,%eax
  801408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80140d:	0f 49 c8             	cmovns %eax,%ecx
  801410:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801416:	e9 db fe ff ff       	jmp    8012f6 <vprintfmt+0x59>
  80141b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80141e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801425:	e9 cc fe ff ff       	jmp    8012f6 <vprintfmt+0x59>
  80142a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80142d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801430:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801434:	0f 89 bc fe ff ff    	jns    8012f6 <vprintfmt+0x59>
				width = precision, precision = -1;
  80143a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80143d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801440:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801447:	e9 aa fe ff ff       	jmp    8012f6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80144c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80144f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801452:	e9 9f fe ff ff       	jmp    8012f6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801457:	8b 45 14             	mov    0x14(%ebp),%eax
  80145a:	8d 50 04             	lea    0x4(%eax),%edx
  80145d:	89 55 14             	mov    %edx,0x14(%ebp)
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	53                   	push   %ebx
  801464:	ff 30                	pushl  (%eax)
  801466:	ff d6                	call   *%esi
			break;
  801468:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80146e:	e9 50 fe ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801473:	8b 45 14             	mov    0x14(%ebp),%eax
  801476:	8d 50 04             	lea    0x4(%eax),%edx
  801479:	89 55 14             	mov    %edx,0x14(%ebp)
  80147c:	8b 00                	mov    (%eax),%eax
  80147e:	99                   	cltd   
  80147f:	31 d0                	xor    %edx,%eax
  801481:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801483:	83 f8 0f             	cmp    $0xf,%eax
  801486:	7f 0b                	jg     801493 <vprintfmt+0x1f6>
  801488:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80148f:	85 d2                	test   %edx,%edx
  801491:	75 18                	jne    8014ab <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  801493:	50                   	push   %eax
  801494:	68 b7 20 80 00       	push   $0x8020b7
  801499:	53                   	push   %ebx
  80149a:	56                   	push   %esi
  80149b:	e8 e0 fd ff ff       	call   801280 <printfmt>
  8014a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014a6:	e9 18 fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8014ab:	52                   	push   %edx
  8014ac:	68 09 20 80 00       	push   $0x802009
  8014b1:	53                   	push   %ebx
  8014b2:	56                   	push   %esi
  8014b3:	e8 c8 fd ff ff       	call   801280 <printfmt>
  8014b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014be:	e9 00 fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c6:	8d 50 04             	lea    0x4(%eax),%edx
  8014c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014ce:	85 ff                	test   %edi,%edi
  8014d0:	b8 b0 20 80 00       	mov    $0x8020b0,%eax
  8014d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014dc:	0f 8e 94 00 00 00    	jle    801576 <vprintfmt+0x2d9>
  8014e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014e6:	0f 84 98 00 00 00    	je     801584 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8014f2:	57                   	push   %edi
  8014f3:	e8 81 02 00 00       	call   801779 <strnlen>
  8014f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014fb:	29 c1                	sub    %eax,%ecx
  8014fd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801500:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801503:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801507:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80150a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80150d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80150f:	eb 0f                	jmp    801520 <vprintfmt+0x283>
					putch(padc, putdat);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	53                   	push   %ebx
  801515:	ff 75 e0             	pushl  -0x20(%ebp)
  801518:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80151a:	83 ef 01             	sub    $0x1,%edi
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 ff                	test   %edi,%edi
  801522:	7f ed                	jg     801511 <vprintfmt+0x274>
  801524:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801527:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80152a:	85 c9                	test   %ecx,%ecx
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
  801531:	0f 49 c1             	cmovns %ecx,%eax
  801534:	29 c1                	sub    %eax,%ecx
  801536:	89 75 08             	mov    %esi,0x8(%ebp)
  801539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80153c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80153f:	89 cb                	mov    %ecx,%ebx
  801541:	eb 4d                	jmp    801590 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801543:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801547:	74 1b                	je     801564 <vprintfmt+0x2c7>
  801549:	0f be c0             	movsbl %al,%eax
  80154c:	83 e8 20             	sub    $0x20,%eax
  80154f:	83 f8 5e             	cmp    $0x5e,%eax
  801552:	76 10                	jbe    801564 <vprintfmt+0x2c7>
					putch('?', putdat);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	ff 75 0c             	pushl  0xc(%ebp)
  80155a:	6a 3f                	push   $0x3f
  80155c:	ff 55 08             	call   *0x8(%ebp)
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	eb 0d                	jmp    801571 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	52                   	push   %edx
  80156b:	ff 55 08             	call   *0x8(%ebp)
  80156e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801571:	83 eb 01             	sub    $0x1,%ebx
  801574:	eb 1a                	jmp    801590 <vprintfmt+0x2f3>
  801576:	89 75 08             	mov    %esi,0x8(%ebp)
  801579:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80157c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80157f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801582:	eb 0c                	jmp    801590 <vprintfmt+0x2f3>
  801584:	89 75 08             	mov    %esi,0x8(%ebp)
  801587:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80158a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80158d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801590:	83 c7 01             	add    $0x1,%edi
  801593:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801597:	0f be d0             	movsbl %al,%edx
  80159a:	85 d2                	test   %edx,%edx
  80159c:	74 23                	je     8015c1 <vprintfmt+0x324>
  80159e:	85 f6                	test   %esi,%esi
  8015a0:	78 a1                	js     801543 <vprintfmt+0x2a6>
  8015a2:	83 ee 01             	sub    $0x1,%esi
  8015a5:	79 9c                	jns    801543 <vprintfmt+0x2a6>
  8015a7:	89 df                	mov    %ebx,%edi
  8015a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015af:	eb 18                	jmp    8015c9 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	6a 20                	push   $0x20
  8015b7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015b9:	83 ef 01             	sub    $0x1,%edi
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 08                	jmp    8015c9 <vprintfmt+0x32c>
  8015c1:	89 df                	mov    %ebx,%edi
  8015c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015c9:	85 ff                	test   %edi,%edi
  8015cb:	7f e4                	jg     8015b1 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d0:	e9 ee fc ff ff       	jmp    8012c3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d5:	83 fa 01             	cmp    $0x1,%edx
  8015d8:	7e 16                	jle    8015f0 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015da:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dd:	8d 50 08             	lea    0x8(%eax),%edx
  8015e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8015e3:	8b 50 04             	mov    0x4(%eax),%edx
  8015e6:	8b 00                	mov    (%eax),%eax
  8015e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015ee:	eb 32                	jmp    801622 <vprintfmt+0x385>
	else if (lflag)
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	74 18                	je     80160c <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f7:	8d 50 04             	lea    0x4(%eax),%edx
  8015fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8015fd:	8b 00                	mov    (%eax),%eax
  8015ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801602:	89 c1                	mov    %eax,%ecx
  801604:	c1 f9 1f             	sar    $0x1f,%ecx
  801607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80160a:	eb 16                	jmp    801622 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  80160c:	8b 45 14             	mov    0x14(%ebp),%eax
  80160f:	8d 50 04             	lea    0x4(%eax),%edx
  801612:	89 55 14             	mov    %edx,0x14(%ebp)
  801615:	8b 00                	mov    (%eax),%eax
  801617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80161a:	89 c1                	mov    %eax,%ecx
  80161c:	c1 f9 1f             	sar    $0x1f,%ecx
  80161f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801622:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801625:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801628:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80162d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801631:	79 6f                	jns    8016a2 <vprintfmt+0x405>
				putch('-', putdat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	53                   	push   %ebx
  801637:	6a 2d                	push   $0x2d
  801639:	ff d6                	call   *%esi
				num = -(long long) num;
  80163b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80163e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801641:	f7 d8                	neg    %eax
  801643:	83 d2 00             	adc    $0x0,%edx
  801646:	f7 da                	neg    %edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 55                	jmp    8016a2 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80164d:	8d 45 14             	lea    0x14(%ebp),%eax
  801650:	e8 d4 fb ff ff       	call   801229 <getuint>
			base = 10;
  801655:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80165a:	eb 46                	jmp    8016a2 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80165c:	8d 45 14             	lea    0x14(%ebp),%eax
  80165f:	e8 c5 fb ff ff       	call   801229 <getuint>
			base = 8;
  801664:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801669:	eb 37                	jmp    8016a2 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  80166b:	83 ec 08             	sub    $0x8,%esp
  80166e:	53                   	push   %ebx
  80166f:	6a 30                	push   $0x30
  801671:	ff d6                	call   *%esi
			putch('x', putdat);
  801673:	83 c4 08             	add    $0x8,%esp
  801676:	53                   	push   %ebx
  801677:	6a 78                	push   $0x78
  801679:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80167b:	8b 45 14             	mov    0x14(%ebp),%eax
  80167e:	8d 50 04             	lea    0x4(%eax),%edx
  801681:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801684:	8b 00                	mov    (%eax),%eax
  801686:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80168b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80168e:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  801693:	eb 0d                	jmp    8016a2 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801695:	8d 45 14             	lea    0x14(%ebp),%eax
  801698:	e8 8c fb ff ff       	call   801229 <getuint>
			base = 16;
  80169d:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8016a9:	51                   	push   %ecx
  8016aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ad:	57                   	push   %edi
  8016ae:	52                   	push   %edx
  8016af:	50                   	push   %eax
  8016b0:	89 da                	mov    %ebx,%edx
  8016b2:	89 f0                	mov    %esi,%eax
  8016b4:	e8 c1 fa ff ff       	call   80117a <printnum>
			break;
  8016b9:	83 c4 20             	add    $0x20,%esp
  8016bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016bf:	e9 ff fb ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	53                   	push   %ebx
  8016c8:	51                   	push   %ecx
  8016c9:	ff d6                	call   *%esi
			break;
  8016cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016d1:	e9 ed fb ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	53                   	push   %ebx
  8016da:	6a 25                	push   $0x25
  8016dc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	eb 03                	jmp    8016e6 <vprintfmt+0x449>
  8016e3:	83 ef 01             	sub    $0x1,%edi
  8016e6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016ea:	75 f7                	jne    8016e3 <vprintfmt+0x446>
  8016ec:	e9 d2 fb ff ff       	jmp    8012c3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5f                   	pop    %edi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 18             	sub    $0x18,%esp
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801708:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80170c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80170f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801716:	85 c0                	test   %eax,%eax
  801718:	74 26                	je     801740 <vsnprintf+0x47>
  80171a:	85 d2                	test   %edx,%edx
  80171c:	7e 22                	jle    801740 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80171e:	ff 75 14             	pushl  0x14(%ebp)
  801721:	ff 75 10             	pushl  0x10(%ebp)
  801724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801727:	50                   	push   %eax
  801728:	68 63 12 80 00       	push   $0x801263
  80172d:	e8 6b fb ff ff       	call   80129d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801735:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	eb 05                	jmp    801745 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80174d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801750:	50                   	push   %eax
  801751:	ff 75 10             	pushl  0x10(%ebp)
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 9a ff ff ff       	call   8016f9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
  80176c:	eb 03                	jmp    801771 <strlen+0x10>
		n++;
  80176e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801775:	75 f7                	jne    80176e <strlen+0xd>
		n++;
	return n;
}
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	eb 03                	jmp    80178c <strnlen+0x13>
		n++;
  801789:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80178c:	39 c2                	cmp    %eax,%edx
  80178e:	74 08                	je     801798 <strnlen+0x1f>
  801790:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801794:	75 f3                	jne    801789 <strnlen+0x10>
  801796:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	83 c2 01             	add    $0x1,%edx
  8017a9:	83 c1 01             	add    $0x1,%ecx
  8017ac:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017b0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017b3:	84 db                	test   %bl,%bl
  8017b5:	75 ef                	jne    8017a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017b7:	5b                   	pop    %ebx
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017c1:	53                   	push   %ebx
  8017c2:	e8 9a ff ff ff       	call   801761 <strlen>
  8017c7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	01 d8                	add    %ebx,%eax
  8017cf:	50                   	push   %eax
  8017d0:	e8 c5 ff ff ff       	call   80179a <strcpy>
	return dst;
}
  8017d5:	89 d8                	mov    %ebx,%eax
  8017d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8017e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e7:	89 f3                	mov    %esi,%ebx
  8017e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017ec:	89 f2                	mov    %esi,%edx
  8017ee:	eb 0f                	jmp    8017ff <strncpy+0x23>
		*dst++ = *src;
  8017f0:	83 c2 01             	add    $0x1,%edx
  8017f3:	0f b6 01             	movzbl (%ecx),%eax
  8017f6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017f9:	80 39 01             	cmpb   $0x1,(%ecx)
  8017fc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017ff:	39 da                	cmp    %ebx,%edx
  801801:	75 ed                	jne    8017f0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801803:	89 f0                	mov    %esi,%eax
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	56                   	push   %esi
  80180d:	53                   	push   %ebx
  80180e:	8b 75 08             	mov    0x8(%ebp),%esi
  801811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801814:	8b 55 10             	mov    0x10(%ebp),%edx
  801817:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801819:	85 d2                	test   %edx,%edx
  80181b:	74 21                	je     80183e <strlcpy+0x35>
  80181d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801821:	89 f2                	mov    %esi,%edx
  801823:	eb 09                	jmp    80182e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801825:	83 c2 01             	add    $0x1,%edx
  801828:	83 c1 01             	add    $0x1,%ecx
  80182b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80182e:	39 c2                	cmp    %eax,%edx
  801830:	74 09                	je     80183b <strlcpy+0x32>
  801832:	0f b6 19             	movzbl (%ecx),%ebx
  801835:	84 db                	test   %bl,%bl
  801837:	75 ec                	jne    801825 <strlcpy+0x1c>
  801839:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80183b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80183e:	29 f0                	sub    %esi,%eax
}
  801840:	5b                   	pop    %ebx
  801841:	5e                   	pop    %esi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80184a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80184d:	eb 06                	jmp    801855 <strcmp+0x11>
		p++, q++;
  80184f:	83 c1 01             	add    $0x1,%ecx
  801852:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801855:	0f b6 01             	movzbl (%ecx),%eax
  801858:	84 c0                	test   %al,%al
  80185a:	74 04                	je     801860 <strcmp+0x1c>
  80185c:	3a 02                	cmp    (%edx),%al
  80185e:	74 ef                	je     80184f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801860:	0f b6 c0             	movzbl %al,%eax
  801863:	0f b6 12             	movzbl (%edx),%edx
  801866:	29 d0                	sub    %edx,%eax
}
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	53                   	push   %ebx
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 55 0c             	mov    0xc(%ebp),%edx
  801874:	89 c3                	mov    %eax,%ebx
  801876:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801879:	eb 06                	jmp    801881 <strncmp+0x17>
		n--, p++, q++;
  80187b:	83 c0 01             	add    $0x1,%eax
  80187e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801881:	39 d8                	cmp    %ebx,%eax
  801883:	74 15                	je     80189a <strncmp+0x30>
  801885:	0f b6 08             	movzbl (%eax),%ecx
  801888:	84 c9                	test   %cl,%cl
  80188a:	74 04                	je     801890 <strncmp+0x26>
  80188c:	3a 0a                	cmp    (%edx),%cl
  80188e:	74 eb                	je     80187b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801890:	0f b6 00             	movzbl (%eax),%eax
  801893:	0f b6 12             	movzbl (%edx),%edx
  801896:	29 d0                	sub    %edx,%eax
  801898:	eb 05                	jmp    80189f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80189a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80189f:	5b                   	pop    %ebx
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018ac:	eb 07                	jmp    8018b5 <strchr+0x13>
		if (*s == c)
  8018ae:	38 ca                	cmp    %cl,%dl
  8018b0:	74 0f                	je     8018c1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018b2:	83 c0 01             	add    $0x1,%eax
  8018b5:	0f b6 10             	movzbl (%eax),%edx
  8018b8:	84 d2                	test   %dl,%dl
  8018ba:	75 f2                	jne    8018ae <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    

008018c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018cd:	eb 03                	jmp    8018d2 <strfind+0xf>
  8018cf:	83 c0 01             	add    $0x1,%eax
  8018d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018d5:	38 ca                	cmp    %cl,%dl
  8018d7:	74 04                	je     8018dd <strfind+0x1a>
  8018d9:	84 d2                	test   %dl,%dl
  8018db:	75 f2                	jne    8018cf <strfind+0xc>
			break;
	return (char *) s;
}
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	57                   	push   %edi
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018eb:	85 c9                	test   %ecx,%ecx
  8018ed:	74 36                	je     801925 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018f5:	75 28                	jne    80191f <memset+0x40>
  8018f7:	f6 c1 03             	test   $0x3,%cl
  8018fa:	75 23                	jne    80191f <memset+0x40>
		c &= 0xFF;
  8018fc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801900:	89 d3                	mov    %edx,%ebx
  801902:	c1 e3 08             	shl    $0x8,%ebx
  801905:	89 d6                	mov    %edx,%esi
  801907:	c1 e6 18             	shl    $0x18,%esi
  80190a:	89 d0                	mov    %edx,%eax
  80190c:	c1 e0 10             	shl    $0x10,%eax
  80190f:	09 f0                	or     %esi,%eax
  801911:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801913:	89 d8                	mov    %ebx,%eax
  801915:	09 d0                	or     %edx,%eax
  801917:	c1 e9 02             	shr    $0x2,%ecx
  80191a:	fc                   	cld    
  80191b:	f3 ab                	rep stos %eax,%es:(%edi)
  80191d:	eb 06                	jmp    801925 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80191f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801922:	fc                   	cld    
  801923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801925:	89 f8                	mov    %edi,%eax
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5f                   	pop    %edi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	57                   	push   %edi
  801930:	56                   	push   %esi
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	8b 75 0c             	mov    0xc(%ebp),%esi
  801937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80193a:	39 c6                	cmp    %eax,%esi
  80193c:	73 35                	jae    801973 <memmove+0x47>
  80193e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801941:	39 d0                	cmp    %edx,%eax
  801943:	73 2e                	jae    801973 <memmove+0x47>
		s += n;
		d += n;
  801945:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801948:	89 d6                	mov    %edx,%esi
  80194a:	09 fe                	or     %edi,%esi
  80194c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801952:	75 13                	jne    801967 <memmove+0x3b>
  801954:	f6 c1 03             	test   $0x3,%cl
  801957:	75 0e                	jne    801967 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801959:	83 ef 04             	sub    $0x4,%edi
  80195c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80195f:	c1 e9 02             	shr    $0x2,%ecx
  801962:	fd                   	std    
  801963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801965:	eb 09                	jmp    801970 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801967:	83 ef 01             	sub    $0x1,%edi
  80196a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80196d:	fd                   	std    
  80196e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801970:	fc                   	cld    
  801971:	eb 1d                	jmp    801990 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801973:	89 f2                	mov    %esi,%edx
  801975:	09 c2                	or     %eax,%edx
  801977:	f6 c2 03             	test   $0x3,%dl
  80197a:	75 0f                	jne    80198b <memmove+0x5f>
  80197c:	f6 c1 03             	test   $0x3,%cl
  80197f:	75 0a                	jne    80198b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801981:	c1 e9 02             	shr    $0x2,%ecx
  801984:	89 c7                	mov    %eax,%edi
  801986:	fc                   	cld    
  801987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801989:	eb 05                	jmp    801990 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80198b:	89 c7                	mov    %eax,%edi
  80198d:	fc                   	cld    
  80198e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801997:	ff 75 10             	pushl  0x10(%ebp)
  80199a:	ff 75 0c             	pushl  0xc(%ebp)
  80199d:	ff 75 08             	pushl  0x8(%ebp)
  8019a0:	e8 87 ff ff ff       	call   80192c <memmove>
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b2:	89 c6                	mov    %eax,%esi
  8019b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019b7:	eb 1a                	jmp    8019d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8019b9:	0f b6 08             	movzbl (%eax),%ecx
  8019bc:	0f b6 1a             	movzbl (%edx),%ebx
  8019bf:	38 d9                	cmp    %bl,%cl
  8019c1:	74 0a                	je     8019cd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019c3:	0f b6 c1             	movzbl %cl,%eax
  8019c6:	0f b6 db             	movzbl %bl,%ebx
  8019c9:	29 d8                	sub    %ebx,%eax
  8019cb:	eb 0f                	jmp    8019dc <memcmp+0x35>
		s1++, s2++;
  8019cd:	83 c0 01             	add    $0x1,%eax
  8019d0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019d3:	39 f0                	cmp    %esi,%eax
  8019d5:	75 e2                	jne    8019b9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	53                   	push   %ebx
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019e7:	89 c1                	mov    %eax,%ecx
  8019e9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019ec:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019f0:	eb 0a                	jmp    8019fc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019f2:	0f b6 10             	movzbl (%eax),%edx
  8019f5:	39 da                	cmp    %ebx,%edx
  8019f7:	74 07                	je     801a00 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019f9:	83 c0 01             	add    $0x1,%eax
  8019fc:	39 c8                	cmp    %ecx,%eax
  8019fe:	72 f2                	jb     8019f2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a00:	5b                   	pop    %ebx
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	57                   	push   %edi
  801a07:	56                   	push   %esi
  801a08:	53                   	push   %ebx
  801a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a0f:	eb 03                	jmp    801a14 <strtol+0x11>
		s++;
  801a11:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a14:	0f b6 01             	movzbl (%ecx),%eax
  801a17:	3c 20                	cmp    $0x20,%al
  801a19:	74 f6                	je     801a11 <strtol+0xe>
  801a1b:	3c 09                	cmp    $0x9,%al
  801a1d:	74 f2                	je     801a11 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a1f:	3c 2b                	cmp    $0x2b,%al
  801a21:	75 0a                	jne    801a2d <strtol+0x2a>
		s++;
  801a23:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a26:	bf 00 00 00 00       	mov    $0x0,%edi
  801a2b:	eb 11                	jmp    801a3e <strtol+0x3b>
  801a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a32:	3c 2d                	cmp    $0x2d,%al
  801a34:	75 08                	jne    801a3e <strtol+0x3b>
		s++, neg = 1;
  801a36:	83 c1 01             	add    $0x1,%ecx
  801a39:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a44:	75 15                	jne    801a5b <strtol+0x58>
  801a46:	80 39 30             	cmpb   $0x30,(%ecx)
  801a49:	75 10                	jne    801a5b <strtol+0x58>
  801a4b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a4f:	75 7c                	jne    801acd <strtol+0xca>
		s += 2, base = 16;
  801a51:	83 c1 02             	add    $0x2,%ecx
  801a54:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a59:	eb 16                	jmp    801a71 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a5b:	85 db                	test   %ebx,%ebx
  801a5d:	75 12                	jne    801a71 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a64:	80 39 30             	cmpb   $0x30,(%ecx)
  801a67:	75 08                	jne    801a71 <strtol+0x6e>
		s++, base = 8;
  801a69:	83 c1 01             	add    $0x1,%ecx
  801a6c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a71:	b8 00 00 00 00       	mov    $0x0,%eax
  801a76:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a79:	0f b6 11             	movzbl (%ecx),%edx
  801a7c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a7f:	89 f3                	mov    %esi,%ebx
  801a81:	80 fb 09             	cmp    $0x9,%bl
  801a84:	77 08                	ja     801a8e <strtol+0x8b>
			dig = *s - '0';
  801a86:	0f be d2             	movsbl %dl,%edx
  801a89:	83 ea 30             	sub    $0x30,%edx
  801a8c:	eb 22                	jmp    801ab0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a8e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a91:	89 f3                	mov    %esi,%ebx
  801a93:	80 fb 19             	cmp    $0x19,%bl
  801a96:	77 08                	ja     801aa0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a98:	0f be d2             	movsbl %dl,%edx
  801a9b:	83 ea 57             	sub    $0x57,%edx
  801a9e:	eb 10                	jmp    801ab0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801aa0:	8d 72 bf             	lea    -0x41(%edx),%esi
  801aa3:	89 f3                	mov    %esi,%ebx
  801aa5:	80 fb 19             	cmp    $0x19,%bl
  801aa8:	77 16                	ja     801ac0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801aaa:	0f be d2             	movsbl %dl,%edx
  801aad:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ab0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ab3:	7d 0b                	jge    801ac0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ab5:	83 c1 01             	add    $0x1,%ecx
  801ab8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801abc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801abe:	eb b9                	jmp    801a79 <strtol+0x76>

	if (endptr)
  801ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ac4:	74 0d                	je     801ad3 <strtol+0xd0>
		*endptr = (char *) s;
  801ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac9:	89 0e                	mov    %ecx,(%esi)
  801acb:	eb 06                	jmp    801ad3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801acd:	85 db                	test   %ebx,%ebx
  801acf:	74 98                	je     801a69 <strtol+0x66>
  801ad1:	eb 9e                	jmp    801a71 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ad3:	89 c2                	mov    %eax,%edx
  801ad5:	f7 da                	neg    %edx
  801ad7:	85 ff                	test   %edi,%edi
  801ad9:	0f 45 c2             	cmovne %edx,%eax
}
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5f                   	pop    %edi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	57                   	push   %edi
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801aed:	57                   	push   %edi
  801aee:	e8 6e fc ff ff       	call   801761 <strlen>
  801af3:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801af6:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801af9:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b03:	eb 46                	jmp    801b4b <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801b05:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801b09:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b0c:	80 f9 09             	cmp    $0x9,%cl
  801b0f:	77 08                	ja     801b19 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b11:	0f be d2             	movsbl %dl,%edx
  801b14:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b17:	eb 27                	jmp    801b40 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b19:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b1c:	80 f9 05             	cmp    $0x5,%cl
  801b1f:	77 08                	ja     801b29 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b21:	0f be d2             	movsbl %dl,%edx
  801b24:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b27:	eb 17                	jmp    801b40 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b29:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b2c:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b2f:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b34:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b38:	77 06                	ja     801b40 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b3a:	0f be d2             	movsbl %dl,%edx
  801b3d:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b40:	0f af ce             	imul   %esi,%ecx
  801b43:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b45:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b48:	83 eb 01             	sub    $0x1,%ebx
  801b4b:	83 fb 01             	cmp    $0x1,%ebx
  801b4e:	7f b5                	jg     801b05 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b66:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b68:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b6d:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	50                   	push   %eax
  801b74:	e8 a1 e7 ff ff       	call   80031a <sys_ipc_recv>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	79 16                	jns    801b96 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b80:	85 f6                	test   %esi,%esi
  801b82:	74 06                	je     801b8a <ipc_recv+0x32>
			*from_env_store = 0;
  801b84:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b8a:	85 db                	test   %ebx,%ebx
  801b8c:	74 2c                	je     801bba <ipc_recv+0x62>
			*perm_store = 0;
  801b8e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b94:	eb 24                	jmp    801bba <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b96:	85 f6                	test   %esi,%esi
  801b98:	74 0a                	je     801ba4 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b9a:	a1 08 40 80 00       	mov    0x804008,%eax
  801b9f:	8b 40 74             	mov    0x74(%eax),%eax
  801ba2:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801ba4:	85 db                	test   %ebx,%ebx
  801ba6:	74 0a                	je     801bb2 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801ba8:	a1 08 40 80 00       	mov    0x804008,%eax
  801bad:	8b 40 78             	mov    0x78(%eax),%eax
  801bb0:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bb2:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	57                   	push   %edi
  801bc5:	56                   	push   %esi
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bd3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bd5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bda:	0f 44 d8             	cmove  %eax,%ebx
  801bdd:	eb 1e                	jmp    801bfd <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bdf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be2:	74 14                	je     801bf8 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801be4:	83 ec 04             	sub    $0x4,%esp
  801be7:	68 a0 23 80 00       	push   $0x8023a0
  801bec:	6a 44                	push   $0x44
  801bee:	68 cc 23 80 00       	push   $0x8023cc
  801bf3:	e8 95 f4 ff ff       	call   80108d <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801bf8:	e8 4e e5 ff ff       	call   80014b <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bfd:	ff 75 14             	pushl  0x14(%ebp)
  801c00:	53                   	push   %ebx
  801c01:	56                   	push   %esi
  801c02:	57                   	push   %edi
  801c03:	e8 ef e6 ff ff       	call   8002f7 <sys_ipc_try_send>
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 d0                	js     801bdf <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c22:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c25:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c2b:	8b 52 50             	mov    0x50(%edx),%edx
  801c2e:	39 ca                	cmp    %ecx,%edx
  801c30:	75 0d                	jne    801c3f <ipc_find_env+0x28>
			return envs[i].env_id;
  801c32:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3a:	8b 40 48             	mov    0x48(%eax),%eax
  801c3d:	eb 0f                	jmp    801c4e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c3f:	83 c0 01             	add    $0x1,%eax
  801c42:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c47:	75 d9                	jne    801c22 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	c1 e8 16             	shr    $0x16,%eax
  801c5b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c62:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c67:	f6 c1 01             	test   $0x1,%cl
  801c6a:	74 1d                	je     801c89 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c6c:	c1 ea 0c             	shr    $0xc,%edx
  801c6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c76:	f6 c2 01             	test   $0x1,%dl
  801c79:	74 0e                	je     801c89 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c7b:	c1 ea 0c             	shr    $0xc,%edx
  801c7e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c85:	ef 
  801c86:	0f b7 c0             	movzwl %ax,%eax
}
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
