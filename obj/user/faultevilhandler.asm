
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 4a 1f 80 00       	push   $0x801f4a
  80012f:	6a 23                	push   $0x23
  800131:	68 67 1f 80 00       	push   $0x801f67
  800136:	e8 69 0f 00 00       	call   8010a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 4a 1f 80 00       	push   $0x801f4a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 67 1f 80 00       	push   $0x801f67
  8001b7:	e8 e8 0e 00 00       	call   8010a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 4a 1f 80 00       	push   $0x801f4a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 67 1f 80 00       	push   $0x801f67
  8001f9:	e8 a6 0e 00 00       	call   8010a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 4a 1f 80 00       	push   $0x801f4a
  800234:	6a 23                	push   $0x23
  800236:	68 67 1f 80 00       	push   $0x801f67
  80023b:	e8 64 0e 00 00       	call   8010a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 4a 1f 80 00       	push   $0x801f4a
  800276:	6a 23                	push   $0x23
  800278:	68 67 1f 80 00       	push   $0x801f67
  80027d:	e8 22 0e 00 00       	call   8010a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 0a 00 00 00       	mov    $0xa,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 0a                	push   $0xa
  8002b3:	68 4a 1f 80 00       	push   $0x801f4a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 67 1f 80 00       	push   $0x801f67
  8002bf:	e8 e0 0d 00 00       	call   8010a4 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 09 00 00 00       	mov    $0x9,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 09                	push   $0x9
  8002f5:	68 4a 1f 80 00       	push   $0x801f4a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 67 1f 80 00       	push   $0x801f67
  800301:	e8 9e 0d 00 00       	call   8010a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 4a 1f 80 00       	push   $0x801f4a
  80035e:	6a 23                	push   $0x23
  800360:	68 67 1f 80 00       	push   $0x801f67
  800365:	e8 3a 0d 00 00       	call   8010a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba f4 1f 80 00       	mov    $0x801ff4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 08 40 80 00       	mov    0x804008,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 78 1f 80 00       	push   $0x801f78
  800479:	e8 ff 0c 00 00       	call   80117d <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2) 
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0); 
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close) 
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 08 40 80 00       	mov    0x804008,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 b9 1f 80 00       	push   $0x801fb9
  8006a3:	e8 d5 0a 00 00       	call   80117d <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 08 40 80 00       	mov    0x804008,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 d5 1f 80 00       	push   $0x801fd5
  800778:	e8 00 0a 00 00       	call   80117d <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 98 1f 80 00       	push   $0x801f98
  80082d:	e8 4b 09 00 00       	call   80117d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 2b 02 00 00       	call   800b21 <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 f1 12 00 00       	call   801c2e <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 80 12 00 00       	call   801bd8 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 0a 12 00 00       	call   801b6f <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 c3 0d 00 00       	call   8017b1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a20:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a25:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a33:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a39:	53                   	push   %ebx
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	68 08 50 80 00       	push   $0x805008
  800a42:	e8 fc 0e 00 00       	call   801943 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a51:	e8 cb fe ff ff       	call   800921 <fsipc>
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	78 3d                	js     800a9a <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a5d:	39 d8                	cmp    %ebx,%eax
  800a5f:	76 19                	jbe    800a7a <devfile_write+0x69>
  800a61:	68 04 20 80 00       	push   $0x802004
  800a66:	68 0b 20 80 00       	push   $0x80200b
  800a6b:	68 9f 00 00 00       	push   $0x9f
  800a70:	68 20 20 80 00       	push   $0x802020
  800a75:	e8 2a 06 00 00       	call   8010a4 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a7a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a7f:	76 19                	jbe    800a9a <devfile_write+0x89>
  800a81:	68 38 20 80 00       	push   $0x802038
  800a86:	68 0b 20 80 00       	push   $0x80200b
  800a8b:	68 a0 00 00 00       	push   $0xa0
  800a90:	68 20 20 80 00       	push   $0x802020
  800a95:	e8 0a 06 00 00       	call   8010a4 <_panic>

	return r;
}
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  800aad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ab2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac2:	e8 5a fe ff ff       	call   800921 <fsipc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	78 4b                	js     800b18 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800acd:	39 c6                	cmp    %eax,%esi
  800acf:	73 16                	jae    800ae7 <devfile_read+0x48>
  800ad1:	68 04 20 80 00       	push   $0x802004
  800ad6:	68 0b 20 80 00       	push   $0x80200b
  800adb:	6a 7e                	push   $0x7e
  800add:	68 20 20 80 00       	push   $0x802020
  800ae2:	e8 bd 05 00 00       	call   8010a4 <_panic>
	assert(r <= PGSIZE);
  800ae7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aec:	7e 16                	jle    800b04 <devfile_read+0x65>
  800aee:	68 2b 20 80 00       	push   $0x80202b
  800af3:	68 0b 20 80 00       	push   $0x80200b
  800af8:	6a 7f                	push   $0x7f
  800afa:	68 20 20 80 00       	push   $0x802020
  800aff:	e8 a0 05 00 00       	call   8010a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b04:	83 ec 04             	sub    $0x4,%esp
  800b07:	50                   	push   %eax
  800b08:	68 00 50 80 00       	push   $0x805000
  800b0d:	ff 75 0c             	pushl  0xc(%ebp)
  800b10:	e8 2e 0e 00 00       	call   801943 <memmove>
	return r;
  800b15:	83 c4 10             	add    $0x10,%esp
}
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 20             	sub    $0x20,%esp
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b2b:	53                   	push   %ebx
  800b2c:	e8 47 0c 00 00       	call   801778 <strlen>
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b39:	7f 67                	jg     800ba2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b41:	50                   	push   %eax
  800b42:	e8 52 f8 ff ff       	call   800399 <fd_alloc>
  800b47:	83 c4 10             	add    $0x10,%esp
		return r;
  800b4a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	78 57                	js     800ba7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	53                   	push   %ebx
  800b54:	68 00 50 80 00       	push   $0x805000
  800b59:	e8 53 0c 00 00       	call   8017b1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	e8 ae fd ff ff       	call   800921 <fsipc>
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	83 c4 10             	add    $0x10,%esp
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	79 14                	jns    800b90 <open+0x6f>
		fd_close(fd, 0);
  800b7c:	83 ec 08             	sub    $0x8,%esp
  800b7f:	6a 00                	push   $0x0
  800b81:	ff 75 f4             	pushl  -0xc(%ebp)
  800b84:	e8 08 f9 ff ff       	call   800491 <fd_close>
		return r;
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	89 da                	mov    %ebx,%edx
  800b8e:	eb 17                	jmp    800ba7 <open+0x86>
	}

	return fd2num(fd);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 f4             	pushl  -0xc(%ebp)
  800b96:	e8 d7 f7 ff ff       	call   800372 <fd2num>
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	83 c4 10             	add    $0x10,%esp
  800ba0:	eb 05                	jmp    800ba7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ba2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbe:	e8 5e fd ff ff       	call   800921 <fsipc>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	ff 75 08             	pushl  0x8(%ebp)
  800bd3:	e8 aa f7 ff ff       	call   800382 <fd2data>
  800bd8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bda:	83 c4 08             	add    $0x8,%esp
  800bdd:	68 65 20 80 00       	push   $0x802065
  800be2:	53                   	push   %ebx
  800be3:	e8 c9 0b 00 00       	call   8017b1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be8:	8b 46 04             	mov    0x4(%esi),%eax
  800beb:	2b 06                	sub    (%esi),%eax
  800bed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bf3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bfa:	00 00 00 
	stat->st_dev = &devpipe;
  800bfd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c04:	30 80 00 
	return 0;
}
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c1d:	53                   	push   %ebx
  800c1e:	6a 00                	push   $0x0
  800c20:	e8 e1 f5 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c25:	89 1c 24             	mov    %ebx,(%esp)
  800c28:	e8 55 f7 ff ff       	call   800382 <fd2data>
  800c2d:	83 c4 08             	add    $0x8,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 00                	push   $0x0
  800c33:	e8 ce f5 ff ff       	call   800206 <sys_page_unmap>
}
  800c38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 1c             	sub    $0x1c,%esp
  800c46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c49:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c4b:	a1 08 40 80 00       	mov    0x804008,%eax
  800c50:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	ff 75 e0             	pushl  -0x20(%ebp)
  800c59:	e8 09 10 00 00       	call   801c67 <pageref>
  800c5e:	89 c3                	mov    %eax,%ebx
  800c60:	89 3c 24             	mov    %edi,(%esp)
  800c63:	e8 ff 0f 00 00       	call   801c67 <pageref>
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	39 c3                	cmp    %eax,%ebx
  800c6d:	0f 94 c1             	sete   %cl
  800c70:	0f b6 c9             	movzbl %cl,%ecx
  800c73:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c76:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c7c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c7f:	39 ce                	cmp    %ecx,%esi
  800c81:	74 1b                	je     800c9e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c83:	39 c3                	cmp    %eax,%ebx
  800c85:	75 c4                	jne    800c4b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c87:	8b 42 58             	mov    0x58(%edx),%eax
  800c8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c8d:	50                   	push   %eax
  800c8e:	56                   	push   %esi
  800c8f:	68 6c 20 80 00       	push   $0x80206c
  800c94:	e8 e4 04 00 00       	call   80117d <cprintf>
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	eb ad                	jmp    800c4b <_pipeisclosed+0xe>
	}
}
  800c9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 28             	sub    $0x28,%esp
  800cb2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cb5:	56                   	push   %esi
  800cb6:	e8 c7 f6 ff ff       	call   800382 <fd2data>
  800cbb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbd:	83 c4 10             	add    $0x10,%esp
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc5:	eb 4b                	jmp    800d12 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cc7:	89 da                	mov    %ebx,%edx
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	e8 6d ff ff ff       	call   800c3d <_pipeisclosed>
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	75 48                	jne    800d1c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cd4:	e8 89 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cd9:	8b 43 04             	mov    0x4(%ebx),%eax
  800cdc:	8b 0b                	mov    (%ebx),%ecx
  800cde:	8d 51 20             	lea    0x20(%ecx),%edx
  800ce1:	39 d0                	cmp    %edx,%eax
  800ce3:	73 e2                	jae    800cc7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cec:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cef:	89 c2                	mov    %eax,%edx
  800cf1:	c1 fa 1f             	sar    $0x1f,%edx
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	c1 e9 1b             	shr    $0x1b,%ecx
  800cf9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cfc:	83 e2 1f             	and    $0x1f,%edx
  800cff:	29 ca                	sub    %ecx,%edx
  800d01:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d09:	83 c0 01             	add    $0x1,%eax
  800d0c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0f:	83 c7 01             	add    $0x1,%edi
  800d12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d15:	75 c2                	jne    800cd9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d17:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1a:	eb 05                	jmp    800d21 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 18             	sub    $0x18,%esp
  800d32:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d35:	57                   	push   %edi
  800d36:	e8 47 f6 ff ff       	call   800382 <fd2data>
  800d3b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d45:	eb 3d                	jmp    800d84 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	74 04                	je     800d4f <devpipe_read+0x26>
				return i;
  800d4b:	89 d8                	mov    %ebx,%eax
  800d4d:	eb 44                	jmp    800d93 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d4f:	89 f2                	mov    %esi,%edx
  800d51:	89 f8                	mov    %edi,%eax
  800d53:	e8 e5 fe ff ff       	call   800c3d <_pipeisclosed>
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	75 32                	jne    800d8e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d5c:	e8 01 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d61:	8b 06                	mov    (%esi),%eax
  800d63:	3b 46 04             	cmp    0x4(%esi),%eax
  800d66:	74 df                	je     800d47 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d68:	99                   	cltd   
  800d69:	c1 ea 1b             	shr    $0x1b,%edx
  800d6c:	01 d0                	add    %edx,%eax
  800d6e:	83 e0 1f             	and    $0x1f,%eax
  800d71:	29 d0                	sub    %edx,%eax
  800d73:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d7e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d81:	83 c3 01             	add    $0x1,%ebx
  800d84:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d87:	75 d8                	jne    800d61 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d89:	8b 45 10             	mov    0x10(%ebp),%eax
  800d8c:	eb 05                	jmp    800d93 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800da3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da6:	50                   	push   %eax
  800da7:	e8 ed f5 ff ff       	call   800399 <fd_alloc>
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	85 c0                	test   %eax,%eax
  800db3:	0f 88 2c 01 00 00    	js     800ee5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	68 07 04 00 00       	push   $0x407
  800dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 b6 f3 ff ff       	call   800181 <sys_page_alloc>
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	89 c2                	mov    %eax,%edx
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	0f 88 0d 01 00 00    	js     800ee5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dde:	50                   	push   %eax
  800ddf:	e8 b5 f5 ff ff       	call   800399 <fd_alloc>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	0f 88 e2 00 00 00    	js     800ed3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	68 07 04 00 00       	push   $0x407
  800df9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 7e f3 ff ff       	call   800181 <sys_page_alloc>
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	0f 88 c3 00 00 00    	js     800ed3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	ff 75 f4             	pushl  -0xc(%ebp)
  800e16:	e8 67 f5 ff ff       	call   800382 <fd2data>
  800e1b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1d:	83 c4 0c             	add    $0xc,%esp
  800e20:	68 07 04 00 00       	push   $0x407
  800e25:	50                   	push   %eax
  800e26:	6a 00                	push   $0x0
  800e28:	e8 54 f3 ff ff       	call   800181 <sys_page_alloc>
  800e2d:	89 c3                	mov    %eax,%ebx
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	0f 88 89 00 00 00    	js     800ec3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3a:	83 ec 0c             	sub    $0xc,%esp
  800e3d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e40:	e8 3d f5 ff ff       	call   800382 <fd2data>
  800e45:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e4c:	50                   	push   %eax
  800e4d:	6a 00                	push   $0x0
  800e4f:	56                   	push   %esi
  800e50:	6a 00                	push   $0x0
  800e52:	e8 6d f3 ff ff       	call   8001c4 <sys_page_map>
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	83 c4 20             	add    $0x20,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 55                	js     800eb5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e60:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e69:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e75:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e83:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e90:	e8 dd f4 ff ff       	call   800372 <fd2num>
  800e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e98:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e9a:	83 c4 04             	add    $0x4,%esp
  800e9d:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea0:	e8 cd f4 ff ff       	call   800372 <fd2num>
  800ea5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	eb 30                	jmp    800ee5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	56                   	push   %esi
  800eb9:	6a 00                	push   $0x0
  800ebb:	e8 46 f3 ff ff       	call   800206 <sys_page_unmap>
  800ec0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ec3:	83 ec 08             	sub    $0x8,%esp
  800ec6:	ff 75 f0             	pushl  -0x10(%ebp)
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 36 f3 ff ff       	call   800206 <sys_page_unmap>
  800ed0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 26 f3 ff ff       	call   800206 <sys_page_unmap>
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef7:	50                   	push   %eax
  800ef8:	ff 75 08             	pushl  0x8(%ebp)
  800efb:	e8 e8 f4 ff ff       	call   8003e8 <fd_lookup>
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 18                	js     800f1f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0d:	e8 70 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f17:	e8 21 fd ff ff       	call   800c3d <_pipeisclosed>
  800f1c:	83 c4 10             	add    $0x10,%esp
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f31:	68 84 20 80 00       	push   $0x802084
  800f36:	ff 75 0c             	pushl  0xc(%ebp)
  800f39:	e8 73 08 00 00       	call   8017b1 <strcpy>
	return 0;
}
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f51:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5c:	eb 2d                	jmp    800f8b <devcons_write+0x46>
		m = n - tot;
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f63:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f66:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f6b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	53                   	push   %ebx
  800f72:	03 45 0c             	add    0xc(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	57                   	push   %edi
  800f77:	e8 c7 09 00 00       	call   801943 <memmove>
		sys_cputs(buf, m);
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	53                   	push   %ebx
  800f80:	57                   	push   %edi
  800f81:	e8 3f f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f86:	01 de                	add    %ebx,%esi
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f90:	72 cc                	jb     800f5e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fa5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fa9:	74 2a                	je     800fd5 <devcons_read+0x3b>
  800fab:	eb 05                	jmp    800fb2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fad:	e8 b0 f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fb2:	e8 2c f1 ff ff       	call   8000e3 <sys_cgetc>
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	74 f2                	je     800fad <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 16                	js     800fd5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fbf:	83 f8 04             	cmp    $0x4,%eax
  800fc2:	74 0c                	je     800fd0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc7:	88 02                	mov    %al,(%edx)
	return 1;
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fce:	eb 05                	jmp    800fd5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fd0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fe3:	6a 01                	push   $0x1
  800fe5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	e8 d7 f0 ff ff       	call   8000c5 <sys_cputs>
}
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <getchar>:

int
getchar(void)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800ff9:	6a 01                	push   $0x1
  800ffb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	6a 00                	push   $0x0
  801001:	e8 48 f6 ff ff       	call   80064e <read>
	if (r < 0)
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 0f                	js     80101c <getchar+0x29>
		return r;
	if (r < 1)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	7e 06                	jle    801017 <getchar+0x24>
		return -E_EOF;
	return c;
  801011:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801015:	eb 05                	jmp    80101c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801017:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	e8 b8 f3 ff ff       	call   8003e8 <fd_lookup>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 11                	js     801048 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801040:	39 10                	cmp    %edx,(%eax)
  801042:	0f 94 c0             	sete   %al
  801045:	0f b6 c0             	movzbl %al,%eax
}
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <opencons>:

int
opencons(void)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801050:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801053:	50                   	push   %eax
  801054:	e8 40 f3 ff ff       	call   800399 <fd_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
		return r;
  80105c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 3e                	js     8010a0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	68 07 04 00 00       	push   $0x407
  80106a:	ff 75 f4             	pushl  -0xc(%ebp)
  80106d:	6a 00                	push   $0x0
  80106f:	e8 0d f1 ff ff       	call   800181 <sys_page_alloc>
  801074:	83 c4 10             	add    $0x10,%esp
		return r;
  801077:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 23                	js     8010a0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80107d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801086:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	50                   	push   %eax
  801096:	e8 d7 f2 ff ff       	call   800372 <fd2num>
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	83 c4 10             	add    $0x10,%esp
}
  8010a0:	89 d0                	mov    %edx,%eax
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010a9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ac:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010b2:	e8 8c f0 ff ff       	call   800143 <sys_getenvid>
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	ff 75 08             	pushl  0x8(%ebp)
  8010c0:	56                   	push   %esi
  8010c1:	50                   	push   %eax
  8010c2:	68 90 20 80 00       	push   $0x802090
  8010c7:	e8 b1 00 00 00       	call   80117d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010cc:	83 c4 18             	add    $0x18,%esp
  8010cf:	53                   	push   %ebx
  8010d0:	ff 75 10             	pushl  0x10(%ebp)
  8010d3:	e8 54 00 00 00       	call   80112c <vcprintf>
	cprintf("\n");
  8010d8:	c7 04 24 7d 20 80 00 	movl   $0x80207d,(%esp)
  8010df:	e8 99 00 00 00       	call   80117d <cprintf>
  8010e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e7:	cc                   	int3   
  8010e8:	eb fd                	jmp    8010e7 <_panic+0x43>

