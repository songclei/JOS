
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 2a 1f 80 00       	push   $0x801f2a
  800114:	6a 23                	push   $0x23
  800116:	68 47 1f 80 00       	push   $0x801f47
  80011b:	e8 69 0f 00 00       	call   801089 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 2a 1f 80 00       	push   $0x801f2a
  800195:	6a 23                	push   $0x23
  800197:	68 47 1f 80 00       	push   $0x801f47
  80019c:	e8 e8 0e 00 00       	call   801089 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 2a 1f 80 00       	push   $0x801f2a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 47 1f 80 00       	push   $0x801f47
  8001de:	e8 a6 0e 00 00       	call   801089 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 2a 1f 80 00       	push   $0x801f2a
  800219:	6a 23                	push   $0x23
  80021b:	68 47 1f 80 00       	push   $0x801f47
  800220:	e8 64 0e 00 00       	call   801089 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 2a 1f 80 00       	push   $0x801f2a
  80025b:	6a 23                	push   $0x23
  80025d:	68 47 1f 80 00       	push   $0x801f47
  800262:	e8 22 0e 00 00       	call   801089 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 0a                	push   $0xa
  800298:	68 2a 1f 80 00       	push   $0x801f2a
  80029d:	6a 23                	push   $0x23
  80029f:	68 47 1f 80 00       	push   $0x801f47
  8002a4:	e8 e0 0d 00 00       	call   801089 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 09                	push   $0x9
  8002da:	68 2a 1f 80 00       	push   $0x801f2a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 47 1f 80 00       	push   $0x801f47
  8002e6:	e8 9e 0d 00 00       	call   801089 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 2a 1f 80 00       	push   $0x801f2a
  800343:	6a 23                	push   $0x23
  800345:	68 47 1f 80 00       	push   $0x801f47
  80034a:	e8 3a 0d 00 00       	call   801089 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 08 40 80 00       	mov    0x804008,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 58 1f 80 00       	push   $0x801f58
  80045e:	e8 ff 0c 00 00       	call   801162 <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2) 
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0); 
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close) 
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 08 40 80 00       	mov    0x804008,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 99 1f 80 00       	push   $0x801f99
  800688:	e8 d5 0a 00 00       	call   801162 <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 08 40 80 00       	mov    0x804008,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 b5 1f 80 00       	push   $0x801fb5
  80075d:	e8 00 0a 00 00       	call   801162 <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 78 1f 80 00       	push   $0x801f78
  800812:	e8 4b 09 00 00       	call   801162 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 2b 02 00 00       	call   800b06 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 f1 12 00 00       	call   801c13 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 80 12 00 00       	call   801bbd <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 0a 12 00 00       	call   801b54 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 c3 0d 00 00       	call   801796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	83 ec 08             	sub    $0x8,%esp
  8009fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800a00:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a05:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a0a:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 40 0c             	mov    0xc(%eax),%eax
  800a13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a18:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a1e:	53                   	push   %ebx
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	68 08 50 80 00       	push   $0x805008
  800a27:	e8 fc 0e 00 00       	call   801928 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a31:	b8 04 00 00 00       	mov    $0x4,%eax
  800a36:	e8 cb fe ff ff       	call   800906 <fsipc>
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 3d                	js     800a7f <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a42:	39 d8                	cmp    %ebx,%eax
  800a44:	76 19                	jbe    800a5f <devfile_write+0x69>
  800a46:	68 e4 1f 80 00       	push   $0x801fe4
  800a4b:	68 eb 1f 80 00       	push   $0x801feb
  800a50:	68 9f 00 00 00       	push   $0x9f
  800a55:	68 00 20 80 00       	push   $0x802000
  800a5a:	e8 2a 06 00 00       	call   801089 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a5f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a64:	76 19                	jbe    800a7f <devfile_write+0x89>
  800a66:	68 18 20 80 00       	push   $0x802018
  800a6b:	68 eb 1f 80 00       	push   $0x801feb
  800a70:	68 a0 00 00 00       	push   $0xa0
  800a75:	68 00 20 80 00       	push   $0x802000
  800a7a:	e8 0a 06 00 00       	call   801089 <_panic>

	return r;
}
  800a7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a92:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a97:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa7:	e8 5a fe ff ff       	call   800906 <fsipc>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	78 4b                	js     800afd <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab2:	39 c6                	cmp    %eax,%esi
  800ab4:	73 16                	jae    800acc <devfile_read+0x48>
  800ab6:	68 e4 1f 80 00       	push   $0x801fe4
  800abb:	68 eb 1f 80 00       	push   $0x801feb
  800ac0:	6a 7e                	push   $0x7e
  800ac2:	68 00 20 80 00       	push   $0x802000
  800ac7:	e8 bd 05 00 00       	call   801089 <_panic>
	assert(r <= PGSIZE);
  800acc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad1:	7e 16                	jle    800ae9 <devfile_read+0x65>
  800ad3:	68 0b 20 80 00       	push   $0x80200b
  800ad8:	68 eb 1f 80 00       	push   $0x801feb
  800add:	6a 7f                	push   $0x7f
  800adf:	68 00 20 80 00       	push   $0x802000
  800ae4:	e8 a0 05 00 00       	call   801089 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae9:	83 ec 04             	sub    $0x4,%esp
  800aec:	50                   	push   %eax
  800aed:	68 00 50 80 00       	push   $0x805000
  800af2:	ff 75 0c             	pushl  0xc(%ebp)
  800af5:	e8 2e 0e 00 00       	call   801928 <memmove>
	return r;
  800afa:	83 c4 10             	add    $0x10,%esp
}
  800afd:	89 d8                	mov    %ebx,%eax
  800aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 20             	sub    $0x20,%esp
  800b0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b10:	53                   	push   %ebx
  800b11:	e8 47 0c 00 00       	call   80175d <strlen>
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1e:	7f 67                	jg     800b87 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	e8 52 f8 ff ff       	call   80037e <fd_alloc>
  800b2c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 57                	js     800b8c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	53                   	push   %ebx
  800b39:	68 00 50 80 00       	push   $0x805000
  800b3e:	e8 53 0c 00 00       	call   801796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b53:	e8 ae fd ff ff       	call   800906 <fsipc>
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	79 14                	jns    800b75 <open+0x6f>
		fd_close(fd, 0);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	6a 00                	push   $0x0
  800b66:	ff 75 f4             	pushl  -0xc(%ebp)
  800b69:	e8 08 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	89 da                	mov    %ebx,%edx
  800b73:	eb 17                	jmp    800b8c <open+0x86>
	}

	return fd2num(fd);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7b:	e8 d7 f7 ff ff       	call   800357 <fd2num>
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	eb 05                	jmp    800b8c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b87:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b8c:	89 d0                	mov    %edx,%eax
  800b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba3:	e8 5e fd ff ff       	call   800906 <fsipc>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	ff 75 08             	pushl  0x8(%ebp)
  800bb8:	e8 aa f7 ff ff       	call   800367 <fd2data>
  800bbd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	68 45 20 80 00       	push   $0x802045
  800bc7:	53                   	push   %ebx
  800bc8:	e8 c9 0b 00 00       	call   801796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bcd:	8b 46 04             	mov    0x4(%esi),%eax
  800bd0:	2b 06                	sub    (%esi),%eax
  800bd2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdf:	00 00 00 
	stat->st_dev = &devpipe;
  800be2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be9:	30 80 00 
	return 0;
}
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c02:	53                   	push   %ebx
  800c03:	6a 00                	push   $0x0
  800c05:	e8 e1 f5 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c0a:	89 1c 24             	mov    %ebx,(%esp)
  800c0d:	e8 55 f7 ff ff       	call   800367 <fd2data>
  800c12:	83 c4 08             	add    $0x8,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 00                	push   $0x0
  800c18:	e8 ce f5 ff ff       	call   8001eb <sys_page_unmap>
}
  800c1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 1c             	sub    $0x1c,%esp
  800c2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c30:	a1 08 40 80 00       	mov    0x804008,%eax
  800c35:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3e:	e8 09 10 00 00       	call   801c4c <pageref>
  800c43:	89 c3                	mov    %eax,%ebx
  800c45:	89 3c 24             	mov    %edi,(%esp)
  800c48:	e8 ff 0f 00 00       	call   801c4c <pageref>
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	39 c3                	cmp    %eax,%ebx
  800c52:	0f 94 c1             	sete   %cl
  800c55:	0f b6 c9             	movzbl %cl,%ecx
  800c58:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c5b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c61:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c64:	39 ce                	cmp    %ecx,%esi
  800c66:	74 1b                	je     800c83 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c68:	39 c3                	cmp    %eax,%ebx
  800c6a:	75 c4                	jne    800c30 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6c:	8b 42 58             	mov    0x58(%edx),%eax
  800c6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c72:	50                   	push   %eax
  800c73:	56                   	push   %esi
  800c74:	68 4c 20 80 00       	push   $0x80204c
  800c79:	e8 e4 04 00 00       	call   801162 <cprintf>
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	eb ad                	jmp    800c30 <_pipeisclosed+0xe>
	}
}
  800c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 28             	sub    $0x28,%esp
  800c97:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9a:	56                   	push   %esi
  800c9b:	e8 c7 f6 ff ff       	call   800367 <fd2data>
  800ca0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	bf 00 00 00 00       	mov    $0x0,%edi
  800caa:	eb 4b                	jmp    800cf7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cac:	89 da                	mov    %ebx,%edx
  800cae:	89 f0                	mov    %esi,%eax
  800cb0:	e8 6d ff ff ff       	call   800c22 <_pipeisclosed>
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	75 48                	jne    800d01 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb9:	e8 89 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbe:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc1:	8b 0b                	mov    (%ebx),%ecx
  800cc3:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	73 e2                	jae    800cac <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd4:	89 c2                	mov    %eax,%edx
  800cd6:	c1 fa 1f             	sar    $0x1f,%edx
  800cd9:	89 d1                	mov    %edx,%ecx
  800cdb:	c1 e9 1b             	shr    $0x1b,%ecx
  800cde:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce1:	83 e2 1f             	and    $0x1f,%edx
  800ce4:	29 ca                	sub    %ecx,%edx
  800ce6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cee:	83 c0 01             	add    $0x1,%eax
  800cf1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf4:	83 c7 01             	add    $0x1,%edi
  800cf7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cfa:	75 c2                	jne    800cbe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cfc:	8b 45 10             	mov    0x10(%ebp),%eax
  800cff:	eb 05                	jmp    800d06 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 18             	sub    $0x18,%esp
  800d17:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1a:	57                   	push   %edi
  800d1b:	e8 47 f6 ff ff       	call   800367 <fd2data>
  800d20:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c4 10             	add    $0x10,%esp
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	eb 3d                	jmp    800d69 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d2c:	85 db                	test   %ebx,%ebx
  800d2e:	74 04                	je     800d34 <devpipe_read+0x26>
				return i;
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	eb 44                	jmp    800d78 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d34:	89 f2                	mov    %esi,%edx
  800d36:	89 f8                	mov    %edi,%eax
  800d38:	e8 e5 fe ff ff       	call   800c22 <_pipeisclosed>
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	75 32                	jne    800d73 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d41:	e8 01 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d46:	8b 06                	mov    (%esi),%eax
  800d48:	3b 46 04             	cmp    0x4(%esi),%eax
  800d4b:	74 df                	je     800d2c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4d:	99                   	cltd   
  800d4e:	c1 ea 1b             	shr    $0x1b,%edx
  800d51:	01 d0                	add    %edx,%eax
  800d53:	83 e0 1f             	and    $0x1f,%eax
  800d56:	29 d0                	sub    %edx,%eax
  800d58:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d63:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d66:	83 c3 01             	add    $0x1,%ebx
  800d69:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d6c:	75 d8                	jne    800d46 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d71:	eb 05                	jmp    800d78 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8b:	50                   	push   %eax
  800d8c:	e8 ed f5 ff ff       	call   80037e <fd_alloc>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	85 c0                	test   %eax,%eax
  800d98:	0f 88 2c 01 00 00    	js     800eca <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 07 04 00 00       	push   $0x407
  800da6:	ff 75 f4             	pushl  -0xc(%ebp)
  800da9:	6a 00                	push   $0x0
  800dab:	e8 b6 f3 ff ff       	call   800166 <sys_page_alloc>
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	89 c2                	mov    %eax,%edx
  800db5:	85 c0                	test   %eax,%eax
  800db7:	0f 88 0d 01 00 00    	js     800eca <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc3:	50                   	push   %eax
  800dc4:	e8 b5 f5 ff ff       	call   80037e <fd_alloc>
  800dc9:	89 c3                	mov    %eax,%ebx
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	0f 88 e2 00 00 00    	js     800eb8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	68 07 04 00 00       	push   $0x407
  800dde:	ff 75 f0             	pushl  -0x10(%ebp)
  800de1:	6a 00                	push   $0x0
  800de3:	e8 7e f3 ff ff       	call   800166 <sys_page_alloc>
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	0f 88 c3 00 00 00    	js     800eb8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfb:	e8 67 f5 ff ff       	call   800367 <fd2data>
  800e00:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e02:	83 c4 0c             	add    $0xc,%esp
  800e05:	68 07 04 00 00       	push   $0x407
  800e0a:	50                   	push   %eax
  800e0b:	6a 00                	push   $0x0
  800e0d:	e8 54 f3 ff ff       	call   800166 <sys_page_alloc>
  800e12:	89 c3                	mov    %eax,%ebx
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	0f 88 89 00 00 00    	js     800ea8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f0             	pushl  -0x10(%ebp)
  800e25:	e8 3d f5 ff ff       	call   800367 <fd2data>
  800e2a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e31:	50                   	push   %eax
  800e32:	6a 00                	push   $0x0
  800e34:	56                   	push   %esi
  800e35:	6a 00                	push   $0x0
  800e37:	e8 6d f3 ff ff       	call   8001a9 <sys_page_map>
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	83 c4 20             	add    $0x20,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	78 55                	js     800e9a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	ff 75 f4             	pushl  -0xc(%ebp)
  800e75:	e8 dd f4 ff ff       	call   800357 <fd2num>
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7f:	83 c4 04             	add    $0x4,%esp
  800e82:	ff 75 f0             	pushl  -0x10(%ebp)
  800e85:	e8 cd f4 ff ff       	call   800357 <fd2num>
  800e8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	eb 30                	jmp    800eca <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	56                   	push   %esi
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 46 f3 ff ff       	call   8001eb <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	ff 75 f0             	pushl  -0x10(%ebp)
  800eae:	6a 00                	push   $0x0
  800eb0:	e8 36 f3 ff ff       	call   8001eb <sys_page_unmap>
  800eb5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 26 f3 ff ff       	call   8001eb <sys_page_unmap>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eca:	89 d0                	mov    %edx,%eax
  800ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	ff 75 08             	pushl  0x8(%ebp)
  800ee0:	e8 e8 f4 ff ff       	call   8003cd <fd_lookup>
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 18                	js     800f04 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef2:	e8 70 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800ef7:	89 c2                	mov    %eax,%edx
  800ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efc:	e8 21 fd ff ff       	call   800c22 <_pipeisclosed>
  800f01:	83 c4 10             	add    $0x10,%esp
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f16:	68 64 20 80 00       	push   $0x802064
  800f1b:	ff 75 0c             	pushl  0xc(%ebp)
  800f1e:	e8 73 08 00 00       	call   801796 <strcpy>
	return 0;
}
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f36:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f41:	eb 2d                	jmp    800f70 <devcons_write+0x46>
		m = n - tot;
  800f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f46:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f48:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f4b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f50:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	53                   	push   %ebx
  800f57:	03 45 0c             	add    0xc(%ebp),%eax
  800f5a:	50                   	push   %eax
  800f5b:	57                   	push   %edi
  800f5c:	e8 c7 09 00 00       	call   801928 <memmove>
		sys_cputs(buf, m);
  800f61:	83 c4 08             	add    $0x8,%esp
  800f64:	53                   	push   %ebx
  800f65:	57                   	push   %edi
  800f66:	e8 3f f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6b:	01 de                	add    %ebx,%esi
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f75:	72 cc                	jb     800f43 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 08             	sub    $0x8,%esp
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8e:	74 2a                	je     800fba <devcons_read+0x3b>
  800f90:	eb 05                	jmp    800f97 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f92:	e8 b0 f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f97:	e8 2c f1 ff ff       	call   8000c8 <sys_cgetc>
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	74 f2                	je     800f92 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 16                	js     800fba <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa4:	83 f8 04             	cmp    $0x4,%eax
  800fa7:	74 0c                	je     800fb5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fac:	88 02                	mov    %al,(%edx)
	return 1;
  800fae:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb3:	eb 05                	jmp    800fba <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc8:	6a 01                	push   $0x1
  800fca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	e8 d7 f0 ff ff       	call   8000aa <sys_cputs>
}
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <getchar>:

