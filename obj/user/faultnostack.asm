
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ab 04 00 00       	call   800550 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ca 1f 80 00       	push   $0x801fca
  80011e:	6a 23                	push   $0x23
  800120:	68 e7 1f 80 00       	push   $0x801fe7
  800125:	e8 8d 0f 00 00       	call   8010b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ca 1f 80 00       	push   $0x801fca
  80019f:	6a 23                	push   $0x23
  8001a1:	68 e7 1f 80 00       	push   $0x801fe7
  8001a6:	e8 0c 0f 00 00       	call   8010b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ca 1f 80 00       	push   $0x801fca
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 e7 1f 80 00       	push   $0x801fe7
  8001e8:	e8 ca 0e 00 00       	call   8010b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ca 1f 80 00       	push   $0x801fca
  800223:	6a 23                	push   $0x23
  800225:	68 e7 1f 80 00       	push   $0x801fe7
  80022a:	e8 88 0e 00 00       	call   8010b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ca 1f 80 00       	push   $0x801fca
  800265:	6a 23                	push   $0x23
  800267:	68 e7 1f 80 00       	push   $0x801fe7
  80026c:	e8 46 0e 00 00       	call   8010b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 0a 00 00 00       	mov    $0xa,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 0a                	push   $0xa
  8002a2:	68 ca 1f 80 00       	push   $0x801fca
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 e7 1f 80 00       	push   $0x801fe7
  8002ae:	e8 04 0e 00 00       	call   8010b7 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 09                	push   $0x9
  8002e4:	68 ca 1f 80 00       	push   $0x801fca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 1f 80 00       	push   $0x801fe7
  8002f0:	e8 c2 0d 00 00       	call   8010b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 ca 1f 80 00       	push   $0x801fca
  80034d:	6a 23                	push   $0x23
  80034f:	68 e7 1f 80 00       	push   $0x801fe7
  800354:	e8 5e 0d 00 00       	call   8010b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax
  80036c:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $4, 0x30(%esp)
  800370:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ecx
  800375:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	movl %eax, (%ecx)
  800379:	89 01                	mov    %eax,(%ecx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80037b:	83 c4 08             	add    $0x8,%esp
	popal 
  80037e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80037f:	83 c4 04             	add    $0x4,%esp
	popfl
  800382:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800383:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800384:	c3                   	ret    

00800385 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	05 00 00 00 30       	add    $0x30000000,%eax
  800390:	c1 e8 0c             	shr    $0xc,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 16             	shr    $0x16,%edx
  8003bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 11                	je     8003d9 <fd_alloc+0x2d>
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 0c             	shr    $0xc,%edx
  8003cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	75 09                	jne    8003e2 <fd_alloc+0x36>
			*fd_store = fd;
  8003d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	eb 17                	jmp    8003f9 <fd_alloc+0x4d>
  8003e2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ec:	75 c9                	jne    8003b7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	c1 e0 0c             	shl    $0xc,%eax
  800409:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	ba 74 20 80 00       	mov    $0x802074,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80045f:	eb 13                	jmp    800474 <dev_lookup+0x23>
  800461:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800464:	39 08                	cmp    %ecx,(%eax)
  800466:	75 0c                	jne    800474 <dev_lookup+0x23>
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 2e                	jmp    8004a2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	75 e7                	jne    800461 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047a:	a1 08 40 80 00       	mov    0x804008,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 f8 1f 80 00       	push   $0x801ff8
  80048c:	e8 ff 0c 00 00       	call   801190 <cprintf>
	*dev = 0;
  800491:	8b 45 0c             	mov    0xc(%ebp),%eax
  800494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 10             	sub    $0x10,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 36 ff ff ff       	call   8003fb <fd_lookup>
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 05                	js     8004d1 <fd_close+0x2d>
	    || fd != fd2) 
  8004cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004cf:	74 0c                	je     8004dd <fd_close+0x39>
		return (must_exist ? r : 0); 
  8004d1:	84 db                	test   %bl,%bl
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	0f 44 c2             	cmove  %edx,%eax
  8004db:	eb 41                	jmp    80051e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff 36                	pushl  (%esi)
  8004e6:	e8 66 ff ff ff       	call   800451 <dev_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 1a                	js     80050e <fd_close+0x6a>
		if (dev->dev_close) 
  8004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0b                	je     80050e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 00                	push   $0x0
  800514:	e8 dc fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	89 d8                	mov    %ebx,%eax
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 c4 fe ff ff       	call   8003fb <fd_lookup>
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 10                	js     80054e <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	6a 01                	push   $0x1
  800543:	ff 75 f4             	pushl  -0xc(%ebp)
  800546:	e8 59 ff ff ff       	call   8004a4 <fd_close>
  80054b:	83 c4 10             	add    $0x10,%esp
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <close_all>:

void
close_all(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	53                   	push   %ebx
  800554:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800557:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	53                   	push   %ebx
  800560:	e8 c0 ff ff ff       	call   800525 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	83 c3 01             	add    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	83 fb 20             	cmp    $0x20,%ebx
  80056e:	75 ec                	jne    80055c <close_all+0xc>
		close(i);
}
  800570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 2c             	sub    $0x2c,%esp
  80057e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 6e fe ff ff       	call   8003fb <fd_lookup>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	85 c0                	test   %eax,%eax
  800592:	0f 88 c1 00 00 00    	js     800659 <dup+0xe4>
		return r;
	close(newfdnum);
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	56                   	push   %esi
  80059c:	e8 84 ff ff ff       	call   800525 <close>

	newfd = INDEX2FD(newfdnum);
  8005a1:	89 f3                	mov    %esi,%ebx
  8005a3:	c1 e3 0c             	shl    $0xc,%ebx
  8005a6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ac:	83 c4 04             	add    $0x4,%esp
  8005af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b2:	e8 de fd ff ff       	call   800395 <fd2data>
  8005b7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005b9:	89 1c 24             	mov    %ebx,(%esp)
  8005bc:	e8 d4 fd ff ff       	call   800395 <fd2data>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c7:	89 f8                	mov    %edi,%eax
  8005c9:	c1 e8 16             	shr    $0x16,%eax
  8005cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d3:	a8 01                	test   $0x1,%al
  8005d5:	74 37                	je     80060e <dup+0x99>
  8005d7:	89 f8                	mov    %edi,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e3:	f6 c2 01             	test   $0x1,%dl
  8005e6:	74 26                	je     80060e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fb:	6a 00                	push   $0x0
  8005fd:	57                   	push   %edi
  8005fe:	6a 00                	push   $0x0
  800600:	e8 ae fb ff ff       	call   8001b3 <sys_page_map>
  800605:	89 c7                	mov    %eax,%edi
  800607:	83 c4 20             	add    $0x20,%esp
  80060a:	85 c0                	test   %eax,%eax
  80060c:	78 2e                	js     80063c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800611:	89 d0                	mov    %edx,%eax
  800613:	c1 e8 0c             	shr    $0xc,%eax
  800616:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061d:	83 ec 0c             	sub    $0xc,%esp
  800620:	25 07 0e 00 00       	and    $0xe07,%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	6a 00                	push   $0x0
  800629:	52                   	push   %edx
  80062a:	6a 00                	push   $0x0
  80062c:	e8 82 fb ff ff       	call   8001b3 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800636:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800638:	85 ff                	test   %edi,%edi
  80063a:	79 1d                	jns    800659 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 00                	push   $0x0
  800642:	e8 ae fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064d:	6a 00                	push   $0x0
  80064f:	e8 a1 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	89 f8                	mov    %edi,%eax
}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	53                   	push   %ebx
  800665:	83 ec 14             	sub    $0x14,%esp
  800668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80066e:	50                   	push   %eax
  80066f:	53                   	push   %ebx
  800670:	e8 86 fd ff ff       	call   8003fb <fd_lookup>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	89 c2                	mov    %eax,%edx
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 6d                	js     8006eb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800688:	ff 30                	pushl  (%eax)
  80068a:	e8 c2 fd ff ff       	call   800451 <dev_lookup>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	78 4c                	js     8006e2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800699:	8b 42 08             	mov    0x8(%edx),%eax
  80069c:	83 e0 03             	and    $0x3,%eax
  80069f:	83 f8 01             	cmp    $0x1,%eax
  8006a2:	75 21                	jne    8006c5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8006a9:	8b 40 48             	mov    0x48(%eax),%eax
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	68 39 20 80 00       	push   $0x802039
  8006b6:	e8 d5 0a 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c3:	eb 26                	jmp    8006eb <read+0x8a>
	}
	if (!dev->dev_read)
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	8b 40 08             	mov    0x8(%eax),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 17                	je     8006e6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	52                   	push   %edx
  8006d9:	ff d0                	call   *%eax
  8006db:	89 c2                	mov    %eax,%edx
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 09                	jmp    8006eb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	eb 05                	jmp    8006eb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006eb:	89 d0                	mov    %edx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	57                   	push   %edi
  8006f6:	56                   	push   %esi
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	eb 21                	jmp    800729 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	29 d8                	sub    %ebx,%eax
  80070f:	50                   	push   %eax
  800710:	89 d8                	mov    %ebx,%eax
  800712:	03 45 0c             	add    0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	57                   	push   %edi
  800717:	e8 45 ff ff ff       	call   800661 <read>
		if (m < 0)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 10                	js     800733 <readn+0x41>
			return m;
		if (m == 0)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 0a                	je     800731 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800727:	01 c3                	add    %eax,%ebx
  800729:	39 f3                	cmp    %esi,%ebx
  80072b:	72 db                	jb     800708 <readn+0x16>
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	eb 02                	jmp    800733 <readn+0x41>
  800731:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	53                   	push   %ebx
  80074a:	e8 ac fc ff ff       	call   8003fb <fd_lookup>
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	89 c2                	mov    %eax,%edx
  800754:	85 c0                	test   %eax,%eax
  800756:	78 68                	js     8007c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800762:	ff 30                	pushl  (%eax)
  800764:	e8 e8 fc ff ff       	call   800451 <dev_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 47                	js     8007b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800777:	75 21                	jne    80079a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800779:	a1 08 40 80 00       	mov    0x804008,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 55 20 80 00       	push   $0x802055
  80078b:	e8 00 0a 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800798:	eb 26                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079d:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 17                	je     8007bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	50                   	push   %eax
  8007ae:	ff d2                	call   *%edx
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 09                	jmp    8007c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 05                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 22 fc ff ff       	call   8003fb <fd_lookup>
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 0e                	js     8007ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	53                   	push   %ebx
  8007ff:	e8 f7 fb ff ff       	call   8003fb <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	89 c2                	mov    %eax,%edx
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 65                	js     800872 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 33 fc ff ff       	call   800451 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 44                	js     800869 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 18 20 80 00       	push   $0x802018
  800840:	e8 4b 09 00 00       	call   801190 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084d:	eb 23                	jmp    800872 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	89 c2                	mov    %eax,%edx
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 09                	jmp    800872 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800869:	89 c2                	mov    %eax,%edx
  80086b:	eb 05                	jmp    800872 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 14             	sub    $0x14,%esp
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 6c fb ff ff       	call   8003fb <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	89 c2                	mov    %eax,%edx
  800894:	85 c0                	test   %eax,%eax
  800896:	78 58                	js     8008f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a2:	ff 30                	pushl  (%eax)
  8008a4:	e8 a8 fb ff ff       	call   800451 <dev_lookup>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 37                	js     8008e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b7:	74 32                	je     8008eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c3:	00 00 00 
	stat->st_isdir = 0;
  8008c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cd:	00 00 00 
	stat->st_dev = dev;
  8008d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 09                	jmp    8008f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	eb 05                	jmp    8008f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	6a 00                	push   $0x0
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 2b 02 00 00       	call   800b34 <open>
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 1b                	js     80092d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	50                   	push   %eax
  800919:	e8 5b ff ff ff       	call   800879 <fstat>
  80091e:	89 c6                	mov    %eax,%esi
	close(fd);
  800920:	89 1c 24             	mov    %ebx,(%esp)
  800923:	e8 fd fb ff ff       	call   800525 <close>
	return r;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	89 f0                	mov    %esi,%eax
}
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 5c 13 00 00       	call   801cac <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	56                   	push   %esi
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 eb 12 00 00       	call   801c56 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 75 12 00 00       	call   801bed <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8d ff ff ff       	call   800934 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 6b ff ff ff       	call   800934 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 45 ff ff ff       	call   800934 <fsipc>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 2c                	js     800a1f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	68 00 50 80 00       	push   $0x805000
  8009fb:	53                   	push   %ebx
  8009fc:	e8 c3 0d 00 00       	call   8017c4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a01:	a1 80 50 80 00       	mov    0x805080,%eax
  800a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a11:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a17:	83 c4 10             	add    $0x10,%esp
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	53                   	push   %ebx
  800a28:	83 ec 08             	sub    $0x8,%esp
  800a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a33:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a38:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a46:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4c:	53                   	push   %ebx
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	68 08 50 80 00       	push   $0x805008
  800a55:	e8 fc 0e 00 00       	call   801956 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a64:	e8 cb fe ff ff       	call   800934 <fsipc>
  800a69:	83 c4 10             	add    $0x10,%esp
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	78 3d                	js     800aad <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a70:	39 d8                	cmp    %ebx,%eax
  800a72:	76 19                	jbe    800a8d <devfile_write+0x69>
  800a74:	68 84 20 80 00       	push   $0x802084
  800a79:	68 8b 20 80 00       	push   $0x80208b
  800a7e:	68 9f 00 00 00       	push   $0x9f
  800a83:	68 a0 20 80 00       	push   $0x8020a0
  800a88:	e8 2a 06 00 00       	call   8010b7 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a8d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a92:	76 19                	jbe    800aad <devfile_write+0x89>
  800a94:	68 b8 20 80 00       	push   $0x8020b8
  800a99:	68 8b 20 80 00       	push   $0x80208b
  800a9e:	68 a0 00 00 00       	push   $0xa0
  800aa3:	68 a0 20 80 00       	push   $0x8020a0
  800aa8:	e8 0a 06 00 00       	call   8010b7 <_panic>

	return r;
}
  800aad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ac5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad5:	e8 5a fe ff ff       	call   800934 <fsipc>
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	85 c0                	test   %eax,%eax
  800ade:	78 4b                	js     800b2b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ae0:	39 c6                	cmp    %eax,%esi
  800ae2:	73 16                	jae    800afa <devfile_read+0x48>
  800ae4:	68 84 20 80 00       	push   $0x802084
  800ae9:	68 8b 20 80 00       	push   $0x80208b
  800aee:	6a 7e                	push   $0x7e
  800af0:	68 a0 20 80 00       	push   $0x8020a0
  800af5:	e8 bd 05 00 00       	call   8010b7 <_panic>
	assert(r <= PGSIZE);
  800afa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aff:	7e 16                	jle    800b17 <devfile_read+0x65>
  800b01:	68 ab 20 80 00       	push   $0x8020ab
  800b06:	68 8b 20 80 00       	push   $0x80208b
  800b0b:	6a 7f                	push   $0x7f
  800b0d:	68 a0 20 80 00       	push   $0x8020a0
  800b12:	e8 a0 05 00 00       	call   8010b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b17:	83 ec 04             	sub    $0x4,%esp
  800b1a:	50                   	push   %eax
  800b1b:	68 00 50 80 00       	push   $0x805000
  800b20:	ff 75 0c             	pushl  0xc(%ebp)
  800b23:	e8 2e 0e 00 00       	call   801956 <memmove>
	return r;
  800b28:	83 c4 10             	add    $0x10,%esp
}
  800b2b:	89 d8                	mov    %ebx,%eax
  800b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	83 ec 20             	sub    $0x20,%esp
  800b3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b3e:	53                   	push   %ebx
  800b3f:	e8 47 0c 00 00       	call   80178b <strlen>
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b4c:	7f 67                	jg     800bb5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b54:	50                   	push   %eax
  800b55:	e8 52 f8 ff ff       	call   8003ac <fd_alloc>
  800b5a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b5d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	78 57                	js     800bba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	53                   	push   %ebx
  800b67:	68 00 50 80 00       	push   $0x805000
  800b6c:	e8 53 0c 00 00       	call   8017c4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b81:	e8 ae fd ff ff       	call   800934 <fsipc>
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	79 14                	jns    800ba3 <open+0x6f>
		fd_close(fd, 0);
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	6a 00                	push   $0x0
  800b94:	ff 75 f4             	pushl  -0xc(%ebp)
  800b97:	e8 08 f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	89 da                	mov    %ebx,%edx
  800ba1:	eb 17                	jmp    800bba <open+0x86>
	}

	return fd2num(fd);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba9:	e8 d7 f7 ff ff       	call   800385 <fd2num>
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	eb 05                	jmp    800bba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bb5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bba:	89 d0                	mov    %edx,%eax
  800bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd1:	e8 5e fd ff ff       	call   800934 <fsipc>
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	ff 75 08             	pushl  0x8(%ebp)
  800be6:	e8 aa f7 ff ff       	call   800395 <fd2data>
  800beb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bed:	83 c4 08             	add    $0x8,%esp
  800bf0:	68 e5 20 80 00       	push   $0x8020e5
  800bf5:	53                   	push   %ebx
  800bf6:	e8 c9 0b 00 00       	call   8017c4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bfb:	8b 46 04             	mov    0x4(%esi),%eax
  800bfe:	2b 06                	sub    (%esi),%eax
  800c00:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c06:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c0d:	00 00 00 
	stat->st_dev = &devpipe;
  800c10:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c17:	30 80 00 
	return 0;
}
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c30:	53                   	push   %ebx
  800c31:	6a 00                	push   $0x0
  800c33:	e8 bd f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c38:	89 1c 24             	mov    %ebx,(%esp)
  800c3b:	e8 55 f7 ff ff       	call   800395 <fd2data>
  800c40:	83 c4 08             	add    $0x8,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 00                	push   $0x0
  800c46:	e8 aa f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 1c             	sub    $0x1c,%esp
  800c59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c5c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c5e:	a1 08 40 80 00       	mov    0x804008,%eax
  800c63:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	ff 75 e0             	pushl  -0x20(%ebp)
  800c6c:	e8 74 10 00 00       	call   801ce5 <pageref>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	89 3c 24             	mov    %edi,(%esp)
  800c76:	e8 6a 10 00 00       	call   801ce5 <pageref>
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	39 c3                	cmp    %eax,%ebx
  800c80:	0f 94 c1             	sete   %cl
  800c83:	0f b6 c9             	movzbl %cl,%ecx
  800c86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c89:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c8f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c92:	39 ce                	cmp    %ecx,%esi
  800c94:	74 1b                	je     800cb1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c96:	39 c3                	cmp    %eax,%ebx
  800c98:	75 c4                	jne    800c5e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c9a:	8b 42 58             	mov    0x58(%edx),%eax
  800c9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ca0:	50                   	push   %eax
  800ca1:	56                   	push   %esi
  800ca2:	68 ec 20 80 00       	push   $0x8020ec
  800ca7:	e8 e4 04 00 00       	call   801190 <cprintf>
  800cac:	83 c4 10             	add    $0x10,%esp
  800caf:	eb ad                	jmp    800c5e <_pipeisclosed+0xe>
	}
}
  800cb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 28             	sub    $0x28,%esp
  800cc5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cc8:	56                   	push   %esi
  800cc9:	e8 c7 f6 ff ff       	call   800395 <fd2data>
  800cce:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd8:	eb 4b                	jmp    800d25 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cda:	89 da                	mov    %ebx,%edx
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	e8 6d ff ff ff       	call   800c50 <_pipeisclosed>
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	75 48                	jne    800d2f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ce7:	e8 65 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cec:	8b 43 04             	mov    0x4(%ebx),%eax
  800cef:	8b 0b                	mov    (%ebx),%ecx
  800cf1:	8d 51 20             	lea    0x20(%ecx),%edx
  800cf4:	39 d0                	cmp    %edx,%eax
  800cf6:	73 e2                	jae    800cda <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	c1 fa 1f             	sar    $0x1f,%edx
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	c1 e9 1b             	shr    $0x1b,%ecx
  800d0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d0f:	83 e2 1f             	and    $0x1f,%edx
  800d12:	29 ca                	sub    %ecx,%edx
  800d14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d1c:	83 c0 01             	add    $0x1,%eax
  800d1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c7 01             	add    $0x1,%edi
  800d25:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d28:	75 c2                	jne    800cec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2d:	eb 05                	jmp    800d34 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 18             	sub    $0x18,%esp
  800d45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d48:	57                   	push   %edi
  800d49:	e8 47 f6 ff ff       	call   800395 <fd2data>
  800d4e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	eb 3d                	jmp    800d97 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d5a:	85 db                	test   %ebx,%ebx
  800d5c:	74 04                	je     800d62 <devpipe_read+0x26>
				return i;
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	eb 44                	jmp    800da6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d62:	89 f2                	mov    %esi,%edx
  800d64:	89 f8                	mov    %edi,%eax
  800d66:	e8 e5 fe ff ff       	call   800c50 <_pipeisclosed>
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	75 32                	jne    800da1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d6f:	e8 dd f3 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d74:	8b 06                	mov    (%esi),%eax
  800d76:	3b 46 04             	cmp    0x4(%esi),%eax
  800d79:	74 df                	je     800d5a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d7b:	99                   	cltd   
  800d7c:	c1 ea 1b             	shr    $0x1b,%edx
  800d7f:	01 d0                	add    %edx,%eax
  800d81:	83 e0 1f             	and    $0x1f,%eax
  800d84:	29 d0                	sub    %edx,%eax
  800d86:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d91:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d94:	83 c3 01             	add    $0x1,%ebx
  800d97:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d9a:	75 d8                	jne    800d74 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9f:	eb 05                	jmp    800da6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800db9:	50                   	push   %eax
  800dba:	e8 ed f5 ff ff       	call   8003ac <fd_alloc>
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	89 c2                	mov    %eax,%edx
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	0f 88 2c 01 00 00    	js     800ef8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	68 07 04 00 00       	push   $0x407
  800dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 92 f3 ff ff       	call   800170 <sys_page_alloc>
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	85 c0                	test   %eax,%eax
  800de5:	0f 88 0d 01 00 00    	js     800ef8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800df1:	50                   	push   %eax
  800df2:	e8 b5 f5 ff ff       	call   8003ac <fd_alloc>
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	0f 88 e2 00 00 00    	js     800ee6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	68 07 04 00 00       	push   $0x407
  800e0c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 5a f3 ff ff       	call   800170 <sys_page_alloc>
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	0f 88 c3 00 00 00    	js     800ee6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f4             	pushl  -0xc(%ebp)
  800e29:	e8 67 f5 ff ff       	call   800395 <fd2data>
  800e2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e30:	83 c4 0c             	add    $0xc,%esp
  800e33:	68 07 04 00 00       	push   $0x407
  800e38:	50                   	push   %eax
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 30 f3 ff ff       	call   800170 <sys_page_alloc>
  800e40:	89 c3                	mov    %eax,%ebx
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	0f 88 89 00 00 00    	js     800ed6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	ff 75 f0             	pushl  -0x10(%ebp)
  800e53:	e8 3d f5 ff ff       	call   800395 <fd2data>
  800e58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e5f:	50                   	push   %eax
  800e60:	6a 00                	push   $0x0
  800e62:	56                   	push   %esi
  800e63:	6a 00                	push   $0x0
  800e65:	e8 49 f3 ff ff       	call   8001b3 <sys_page_map>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 55                	js     800ec8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea3:	e8 dd f4 ff ff       	call   800385 <fd2num>
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ead:	83 c4 04             	add    $0x4,%esp
  800eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb3:	e8 cd f4 ff ff       	call   800385 <fd2num>
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec6:	eb 30                	jmp    800ef8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800ec8:	83 ec 08             	sub    $0x8,%esp
  800ecb:	56                   	push   %esi
  800ecc:	6a 00                	push   $0x0
  800ece:	e8 22 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ed3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	ff 75 f0             	pushl  -0x10(%ebp)
  800edc:	6a 00                	push   $0x0
  800ede:	e8 12 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ee3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eec:	6a 00                	push   $0x0
  800eee:	e8 02 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ef8:	89 d0                	mov    %edx,%eax
  800efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 75 08             	pushl  0x8(%ebp)
  800f0e:	e8 e8 f4 ff ff       	call   8003fb <fd_lookup>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 18                	js     800f32 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f20:	e8 70 f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2a:	e8 21 fd ff ff       	call   800c50 <_pipeisclosed>
  800f2f:	83 c4 10             	add    $0x10,%esp
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f37:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f44:	68 04 21 80 00       	push   $0x802104
  800f49:	ff 75 0c             	pushl  0xc(%ebp)
  800f4c:	e8 73 08 00 00       	call   8017c4 <strcpy>
	return 0;
}
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f64:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f69:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6f:	eb 2d                	jmp    800f9e <devcons_write+0x46>
		m = n - tot;
  800f71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f74:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f76:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f79:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f7e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	53                   	push   %ebx
  800f85:	03 45 0c             	add    0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	57                   	push   %edi
  800f8a:	e8 c7 09 00 00       	call   801956 <memmove>
		sys_cputs(buf, m);
  800f8f:	83 c4 08             	add    $0x8,%esp
  800f92:	53                   	push   %ebx
  800f93:	57                   	push   %edi
  800f94:	e8 1b f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f99:	01 de                	add    %ebx,%esi
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800fa3:	72 cc                	jb     800f71 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800fa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fbc:	74 2a                	je     800fe8 <devcons_read+0x3b>
  800fbe:	eb 05                	jmp    800fc5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fc0:	e8 8c f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fc5:	e8 08 f1 ff ff       	call   8000d2 <sys_cgetc>
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	74 f2                	je     800fc0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 16                	js     800fe8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fd2:	83 f8 04             	cmp    $0x4,%eax
  800fd5:	74 0c                	je     800fe3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fda:	88 02                	mov    %al,(%edx)
	return 1;
  800fdc:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe1:	eb 05                	jmp    800fe8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800ff6:	6a 01                	push   $0x1
  800ff8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	e8 b3 f0 ff ff       	call   8000b4 <sys_cputs>
}
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <getchar>:

int
getchar(void)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80100c:	6a 01                	push   $0x1
  80100e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	6a 00                	push   $0x0
  801014:	e8 48 f6 ff ff       	call   800661 <read>
	if (r < 0)
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 0f                	js     80102f <getchar+0x29>
		return r;
	if (r < 1)
  801020:	85 c0                	test   %eax,%eax
  801022:	7e 06                	jle    80102a <getchar+0x24>
		return -E_EOF;
	return c;
  801024:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801028:	eb 05                	jmp    80102f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80102a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801037:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103a:	50                   	push   %eax
  80103b:	ff 75 08             	pushl  0x8(%ebp)
  80103e:	e8 b8 f3 ff ff       	call   8003fb <fd_lookup>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 11                	js     80105b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80104a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801053:	39 10                	cmp    %edx,(%eax)
  801055:	0f 94 c0             	sete   %al
  801058:	0f b6 c0             	movzbl %al,%eax
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <opencons>:

int
opencons(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	e8 40 f3 ff ff       	call   8003ac <fd_alloc>
  80106c:	83 c4 10             	add    $0x10,%esp
		return r;
  80106f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	78 3e                	js     8010b3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	68 07 04 00 00       	push   $0x407
  80107d:	ff 75 f4             	pushl  -0xc(%ebp)
  801080:	6a 00                	push   $0x0
  801082:	e8 e9 f0 ff ff       	call   800170 <sys_page_alloc>
  801087:	83 c4 10             	add    $0x10,%esp
		return r;
  80108a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 23                	js     8010b3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801090:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801099:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80109b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	50                   	push   %eax
  8010a9:	e8 d7 f2 ff ff       	call   800385 <fd2num>
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	83 c4 10             	add    $0x10,%esp
}
  8010b3:	89 d0                	mov    %edx,%eax
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010c5:	e8 68 f0 ff ff       	call   800132 <sys_getenvid>
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	ff 75 0c             	pushl  0xc(%ebp)
  8010d0:	ff 75 08             	pushl  0x8(%ebp)
  8010d3:	56                   	push   %esi
  8010d4:	50                   	push   %eax
  8010d5:	68 10 21 80 00       	push   $0x802110
  8010da:	e8 b1 00 00 00       	call   801190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010df:	83 c4 18             	add    $0x18,%esp
  8010e2:	53                   	push   %ebx
  8010e3:	ff 75 10             	pushl  0x10(%ebp)
  8010e6:	e8 54 00 00 00       	call   80113f <vcprintf>
	cprintf("\n");
  8010eb:	c7 04 24 fd 20 80 00 	movl   $0x8020fd,(%esp)
  8010f2:	e8 99 00 00 00       	call   801190 <cprintf>
  8010f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010fa:	cc                   	int3   
  8010fb:	eb fd                	jmp    8010fa <_panic+0x43>