008010ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010f4:	8b 13                	mov    (%ebx),%edx
  8010f6:	8d 42 01             	lea    0x1(%edx),%eax
  8010f9:	89 03                	mov    %eax,(%ebx)
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801102:	3d ff 00 00 00       	cmp    $0xff,%eax
  801107:	75 1a                	jne    801123 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	68 ff 00 00 00       	push   $0xff
  801111:	8d 43 08             	lea    0x8(%ebx),%eax
  801114:	50                   	push   %eax
  801115:	e8 ab ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80111a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801120:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801123:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80113c:	00 00 00 
	b.cnt = 0;
  80113f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801149:	ff 75 0c             	pushl  0xc(%ebp)
  80114c:	ff 75 08             	pushl  0x8(%ebp)
  80114f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	68 ea 10 80 00       	push   $0x8010ea
  80115b:	e8 54 01 00 00       	call   8012b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801169:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	e8 50 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801175:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801183:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801186:	50                   	push   %eax
  801187:	ff 75 08             	pushl  0x8(%ebp)
  80118a:	e8 9d ff ff ff       	call   80112c <vcprintf>
	va_end(ap);

	return cnt;
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 1c             	sub    $0x1c,%esp
  80119a:	89 c7                	mov    %eax,%edi
  80119c:	89 d6                	mov    %edx,%esi
  80119e:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011b8:	39 d3                	cmp    %edx,%ebx
  8011ba:	72 05                	jb     8011c1 <printnum+0x30>
  8011bc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011bf:	77 45                	ja     801206 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	ff 75 18             	pushl  0x18(%ebp)
  8011c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011cd:	53                   	push   %ebx
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011da:	ff 75 dc             	pushl  -0x24(%ebp)
  8011dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e0:	e8 cb 0a 00 00       	call   801cb0 <__udivdi3>
  8011e5:	83 c4 18             	add    $0x18,%esp
  8011e8:	52                   	push   %edx
  8011e9:	50                   	push   %eax
  8011ea:	89 f2                	mov    %esi,%edx
  8011ec:	89 f8                	mov    %edi,%eax
  8011ee:	e8 9e ff ff ff       	call   801191 <printnum>
  8011f3:	83 c4 20             	add    $0x20,%esp
  8011f6:	eb 18                	jmp    801210 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	56                   	push   %esi
  8011fc:	ff 75 18             	pushl  0x18(%ebp)
  8011ff:	ff d7                	call   *%edi
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	eb 03                	jmp    801209 <printnum+0x78>
  801206:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801209:	83 eb 01             	sub    $0x1,%ebx
  80120c:	85 db                	test   %ebx,%ebx
  80120e:	7f e8                	jg     8011f8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	56                   	push   %esi
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121a:	ff 75 e0             	pushl  -0x20(%ebp)
  80121d:	ff 75 dc             	pushl  -0x24(%ebp)
  801220:	ff 75 d8             	pushl  -0x28(%ebp)
  801223:	e8 b8 0b 00 00       	call   801de0 <__umoddi3>
  801228:	83 c4 14             	add    $0x14,%esp
  80122b:	0f be 80 b3 20 80 00 	movsbl 0x8020b3(%eax),%eax
  801232:	50                   	push   %eax
  801233:	ff d7                	call   *%edi
}
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801243:	83 fa 01             	cmp    $0x1,%edx
  801246:	7e 0e                	jle    801256 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801248:	8b 10                	mov    (%eax),%edx
  80124a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80124d:	89 08                	mov    %ecx,(%eax)
  80124f:	8b 02                	mov    (%edx),%eax
  801251:	8b 52 04             	mov    0x4(%edx),%edx
  801254:	eb 22                	jmp    801278 <getuint+0x38>
	else if (lflag)
  801256:	85 d2                	test   %edx,%edx
  801258:	74 10                	je     80126a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80125a:	8b 10                	mov    (%eax),%edx
  80125c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80125f:	89 08                	mov    %ecx,(%eax)
  801261:	8b 02                	mov    (%edx),%eax
  801263:	ba 00 00 00 00       	mov    $0x0,%edx
  801268:	eb 0e                	jmp    801278 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80126a:	8b 10                	mov    (%eax),%edx
  80126c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80126f:	89 08                	mov    %ecx,(%eax)
  801271:	8b 02                	mov    (%edx),%eax
  801273:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801280:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801284:	8b 10                	mov    (%eax),%edx
  801286:	3b 50 04             	cmp    0x4(%eax),%edx
  801289:	73 0a                	jae    801295 <sprintputch+0x1b>
		*b->buf++ = ch;
  80128b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80128e:	89 08                	mov    %ecx,(%eax)
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	88 02                	mov    %al,(%edx)
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80129d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a0:	50                   	push   %eax
  8012a1:	ff 75 10             	pushl  0x10(%ebp)
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	ff 75 08             	pushl  0x8(%ebp)
  8012aa:	e8 05 00 00 00       	call   8012b4 <vprintfmt>
	va_end(ap);
}
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 2c             	sub    $0x2c,%esp
  8012bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c6:	eb 12                	jmp    8012da <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	0f 84 38 04 00 00    	je     801708 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	50                   	push   %eax
  8012d5:	ff d6                	call   *%esi
  8012d7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012da:	83 c7 01             	add    $0x1,%edi
  8012dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012e1:	83 f8 25             	cmp    $0x25,%eax
  8012e4:	75 e2                	jne    8012c8 <vprintfmt+0x14>
  8012e6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012ea:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801304:	eb 07                	jmp    80130d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  801309:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130d:	8d 47 01             	lea    0x1(%edi),%eax
  801310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801313:	0f b6 07             	movzbl (%edi),%eax
  801316:	0f b6 c8             	movzbl %al,%ecx
  801319:	83 e8 23             	sub    $0x23,%eax
  80131c:	3c 55                	cmp    $0x55,%al
  80131e:	0f 87 c9 03 00 00    	ja     8016ed <vprintfmt+0x439>
  801324:	0f b6 c0             	movzbl %al,%eax
  801327:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  80132e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801331:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801335:	eb d6                	jmp    80130d <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  801337:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80133e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801344:	eb 94                	jmp    8012da <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  801346:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  80134d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801353:	eb 85                	jmp    8012da <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801355:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  80135c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801362:	e9 73 ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  801367:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  80136e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801374:	e9 61 ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  801379:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801380:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  801386:	e9 4f ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80138b:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801392:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  801398:	e9 3d ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80139d:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  8013a4:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  8013aa:	e9 2b ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  8013af:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  8013b6:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  8013bc:	e9 19 ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8013c1:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013c8:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013ce:	e9 07 ff ff ff       	jmp    8012da <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013d3:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013da:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013e0:	e9 f5 fe ff ff       	jmp    8012da <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013f3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013f7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013fa:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013fd:	83 fa 09             	cmp    $0x9,%edx
  801400:	77 3f                	ja     801441 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801402:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801405:	eb e9                	jmp    8013f0 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801407:	8b 45 14             	mov    0x14(%ebp),%eax
  80140a:	8d 48 04             	lea    0x4(%eax),%ecx
  80140d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801410:	8b 00                	mov    (%eax),%eax
  801412:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801418:	eb 2d                	jmp    801447 <vprintfmt+0x193>
  80141a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80141d:	85 c0                	test   %eax,%eax
  80141f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801424:	0f 49 c8             	cmovns %eax,%ecx
  801427:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80142a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80142d:	e9 db fe ff ff       	jmp    80130d <vprintfmt+0x59>
  801432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801435:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80143c:	e9 cc fe ff ff       	jmp    80130d <vprintfmt+0x59>
  801441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80144b:	0f 89 bc fe ff ff    	jns    80130d <vprintfmt+0x59>
				width = precision, precision = -1;
  801451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80145e:	e9 aa fe ff ff       	jmp    80130d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801469:	e9 9f fe ff ff       	jmp    80130d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80146e:	8b 45 14             	mov    0x14(%ebp),%eax
  801471:	8d 50 04             	lea    0x4(%eax),%edx
  801474:	89 55 14             	mov    %edx,0x14(%ebp)
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	53                   	push   %ebx
  80147b:	ff 30                	pushl  (%eax)
  80147d:	ff d6                	call   *%esi
			break;
  80147f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801485:	e9 50 fe ff ff       	jmp    8012da <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80148a:	8b 45 14             	mov    0x14(%ebp),%eax
  80148d:	8d 50 04             	lea    0x4(%eax),%edx
  801490:	89 55 14             	mov    %edx,0x14(%ebp)
  801493:	8b 00                	mov    (%eax),%eax
  801495:	99                   	cltd   
  801496:	31 d0                	xor    %edx,%eax
  801498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80149a:	83 f8 0f             	cmp    $0xf,%eax
  80149d:	7f 0b                	jg     8014aa <vprintfmt+0x1f6>
  80149f:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  8014a6:	85 d2                	test   %edx,%edx
  8014a8:	75 18                	jne    8014c2 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  8014aa:	50                   	push   %eax
  8014ab:	68 cb 20 80 00       	push   $0x8020cb
  8014b0:	53                   	push   %ebx
  8014b1:	56                   	push   %esi
  8014b2:	e8 e0 fd ff ff       	call   801297 <printfmt>
  8014b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014bd:	e9 18 fe ff ff       	jmp    8012da <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8014c2:	52                   	push   %edx
  8014c3:	68 1d 20 80 00       	push   $0x80201d
  8014c8:	53                   	push   %ebx
  8014c9:	56                   	push   %esi
  8014ca:	e8 c8 fd ff ff       	call   801297 <printfmt>
  8014cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d5:	e9 00 fe ff ff       	jmp    8012da <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014da:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dd:	8d 50 04             	lea    0x4(%eax),%edx
  8014e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014e5:	85 ff                	test   %edi,%edi
  8014e7:	b8 c4 20 80 00       	mov    $0x8020c4,%eax
  8014ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014f3:	0f 8e 94 00 00 00    	jle    80158d <vprintfmt+0x2d9>
  8014f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014fd:	0f 84 98 00 00 00    	je     80159b <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	ff 75 d0             	pushl  -0x30(%ebp)
  801509:	57                   	push   %edi
  80150a:	e8 81 02 00 00       	call   801790 <strnlen>
  80150f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801512:	29 c1                	sub    %eax,%ecx
  801514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80151a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80151e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801526:	eb 0f                	jmp    801537 <vprintfmt+0x283>
					putch(padc, putdat);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	53                   	push   %ebx
  80152c:	ff 75 e0             	pushl  -0x20(%ebp)
  80152f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801531:	83 ef 01             	sub    $0x1,%edi
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 ff                	test   %edi,%edi
  801539:	7f ed                	jg     801528 <vprintfmt+0x274>
  80153b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80153e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801541:	85 c9                	test   %ecx,%ecx
  801543:	b8 00 00 00 00       	mov    $0x0,%eax
  801548:	0f 49 c1             	cmovns %ecx,%eax
  80154b:	29 c1                	sub    %eax,%ecx
  80154d:	89 75 08             	mov    %esi,0x8(%ebp)
  801550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801556:	89 cb                	mov    %ecx,%ebx
  801558:	eb 4d                	jmp    8015a7 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80155a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80155e:	74 1b                	je     80157b <vprintfmt+0x2c7>
  801560:	0f be c0             	movsbl %al,%eax
  801563:	83 e8 20             	sub    $0x20,%eax
  801566:	83 f8 5e             	cmp    $0x5e,%eax
  801569:	76 10                	jbe    80157b <vprintfmt+0x2c7>
					putch('?', putdat);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	ff 75 0c             	pushl  0xc(%ebp)
  801571:	6a 3f                	push   $0x3f
  801573:	ff 55 08             	call   *0x8(%ebp)
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	eb 0d                	jmp    801588 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	ff 75 0c             	pushl  0xc(%ebp)
  801581:	52                   	push   %edx
  801582:	ff 55 08             	call   *0x8(%ebp)
  801585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801588:	83 eb 01             	sub    $0x1,%ebx
  80158b:	eb 1a                	jmp    8015a7 <vprintfmt+0x2f3>
  80158d:	89 75 08             	mov    %esi,0x8(%ebp)
  801590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801599:	eb 0c                	jmp    8015a7 <vprintfmt+0x2f3>
  80159b:	89 75 08             	mov    %esi,0x8(%ebp)
  80159e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8015a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8015a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8015a7:	83 c7 01             	add    $0x1,%edi
  8015aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ae:	0f be d0             	movsbl %al,%edx
  8015b1:	85 d2                	test   %edx,%edx
  8015b3:	74 23                	je     8015d8 <vprintfmt+0x324>
  8015b5:	85 f6                	test   %esi,%esi
  8015b7:	78 a1                	js     80155a <vprintfmt+0x2a6>
  8015b9:	83 ee 01             	sub    $0x1,%esi
  8015bc:	79 9c                	jns    80155a <vprintfmt+0x2a6>
  8015be:	89 df                	mov    %ebx,%edi
  8015c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015c6:	eb 18                	jmp    8015e0 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	53                   	push   %ebx
  8015cc:	6a 20                	push   $0x20
  8015ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015d0:	83 ef 01             	sub    $0x1,%edi
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 08                	jmp    8015e0 <vprintfmt+0x32c>
  8015d8:	89 df                	mov    %ebx,%edi
  8015da:	8b 75 08             	mov    0x8(%ebp),%esi
  8015dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015e0:	85 ff                	test   %edi,%edi
  8015e2:	7f e4                	jg     8015c8 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e7:	e9 ee fc ff ff       	jmp    8012da <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015ec:	83 fa 01             	cmp    $0x1,%edx
  8015ef:	7e 16                	jle    801607 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f4:	8d 50 08             	lea    0x8(%eax),%edx
  8015f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8015fa:	8b 50 04             	mov    0x4(%eax),%edx
  8015fd:	8b 00                	mov    (%eax),%eax
  8015ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801605:	eb 32                	jmp    801639 <vprintfmt+0x385>
	else if (lflag)
  801607:	85 d2                	test   %edx,%edx
  801609:	74 18                	je     801623 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8d 50 04             	lea    0x4(%eax),%edx
  801611:	89 55 14             	mov    %edx,0x14(%ebp)
  801614:	8b 00                	mov    (%eax),%eax
  801616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801619:	89 c1                	mov    %eax,%ecx
  80161b:	c1 f9 1f             	sar    $0x1f,%ecx
  80161e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801621:	eb 16                	jmp    801639 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  801623:	8b 45 14             	mov    0x14(%ebp),%eax
  801626:	8d 50 04             	lea    0x4(%eax),%edx
  801629:	89 55 14             	mov    %edx,0x14(%ebp)
  80162c:	8b 00                	mov    (%eax),%eax
  80162e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801631:	89 c1                	mov    %eax,%ecx
  801633:	c1 f9 1f             	sar    $0x1f,%ecx
  801636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80163c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80163f:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801648:	79 6f                	jns    8016b9 <vprintfmt+0x405>
				putch('-', putdat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	53                   	push   %ebx
  80164e:	6a 2d                	push   $0x2d
  801650:	ff d6                	call   *%esi
				num = -(long long) num;
  801652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801658:	f7 d8                	neg    %eax
  80165a:	83 d2 00             	adc    $0x0,%edx
  80165d:	f7 da                	neg    %edx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 55                	jmp    8016b9 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801664:	8d 45 14             	lea    0x14(%ebp),%eax
  801667:	e8 d4 fb ff ff       	call   801240 <getuint>
			base = 10;
  80166c:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801671:	eb 46                	jmp    8016b9 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801673:	8d 45 14             	lea    0x14(%ebp),%eax
  801676:	e8 c5 fb ff ff       	call   801240 <getuint>
			base = 8;
  80167b:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801680:	eb 37                	jmp    8016b9 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	53                   	push   %ebx
  801686:	6a 30                	push   $0x30
  801688:	ff d6                	call   *%esi
			putch('x', putdat);
  80168a:	83 c4 08             	add    $0x8,%esp
  80168d:	53                   	push   %ebx
  80168e:	6a 78                	push   $0x78
  801690:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801692:	8b 45 14             	mov    0x14(%ebp),%eax
  801695:	8d 50 04             	lea    0x4(%eax),%edx
  801698:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80169b:	8b 00                	mov    (%eax),%eax
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8016a2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016a5:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  8016aa:	eb 0d                	jmp    8016b9 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8016af:	e8 8c fb ff ff       	call   801240 <getuint>
			base = 16;
  8016b4:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8016c0:	51                   	push   %ecx
  8016c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8016c4:	57                   	push   %edi
  8016c5:	52                   	push   %edx
  8016c6:	50                   	push   %eax
  8016c7:	89 da                	mov    %ebx,%edx
  8016c9:	89 f0                	mov    %esi,%eax
  8016cb:	e8 c1 fa ff ff       	call   801191 <printnum>
			break;
  8016d0:	83 c4 20             	add    $0x20,%esp
  8016d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016d6:	e9 ff fb ff ff       	jmp    8012da <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	53                   	push   %ebx
  8016df:	51                   	push   %ecx
  8016e0:	ff d6                	call   *%esi
			break;
  8016e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016e8:	e9 ed fb ff ff       	jmp    8012da <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	53                   	push   %ebx
  8016f1:	6a 25                	push   $0x25
  8016f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 03                	jmp    8016fd <vprintfmt+0x449>
  8016fa:	83 ef 01             	sub    $0x1,%edi
  8016fd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801701:	75 f7                	jne    8016fa <vprintfmt+0x446>
  801703:	e9 d2 fb ff ff       	jmp    8012da <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5f                   	pop    %edi
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 18             	sub    $0x18,%esp
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80171c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80171f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80172d:	85 c0                	test   %eax,%eax
  80172f:	74 26                	je     801757 <vsnprintf+0x47>
  801731:	85 d2                	test   %edx,%edx
  801733:	7e 22                	jle    801757 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801735:	ff 75 14             	pushl  0x14(%ebp)
  801738:	ff 75 10             	pushl  0x10(%ebp)
  80173b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80173e:	50                   	push   %eax
  80173f:	68 7a 12 80 00       	push   $0x80127a
  801744:	e8 6b fb ff ff       	call   8012b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80174c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	eb 05                	jmp    80175c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801764:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801767:	50                   	push   %eax
  801768:	ff 75 10             	pushl  0x10(%ebp)
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	ff 75 08             	pushl  0x8(%ebp)
  801771:	e8 9a ff ff ff       	call   801710 <vsnprintf>
	va_end(ap);

	return rc;
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80177e:	b8 00 00 00 00       	mov    $0x0,%eax
  801783:	eb 03                	jmp    801788 <strlen+0x10>
		n++;
  801785:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801788:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80178c:	75 f7                	jne    801785 <strlen+0xd>
		n++;
	return n;
}
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801796:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	eb 03                	jmp    8017a3 <strnlen+0x13>
		n++;
  8017a0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017a3:	39 c2                	cmp    %eax,%edx
  8017a5:	74 08                	je     8017af <strnlen+0x1f>
  8017a7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8017ab:	75 f3                	jne    8017a0 <strnlen+0x10>
  8017ad:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017bb:	89 c2                	mov    %eax,%edx
  8017bd:	83 c2 01             	add    $0x1,%edx
  8017c0:	83 c1 01             	add    $0x1,%ecx
  8017c3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017c7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017ca:	84 db                	test   %bl,%bl
  8017cc:	75 ef                	jne    8017bd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017ce:	5b                   	pop    %ebx
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	53                   	push   %ebx
  8017d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017d8:	53                   	push   %ebx
  8017d9:	e8 9a ff ff ff       	call   801778 <strlen>
  8017de:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017e1:	ff 75 0c             	pushl  0xc(%ebp)
  8017e4:	01 d8                	add    %ebx,%eax
  8017e6:	50                   	push   %eax
  8017e7:	e8 c5 ff ff ff       	call   8017b1 <strcpy>
	return dst;
}
  8017ec:	89 d8                	mov    %ebx,%eax
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fe:	89 f3                	mov    %esi,%ebx
  801800:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801803:	89 f2                	mov    %esi,%edx
  801805:	eb 0f                	jmp    801816 <strncpy+0x23>
		*dst++ = *src;
  801807:	83 c2 01             	add    $0x1,%edx
  80180a:	0f b6 01             	movzbl (%ecx),%eax
  80180d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801810:	80 39 01             	cmpb   $0x1,(%ecx)
  801813:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801816:	39 da                	cmp    %ebx,%edx
  801818:	75 ed                	jne    801807 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80181a:	89 f0                	mov    %esi,%eax
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	8b 75 08             	mov    0x8(%ebp),%esi
  801828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182b:	8b 55 10             	mov    0x10(%ebp),%edx
  80182e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801830:	85 d2                	test   %edx,%edx
  801832:	74 21                	je     801855 <strlcpy+0x35>
  801834:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801838:	89 f2                	mov    %esi,%edx
  80183a:	eb 09                	jmp    801845 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80183c:	83 c2 01             	add    $0x1,%edx
  80183f:	83 c1 01             	add    $0x1,%ecx
  801842:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801845:	39 c2                	cmp    %eax,%edx
  801847:	74 09                	je     801852 <strlcpy+0x32>
  801849:	0f b6 19             	movzbl (%ecx),%ebx
  80184c:	84 db                	test   %bl,%bl
  80184e:	75 ec                	jne    80183c <strlcpy+0x1c>
  801850:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801852:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801855:	29 f0                	sub    %esi,%eax
}
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801864:	eb 06                	jmp    80186c <strcmp+0x11>
		p++, q++;
  801866:	83 c1 01             	add    $0x1,%ecx
  801869:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80186c:	0f b6 01             	movzbl (%ecx),%eax
  80186f:	84 c0                	test   %al,%al
  801871:	74 04                	je     801877 <strcmp+0x1c>
  801873:	3a 02                	cmp    (%edx),%al
  801875:	74 ef                	je     801866 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801877:	0f b6 c0             	movzbl %al,%eax
  80187a:	0f b6 12             	movzbl (%edx),%edx
  80187d:	29 d0                	sub    %edx,%eax
}
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	53                   	push   %ebx
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801890:	eb 06                	jmp    801898 <strncmp+0x17>
		n--, p++, q++;
  801892:	83 c0 01             	add    $0x1,%eax
  801895:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801898:	39 d8                	cmp    %ebx,%eax
  80189a:	74 15                	je     8018b1 <strncmp+0x30>
  80189c:	0f b6 08             	movzbl (%eax),%ecx
  80189f:	84 c9                	test   %cl,%cl
  8018a1:	74 04                	je     8018a7 <strncmp+0x26>
  8018a3:	3a 0a                	cmp    (%edx),%cl
  8018a5:	74 eb                	je     801892 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a7:	0f b6 00             	movzbl (%eax),%eax
  8018aa:	0f b6 12             	movzbl (%edx),%edx
  8018ad:	29 d0                	sub    %edx,%eax
  8018af:	eb 05                	jmp    8018b6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8018b6:	5b                   	pop    %ebx
  8018b7:	5d                   	pop    %ebp
  8018b8:	c3                   	ret    