int
getchar(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fde:	6a 01                	push   $0x1
  800fe0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe3:	50                   	push   %eax
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 48 f6 ff ff       	call   800633 <read>
	if (r < 0)
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 0f                	js     801001 <getchar+0x29>
		return r;
	if (r < 1)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	7e 06                	jle    800ffc <getchar+0x24>
		return -E_EOF;
	return c;
  800ff6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ffa:	eb 05                	jmp    801001 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ffc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801009:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	e8 b8 f3 ff ff       	call   8003cd <fd_lookup>
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 11                	js     80102d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80101c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801025:	39 10                	cmp    %edx,(%eax)
  801027:	0f 94 c0             	sete   %al
  80102a:	0f b6 c0             	movzbl %al,%eax
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <opencons>:

int
opencons(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801035:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801038:	50                   	push   %eax
  801039:	e8 40 f3 ff ff       	call   80037e <fd_alloc>
  80103e:	83 c4 10             	add    $0x10,%esp
		return r;
  801041:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801043:	85 c0                	test   %eax,%eax
  801045:	78 3e                	js     801085 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	68 07 04 00 00       	push   $0x407
  80104f:	ff 75 f4             	pushl  -0xc(%ebp)
  801052:	6a 00                	push   $0x0
  801054:	e8 0d f1 ff ff       	call   800166 <sys_page_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
		return r;
  80105c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 23                	js     801085 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801062:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	50                   	push   %eax
  80107b:	e8 d7 f2 ff ff       	call   800357 <fd2num>
  801080:	89 c2                	mov    %eax,%edx
  801082:	83 c4 10             	add    $0x10,%esp
}
  801085:	89 d0                	mov    %edx,%eax
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801091:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801097:	e8 8c f0 ff ff       	call   800128 <sys_getenvid>
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	ff 75 0c             	pushl  0xc(%ebp)
  8010a2:	ff 75 08             	pushl  0x8(%ebp)
  8010a5:	56                   	push   %esi
  8010a6:	50                   	push   %eax
  8010a7:	68 70 20 80 00       	push   $0x802070
  8010ac:	e8 b1 00 00 00       	call   801162 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b1:	83 c4 18             	add    $0x18,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	ff 75 10             	pushl  0x10(%ebp)
  8010b8:	e8 54 00 00 00       	call   801111 <vcprintf>
	cprintf("\n");
  8010bd:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010c4:	e8 99 00 00 00       	call   801162 <cprintf>
  8010c9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010cc:	cc                   	int3   
  8010cd:	eb fd                	jmp    8010cc <_panic+0x43>

008010cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d9:	8b 13                	mov    (%ebx),%edx
  8010db:	8d 42 01             	lea    0x1(%edx),%eax
  8010de:	89 03                	mov    %eax,(%ebx)
  8010e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ec:	75 1a                	jne    801108 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	68 ff 00 00 00       	push   $0xff
  8010f6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f9:	50                   	push   %eax
  8010fa:	e8 ab ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801105:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801108:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80110c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801121:	00 00 00 
	b.cnt = 0;
  801124:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112e:	ff 75 0c             	pushl  0xc(%ebp)
  801131:	ff 75 08             	pushl  0x8(%ebp)
  801134:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	68 cf 10 80 00       	push   $0x8010cf
  801140:	e8 54 01 00 00       	call   801299 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801145:	83 c4 08             	add    $0x8,%esp
  801148:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	e8 50 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80115a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801168:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116b:	50                   	push   %eax
  80116c:	ff 75 08             	pushl  0x8(%ebp)
  80116f:	e8 9d ff ff ff       	call   801111 <vcprintf>
	va_end(ap);

	return cnt;
}
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 1c             	sub    $0x1c,%esp
  80117f:	89 c7                	mov    %eax,%edi
  801181:	89 d6                	mov    %edx,%esi
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
  801186:	8b 55 0c             	mov    0xc(%ebp),%edx
  801189:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80118c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
  801197:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80119d:	39 d3                	cmp    %edx,%ebx
  80119f:	72 05                	jb     8011a6 <printnum+0x30>
  8011a1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a4:	77 45                	ja     8011eb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	ff 75 18             	pushl  0x18(%ebp)
  8011ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8011af:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b2:	53                   	push   %ebx
  8011b3:	ff 75 10             	pushl  0x10(%ebp)
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c5:	e8 c6 0a 00 00       	call   801c90 <__udivdi3>
  8011ca:	83 c4 18             	add    $0x18,%esp
  8011cd:	52                   	push   %edx
  8011ce:	50                   	push   %eax
  8011cf:	89 f2                	mov    %esi,%edx
  8011d1:	89 f8                	mov    %edi,%eax
  8011d3:	e8 9e ff ff ff       	call   801176 <printnum>
  8011d8:	83 c4 20             	add    $0x20,%esp
  8011db:	eb 18                	jmp    8011f5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	ff 75 18             	pushl  0x18(%ebp)
  8011e4:	ff d7                	call   *%edi
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	eb 03                	jmp    8011ee <printnum+0x78>
  8011eb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ee:	83 eb 01             	sub    $0x1,%ebx
  8011f1:	85 db                	test   %ebx,%ebx
  8011f3:	7f e8                	jg     8011dd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	56                   	push   %esi
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801202:	ff 75 dc             	pushl  -0x24(%ebp)
  801205:	ff 75 d8             	pushl  -0x28(%ebp)
  801208:	e8 b3 0b 00 00       	call   801dc0 <__umoddi3>
  80120d:	83 c4 14             	add    $0x14,%esp
  801210:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  801217:	50                   	push   %eax
  801218:	ff d7                	call   *%edi
}
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801228:	83 fa 01             	cmp    $0x1,%edx
  80122b:	7e 0e                	jle    80123b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122d:	8b 10                	mov    (%eax),%edx
  80122f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801232:	89 08                	mov    %ecx,(%eax)
  801234:	8b 02                	mov    (%edx),%eax
  801236:	8b 52 04             	mov    0x4(%edx),%edx
  801239:	eb 22                	jmp    80125d <getuint+0x38>
	else if (lflag)
  80123b:	85 d2                	test   %edx,%edx
  80123d:	74 10                	je     80124f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123f:	8b 10                	mov    (%eax),%edx
  801241:	8d 4a 04             	lea    0x4(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 02                	mov    (%edx),%eax
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
  80124d:	eb 0e                	jmp    80125d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124f:	8b 10                	mov    (%eax),%edx
  801251:	8d 4a 04             	lea    0x4(%edx),%ecx
  801254:	89 08                	mov    %ecx,(%eax)
  801256:	8b 02                	mov    (%edx),%eax
  801258:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801265:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801269:	8b 10                	mov    (%eax),%edx
  80126b:	3b 50 04             	cmp    0x4(%eax),%edx
  80126e:	73 0a                	jae    80127a <sprintputch+0x1b>
		*b->buf++ = ch;
  801270:	8d 4a 01             	lea    0x1(%edx),%ecx
  801273:	89 08                	mov    %ecx,(%eax)
  801275:	8b 45 08             	mov    0x8(%ebp),%eax
  801278:	88 02                	mov    %al,(%edx)
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801282:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801285:	50                   	push   %eax
  801286:	ff 75 10             	pushl  0x10(%ebp)
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 05 00 00 00       	call   801299 <vprintfmt>
	va_end(ap);
}
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 2c             	sub    $0x2c,%esp
  8012a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012ab:	eb 12                	jmp    8012bf <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	0f 84 38 04 00 00    	je     8016ed <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	50                   	push   %eax
  8012ba:	ff d6                	call   *%esi
  8012bc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012bf:	83 c7 01             	add    $0x1,%edi
  8012c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c6:	83 f8 25             	cmp    $0x25,%eax
  8012c9:	75 e2                	jne    8012ad <vprintfmt+0x14>
  8012cb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012cf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e9:	eb 07                	jmp    8012f2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ee:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f2:	8d 47 01             	lea    0x1(%edi),%eax
  8012f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f8:	0f b6 07             	movzbl (%edi),%eax
  8012fb:	0f b6 c8             	movzbl %al,%ecx
  8012fe:	83 e8 23             	sub    $0x23,%eax
  801301:	3c 55                	cmp    $0x55,%al
  801303:	0f 87 c9 03 00 00    	ja     8016d2 <vprintfmt+0x439>
  801309:	0f b6 c0             	movzbl %al,%eax
  80130c:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801316:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131a:	eb d6                	jmp    8012f2 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80131c:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801323:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801329:	eb 94                	jmp    8012bf <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80132b:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801332:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801338:	eb 85                	jmp    8012bf <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80133a:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  801341:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801347:	e9 73 ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80134c:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801353:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801359:	e9 61 ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80135e:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801365:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80136b:	e9 4f ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  801370:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801377:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80137d:	e9 3d ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801382:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801389:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80138f:	e9 2b ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801394:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  80139b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8013a1:	e9 19 ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8013a6:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013ad:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013b3:	e9 07 ff ff ff       	jmp    8012bf <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013b8:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013bf:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013c5:	e9 f5 fe ff ff       	jmp    8012bf <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013d8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013dc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013df:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013e2:	83 fa 09             	cmp    $0x9,%edx
  8013e5:	77 3f                	ja     801426 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013e7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013ea:	eb e9                	jmp    8013d5 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ef:	8d 48 04             	lea    0x4(%eax),%ecx
  8013f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013f5:	8b 00                	mov    (%eax),%eax
  8013f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013fd:	eb 2d                	jmp    80142c <vprintfmt+0x193>
  8013ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801402:	85 c0                	test   %eax,%eax
  801404:	b9 00 00 00 00       	mov    $0x0,%ecx
  801409:	0f 49 c8             	cmovns %eax,%ecx
  80140c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80140f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801412:	e9 db fe ff ff       	jmp    8012f2 <vprintfmt+0x59>
  801417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80141a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801421:	e9 cc fe ff ff       	jmp    8012f2 <vprintfmt+0x59>
  801426:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801429:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80142c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801430:	0f 89 bc fe ff ff    	jns    8012f2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801436:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801439:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80143c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801443:	e9 aa fe ff ff       	jmp    8012f2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801448:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80144b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80144e:	e9 9f fe ff ff       	jmp    8012f2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801453:	8b 45 14             	mov    0x14(%ebp),%eax
  801456:	8d 50 04             	lea    0x4(%eax),%edx
  801459:	89 55 14             	mov    %edx,0x14(%ebp)
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	53                   	push   %ebx
  801460:	ff 30                	pushl  (%eax)
  801462:	ff d6                	call   *%esi
			break;
  801464:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80146a:	e9 50 fe ff ff       	jmp    8012bf <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80146f:	8b 45 14             	mov    0x14(%ebp),%eax
  801472:	8d 50 04             	lea    0x4(%eax),%edx
  801475:	89 55 14             	mov    %edx,0x14(%ebp)
  801478:	8b 00                	mov    (%eax),%eax
  80147a:	99                   	cltd   
  80147b:	31 d0                	xor    %edx,%eax
  80147d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80147f:	83 f8 0f             	cmp    $0xf,%eax
  801482:	7f 0b                	jg     80148f <vprintfmt+0x1f6>
  801484:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	75 18                	jne    8014a7 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80148f:	50                   	push   %eax
  801490:	68 ab 20 80 00       	push   $0x8020ab
  801495:	53                   	push   %ebx
  801496:	56                   	push   %esi
  801497:	e8 e0 fd ff ff       	call   80127c <printfmt>
  80149c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014a2:	e9 18 fe ff ff       	jmp    8012bf <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8014a7:	52                   	push   %edx
  8014a8:	68 fd 1f 80 00       	push   $0x801ffd
  8014ad:	53                   	push   %ebx
  8014ae:	56                   	push   %esi
  8014af:	e8 c8 fd ff ff       	call   80127c <printfmt>
  8014b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ba:	e9 00 fe ff ff       	jmp    8012bf <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c2:	8d 50 04             	lea    0x4(%eax),%edx
  8014c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014ca:	85 ff                	test   %edi,%edi
  8014cc:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014d1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014d8:	0f 8e 94 00 00 00    	jle    801572 <vprintfmt+0x2d9>
  8014de:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014e2:	0f 84 98 00 00 00    	je     801580 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	ff 75 d0             	pushl  -0x30(%ebp)
  8014ee:	57                   	push   %edi
  8014ef:	e8 81 02 00 00       	call   801775 <strnlen>
  8014f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014f7:	29 c1                	sub    %eax,%ecx
  8014f9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014fc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801503:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801506:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801509:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80150b:	eb 0f                	jmp    80151c <vprintfmt+0x283>
					putch(padc, putdat);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	53                   	push   %ebx
  801511:	ff 75 e0             	pushl  -0x20(%ebp)
  801514:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801516:	83 ef 01             	sub    $0x1,%edi
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 ff                	test   %edi,%edi
  80151e:	7f ed                	jg     80150d <vprintfmt+0x274>
  801520:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801523:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801526:	85 c9                	test   %ecx,%ecx
  801528:	b8 00 00 00 00       	mov    $0x0,%eax
  80152d:	0f 49 c1             	cmovns %ecx,%eax
  801530:	29 c1                	sub    %eax,%ecx
  801532:	89 75 08             	mov    %esi,0x8(%ebp)
  801535:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801538:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80153b:	89 cb                	mov    %ecx,%ebx
  80153d:	eb 4d                	jmp    80158c <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80153f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801543:	74 1b                	je     801560 <vprintfmt+0x2c7>
  801545:	0f be c0             	movsbl %al,%eax
  801548:	83 e8 20             	sub    $0x20,%eax
  80154b:	83 f8 5e             	cmp    $0x5e,%eax
  80154e:	76 10                	jbe    801560 <vprintfmt+0x2c7>
					putch('?', putdat);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	ff 75 0c             	pushl  0xc(%ebp)
  801556:	6a 3f                	push   $0x3f
  801558:	ff 55 08             	call   *0x8(%ebp)
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 0d                	jmp    80156d <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	52                   	push   %edx
  801567:	ff 55 08             	call   *0x8(%ebp)
  80156a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80156d:	83 eb 01             	sub    $0x1,%ebx
  801570:	eb 1a                	jmp    80158c <vprintfmt+0x2f3>
  801572:	89 75 08             	mov    %esi,0x8(%ebp)
  801575:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801578:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80157b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80157e:	eb 0c                	jmp    80158c <vprintfmt+0x2f3>
  801580:	89 75 08             	mov    %esi,0x8(%ebp)
  801583:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801586:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801589:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80158c:	83 c7 01             	add    $0x1,%edi
  80158f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801593:	0f be d0             	movsbl %al,%edx
  801596:	85 d2                	test   %edx,%edx
  801598:	74 23                	je     8015bd <vprintfmt+0x324>
  80159a:	85 f6                	test   %esi,%esi
  80159c:	78 a1                	js     80153f <vprintfmt+0x2a6>
  80159e:	83 ee 01             	sub    $0x1,%esi
  8015a1:	79 9c                	jns    80153f <vprintfmt+0x2a6>
  8015a3:	89 df                	mov    %ebx,%edi
  8015a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ab:	eb 18                	jmp    8015c5 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	53                   	push   %ebx
  8015b1:	6a 20                	push   $0x20
  8015b3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015b5:	83 ef 01             	sub    $0x1,%edi
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	eb 08                	jmp    8015c5 <vprintfmt+0x32c>
  8015bd:	89 df                	mov    %ebx,%edi
  8015bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015c5:	85 ff                	test   %edi,%edi
  8015c7:	7f e4                	jg     8015ad <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015cc:	e9 ee fc ff ff       	jmp    8012bf <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d1:	83 fa 01             	cmp    $0x1,%edx
  8015d4:	7e 16                	jle    8015ec <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d9:	8d 50 08             	lea    0x8(%eax),%edx
  8015dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8015df:	8b 50 04             	mov    0x4(%eax),%edx
  8015e2:	8b 00                	mov    (%eax),%eax
  8015e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015ea:	eb 32                	jmp    80161e <vprintfmt+0x385>
	else if (lflag)
  8015ec:	85 d2                	test   %edx,%edx
  8015ee:	74 18                	je     801608 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f3:	8d 50 04             	lea    0x4(%eax),%edx
  8015f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8015f9:	8b 00                	mov    (%eax),%eax
  8015fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015fe:	89 c1                	mov    %eax,%ecx
  801600:	c1 f9 1f             	sar    $0x1f,%ecx
  801603:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801606:	eb 16                	jmp    80161e <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  801608:	8b 45 14             	mov    0x14(%ebp),%eax
  80160b:	8d 50 04             	lea    0x4(%eax),%edx
  80160e:	89 55 14             	mov    %edx,0x14(%ebp)
  801611:	8b 00                	mov    (%eax),%eax
  801613:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801616:	89 c1                	mov    %eax,%ecx
  801618:	c1 f9 1f             	sar    $0x1f,%ecx
  80161b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80161e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801621:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801624:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80162d:	79 6f                	jns    80169e <vprintfmt+0x405>
				putch('-', putdat);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	53                   	push   %ebx
  801633:	6a 2d                	push   $0x2d
  801635:	ff d6                	call   *%esi
				num = -(long long) num;
  801637:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80163a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80163d:	f7 d8                	neg    %eax
  80163f:	83 d2 00             	adc    $0x0,%edx
  801642:	f7 da                	neg    %edx
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	eb 55                	jmp    80169e <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801649:	8d 45 14             	lea    0x14(%ebp),%eax
  80164c:	e8 d4 fb ff ff       	call   801225 <getuint>
			base = 10;
  801651:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801656:	eb 46                	jmp    80169e <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801658:	8d 45 14             	lea    0x14(%ebp),%eax
  80165b:	e8 c5 fb ff ff       	call   801225 <getuint>
			base = 8;
  801660:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801665:	eb 37                	jmp    80169e <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	53                   	push   %ebx
  80166b:	6a 30                	push   $0x30
  80166d:	ff d6                	call   *%esi
			putch('x', putdat);
  80166f:	83 c4 08             	add    $0x8,%esp
  801672:	53                   	push   %ebx
  801673:	6a 78                	push   $0x78
  801675:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801677:	8b 45 14             	mov    0x14(%ebp),%eax
  80167a:	8d 50 04             	lea    0x4(%eax),%edx
  80167d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801680:	8b 00                	mov    (%eax),%eax
  801682:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801687:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80168a:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80168f:	eb 0d                	jmp    80169e <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801691:	8d 45 14             	lea    0x14(%ebp),%eax
  801694:	e8 8c fb ff ff       	call   801225 <getuint>
			base = 16;
  801699:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8016a5:	51                   	push   %ecx
  8016a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a9:	57                   	push   %edi
  8016aa:	52                   	push   %edx
  8016ab:	50                   	push   %eax
  8016ac:	89 da                	mov    %ebx,%edx
  8016ae:	89 f0                	mov    %esi,%eax
  8016b0:	e8 c1 fa ff ff       	call   801176 <printnum>
			break;
  8016b5:	83 c4 20             	add    $0x20,%esp
  8016b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016bb:	e9 ff fb ff ff       	jmp    8012bf <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	53                   	push   %ebx
  8016c4:	51                   	push   %ecx
  8016c5:	ff d6                	call   *%esi
			break;
  8016c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016cd:	e9 ed fb ff ff       	jmp    8012bf <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	53                   	push   %ebx
  8016d6:	6a 25                	push   $0x25
  8016d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb 03                	jmp    8016e2 <vprintfmt+0x449>
  8016df:	83 ef 01             	sub    $0x1,%edi
  8016e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016e6:	75 f7                	jne    8016df <vprintfmt+0x446>
  8016e8:	e9 d2 fb ff ff       	jmp    8012bf <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 18             	sub    $0x18,%esp
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80170b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801712:	85 c0                	test   %eax,%eax
  801714:	74 26                	je     80173c <vsnprintf+0x47>
  801716:	85 d2                	test   %edx,%edx
  801718:	7e 22                	jle    80173c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80171a:	ff 75 14             	pushl  0x14(%ebp)
  80171d:	ff 75 10             	pushl  0x10(%ebp)
  801720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801723:	50                   	push   %eax
  801724:	68 5f 12 80 00       	push   $0x80125f
  801729:	e8 6b fb ff ff       	call   801299 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80172e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 05                	jmp    801741 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80173c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80174c:	50                   	push   %eax
  80174d:	ff 75 10             	pushl  0x10(%ebp)
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	ff 75 08             	pushl  0x8(%ebp)
  801756:	e8 9a ff ff ff       	call   8016f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
  801768:	eb 03                	jmp    80176d <strlen+0x10>
		n++;
  80176a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80176d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801771:	75 f7                	jne    80176a <strlen+0xd>
		n++;
	return n;
}
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80177e:	ba 00 00 00 00       	mov    $0x0,%edx
  801783:	eb 03                	jmp    801788 <strnlen+0x13>
		n++;
  801785:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801788:	39 c2                	cmp    %eax,%edx
  80178a:	74 08                	je     801794 <strnlen+0x1f>
  80178c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801790:	75 f3                	jne    801785 <strnlen+0x10>
  801792:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017a0:	89 c2                	mov    %eax,%edx
  8017a2:	83 c2 01             	add    $0x1,%edx
  8017a5:	83 c1 01             	add    $0x1,%ecx
  8017a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017af:	84 db                	test   %bl,%bl
  8017b1:	75 ef                	jne    8017a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017b3:	5b                   	pop    %ebx
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017bd:	53                   	push   %ebx
  8017be:	e8 9a ff ff ff       	call   80175d <strlen>
  8017c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017c6:	ff 75 0c             	pushl  0xc(%ebp)
  8017c9:	01 d8                	add    %ebx,%eax
  8017cb:	50                   	push   %eax
  8017cc:	e8 c5 ff ff ff       	call   801796 <strcpy>
	return dst;
}
  8017d1:	89 d8                	mov    %ebx,%eax
  8017d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8017e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e3:	89 f3                	mov    %esi,%ebx
  8017e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017e8:	89 f2                	mov    %esi,%edx
  8017ea:	eb 0f                	jmp    8017fb <strncpy+0x23>
		*dst++ = *src;
  8017ec:	83 c2 01             	add    $0x1,%edx
  8017ef:	0f b6 01             	movzbl (%ecx),%eax
  8017f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8017f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017fb:	39 da                	cmp    %ebx,%edx
  8017fd:	75 ed                	jne    8017ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017ff:	89 f0                	mov    %esi,%eax
  801801:	5b                   	pop    %ebx
  801802:	5e                   	pop    %esi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	56                   	push   %esi
  801809:	53                   	push   %ebx
  80180a:	8b 75 08             	mov    0x8(%ebp),%esi
  80180d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801810:	8b 55 10             	mov    0x10(%ebp),%edx
  801813:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801815:	85 d2                	test   %edx,%edx
  801817:	74 21                	je     80183a <strlcpy+0x35>
  801819:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80181d:	89 f2                	mov    %esi,%edx
  80181f:	eb 09                	jmp    80182a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801821:	83 c2 01             	add    $0x1,%edx
  801824:	83 c1 01             	add    $0x1,%ecx
  801827:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80182a:	39 c2                	cmp    %eax,%edx
  80182c:	74 09                	je     801837 <strlcpy+0x32>
  80182e:	0f b6 19             	movzbl (%ecx),%ebx
  801831:	84 db                	test   %bl,%bl
  801833:	75 ec                	jne    801821 <strlcpy+0x1c>
  801835:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801837:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80183a:	29 f0                	sub    %esi,%eax
}
  80183c:	5b                   	pop    %ebx
  80183d:	5e                   	pop    %esi
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801849:	eb 06                	jmp    801851 <strcmp+0x11>
		p++, q++;
  80184b:	83 c1 01             	add    $0x1,%ecx
  80184e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801851:	0f b6 01             	movzbl (%ecx),%eax
  801854:	84 c0                	test   %al,%al
  801856:	74 04                	je     80185c <strcmp+0x1c>
  801858:	3a 02                	cmp    (%edx),%al
  80185a:	74 ef                	je     80184b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80185c:	0f b6 c0             	movzbl %al,%eax
  80185f:	0f b6 12             	movzbl (%edx),%edx
  801862:	29 d0                	sub    %edx,%eax
}
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	53                   	push   %ebx
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801870:	89 c3                	mov    %eax,%ebx
  801872:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801875:	eb 06                	jmp    80187d <strncmp+0x17>
		n--, p++, q++;
  801877:	83 c0 01             	add    $0x1,%eax
  80187a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80187d:	39 d8                	cmp    %ebx,%eax
  80187f:	74 15                	je     801896 <strncmp+0x30>
  801881:	0f b6 08             	movzbl (%eax),%ecx
  801884:	84 c9                	test   %cl,%cl
  801886:	74 04                	je     80188c <strncmp+0x26>
  801888:	3a 0a                	cmp    (%edx),%cl
  80188a:	74 eb                	je     801877 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80188c:	0f b6 00             	movzbl (%eax),%eax
  80188f:	0f b6 12             	movzbl (%edx),%edx
  801892:	29 d0                	sub    %edx,%eax
  801894:	eb 05                	jmp    80189b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801896:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80189b:	5b                   	pop    %ebx
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018a8:	eb 07                	jmp    8018b1 <strchr+0x13>
		if (*s == c)
  8018aa:	38 ca                	cmp    %cl,%dl
  8018ac:	74 0f                	je     8018bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018ae:	83 c0 01             	add    $0x1,%eax
  8018b1:	0f b6 10             	movzbl (%eax),%edx
  8018b4:	84 d2                	test   %dl,%dl
  8018b6:	75 f2                	jne    8018aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018c9:	eb 03                	jmp    8018ce <strfind+0xf>
  8018cb:	83 c0 01             	add    $0x1,%eax
  8018ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018d1:	38 ca                	cmp    %cl,%dl
  8018d3:	74 04                	je     8018d9 <strfind+0x1a>
  8018d5:	84 d2                	test   %dl,%dl
  8018d7:	75 f2                	jne    8018cb <strfind+0xc>
			break;
	return (char *) s;
}
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	57                   	push   %edi
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018e7:	85 c9                	test   %ecx,%ecx
  8018e9:	74 36                	je     801921 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018f1:	75 28                	jne    80191b <memset+0x40>
  8018f3:	f6 c1 03             	test   $0x3,%cl
  8018f6:	75 23                	jne    80191b <memset+0x40>
		c &= 0xFF;
  8018f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018fc:	89 d3                	mov    %edx,%ebx
  8018fe:	c1 e3 08             	shl    $0x8,%ebx
  801901:	89 d6                	mov    %edx,%esi
  801903:	c1 e6 18             	shl    $0x18,%esi
  801906:	89 d0                	mov    %edx,%eax
  801908:	c1 e0 10             	shl    $0x10,%eax
  80190b:	09 f0                	or     %esi,%eax
  80190d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	09 d0                	or     %edx,%eax
  801913:	c1 e9 02             	shr    $0x2,%ecx
  801916:	fc                   	cld    
  801917:	f3 ab                	rep stos %eax,%es:(%edi)
  801919:	eb 06                	jmp    801921 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80191b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191e:	fc                   	cld    
  80191f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801921:	89 f8                	mov    %edi,%eax
  801923:	5b                   	pop    %ebx
  801924:	5e                   	pop    %esi
  801925:	5f                   	pop    %edi
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	57                   	push   %edi
  80192c:	56                   	push   %esi
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	8b 75 0c             	mov    0xc(%ebp),%esi
  801933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801936:	39 c6                	cmp    %eax,%esi
  801938:	73 35                	jae    80196f <memmove+0x47>
  80193a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80193d:	39 d0                	cmp    %edx,%eax
  80193f:	73 2e                	jae    80196f <memmove+0x47>
		s += n;
		d += n;
  801941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801944:	89 d6                	mov    %edx,%esi
  801946:	09 fe                	or     %edi,%esi
  801948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80194e:	75 13                	jne    801963 <memmove+0x3b>
  801950:	f6 c1 03             	test   $0x3,%cl
  801953:	75 0e                	jne    801963 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801955:	83 ef 04             	sub    $0x4,%edi
  801958:	8d 72 fc             	lea    -0x4(%edx),%esi
  80195b:	c1 e9 02             	shr    $0x2,%ecx
  80195e:	fd                   	std    
  80195f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801961:	eb 09                	jmp    80196c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801963:	83 ef 01             	sub    $0x1,%edi
  801966:	8d 72 ff             	lea    -0x1(%edx),%esi
  801969:	fd                   	std    
  80196a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80196c:	fc                   	cld    
  80196d:	eb 1d                	jmp    80198c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80196f:	89 f2                	mov    %esi,%edx
  801971:	09 c2                	or     %eax,%edx
  801973:	f6 c2 03             	test   $0x3,%dl
  801976:	75 0f                	jne    801987 <memmove+0x5f>
  801978:	f6 c1 03             	test   $0x3,%cl
  80197b:	75 0a                	jne    801987 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80197d:	c1 e9 02             	shr    $0x2,%ecx
  801980:	89 c7                	mov    %eax,%edi
  801982:	fc                   	cld    
  801983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801985:	eb 05                	jmp    80198c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801987:	89 c7                	mov    %eax,%edi
  801989:	fc                   	cld    
  80198a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80198c:	5e                   	pop    %esi
  80198d:	5f                   	pop    %edi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801993:	ff 75 10             	pushl  0x10(%ebp)
  801996:	ff 75 0c             	pushl  0xc(%ebp)
  801999:	ff 75 08             	pushl  0x8(%ebp)
  80199c:	e8 87 ff ff ff       	call   801928 <memmove>
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ae:	89 c6                	mov    %eax,%esi
  8019b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019b3:	eb 1a                	jmp    8019cf <memcmp+0x2c>
		if (*s1 != *s2)
  8019b5:	0f b6 08             	movzbl (%eax),%ecx
  8019b8:	0f b6 1a             	movzbl (%edx),%ebx
  8019bb:	38 d9                	cmp    %bl,%cl
  8019bd:	74 0a                	je     8019c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019bf:	0f b6 c1             	movzbl %cl,%eax
  8019c2:	0f b6 db             	movzbl %bl,%ebx
  8019c5:	29 d8                	sub    %ebx,%eax
  8019c7:	eb 0f                	jmp    8019d8 <memcmp+0x35>
		s1++, s2++;
  8019c9:	83 c0 01             	add    $0x1,%eax
  8019cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019cf:	39 f0                	cmp    %esi,%eax
  8019d1:	75 e2                	jne    8019b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d8:	5b                   	pop    %ebx
  8019d9:	5e                   	pop    %esi
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	53                   	push   %ebx
  8019e0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019e3:	89 c1                	mov    %eax,%ecx
  8019e5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019ec:	eb 0a                	jmp    8019f8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019ee:	0f b6 10             	movzbl (%eax),%edx
  8019f1:	39 da                	cmp    %ebx,%edx
  8019f3:	74 07                	je     8019fc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019f5:	83 c0 01             	add    $0x1,%eax
  8019f8:	39 c8                	cmp    %ecx,%eax
  8019fa:	72 f2                	jb     8019ee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019fc:	5b                   	pop    %ebx
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	57                   	push   %edi
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a0b:	eb 03                	jmp    801a10 <strtol+0x11>
		s++;
  801a0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a10:	0f b6 01             	movzbl (%ecx),%eax
  801a13:	3c 20                	cmp    $0x20,%al
  801a15:	74 f6                	je     801a0d <strtol+0xe>
  801a17:	3c 09                	cmp    $0x9,%al
  801a19:	74 f2                	je     801a0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a1b:	3c 2b                	cmp    $0x2b,%al
  801a1d:	75 0a                	jne    801a29 <strtol+0x2a>
		s++;
  801a1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a22:	bf 00 00 00 00       	mov    $0x0,%edi
  801a27:	eb 11                	jmp    801a3a <strtol+0x3b>
  801a29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a2e:	3c 2d                	cmp    $0x2d,%al
  801a30:	75 08                	jne    801a3a <strtol+0x3b>
		s++, neg = 1;
  801a32:	83 c1 01             	add    $0x1,%ecx
  801a35:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a40:	75 15                	jne    801a57 <strtol+0x58>
  801a42:	80 39 30             	cmpb   $0x30,(%ecx)
  801a45:	75 10                	jne    801a57 <strtol+0x58>
  801a47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a4b:	75 7c                	jne    801ac9 <strtol+0xca>
		s += 2, base = 16;
  801a4d:	83 c1 02             	add    $0x2,%ecx
  801a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a55:	eb 16                	jmp    801a6d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a57:	85 db                	test   %ebx,%ebx
  801a59:	75 12                	jne    801a6d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a60:	80 39 30             	cmpb   $0x30,(%ecx)
  801a63:	75 08                	jne    801a6d <strtol+0x6e>
		s++, base = 8;
  801a65:	83 c1 01             	add    $0x1,%ecx
  801a68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a75:	0f b6 11             	movzbl (%ecx),%edx
  801a78:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a7b:	89 f3                	mov    %esi,%ebx
  801a7d:	80 fb 09             	cmp    $0x9,%bl
  801a80:	77 08                	ja     801a8a <strtol+0x8b>
			dig = *s - '0';
  801a82:	0f be d2             	movsbl %dl,%edx
  801a85:	83 ea 30             	sub    $0x30,%edx
  801a88:	eb 22                	jmp    801aac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a8d:	89 f3                	mov    %esi,%ebx
  801a8f:	80 fb 19             	cmp    $0x19,%bl
  801a92:	77 08                	ja     801a9c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a94:	0f be d2             	movsbl %dl,%edx
  801a97:	83 ea 57             	sub    $0x57,%edx
  801a9a:	eb 10                	jmp    801aac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a9f:	89 f3                	mov    %esi,%ebx
  801aa1:	80 fb 19             	cmp    $0x19,%bl
  801aa4:	77 16                	ja     801abc <strtol+0xbd>
			dig = *s - 'A' + 10;
  801aa6:	0f be d2             	movsbl %dl,%edx
  801aa9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  801aaf:	7d 0b                	jge    801abc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ab1:	83 c1 01             	add    $0x1,%ecx
  801ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ab8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801aba:	eb b9                	jmp    801a75 <strtol+0x76>

	if (endptr)
  801abc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ac0:	74 0d                	je     801acf <strtol+0xd0>
		*endptr = (char *) s;
  801ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac5:	89 0e                	mov    %ecx,(%esi)
  801ac7:	eb 06                	jmp    801acf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ac9:	85 db                	test   %ebx,%ebx
  801acb:	74 98                	je     801a65 <strtol+0x66>
  801acd:	eb 9e                	jmp    801a6d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801acf:	89 c2                	mov    %eax,%edx
  801ad1:	f7 da                	neg    %edx
  801ad3:	85 ff                	test   %edi,%edi
  801ad5:	0f 45 c2             	cmovne %edx,%eax
}
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801ae9:	57                   	push   %edi
  801aea:	e8 6e fc ff ff       	call   80175d <strlen>
  801aef:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801af2:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801af5:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801aff:	eb 46                	jmp    801b47 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801b01:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801b05:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b08:	80 f9 09             	cmp    $0x9,%cl
  801b0b:	77 08                	ja     801b15 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b0d:	0f be d2             	movsbl %dl,%edx
  801b10:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b13:	eb 27                	jmp    801b3c <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b15:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b18:	80 f9 05             	cmp    $0x5,%cl
  801b1b:	77 08                	ja     801b25 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b1d:	0f be d2             	movsbl %dl,%edx
  801b20:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b23:	eb 17                	jmp    801b3c <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b25:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b28:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b2b:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b30:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b34:	77 06                	ja     801b3c <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b36:	0f be d2             	movsbl %dl,%edx
  801b39:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b3c:	0f af ce             	imul   %esi,%ecx
  801b3f:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b41:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b44:	83 eb 01             	sub    $0x1,%ebx
  801b47:	83 fb 01             	cmp    $0x1,%ebx
  801b4a:	7f b5                	jg     801b01 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5f                   	pop    %edi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b62:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b64:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b69:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b6c:	83 ec 0c             	sub    $0xc,%esp
  801b6f:	50                   	push   %eax
  801b70:	e8 a1 e7 ff ff       	call   800316 <sys_ipc_recv>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	79 16                	jns    801b92 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b7c:	85 f6                	test   %esi,%esi
  801b7e:	74 06                	je     801b86 <ipc_recv+0x32>
			*from_env_store = 0;
  801b80:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b86:	85 db                	test   %ebx,%ebx
  801b88:	74 2c                	je     801bb6 <ipc_recv+0x62>
			*perm_store = 0;
  801b8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b90:	eb 24                	jmp    801bb6 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b92:	85 f6                	test   %esi,%esi
  801b94:	74 0a                	je     801ba0 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b96:	a1 08 40 80 00       	mov    0x804008,%eax
  801b9b:	8b 40 74             	mov    0x74(%eax),%eax
  801b9e:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801ba0:	85 db                	test   %ebx,%ebx
  801ba2:	74 0a                	je     801bae <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801ba4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba9:	8b 40 78             	mov    0x78(%eax),%eax
  801bac:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bae:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bcf:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bd1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bd6:	0f 44 d8             	cmove  %eax,%ebx
  801bd9:	eb 1e                	jmp    801bf9 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bdb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bde:	74 14                	je     801bf4 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	68 a0 23 80 00       	push   $0x8023a0
  801be8:	6a 44                	push   $0x44
  801bea:	68 cc 23 80 00       	push   $0x8023cc
  801bef:	e8 95 f4 ff ff       	call   801089 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801bf4:	e8 4e e5 ff ff       	call   800147 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bf9:	ff 75 14             	pushl  0x14(%ebp)
  801bfc:	53                   	push   %ebx
  801bfd:	56                   	push   %esi
  801bfe:	57                   	push   %edi
  801bff:	e8 ef e6 ff ff       	call   8002f3 <sys_ipc_try_send>
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 d0                	js     801bdb <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c1e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c21:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c27:	8b 52 50             	mov    0x50(%edx),%edx
  801c2a:	39 ca                	cmp    %ecx,%edx
  801c2c:	75 0d                	jne    801c3b <ipc_find_env+0x28>
			return envs[i].env_id;
  801c2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c31:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c36:	8b 40 48             	mov    0x48(%eax),%eax
  801c39:	eb 0f                	jmp    801c4a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c3b:	83 c0 01             	add    $0x1,%eax
  801c3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c43:	75 d9                	jne    801c1e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c52:	89 d0                	mov    %edx,%eax
  801c54:	c1 e8 16             	shr    $0x16,%eax
  801c57:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c5e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c63:	f6 c1 01             	test   $0x1,%cl
  801c66:	74 1d                	je     801c85 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c68:	c1 ea 0c             	shr    $0xc,%edx
  801c6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c72:	f6 c2 01             	test   $0x1,%dl
  801c75:	74 0e                	je     801c85 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c77:	c1 ea 0c             	shr    $0xc,%edx
  801c7a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c81:	ef 
  801c82:	0f b7 c0             	movzwl %ax,%eax
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    
  801c87:	66 90                	xchg   %ax,%ax
  801c89:	66 90                	xchg   %ax,%ax
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