008010fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	53                   	push   %ebx
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801107:	8b 13                	mov    (%ebx),%edx
  801109:	8d 42 01             	lea    0x1(%edx),%eax
  80110c:	89 03                	mov    %eax,(%ebx)
  80110e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801111:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801115:	3d ff 00 00 00       	cmp    $0xff,%eax
  80111a:	75 1a                	jne    801136 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	68 ff 00 00 00       	push   $0xff
  801124:	8d 43 08             	lea    0x8(%ebx),%eax
  801127:	50                   	push   %eax
  801128:	e8 87 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80112d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801133:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801136:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80113a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80114f:	00 00 00 
	b.cnt = 0;
  801152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80115c:	ff 75 0c             	pushl  0xc(%ebp)
  80115f:	ff 75 08             	pushl  0x8(%ebp)
  801162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	68 fd 10 80 00       	push   $0x8010fd
  80116e:	e8 54 01 00 00       	call   8012c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801173:	83 c4 08             	add    $0x8,%esp
  801176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80117c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	e8 2c ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801199:	50                   	push   %eax
  80119a:	ff 75 08             	pushl  0x8(%ebp)
  80119d:	e8 9d ff ff ff       	call   80113f <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 1c             	sub    $0x1c,%esp
  8011ad:	89 c7                	mov    %eax,%edi
  8011af:	89 d6                	mov    %edx,%esi
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011cb:	39 d3                	cmp    %edx,%ebx
  8011cd:	72 05                	jb     8011d4 <printnum+0x30>
  8011cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011d2:	77 45                	ja     801219 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011d4:	83 ec 0c             	sub    $0xc,%esp
  8011d7:	ff 75 18             	pushl  0x18(%ebp)
  8011da:	8b 45 14             	mov    0x14(%ebp),%eax
  8011dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011e0:	53                   	push   %ebx
  8011e1:	ff 75 10             	pushl  0x10(%ebp)
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f3:	e8 28 0b 00 00       	call   801d20 <__udivdi3>
  8011f8:	83 c4 18             	add    $0x18,%esp
  8011fb:	52                   	push   %edx
  8011fc:	50                   	push   %eax
  8011fd:	89 f2                	mov    %esi,%edx
  8011ff:	89 f8                	mov    %edi,%eax
  801201:	e8 9e ff ff ff       	call   8011a4 <printnum>
  801206:	83 c4 20             	add    $0x20,%esp
  801209:	eb 18                	jmp    801223 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	56                   	push   %esi
  80120f:	ff 75 18             	pushl  0x18(%ebp)
  801212:	ff d7                	call   *%edi
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	eb 03                	jmp    80121c <printnum+0x78>
  801219:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80121c:	83 eb 01             	sub    $0x1,%ebx
  80121f:	85 db                	test   %ebx,%ebx
  801221:	7f e8                	jg     80120b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	56                   	push   %esi
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122d:	ff 75 e0             	pushl  -0x20(%ebp)
  801230:	ff 75 dc             	pushl  -0x24(%ebp)
  801233:	ff 75 d8             	pushl  -0x28(%ebp)
  801236:	e8 15 0c 00 00       	call   801e50 <__umoddi3>
  80123b:	83 c4 14             	add    $0x14,%esp
  80123e:	0f be 80 33 21 80 00 	movsbl 0x802133(%eax),%eax
  801245:	50                   	push   %eax
  801246:	ff d7                	call   *%edi
}
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801256:	83 fa 01             	cmp    $0x1,%edx
  801259:	7e 0e                	jle    801269 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801260:	89 08                	mov    %ecx,(%eax)
  801262:	8b 02                	mov    (%edx),%eax
  801264:	8b 52 04             	mov    0x4(%edx),%edx
  801267:	eb 22                	jmp    80128b <getuint+0x38>
	else if (lflag)
  801269:	85 d2                	test   %edx,%edx
  80126b:	74 10                	je     80127d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801272:	89 08                	mov    %ecx,(%eax)
  801274:	8b 02                	mov    (%edx),%eax
  801276:	ba 00 00 00 00       	mov    $0x0,%edx
  80127b:	eb 0e                	jmp    80128b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80127d:	8b 10                	mov    (%eax),%edx
  80127f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801282:	89 08                	mov    %ecx,(%eax)
  801284:	8b 02                	mov    (%edx),%eax
  801286:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801297:	8b 10                	mov    (%eax),%edx
  801299:	3b 50 04             	cmp    0x4(%eax),%edx
  80129c:	73 0a                	jae    8012a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80129e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012a1:	89 08                	mov    %ecx,(%eax)
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	88 02                	mov    %al,(%edx)
}
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8012b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 10             	pushl  0x10(%ebp)
  8012b7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ba:	ff 75 08             	pushl  0x8(%ebp)
  8012bd:	e8 05 00 00 00       	call   8012c7 <vprintfmt>
	va_end(ap);
}
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	57                   	push   %edi
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 2c             	sub    $0x2c,%esp
  8012d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d9:	eb 12                	jmp    8012ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 84 38 04 00 00    	je     80171b <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	53                   	push   %ebx
  8012e7:	50                   	push   %eax
  8012e8:	ff d6                	call   *%esi
  8012ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012ed:	83 c7 01             	add    $0x1,%edi
  8012f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012f4:	83 f8 25             	cmp    $0x25,%eax
  8012f7:	75 e2                	jne    8012db <vprintfmt+0x14>
  8012f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801304:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	eb 07                	jmp    801320 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  80131c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801320:	8d 47 01             	lea    0x1(%edi),%eax
  801323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801326:	0f b6 07             	movzbl (%edi),%eax
  801329:	0f b6 c8             	movzbl %al,%ecx
  80132c:	83 e8 23             	sub    $0x23,%eax
  80132f:	3c 55                	cmp    $0x55,%al
  801331:	0f 87 c9 03 00 00    	ja     801700 <vprintfmt+0x439>
  801337:	0f b6 c0             	movzbl %al,%eax
  80133a:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801344:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801348:	eb d6                	jmp    801320 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80134a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801351:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801354:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801357:	eb 94                	jmp    8012ed <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  801359:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801360:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801366:	eb 85                	jmp    8012ed <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801368:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  80136f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801375:	e9 73 ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80137a:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801381:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801387:	e9 61 ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80138c:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801393:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  801399:	e9 4f ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80139e:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  8013a5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  8013ab:	e9 3d ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  8013b0:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  8013b7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8013bd:	e9 2b ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8013c2:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  8013c9:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8013cf:	e9 19 ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8013d4:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013db:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013e1:	e9 07 ff ff ff       	jmp    8012ed <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013e6:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013ed:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013f3:	e9 f5 fe ff ff       	jmp    8012ed <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801400:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801403:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801406:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80140a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80140d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801410:	83 fa 09             	cmp    $0x9,%edx
  801413:	77 3f                	ja     801454 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801415:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801418:	eb e9                	jmp    801403 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80141a:	8b 45 14             	mov    0x14(%ebp),%eax
  80141d:	8d 48 04             	lea    0x4(%eax),%ecx
  801420:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801423:	8b 00                	mov    (%eax),%eax
  801425:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80142b:	eb 2d                	jmp    80145a <vprintfmt+0x193>
  80142d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801430:	85 c0                	test   %eax,%eax
  801432:	b9 00 00 00 00       	mov    $0x0,%ecx
  801437:	0f 49 c8             	cmovns %eax,%ecx
  80143a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801440:	e9 db fe ff ff       	jmp    801320 <vprintfmt+0x59>
  801445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801448:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80144f:	e9 cc fe ff ff       	jmp    801320 <vprintfmt+0x59>
  801454:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801457:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80145a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80145e:	0f 89 bc fe ff ff    	jns    801320 <vprintfmt+0x59>
				width = precision, precision = -1;
  801464:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80146a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801471:	e9 aa fe ff ff       	jmp    801320 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801476:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80147c:	e9 9f fe ff ff       	jmp    801320 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801481:	8b 45 14             	mov    0x14(%ebp),%eax
  801484:	8d 50 04             	lea    0x4(%eax),%edx
  801487:	89 55 14             	mov    %edx,0x14(%ebp)
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	53                   	push   %ebx
  80148e:	ff 30                	pushl  (%eax)
  801490:	ff d6                	call   *%esi
			break;
  801492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801498:	e9 50 fe ff ff       	jmp    8012ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80149d:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a0:	8d 50 04             	lea    0x4(%eax),%edx
  8014a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a6:	8b 00                	mov    (%eax),%eax
  8014a8:	99                   	cltd   
  8014a9:	31 d0                	xor    %edx,%eax
  8014ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014ad:	83 f8 0f             	cmp    $0xf,%eax
  8014b0:	7f 0b                	jg     8014bd <vprintfmt+0x1f6>
  8014b2:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  8014b9:	85 d2                	test   %edx,%edx
  8014bb:	75 18                	jne    8014d5 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8014bd:	50                   	push   %eax
  8014be:	68 4b 21 80 00       	push   $0x80214b
  8014c3:	53                   	push   %ebx
  8014c4:	56                   	push   %esi
  8014c5:	e8 e0 fd ff ff       	call   8012aa <printfmt>
  8014ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014d0:	e9 18 fe ff ff       	jmp    8012ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8014d5:	52                   	push   %edx
  8014d6:	68 9d 20 80 00       	push   $0x80209d
  8014db:	53                   	push   %ebx
  8014dc:	56                   	push   %esi
  8014dd:	e8 c8 fd ff ff       	call   8012aa <printfmt>
  8014e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e8:	e9 00 fe ff ff       	jmp    8012ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f0:	8d 50 04             	lea    0x4(%eax),%edx
  8014f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014f8:	85 ff                	test   %edi,%edi
  8014fa:	b8 44 21 80 00       	mov    $0x802144,%eax
  8014ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801502:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801506:	0f 8e 94 00 00 00    	jle    8015a0 <vprintfmt+0x2d9>
  80150c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801510:	0f 84 98 00 00 00    	je     8015ae <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  801516:	83 ec 08             	sub    $0x8,%esp
  801519:	ff 75 d0             	pushl  -0x30(%ebp)
  80151c:	57                   	push   %edi
  80151d:	e8 81 02 00 00       	call   8017a3 <strnlen>
  801522:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801525:	29 c1                	sub    %eax,%ecx
  801527:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80152a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80152d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801531:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801534:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801537:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801539:	eb 0f                	jmp    80154a <vprintfmt+0x283>
					putch(padc, putdat);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	53                   	push   %ebx
  80153f:	ff 75 e0             	pushl  -0x20(%ebp)
  801542:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801544:	83 ef 01             	sub    $0x1,%edi
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	85 ff                	test   %edi,%edi
  80154c:	7f ed                	jg     80153b <vprintfmt+0x274>
  80154e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801551:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801554:	85 c9                	test   %ecx,%ecx
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
  80155b:	0f 49 c1             	cmovns %ecx,%eax
  80155e:	29 c1                	sub    %eax,%ecx
  801560:	89 75 08             	mov    %esi,0x8(%ebp)
  801563:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801566:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801569:	89 cb                	mov    %ecx,%ebx
  80156b:	eb 4d                	jmp    8015ba <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80156d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801571:	74 1b                	je     80158e <vprintfmt+0x2c7>
  801573:	0f be c0             	movsbl %al,%eax
  801576:	83 e8 20             	sub    $0x20,%eax
  801579:	83 f8 5e             	cmp    $0x5e,%eax
  80157c:	76 10                	jbe    80158e <vprintfmt+0x2c7>
					putch('?', putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	6a 3f                	push   $0x3f
  801586:	ff 55 08             	call   *0x8(%ebp)
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	eb 0d                	jmp    80159b <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	52                   	push   %edx
  801595:	ff 55 08             	call   *0x8(%ebp)
  801598:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80159b:	83 eb 01             	sub    $0x1,%ebx
  80159e:	eb 1a                	jmp    8015ba <vprintfmt+0x2f3>
  8015a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8015a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8015a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8015a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8015ac:	eb 0c                	jmp    8015ba <vprintfmt+0x2f3>
  8015ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8015b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8015b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8015b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8015ba:	83 c7 01             	add    $0x1,%edi
  8015bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c1:	0f be d0             	movsbl %al,%edx
  8015c4:	85 d2                	test   %edx,%edx
  8015c6:	74 23                	je     8015eb <vprintfmt+0x324>
  8015c8:	85 f6                	test   %esi,%esi
  8015ca:	78 a1                	js     80156d <vprintfmt+0x2a6>
  8015cc:	83 ee 01             	sub    $0x1,%esi
  8015cf:	79 9c                	jns    80156d <vprintfmt+0x2a6>
  8015d1:	89 df                	mov    %ebx,%edi
  8015d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015d9:	eb 18                	jmp    8015f3 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	53                   	push   %ebx
  8015df:	6a 20                	push   $0x20
  8015e1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015e3:	83 ef 01             	sub    $0x1,%edi
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	eb 08                	jmp    8015f3 <vprintfmt+0x32c>
  8015eb:	89 df                	mov    %ebx,%edi
  8015ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015f3:	85 ff                	test   %edi,%edi
  8015f5:	7f e4                	jg     8015db <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fa:	e9 ee fc ff ff       	jmp    8012ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015ff:	83 fa 01             	cmp    $0x1,%edx
  801602:	7e 16                	jle    80161a <vprintfmt+0x353>
		return va_arg(*ap, long long);
  801604:	8b 45 14             	mov    0x14(%ebp),%eax
  801607:	8d 50 08             	lea    0x8(%eax),%edx
  80160a:	89 55 14             	mov    %edx,0x14(%ebp)
  80160d:	8b 50 04             	mov    0x4(%eax),%edx
  801610:	8b 00                	mov    (%eax),%eax
  801612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801615:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801618:	eb 32                	jmp    80164c <vprintfmt+0x385>
	else if (lflag)
  80161a:	85 d2                	test   %edx,%edx
  80161c:	74 18                	je     801636 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80161e:	8b 45 14             	mov    0x14(%ebp),%eax
  801621:	8d 50 04             	lea    0x4(%eax),%edx
  801624:	89 55 14             	mov    %edx,0x14(%ebp)
  801627:	8b 00                	mov    (%eax),%eax
  801629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80162c:	89 c1                	mov    %eax,%ecx
  80162e:	c1 f9 1f             	sar    $0x1f,%ecx
  801631:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801634:	eb 16                	jmp    80164c <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  801636:	8b 45 14             	mov    0x14(%ebp),%eax
  801639:	8d 50 04             	lea    0x4(%eax),%edx
  80163c:	89 55 14             	mov    %edx,0x14(%ebp)
  80163f:	8b 00                	mov    (%eax),%eax
  801641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801644:	89 c1                	mov    %eax,%ecx
  801646:	c1 f9 1f             	sar    $0x1f,%ecx
  801649:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80164c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80164f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801652:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801657:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80165b:	79 6f                	jns    8016cc <vprintfmt+0x405>
				putch('-', putdat);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	53                   	push   %ebx
  801661:	6a 2d                	push   $0x2d
  801663:	ff d6                	call   *%esi
				num = -(long long) num;
  801665:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801668:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80166b:	f7 d8                	neg    %eax
  80166d:	83 d2 00             	adc    $0x0,%edx
  801670:	f7 da                	neg    %edx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	eb 55                	jmp    8016cc <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801677:	8d 45 14             	lea    0x14(%ebp),%eax
  80167a:	e8 d4 fb ff ff       	call   801253 <getuint>
			base = 10;
  80167f:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801684:	eb 46                	jmp    8016cc <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801686:	8d 45 14             	lea    0x14(%ebp),%eax
  801689:	e8 c5 fb ff ff       	call   801253 <getuint>
			base = 8;
  80168e:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801693:	eb 37                	jmp    8016cc <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801695:	83 ec 08             	sub    $0x8,%esp
  801698:	53                   	push   %ebx
  801699:	6a 30                	push   $0x30
  80169b:	ff d6                	call   *%esi
			putch('x', putdat);
  80169d:	83 c4 08             	add    $0x8,%esp
  8016a0:	53                   	push   %ebx
  8016a1:	6a 78                	push   $0x78
  8016a3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a8:	8d 50 04             	lea    0x4(%eax),%edx
  8016ab:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016ae:	8b 00                	mov    (%eax),%eax
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8016b5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016b8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8016bd:	eb 0d                	jmp    8016cc <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8016c2:	e8 8c fb ff ff       	call   801253 <getuint>
			base = 16;
  8016c7:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8016cc:	83 ec 0c             	sub    $0xc,%esp
  8016cf:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8016d3:	51                   	push   %ecx
  8016d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d7:	57                   	push   %edi
  8016d8:	52                   	push   %edx
  8016d9:	50                   	push   %eax
  8016da:	89 da                	mov    %ebx,%edx
  8016dc:	89 f0                	mov    %esi,%eax
  8016de:	e8 c1 fa ff ff       	call   8011a4 <printnum>
			break;
  8016e3:	83 c4 20             	add    $0x20,%esp
  8016e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016e9:	e9 ff fb ff ff       	jmp    8012ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	51                   	push   %ecx
  8016f3:	ff d6                	call   *%esi
			break;
  8016f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016fb:	e9 ed fb ff ff       	jmp    8012ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	53                   	push   %ebx
  801704:	6a 25                	push   $0x25
  801706:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 03                	jmp    801710 <vprintfmt+0x449>
  80170d:	83 ef 01             	sub    $0x1,%edi
  801710:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801714:	75 f7                	jne    80170d <vprintfmt+0x446>
  801716:	e9 d2 fb ff ff       	jmp    8012ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80171b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5f                   	pop    %edi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 18             	sub    $0x18,%esp
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80172f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801732:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801736:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801739:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801740:	85 c0                	test   %eax,%eax
  801742:	74 26                	je     80176a <vsnprintf+0x47>
  801744:	85 d2                	test   %edx,%edx
  801746:	7e 22                	jle    80176a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801748:	ff 75 14             	pushl  0x14(%ebp)
  80174b:	ff 75 10             	pushl  0x10(%ebp)
  80174e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	68 8d 12 80 00       	push   $0x80128d
  801757:	e8 6b fb ff ff       	call   8012c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80175c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80175f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	eb 05                	jmp    80176f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80176a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801777:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80177a:	50                   	push   %eax
  80177b:	ff 75 10             	pushl  0x10(%ebp)
  80177e:	ff 75 0c             	pushl  0xc(%ebp)
  801781:	ff 75 08             	pushl  0x8(%ebp)
  801784:	e8 9a ff ff ff       	call   801723 <vsnprintf>
	va_end(ap);

	return rc;
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
  801796:	eb 03                	jmp    80179b <strlen+0x10>
		n++;
  801798:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80179b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80179f:	75 f7                	jne    801798 <strlen+0xd>
		n++;
	return n;
}
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	eb 03                	jmp    8017b6 <strnlen+0x13>
		n++;
  8017b3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017b6:	39 c2                	cmp    %eax,%edx
  8017b8:	74 08                	je     8017c2 <strnlen+0x1f>
  8017ba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8017be:	75 f3                	jne    8017b3 <strnlen+0x10>
  8017c0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	53                   	push   %ebx
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017ce:	89 c2                	mov    %eax,%edx
  8017d0:	83 c2 01             	add    $0x1,%edx
  8017d3:	83 c1 01             	add    $0x1,%ecx
  8017d6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017da:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017dd:	84 db                	test   %bl,%bl
  8017df:	75 ef                	jne    8017d0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017e1:	5b                   	pop    %ebx
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017eb:	53                   	push   %ebx
  8017ec:	e8 9a ff ff ff       	call   80178b <strlen>
  8017f1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017f4:	ff 75 0c             	pushl  0xc(%ebp)
  8017f7:	01 d8                	add    %ebx,%eax
  8017f9:	50                   	push   %eax
  8017fa:	e8 c5 ff ff ff       	call   8017c4 <strcpy>
	return dst;
}
  8017ff:	89 d8                	mov    %ebx,%eax
  801801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	8b 75 08             	mov    0x8(%ebp),%esi
  80180e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801811:	89 f3                	mov    %esi,%ebx
  801813:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801816:	89 f2                	mov    %esi,%edx
  801818:	eb 0f                	jmp    801829 <strncpy+0x23>
		*dst++ = *src;
  80181a:	83 c2 01             	add    $0x1,%edx
  80181d:	0f b6 01             	movzbl (%ecx),%eax
  801820:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801823:	80 39 01             	cmpb   $0x1,(%ecx)
  801826:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801829:	39 da                	cmp    %ebx,%edx
  80182b:	75 ed                	jne    80181a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80182d:	89 f0                	mov    %esi,%eax
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	8b 75 08             	mov    0x8(%ebp),%esi
  80183b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183e:	8b 55 10             	mov    0x10(%ebp),%edx
  801841:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801843:	85 d2                	test   %edx,%edx
  801845:	74 21                	je     801868 <strlcpy+0x35>
  801847:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80184b:	89 f2                	mov    %esi,%edx
  80184d:	eb 09                	jmp    801858 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80184f:	83 c2 01             	add    $0x1,%edx
  801852:	83 c1 01             	add    $0x1,%ecx
  801855:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801858:	39 c2                	cmp    %eax,%edx
  80185a:	74 09                	je     801865 <strlcpy+0x32>
  80185c:	0f b6 19             	movzbl (%ecx),%ebx
  80185f:	84 db                	test   %bl,%bl
  801861:	75 ec                	jne    80184f <strlcpy+0x1c>
  801863:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801865:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801868:	29 f0                	sub    %esi,%eax
}
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801874:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801877:	eb 06                	jmp    80187f <strcmp+0x11>
		p++, q++;
  801879:	83 c1 01             	add    $0x1,%ecx
  80187c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80187f:	0f b6 01             	movzbl (%ecx),%eax
  801882:	84 c0                	test   %al,%al
  801884:	74 04                	je     80188a <strcmp+0x1c>
  801886:	3a 02                	cmp    (%edx),%al
  801888:	74 ef                	je     801879 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80188a:	0f b6 c0             	movzbl %al,%eax
  80188d:	0f b6 12             	movzbl (%edx),%edx
  801890:	29 d0                	sub    %edx,%eax
}
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	53                   	push   %ebx
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018a3:	eb 06                	jmp    8018ab <strncmp+0x17>
		n--, p++, q++;
  8018a5:	83 c0 01             	add    $0x1,%eax
  8018a8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8018ab:	39 d8                	cmp    %ebx,%eax
  8018ad:	74 15                	je     8018c4 <strncmp+0x30>
  8018af:	0f b6 08             	movzbl (%eax),%ecx
  8018b2:	84 c9                	test   %cl,%cl
  8018b4:	74 04                	je     8018ba <strncmp+0x26>
  8018b6:	3a 0a                	cmp    (%edx),%cl
  8018b8:	74 eb                	je     8018a5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018ba:	0f b6 00             	movzbl (%eax),%eax
  8018bd:	0f b6 12             	movzbl (%edx),%edx
  8018c0:	29 d0                	sub    %edx,%eax
  8018c2:	eb 05                	jmp    8018c9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8018c4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018d6:	eb 07                	jmp    8018df <strchr+0x13>
		if (*s == c)
  8018d8:	38 ca                	cmp    %cl,%dl
  8018da:	74 0f                	je     8018eb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018dc:	83 c0 01             	add    $0x1,%eax
  8018df:	0f b6 10             	movzbl (%eax),%edx
  8018e2:	84 d2                	test   %dl,%dl
  8018e4:	75 f2                	jne    8018d8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f7:	eb 03                	jmp    8018fc <strfind+0xf>
  8018f9:	83 c0 01             	add    $0x1,%eax
  8018fc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018ff:	38 ca                	cmp    %cl,%dl
  801901:	74 04                	je     801907 <strfind+0x1a>
  801903:	84 d2                	test   %dl,%dl
  801905:	75 f2                	jne    8018f9 <strfind+0xc>
			break;
	return (char *) s;
}
  801907:	5d                   	pop    %ebp
  801908:	c3                   	ret    