008018b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018c3:	eb 07                	jmp    8018cc <strchr+0x13>
		if (*s == c)
  8018c5:	38 ca                	cmp    %cl,%dl
  8018c7:	74 0f                	je     8018d8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018c9:	83 c0 01             	add    $0x1,%eax
  8018cc:	0f b6 10             	movzbl (%eax),%edx
  8018cf:	84 d2                	test   %dl,%dl
  8018d1:	75 f2                	jne    8018c5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018e4:	eb 03                	jmp    8018e9 <strfind+0xf>
  8018e6:	83 c0 01             	add    $0x1,%eax
  8018e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018ec:	38 ca                	cmp    %cl,%dl
  8018ee:	74 04                	je     8018f4 <strfind+0x1a>
  8018f0:	84 d2                	test   %dl,%dl
  8018f2:	75 f2                	jne    8018e6 <strfind+0xc>
			break;
	return (char *) s;
}
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    

008018f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	57                   	push   %edi
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801902:	85 c9                	test   %ecx,%ecx
  801904:	74 36                	je     80193c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80190c:	75 28                	jne    801936 <memset+0x40>
  80190e:	f6 c1 03             	test   $0x3,%cl
  801911:	75 23                	jne    801936 <memset+0x40>
		c &= 0xFF;
  801913:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801917:	89 d3                	mov    %edx,%ebx
  801919:	c1 e3 08             	shl    $0x8,%ebx
  80191c:	89 d6                	mov    %edx,%esi
  80191e:	c1 e6 18             	shl    $0x18,%esi
  801921:	89 d0                	mov    %edx,%eax
  801923:	c1 e0 10             	shl    $0x10,%eax
  801926:	09 f0                	or     %esi,%eax
  801928:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	09 d0                	or     %edx,%eax
  80192e:	c1 e9 02             	shr    $0x2,%ecx
  801931:	fc                   	cld    
  801932:	f3 ab                	rep stos %eax,%es:(%edi)
  801934:	eb 06                	jmp    80193c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801936:	8b 45 0c             	mov    0xc(%ebp),%eax
  801939:	fc                   	cld    
  80193a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80193c:	89 f8                	mov    %edi,%eax
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5f                   	pop    %edi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	57                   	push   %edi
  801947:	56                   	push   %esi
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80194e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801951:	39 c6                	cmp    %eax,%esi
  801953:	73 35                	jae    80198a <memmove+0x47>
  801955:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801958:	39 d0                	cmp    %edx,%eax
  80195a:	73 2e                	jae    80198a <memmove+0x47>
		s += n;
		d += n;
  80195c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80195f:	89 d6                	mov    %edx,%esi
  801961:	09 fe                	or     %edi,%esi
  801963:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801969:	75 13                	jne    80197e <memmove+0x3b>
  80196b:	f6 c1 03             	test   $0x3,%cl
  80196e:	75 0e                	jne    80197e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801970:	83 ef 04             	sub    $0x4,%edi
  801973:	8d 72 fc             	lea    -0x4(%edx),%esi
  801976:	c1 e9 02             	shr    $0x2,%ecx
  801979:	fd                   	std    
  80197a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80197c:	eb 09                	jmp    801987 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80197e:	83 ef 01             	sub    $0x1,%edi
  801981:	8d 72 ff             	lea    -0x1(%edx),%esi
  801984:	fd                   	std    
  801985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801987:	fc                   	cld    
  801988:	eb 1d                	jmp    8019a7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80198a:	89 f2                	mov    %esi,%edx
  80198c:	09 c2                	or     %eax,%edx
  80198e:	f6 c2 03             	test   $0x3,%dl
  801991:	75 0f                	jne    8019a2 <memmove+0x5f>
  801993:	f6 c1 03             	test   $0x3,%cl
  801996:	75 0a                	jne    8019a2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801998:	c1 e9 02             	shr    $0x2,%ecx
  80199b:	89 c7                	mov    %eax,%edi
  80199d:	fc                   	cld    
  80199e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019a0:	eb 05                	jmp    8019a7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8019a2:	89 c7                	mov    %eax,%edi
  8019a4:	fc                   	cld    
  8019a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019a7:	5e                   	pop    %esi
  8019a8:	5f                   	pop    %edi
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    