00801909 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801909:	55                   	push   %ebp
  80190a:	89 e5                	mov    %esp,%ebp
  80190c:	57                   	push   %edi
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
  80190f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801915:	85 c9                	test   %ecx,%ecx
  801917:	74 36                	je     80194f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801919:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80191f:	75 28                	jne    801949 <memset+0x40>
  801921:	f6 c1 03             	test   $0x3,%cl
  801924:	75 23                	jne    801949 <memset+0x40>
		c &= 0xFF;
  801926:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80192a:	89 d3                	mov    %edx,%ebx
  80192c:	c1 e3 08             	shl    $0x8,%ebx
  80192f:	89 d6                	mov    %edx,%esi
  801931:	c1 e6 18             	shl    $0x18,%esi
  801934:	89 d0                	mov    %edx,%eax
  801936:	c1 e0 10             	shl    $0x10,%eax
  801939:	09 f0                	or     %esi,%eax
  80193b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80193d:	89 d8                	mov    %ebx,%eax
  80193f:	09 d0                	or     %edx,%eax
  801941:	c1 e9 02             	shr    $0x2,%ecx
  801944:	fc                   	cld    
  801945:	f3 ab                	rep stos %eax,%es:(%edi)
  801947:	eb 06                	jmp    80194f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194c:	fc                   	cld    
  80194d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80194f:	89 f8                	mov    %edi,%eax
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5f                   	pop    %edi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801964:	39 c6                	cmp    %eax,%esi
  801966:	73 35                	jae    80199d <memmove+0x47>
  801968:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80196b:	39 d0                	cmp    %edx,%eax
  80196d:	73 2e                	jae    80199d <memmove+0x47>
		s += n;
		d += n;
  80196f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801972:	89 d6                	mov    %edx,%esi
  801974:	09 fe                	or     %edi,%esi
  801976:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80197c:	75 13                	jne    801991 <memmove+0x3b>
  80197e:	f6 c1 03             	test   $0x3,%cl
  801981:	75 0e                	jne    801991 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801983:	83 ef 04             	sub    $0x4,%edi
  801986:	8d 72 fc             	lea    -0x4(%edx),%esi
  801989:	c1 e9 02             	shr    $0x2,%ecx
  80198c:	fd                   	std    
  80198d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80198f:	eb 09                	jmp    80199a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801991:	83 ef 01             	sub    $0x1,%edi
  801994:	8d 72 ff             	lea    -0x1(%edx),%esi
  801997:	fd                   	std    
  801998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80199a:	fc                   	cld    
  80199b:	eb 1d                	jmp    8019ba <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80199d:	89 f2                	mov    %esi,%edx
  80199f:	09 c2                	or     %eax,%edx
  8019a1:	f6 c2 03             	test   $0x3,%dl
  8019a4:	75 0f                	jne    8019b5 <memmove+0x5f>
  8019a6:	f6 c1 03             	test   $0x3,%cl
  8019a9:	75 0a                	jne    8019b5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8019ab:	c1 e9 02             	shr    $0x2,%ecx
  8019ae:	89 c7                	mov    %eax,%edi
  8019b0:	fc                   	cld    
  8019b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019b3:	eb 05                	jmp    8019ba <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8019b5:	89 c7                	mov    %eax,%edi
  8019b7:	fc                   	cld    
  8019b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019ba:	5e                   	pop    %esi
  8019bb:	5f                   	pop    %edi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    

008019be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8019c1:	ff 75 10             	pushl  0x10(%ebp)
  8019c4:	ff 75 0c             	pushl  0xc(%ebp)
  8019c7:	ff 75 08             	pushl  0x8(%ebp)
  8019ca:	e8 87 ff ff ff       	call   801956 <memmove>
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019dc:	89 c6                	mov    %eax,%esi
  8019de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019e1:	eb 1a                	jmp    8019fd <memcmp+0x2c>
		if (*s1 != *s2)
  8019e3:	0f b6 08             	movzbl (%eax),%ecx
  8019e6:	0f b6 1a             	movzbl (%edx),%ebx
  8019e9:	38 d9                	cmp    %bl,%cl
  8019eb:	74 0a                	je     8019f7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019ed:	0f b6 c1             	movzbl %cl,%eax
  8019f0:	0f b6 db             	movzbl %bl,%ebx
  8019f3:	29 d8                	sub    %ebx,%eax
  8019f5:	eb 0f                	jmp    801a06 <memcmp+0x35>
		s1++, s2++;
  8019f7:	83 c0 01             	add    $0x1,%eax
  8019fa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019fd:	39 f0                	cmp    %esi,%eax
  8019ff:	75 e2                	jne    8019e3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801a11:	89 c1                	mov    %eax,%ecx
  801a13:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801a16:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a1a:	eb 0a                	jmp    801a26 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a1c:	0f b6 10             	movzbl (%eax),%edx
  801a1f:	39 da                	cmp    %ebx,%edx
  801a21:	74 07                	je     801a2a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a23:	83 c0 01             	add    $0x1,%eax
  801a26:	39 c8                	cmp    %ecx,%eax
  801a28:	72 f2                	jb     801a1c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a2a:	5b                   	pop    %ebx
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	57                   	push   %edi
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a39:	eb 03                	jmp    801a3e <strtol+0x11>
		s++;
  801a3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a3e:	0f b6 01             	movzbl (%ecx),%eax
  801a41:	3c 20                	cmp    $0x20,%al
  801a43:	74 f6                	je     801a3b <strtol+0xe>
  801a45:	3c 09                	cmp    $0x9,%al
  801a47:	74 f2                	je     801a3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a49:	3c 2b                	cmp    $0x2b,%al
  801a4b:	75 0a                	jne    801a57 <strtol+0x2a>
		s++;
  801a4d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a50:	bf 00 00 00 00       	mov    $0x0,%edi
  801a55:	eb 11                	jmp    801a68 <strtol+0x3b>
  801a57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a5c:	3c 2d                	cmp    $0x2d,%al
  801a5e:	75 08                	jne    801a68 <strtol+0x3b>
		s++, neg = 1;
  801a60:	83 c1 01             	add    $0x1,%ecx
  801a63:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a6e:	75 15                	jne    801a85 <strtol+0x58>
  801a70:	80 39 30             	cmpb   $0x30,(%ecx)
  801a73:	75 10                	jne    801a85 <strtol+0x58>
  801a75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a79:	75 7c                	jne    801af7 <strtol+0xca>
		s += 2, base = 16;
  801a7b:	83 c1 02             	add    $0x2,%ecx
  801a7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a83:	eb 16                	jmp    801a9b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a85:	85 db                	test   %ebx,%ebx
  801a87:	75 12                	jne    801a9b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a89:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a8e:	80 39 30             	cmpb   $0x30,(%ecx)
  801a91:	75 08                	jne    801a9b <strtol+0x6e>
		s++, base = 8;
  801a93:	83 c1 01             	add    $0x1,%ecx
  801a96:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801aa3:	0f b6 11             	movzbl (%ecx),%edx
  801aa6:	8d 72 d0             	lea    -0x30(%edx),%esi
  801aa9:	89 f3                	mov    %esi,%ebx
  801aab:	80 fb 09             	cmp    $0x9,%bl
  801aae:	77 08                	ja     801ab8 <strtol+0x8b>
			dig = *s - '0';
  801ab0:	0f be d2             	movsbl %dl,%edx
  801ab3:	83 ea 30             	sub    $0x30,%edx
  801ab6:	eb 22                	jmp    801ada <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ab8:	8d 72 9f             	lea    -0x61(%edx),%esi
  801abb:	89 f3                	mov    %esi,%ebx
  801abd:	80 fb 19             	cmp    $0x19,%bl
  801ac0:	77 08                	ja     801aca <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ac2:	0f be d2             	movsbl %dl,%edx
  801ac5:	83 ea 57             	sub    $0x57,%edx
  801ac8:	eb 10                	jmp    801ada <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801aca:	8d 72 bf             	lea    -0x41(%edx),%esi
  801acd:	89 f3                	mov    %esi,%ebx
  801acf:	80 fb 19             	cmp    $0x19,%bl
  801ad2:	77 16                	ja     801aea <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ad4:	0f be d2             	movsbl %dl,%edx
  801ad7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ada:	3b 55 10             	cmp    0x10(%ebp),%edx
  801add:	7d 0b                	jge    801aea <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801adf:	83 c1 01             	add    $0x1,%ecx
  801ae2:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ae6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ae8:	eb b9                	jmp    801aa3 <strtol+0x76>

	if (endptr)
  801aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801aee:	74 0d                	je     801afd <strtol+0xd0>
		*endptr = (char *) s;
  801af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af3:	89 0e                	mov    %ecx,(%esi)
  801af5:	eb 06                	jmp    801afd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801af7:	85 db                	test   %ebx,%ebx
  801af9:	74 98                	je     801a93 <strtol+0x66>
  801afb:	eb 9e                	jmp    801a9b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801afd:	89 c2                	mov    %eax,%edx
  801aff:	f7 da                	neg    %edx
  801b01:	85 ff                	test   %edi,%edi
  801b03:	0f 45 c2             	cmovne %edx,%eax
}
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5f                   	pop    %edi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	57                   	push   %edi
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 04             	sub    $0x4,%esp
  801b14:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801b17:	57                   	push   %edi
  801b18:	e8 6e fc ff ff       	call   80178b <strlen>
  801b1d:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b20:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801b23:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b2d:	eb 46                	jmp    801b75 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801b2f:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801b33:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b36:	80 f9 09             	cmp    $0x9,%cl
  801b39:	77 08                	ja     801b43 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b3b:	0f be d2             	movsbl %dl,%edx
  801b3e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b41:	eb 27                	jmp    801b6a <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b43:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b46:	80 f9 05             	cmp    $0x5,%cl
  801b49:	77 08                	ja     801b53 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b4b:	0f be d2             	movsbl %dl,%edx
  801b4e:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b51:	eb 17                	jmp    801b6a <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b53:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b56:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b59:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b5e:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b62:	77 06                	ja     801b6a <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b64:	0f be d2             	movsbl %dl,%edx
  801b67:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b6a:	0f af ce             	imul   %esi,%ecx
  801b6d:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b6f:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b72:	83 eb 01             	sub    $0x1,%ebx
  801b75:	83 fb 01             	cmp    $0x1,%ebx
  801b78:	7f b5                	jg     801b2f <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5f                   	pop    %edi
  801b80:	5d                   	pop    %ebp
  801b81:	c3                   	ret    