008019ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8019ae:	ff 75 10             	pushl  0x10(%ebp)
  8019b1:	ff 75 0c             	pushl  0xc(%ebp)
  8019b4:	ff 75 08             	pushl  0x8(%ebp)
  8019b7:	e8 87 ff ff ff       	call   801943 <memmove>
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c9:	89 c6                	mov    %eax,%esi
  8019cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019ce:	eb 1a                	jmp    8019ea <memcmp+0x2c>
		if (*s1 != *s2)
  8019d0:	0f b6 08             	movzbl (%eax),%ecx
  8019d3:	0f b6 1a             	movzbl (%edx),%ebx
  8019d6:	38 d9                	cmp    %bl,%cl
  8019d8:	74 0a                	je     8019e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019da:	0f b6 c1             	movzbl %cl,%eax
  8019dd:	0f b6 db             	movzbl %bl,%ebx
  8019e0:	29 d8                	sub    %ebx,%eax
  8019e2:	eb 0f                	jmp    8019f3 <memcmp+0x35>
		s1++, s2++;
  8019e4:	83 c0 01             	add    $0x1,%eax
  8019e7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019ea:	39 f0                	cmp    %esi,%eax
  8019ec:	75 e2                	jne    8019d0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	53                   	push   %ebx
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019fe:	89 c1                	mov    %eax,%ecx
  801a00:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801a03:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a07:	eb 0a                	jmp    801a13 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a09:	0f b6 10             	movzbl (%eax),%edx
  801a0c:	39 da                	cmp    %ebx,%edx
  801a0e:	74 07                	je     801a17 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a10:	83 c0 01             	add    $0x1,%eax
  801a13:	39 c8                	cmp    %ecx,%eax
  801a15:	72 f2                	jb     801a09 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a17:	5b                   	pop    %ebx
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a26:	eb 03                	jmp    801a2b <strtol+0x11>
		s++;
  801a28:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a2b:	0f b6 01             	movzbl (%ecx),%eax
  801a2e:	3c 20                	cmp    $0x20,%al
  801a30:	74 f6                	je     801a28 <strtol+0xe>
  801a32:	3c 09                	cmp    $0x9,%al
  801a34:	74 f2                	je     801a28 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a36:	3c 2b                	cmp    $0x2b,%al
  801a38:	75 0a                	jne    801a44 <strtol+0x2a>
		s++;
  801a3a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a3d:	bf 00 00 00 00       	mov    $0x0,%edi
  801a42:	eb 11                	jmp    801a55 <strtol+0x3b>
  801a44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a49:	3c 2d                	cmp    $0x2d,%al
  801a4b:	75 08                	jne    801a55 <strtol+0x3b>
		s++, neg = 1;
  801a4d:	83 c1 01             	add    $0x1,%ecx
  801a50:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a55:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a5b:	75 15                	jne    801a72 <strtol+0x58>
  801a5d:	80 39 30             	cmpb   $0x30,(%ecx)
  801a60:	75 10                	jne    801a72 <strtol+0x58>
  801a62:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a66:	75 7c                	jne    801ae4 <strtol+0xca>
		s += 2, base = 16;
  801a68:	83 c1 02             	add    $0x2,%ecx
  801a6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a70:	eb 16                	jmp    801a88 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	75 12                	jne    801a88 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a76:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a7b:	80 39 30             	cmpb   $0x30,(%ecx)
  801a7e:	75 08                	jne    801a88 <strtol+0x6e>
		s++, base = 8;
  801a80:	83 c1 01             	add    $0x1,%ecx
  801a83:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a90:	0f b6 11             	movzbl (%ecx),%edx
  801a93:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a96:	89 f3                	mov    %esi,%ebx
  801a98:	80 fb 09             	cmp    $0x9,%bl
  801a9b:	77 08                	ja     801aa5 <strtol+0x8b>
			dig = *s - '0';
  801a9d:	0f be d2             	movsbl %dl,%edx
  801aa0:	83 ea 30             	sub    $0x30,%edx
  801aa3:	eb 22                	jmp    801ac7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801aa5:	8d 72 9f             	lea    -0x61(%edx),%esi
  801aa8:	89 f3                	mov    %esi,%ebx
  801aaa:	80 fb 19             	cmp    $0x19,%bl
  801aad:	77 08                	ja     801ab7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801aaf:	0f be d2             	movsbl %dl,%edx
  801ab2:	83 ea 57             	sub    $0x57,%edx
  801ab5:	eb 10                	jmp    801ac7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ab7:	8d 72 bf             	lea    -0x41(%edx),%esi
  801aba:	89 f3                	mov    %esi,%ebx
  801abc:	80 fb 19             	cmp    $0x19,%bl
  801abf:	77 16                	ja     801ad7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ac1:	0f be d2             	movsbl %dl,%edx
  801ac4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ac7:	3b 55 10             	cmp    0x10(%ebp),%edx
  801aca:	7d 0b                	jge    801ad7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801acc:	83 c1 01             	add    $0x1,%ecx
  801acf:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ad3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ad5:	eb b9                	jmp    801a90 <strtol+0x76>

	if (endptr)
  801ad7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801adb:	74 0d                	je     801aea <strtol+0xd0>
		*endptr = (char *) s;
  801add:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae0:	89 0e                	mov    %ecx,(%esi)
  801ae2:	eb 06                	jmp    801aea <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ae4:	85 db                	test   %ebx,%ebx
  801ae6:	74 98                	je     801a80 <strtol+0x66>
  801ae8:	eb 9e                	jmp    801a88 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	f7 da                	neg    %edx
  801aee:	85 ff                	test   %edi,%edi
  801af0:	0f 45 c2             	cmovne %edx,%eax
}
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5f                   	pop    %edi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	57                   	push   %edi
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801b04:	57                   	push   %edi
  801b05:	e8 6e fc ff ff       	call   801778 <strlen>
  801b0a:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b0d:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801b10:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b1a:	eb 46                	jmp    801b62 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801b1c:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801b20:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b23:	80 f9 09             	cmp    $0x9,%cl
  801b26:	77 08                	ja     801b30 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b28:	0f be d2             	movsbl %dl,%edx
  801b2b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b2e:	eb 27                	jmp    801b57 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b30:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b33:	80 f9 05             	cmp    $0x5,%cl
  801b36:	77 08                	ja     801b40 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b38:	0f be d2             	movsbl %dl,%edx
  801b3b:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b3e:	eb 17                	jmp    801b57 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b40:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b43:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b46:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b4b:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b4f:	77 06                	ja     801b57 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b51:	0f be d2             	movsbl %dl,%edx
  801b54:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b57:	0f af ce             	imul   %esi,%ecx
  801b5a:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b5c:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b5f:	83 eb 01             	sub    $0x1,%ebx
  801b62:	83 fb 01             	cmp    $0x1,%ebx
  801b65:	7f b5                	jg     801b1c <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5f                   	pop    %edi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	8b 75 08             	mov    0x8(%ebp),%esi
  801b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b7d:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b7f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b84:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	50                   	push   %eax
  801b8b:	e8 a1 e7 ff ff       	call   800331 <sys_ipc_recv>
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	79 16                	jns    801bad <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b97:	85 f6                	test   %esi,%esi
  801b99:	74 06                	je     801ba1 <ipc_recv+0x32>
			*from_env_store = 0;
  801b9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801ba1:	85 db                	test   %ebx,%ebx
  801ba3:	74 2c                	je     801bd1 <ipc_recv+0x62>
			*perm_store = 0;
  801ba5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bab:	eb 24                	jmp    801bd1 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801bad:	85 f6                	test   %esi,%esi
  801baf:	74 0a                	je     801bbb <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801bb1:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb6:	8b 40 74             	mov    0x74(%eax),%eax
  801bb9:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801bbb:	85 db                	test   %ebx,%ebx
  801bbd:	74 0a                	je     801bc9 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801bbf:	a1 08 40 80 00       	mov    0x804008,%eax
  801bc4:	8b 40 78             	mov    0x78(%eax),%eax
  801bc7:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bc9:	a1 08 40 80 00       	mov    0x804008,%eax
  801bce:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	57                   	push   %edi
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801be4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bea:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bf1:	0f 44 d8             	cmove  %eax,%ebx
  801bf4:	eb 1e                	jmp    801c14 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bf6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf9:	74 14                	je     801c0f <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bfb:	83 ec 04             	sub    $0x4,%esp
  801bfe:	68 c0 23 80 00       	push   $0x8023c0
  801c03:	6a 44                	push   $0x44
  801c05:	68 ec 23 80 00       	push   $0x8023ec
  801c0a:	e8 95 f4 ff ff       	call   8010a4 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c0f:	e8 4e e5 ff ff       	call   800162 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c14:	ff 75 14             	pushl  0x14(%ebp)
  801c17:	53                   	push   %ebx
  801c18:	56                   	push   %esi
  801c19:	57                   	push   %edi
  801c1a:	e8 ef e6 ff ff       	call   80030e <sys_ipc_try_send>
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 d0                	js     801bf6 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c39:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c3c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c42:	8b 52 50             	mov    0x50(%edx),%edx
  801c45:	39 ca                	cmp    %ecx,%edx
  801c47:	75 0d                	jne    801c56 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c51:	8b 40 48             	mov    0x48(%eax),%eax
  801c54:	eb 0f                	jmp    801c65 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c5e:	75 d9                	jne    801c39 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c6d:	89 d0                	mov    %edx,%eax
  801c6f:	c1 e8 16             	shr    $0x16,%eax
  801c72:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c7e:	f6 c1 01             	test   $0x1,%cl
  801c81:	74 1d                	je     801ca0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c83:	c1 ea 0c             	shr    $0xc,%edx
  801c86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c8d:	f6 c2 01             	test   $0x1,%dl
  801c90:	74 0e                	je     801ca0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c92:	c1 ea 0c             	shr    $0xc,%edx
  801c95:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c9c:	ef 
  801c9d:	0f b7 c0             	movzwl %ax,%eax
}
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__udivdi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801cbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 f6                	test   %esi,%esi
  801cc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ccd:	89 ca                	mov    %ecx,%edx
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	75 3d                	jne    801d10 <__udivdi3+0x60>
  801cd3:	39 cf                	cmp    %ecx,%edi
  801cd5:	0f 87 c5 00 00 00    	ja     801da0 <__udivdi3+0xf0>
  801cdb:	85 ff                	test   %edi,%edi
  801cdd:	89 fd                	mov    %edi,%ebp
  801cdf:	75 0b                	jne    801cec <__udivdi3+0x3c>
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	31 d2                	xor    %edx,%edx
  801ce8:	f7 f7                	div    %edi
  801cea:	89 c5                	mov    %eax,%ebp
  801cec:	89 c8                	mov    %ecx,%eax
  801cee:	31 d2                	xor    %edx,%edx
  801cf0:	f7 f5                	div    %ebp
  801cf2:	89 c1                	mov    %eax,%ecx
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	89 cf                	mov    %ecx,%edi
  801cf8:	f7 f5                	div    %ebp
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	89 d8                	mov    %ebx,%eax
  801cfe:	89 fa                	mov    %edi,%edx
  801d00:	83 c4 1c             	add    $0x1c,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
  801d08:	90                   	nop
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	39 ce                	cmp    %ecx,%esi
  801d12:	77 74                	ja     801d88 <__udivdi3+0xd8>
  801d14:	0f bd fe             	bsr    %esi,%edi
  801d17:	83 f7 1f             	xor    $0x1f,%edi
  801d1a:	0f 84 98 00 00 00    	je     801db8 <__udivdi3+0x108>
  801d20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	89 c5                	mov    %eax,%ebp
  801d29:	29 fb                	sub    %edi,%ebx
  801d2b:	d3 e6                	shl    %cl,%esi
  801d2d:	89 d9                	mov    %ebx,%ecx
  801d2f:	d3 ed                	shr    %cl,%ebp
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	d3 e0                	shl    %cl,%eax
  801d35:	09 ee                	or     %ebp,%esi
  801d37:	89 d9                	mov    %ebx,%ecx
  801d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3d:	89 d5                	mov    %edx,%ebp
  801d3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d43:	d3 ed                	shr    %cl,%ebp
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e2                	shl    %cl,%edx
  801d49:	89 d9                	mov    %ebx,%ecx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	09 c2                	or     %eax,%edx
  801d4f:	89 d0                	mov    %edx,%eax
  801d51:	89 ea                	mov    %ebp,%edx
  801d53:	f7 f6                	div    %esi
  801d55:	89 d5                	mov    %edx,%ebp
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	f7 64 24 0c          	mull   0xc(%esp)
  801d5d:	39 d5                	cmp    %edx,%ebp
  801d5f:	72 10                	jb     801d71 <__udivdi3+0xc1>
  801d61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d65:	89 f9                	mov    %edi,%ecx
  801d67:	d3 e6                	shl    %cl,%esi
  801d69:	39 c6                	cmp    %eax,%esi
  801d6b:	73 07                	jae    801d74 <__udivdi3+0xc4>
  801d6d:	39 d5                	cmp    %edx,%ebp
  801d6f:	75 03                	jne    801d74 <__udivdi3+0xc4>
  801d71:	83 eb 01             	sub    $0x1,%ebx
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 d8                	mov    %ebx,%eax
  801d78:	89 fa                	mov    %edi,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	31 ff                	xor    %edi,%edi
  801d8a:	31 db                	xor    %ebx,%ebx
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	89 fa                	mov    %edi,%edx
  801d90:	83 c4 1c             	add    $0x1c,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
  801d98:	90                   	nop
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	89 d8                	mov    %ebx,%eax
  801da2:	f7 f7                	div    %edi
  801da4:	31 ff                	xor    %edi,%edi
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 fa                	mov    %edi,%edx
  801dac:	83 c4 1c             	add    $0x1c,%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5f                   	pop    %edi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	39 ce                	cmp    %ecx,%esi
  801dba:	72 0c                	jb     801dc8 <__udivdi3+0x118>
  801dbc:	31 db                	xor    %ebx,%ebx
  801dbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801dc2:	0f 87 34 ff ff ff    	ja     801cfc <__udivdi3+0x4c>
  801dc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dcd:	e9 2a ff ff ff       	jmp    801cfc <__udivdi3+0x4c>
  801dd2:	66 90                	xchg   %ax,%ax
  801dd4:	66 90                	xchg   %ax,%ax
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <__umoddi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	83 ec 1c             	sub    $0x1c,%esp
  801de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801deb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801def:	8b 74 24 34          	mov    0x34(%esp),%esi
  801df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801df7:	85 d2                	test   %edx,%edx
  801df9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e01:	89 f3                	mov    %esi,%ebx
  801e03:	89 3c 24             	mov    %edi,(%esp)
  801e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e0a:	75 1c                	jne    801e28 <__umoddi3+0x48>
  801e0c:	39 f7                	cmp    %esi,%edi
  801e0e:	76 50                	jbe    801e60 <__umoddi3+0x80>
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	f7 f7                	div    %edi
  801e16:	89 d0                	mov    %edx,%eax
  801e18:	31 d2                	xor    %edx,%edx
  801e1a:	83 c4 1c             	add    $0x1c,%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	39 f2                	cmp    %esi,%edx
  801e2a:	89 d0                	mov    %edx,%eax
  801e2c:	77 52                	ja     801e80 <__umoddi3+0xa0>
  801e2e:	0f bd ea             	bsr    %edx,%ebp
  801e31:	83 f5 1f             	xor    $0x1f,%ebp
  801e34:	75 5a                	jne    801e90 <__umoddi3+0xb0>
  801e36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e3a:	0f 82 e0 00 00 00    	jb     801f20 <__umoddi3+0x140>
  801e40:	39 0c 24             	cmp    %ecx,(%esp)
  801e43:	0f 86 d7 00 00 00    	jbe    801f20 <__umoddi3+0x140>
  801e49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e51:	83 c4 1c             	add    $0x1c,%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    
  801e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e60:	85 ff                	test   %edi,%edi
  801e62:	89 fd                	mov    %edi,%ebp
  801e64:	75 0b                	jne    801e71 <__umoddi3+0x91>
  801e66:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6b:	31 d2                	xor    %edx,%edx
  801e6d:	f7 f7                	div    %edi
  801e6f:	89 c5                	mov    %eax,%ebp
  801e71:	89 f0                	mov    %esi,%eax
  801e73:	31 d2                	xor    %edx,%edx
  801e75:	f7 f5                	div    %ebp
  801e77:	89 c8                	mov    %ecx,%eax
  801e79:	f7 f5                	div    %ebp
  801e7b:	89 d0                	mov    %edx,%eax
  801e7d:	eb 99                	jmp    801e18 <__umoddi3+0x38>
  801e7f:	90                   	nop
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	83 c4 1c             	add    $0x1c,%esp
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5f                   	pop    %edi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    
  801e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e90:	8b 34 24             	mov    (%esp),%esi
  801e93:	bf 20 00 00 00       	mov    $0x20,%edi
  801e98:	89 e9                	mov    %ebp,%ecx
  801e9a:	29 ef                	sub    %ebp,%edi
  801e9c:	d3 e0                	shl    %cl,%eax
  801e9e:	89 f9                	mov    %edi,%ecx
  801ea0:	89 f2                	mov    %esi,%edx
  801ea2:	d3 ea                	shr    %cl,%edx
  801ea4:	89 e9                	mov    %ebp,%ecx
  801ea6:	09 c2                	or     %eax,%edx
  801ea8:	89 d8                	mov    %ebx,%eax
  801eaa:	89 14 24             	mov    %edx,(%esp)
  801ead:	89 f2                	mov    %esi,%edx
  801eaf:	d3 e2                	shl    %cl,%edx
  801eb1:	89 f9                	mov    %edi,%ecx
  801eb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ebb:	d3 e8                	shr    %cl,%eax
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	89 c6                	mov    %eax,%esi
  801ec1:	d3 e3                	shl    %cl,%ebx
  801ec3:	89 f9                	mov    %edi,%ecx
  801ec5:	89 d0                	mov    %edx,%eax
  801ec7:	d3 e8                	shr    %cl,%eax
  801ec9:	89 e9                	mov    %ebp,%ecx
  801ecb:	09 d8                	or     %ebx,%eax
  801ecd:	89 d3                	mov    %edx,%ebx
  801ecf:	89 f2                	mov    %esi,%edx
  801ed1:	f7 34 24             	divl   (%esp)
  801ed4:	89 d6                	mov    %edx,%esi
  801ed6:	d3 e3                	shl    %cl,%ebx
  801ed8:	f7 64 24 04          	mull   0x4(%esp)
  801edc:	39 d6                	cmp    %edx,%esi
  801ede:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee2:	89 d1                	mov    %edx,%ecx
  801ee4:	89 c3                	mov    %eax,%ebx
  801ee6:	72 08                	jb     801ef0 <__umoddi3+0x110>
  801ee8:	75 11                	jne    801efb <__umoddi3+0x11b>
  801eea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801eee:	73 0b                	jae    801efb <__umoddi3+0x11b>
  801ef0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ef4:	1b 14 24             	sbb    (%esp),%edx
  801ef7:	89 d1                	mov    %edx,%ecx
  801ef9:	89 c3                	mov    %eax,%ebx
  801efb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eff:	29 da                	sub    %ebx,%edx
  801f01:	19 ce                	sbb    %ecx,%esi
  801f03:	89 f9                	mov    %edi,%ecx
  801f05:	89 f0                	mov    %esi,%eax
  801f07:	d3 e0                	shl    %cl,%eax
  801f09:	89 e9                	mov    %ebp,%ecx
  801f0b:	d3 ea                	shr    %cl,%edx
  801f0d:	89 e9                	mov    %ebp,%ecx
  801f0f:	d3 ee                	shr    %cl,%esi
  801f11:	09 d0                	or     %edx,%eax
  801f13:	89 f2                	mov    %esi,%edx
  801f15:	83 c4 1c             	add    $0x1c,%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
  801f1d:	8d 76 00             	lea    0x0(%esi),%esi
  801f20:	29 f9                	sub    %edi,%ecx
  801f22:	19 d6                	sbb    %edx,%esi
  801f24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f2c:	e9 18 ff ff ff       	jmp    801e49 <__umoddi3+0x69>