00801b82 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801b88:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b8f:	75 52                	jne    801be3 <set_pgfault_handler+0x61>
		// First time through!
		// LAB 4: Your code here.
		int r;
		
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) 
  801b91:	83 ec 04             	sub    $0x4,%esp
  801b94:	6a 07                	push   $0x7
  801b96:	68 00 f0 bf ee       	push   $0xeebff000
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 ce e5 ff ff       	call   800170 <sys_page_alloc>
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	79 12                	jns    801bbb <set_pgfault_handler+0x39>
			panic("sys_page_alloc: %e", r);
  801ba9:	50                   	push   %eax
  801baa:	68 3f 24 80 00       	push   $0x80243f
  801baf:	6a 23                	push   $0x23
  801bb1:	68 52 24 80 00       	push   $0x802452
  801bb6:	e8 fc f4 ff ff       	call   8010b7 <_panic>
		
		if((r = sys_env_set_pgfault_upcall(0, _pgfault_upcall)) < 0)
  801bbb:	83 ec 08             	sub    $0x8,%esp
  801bbe:	68 61 03 80 00       	push   $0x800361
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 f1 e6 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	79 12                	jns    801be3 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall: %e", r);
  801bd1:	50                   	push   %eax
  801bd2:	68 60 24 80 00       	push   $0x802460
  801bd7:	6a 26                	push   $0x26
  801bd9:	68 52 24 80 00       	push   $0x802452
  801bde:	e8 d4 f4 ff ff       	call   8010b7 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    

00801bed <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	56                   	push   %esi
  801bf1:	53                   	push   %ebx
  801bf2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801bfb:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801bfd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c02:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	50                   	push   %eax
  801c09:	e8 12 e7 ff ff       	call   800320 <sys_ipc_recv>
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	85 c0                	test   %eax,%eax
  801c13:	79 16                	jns    801c2b <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801c15:	85 f6                	test   %esi,%esi
  801c17:	74 06                	je     801c1f <ipc_recv+0x32>
			*from_env_store = 0;
  801c19:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c1f:	85 db                	test   %ebx,%ebx
  801c21:	74 2c                	je     801c4f <ipc_recv+0x62>
			*perm_store = 0;
  801c23:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c29:	eb 24                	jmp    801c4f <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801c2b:	85 f6                	test   %esi,%esi
  801c2d:	74 0a                	je     801c39 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801c2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801c34:	8b 40 74             	mov    0x74(%eax),%eax
  801c37:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c39:	85 db                	test   %ebx,%ebx
  801c3b:	74 0a                	je     801c47 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801c3d:	a1 08 40 80 00       	mov    0x804008,%eax
  801c42:	8b 40 78             	mov    0x78(%eax),%eax
  801c45:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801c47:	a1 08 40 80 00       	mov    0x804008,%eax
  801c4c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	57                   	push   %edi
  801c5a:	56                   	push   %esi
  801c5b:	53                   	push   %ebx
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c62:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801c68:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801c6a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c6f:	0f 44 d8             	cmove  %eax,%ebx
  801c72:	eb 1e                	jmp    801c92 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801c74:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c77:	74 14                	je     801c8d <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	68 80 24 80 00       	push   $0x802480
  801c81:	6a 44                	push   $0x44
  801c83:	68 ac 24 80 00       	push   $0x8024ac
  801c88:	e8 2a f4 ff ff       	call   8010b7 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c8d:	e8 bf e4 ff ff       	call   800151 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c92:	ff 75 14             	pushl  0x14(%ebp)
  801c95:	53                   	push   %ebx
  801c96:	56                   	push   %esi
  801c97:	57                   	push   %edi
  801c98:	e8 60 e6 ff ff       	call   8002fd <sys_ipc_try_send>
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 d0                	js     801c74 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5f                   	pop    %edi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc0:	8b 52 50             	mov    0x50(%edx),%edx
  801cc3:	39 ca                	cmp    %ecx,%edx
  801cc5:	75 0d                	jne    801cd4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ccf:	8b 40 48             	mov    0x48(%eax),%eax
  801cd2:	eb 0f                	jmp    801ce3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cd4:	83 c0 01             	add    $0x1,%eax
  801cd7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdc:	75 d9                	jne    801cb7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	c1 e8 16             	shr    $0x16,%eax
  801cf0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cfc:	f6 c1 01             	test   $0x1,%cl
  801cff:	74 1d                	je     801d1e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d01:	c1 ea 0c             	shr    $0xc,%edx
  801d04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d0b:	f6 c2 01             	test   $0x1,%dl
  801d0e:	74 0e                	je     801d1e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d10:	c1 ea 0c             	shr    $0xc,%edx
  801d13:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d1a:	ef 
  801d1b:	0f b7 c0             	movzwl %ax,%eax
}
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 f6                	test   %esi,%esi
  801d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3d:	89 ca                	mov    %ecx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	75 3d                	jne    801d80 <__udivdi3+0x60>
  801d43:	39 cf                	cmp    %ecx,%edi
  801d45:	0f 87 c5 00 00 00    	ja     801e10 <__udivdi3+0xf0>
  801d4b:	85 ff                	test   %edi,%edi
  801d4d:	89 fd                	mov    %edi,%ebp
  801d4f:	75 0b                	jne    801d5c <__udivdi3+0x3c>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	31 d2                	xor    %edx,%edx
  801d58:	f7 f7                	div    %edi
  801d5a:	89 c5                	mov    %eax,%ebp
  801d5c:	89 c8                	mov    %ecx,%eax
  801d5e:	31 d2                	xor    %edx,%edx
  801d60:	f7 f5                	div    %ebp
  801d62:	89 c1                	mov    %eax,%ecx
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	89 cf                	mov    %ecx,%edi
  801d68:	f7 f5                	div    %ebp
  801d6a:	89 c3                	mov    %eax,%ebx
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
  801d80:	39 ce                	cmp    %ecx,%esi
  801d82:	77 74                	ja     801df8 <__udivdi3+0xd8>
  801d84:	0f bd fe             	bsr    %esi,%edi
  801d87:	83 f7 1f             	xor    $0x1f,%edi
  801d8a:	0f 84 98 00 00 00    	je     801e28 <__udivdi3+0x108>
  801d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	29 fb                	sub    %edi,%ebx
  801d9b:	d3 e6                	shl    %cl,%esi
  801d9d:	89 d9                	mov    %ebx,%ecx
  801d9f:	d3 ed                	shr    %cl,%ebp
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e0                	shl    %cl,%eax
  801da5:	09 ee                	or     %ebp,%esi
  801da7:	89 d9                	mov    %ebx,%ecx
  801da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dad:	89 d5                	mov    %edx,%ebp
  801daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801db3:	d3 ed                	shr    %cl,%ebp
  801db5:	89 f9                	mov    %edi,%ecx
  801db7:	d3 e2                	shl    %cl,%edx
  801db9:	89 d9                	mov    %ebx,%ecx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	09 c2                	or     %eax,%edx
  801dbf:	89 d0                	mov    %edx,%eax
  801dc1:	89 ea                	mov    %ebp,%edx
  801dc3:	f7 f6                	div    %esi
  801dc5:	89 d5                	mov    %edx,%ebp
  801dc7:	89 c3                	mov    %eax,%ebx
  801dc9:	f7 64 24 0c          	mull   0xc(%esp)
  801dcd:	39 d5                	cmp    %edx,%ebp
  801dcf:	72 10                	jb     801de1 <__udivdi3+0xc1>
  801dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e6                	shl    %cl,%esi
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 07                	jae    801de4 <__udivdi3+0xc4>
  801ddd:	39 d5                	cmp    %edx,%ebp
  801ddf:	75 03                	jne    801de4 <__udivdi3+0xc4>
  801de1:	83 eb 01             	sub    $0x1,%ebx
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	89 d8                	mov    %ebx,%eax
  801de8:	89 fa                	mov    %edi,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	31 ff                	xor    %edi,%edi
  801dfa:	31 db                	xor    %ebx,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	f7 f7                	div    %edi
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 fa                	mov    %edi,%edx
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	72 0c                	jb     801e38 <__udivdi3+0x118>
  801e2c:	31 db                	xor    %ebx,%ebx
  801e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e32:	0f 87 34 ff ff ff    	ja     801d6c <__udivdi3+0x4c>
  801e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e3d:	e9 2a ff ff ff       	jmp    801d6c <__udivdi3+0x4c>
  801e42:	66 90                	xchg   %ax,%ax
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 d2                	test   %edx,%edx
  801e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 f3                	mov    %esi,%ebx
  801e73:	89 3c 24             	mov    %edi,(%esp)
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	75 1c                	jne    801e98 <__umoddi3+0x48>
  801e7c:	39 f7                	cmp    %esi,%edi
  801e7e:	76 50                	jbe    801ed0 <__umoddi3+0x80>
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	f7 f7                	div    %edi
  801e86:	89 d0                	mov    %edx,%eax
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	39 f2                	cmp    %esi,%edx
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	77 52                	ja     801ef0 <__umoddi3+0xa0>
  801e9e:	0f bd ea             	bsr    %edx,%ebp
  801ea1:	83 f5 1f             	xor    $0x1f,%ebp
  801ea4:	75 5a                	jne    801f00 <__umoddi3+0xb0>
  801ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eaa:	0f 82 e0 00 00 00    	jb     801f90 <__umoddi3+0x140>
  801eb0:	39 0c 24             	cmp    %ecx,(%esp)
  801eb3:	0f 86 d7 00 00 00    	jbe    801f90 <__umoddi3+0x140>
  801eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	85 ff                	test   %edi,%edi
  801ed2:	89 fd                	mov    %edi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f7                	div    %edi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	31 d2                	xor    %edx,%edx
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 c8                	mov    %ecx,%eax
  801ee9:	f7 f5                	div    %ebp
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	eb 99                	jmp    801e88 <__umoddi3+0x38>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	83 c4 1c             	add    $0x1c,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 34 24             	mov    (%esp),%esi
  801f03:	bf 20 00 00 00       	mov    $0x20,%edi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ef                	sub    %ebp,%edi
  801f0c:	d3 e0                	shl    %cl,%eax
  801f0e:	89 f9                	mov    %edi,%ecx
  801f10:	89 f2                	mov    %esi,%edx
  801f12:	d3 ea                	shr    %cl,%edx
  801f14:	89 e9                	mov    %ebp,%ecx
  801f16:	09 c2                	or     %eax,%edx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 14 24             	mov    %edx,(%esp)
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	d3 e2                	shl    %cl,%edx
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f2b:	d3 e8                	shr    %cl,%eax
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	89 c6                	mov    %eax,%esi
  801f31:	d3 e3                	shl    %cl,%ebx
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	09 d8                	or     %ebx,%eax
  801f3d:	89 d3                	mov    %edx,%ebx
  801f3f:	89 f2                	mov    %esi,%edx
  801f41:	f7 34 24             	divl   (%esp)
  801f44:	89 d6                	mov    %edx,%esi
  801f46:	d3 e3                	shl    %cl,%ebx
  801f48:	f7 64 24 04          	mull   0x4(%esp)
  801f4c:	39 d6                	cmp    %edx,%esi
  801f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f52:	89 d1                	mov    %edx,%ecx
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	72 08                	jb     801f60 <__umoddi3+0x110>
  801f58:	75 11                	jne    801f6b <__umoddi3+0x11b>
  801f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f5e:	73 0b                	jae    801f6b <__umoddi3+0x11b>
  801f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f64:	1b 14 24             	sbb    (%esp),%edx
  801f67:	89 d1                	mov    %edx,%ecx
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f6f:	29 da                	sub    %ebx,%edx
  801f71:	19 ce                	sbb    %ecx,%esi
  801f73:	89 f9                	mov    %edi,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e0                	shl    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	d3 ea                	shr    %cl,%edx
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	09 d0                	or     %edx,%eax
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	83 c4 1c             	add    $0x1c,%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	29 f9                	sub    %edi,%ecx
  801f92:	19 d6                	sbb    %edx,%esi
  801f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f9c:	e9 18 ff ff ff       	jmp    801eb9 <__umoddi3+0x69>
