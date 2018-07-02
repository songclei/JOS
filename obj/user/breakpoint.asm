
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 87 04 00 00       	call   800511 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 2a 1f 80 00       	push   $0x801f2a
  800103:	6a 23                	push   $0x23
  800105:	68 47 1f 80 00       	push   $0x801f47
  80010a:	e8 69 0f 00 00       	call   801078 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 2a 1f 80 00       	push   $0x801f2a
  800184:	6a 23                	push   $0x23
  800186:	68 47 1f 80 00       	push   $0x801f47
  80018b:	e8 e8 0e 00 00       	call   801078 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 2a 1f 80 00       	push   $0x801f2a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 47 1f 80 00       	push   $0x801f47
  8001cd:	e8 a6 0e 00 00       	call   801078 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 2a 1f 80 00       	push   $0x801f2a
  800208:	6a 23                	push   $0x23
  80020a:	68 47 1f 80 00       	push   $0x801f47
  80020f:	e8 64 0e 00 00       	call   801078 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 2a 1f 80 00       	push   $0x801f2a
  80024a:	6a 23                	push   $0x23
  80024c:	68 47 1f 80 00       	push   $0x801f47
  800251:	e8 22 0e 00 00       	call   801078 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 0a                	push   $0xa
  800287:	68 2a 1f 80 00       	push   $0x801f2a
  80028c:	6a 23                	push   $0x23
  80028e:	68 47 1f 80 00       	push   $0x801f47
  800293:	e8 e0 0d 00 00       	call   801078 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 09                	push   $0x9
  8002c9:	68 2a 1f 80 00       	push   $0x801f2a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 47 1f 80 00       	push   $0x801f47
  8002d5:	e8 9e 0d 00 00       	call   801078 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 2a 1f 80 00       	push   $0x801f2a
  800332:	6a 23                	push   $0x23
  800334:	68 47 1f 80 00       	push   $0x801f47
  800339:	e8 3a 0d 00 00       	call   801078 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 11                	je     80039a <fd_alloc+0x2d>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	75 09                	jne    8003a3 <fd_alloc+0x36>
			*fd_store = fd;
  80039a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039c:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a1:	eb 17                	jmp    8003ba <fd_alloc+0x4d>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 c9                	jne    800378 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	eb 13                	jmp    800410 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb 0c                	jmp    800410 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb 05                	jmp    800410 <fd_lookup+0x54>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	eb 13                	jmp    800435 <dev_lookup+0x23>
  800422:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	75 0c                	jne    800435 <dev_lookup+0x23>
			*dev = devtab[i];
  800429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 2e                	jmp    800463 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 e7                	jne    800422 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 08 40 80 00       	mov    0x804008,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 58 1f 80 00       	push   $0x801f58
  80044d:	e8 ff 0c 00 00       	call   801151 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 10             	sub    $0x10,%esp
  80046d:	8b 75 08             	mov    0x8(%ebp),%esi
  800470:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047d:	c1 e8 0c             	shr    $0xc,%eax
  800480:	50                   	push   %eax
  800481:	e8 36 ff ff ff       	call   8003bc <fd_lookup>
  800486:	83 c4 08             	add    $0x8,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	78 05                	js     800492 <fd_close+0x2d>
	    || fd != fd2) 
  80048d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800490:	74 0c                	je     80049e <fd_close+0x39>
		return (must_exist ? r : 0); 
  800492:	84 db                	test   %bl,%bl
  800494:	ba 00 00 00 00       	mov    $0x0,%edx
  800499:	0f 44 c2             	cmove  %edx,%eax
  80049c:	eb 41                	jmp    8004df <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a4:	50                   	push   %eax
  8004a5:	ff 36                	pushl  (%esi)
  8004a7:	e8 66 ff ff ff       	call   800412 <dev_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 1a                	js     8004cf <fd_close+0x6a>
		if (dev->dev_close) 
  8004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004bb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	74 0b                	je     8004cf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c4:	83 ec 0c             	sub    $0xc,%esp
  8004c7:	56                   	push   %esi
  8004c8:	ff d0                	call   *%eax
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	6a 00                	push   $0x0
  8004d5:	e8 00 fd ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	89 d8                	mov    %ebx,%eax
}
  8004df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e2:	5b                   	pop    %ebx
  8004e3:	5e                   	pop    %esi
  8004e4:	5d                   	pop    %ebp
  8004e5:	c3                   	ret    

008004e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 c4 fe ff ff       	call   8003bc <fd_lookup>
  8004f8:	83 c4 08             	add    $0x8,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 10                	js     80050f <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	6a 01                	push   $0x1
  800504:	ff 75 f4             	pushl  -0xc(%ebp)
  800507:	e8 59 ff ff ff       	call   800465 <fd_close>
  80050c:	83 c4 10             	add    $0x10,%esp
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <close_all>:

void
close_all(void)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	53                   	push   %ebx
  800515:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	53                   	push   %ebx
  800521:	e8 c0 ff ff ff       	call   8004e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	83 c3 01             	add    $0x1,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	83 fb 20             	cmp    $0x20,%ebx
  80052f:	75 ec                	jne    80051d <close_all+0xc>
		close(i);
}
  800531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
  80053c:	83 ec 2c             	sub    $0x2c,%esp
  80053f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800542:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 6e fe ff ff       	call   8003bc <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	0f 88 c1 00 00 00    	js     80061a <dup+0xe4>
		return r;
	close(newfdnum);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	56                   	push   %esi
  80055d:	e8 84 ff ff ff       	call   8004e6 <close>

	newfd = INDEX2FD(newfdnum);
  800562:	89 f3                	mov    %esi,%ebx
  800564:	c1 e3 0c             	shl    $0xc,%ebx
  800567:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056d:	83 c4 04             	add    $0x4,%esp
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	e8 de fd ff ff       	call   800356 <fd2data>
  800578:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057a:	89 1c 24             	mov    %ebx,(%esp)
  80057d:	e8 d4 fd ff ff       	call   800356 <fd2data>
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800588:	89 f8                	mov    %edi,%eax
  80058a:	c1 e8 16             	shr    $0x16,%eax
  80058d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800594:	a8 01                	test   $0x1,%al
  800596:	74 37                	je     8005cf <dup+0x99>
  800598:	89 f8                	mov    %edi,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a4:	f6 c2 01             	test   $0x1,%dl
  8005a7:	74 26                	je     8005cf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bc:	6a 00                	push   $0x0
  8005be:	57                   	push   %edi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 d2 fb ff ff       	call   800198 <sys_page_map>
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 2e                	js     8005fd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	53                   	push   %ebx
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 a6 fb ff ff       	call   800198 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	79 1d                	jns    80061a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 00                	push   $0x0
  800603:	e8 d2 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800608:	83 c4 08             	add    $0x8,%esp
  80060b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060e:	6a 00                	push   $0x0
  800610:	e8 c5 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	89 f8                	mov    %edi,%eax
}
  80061a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061d:	5b                   	pop    %ebx
  80061e:	5e                   	pop    %esi
  80061f:	5f                   	pop    %edi
  800620:	5d                   	pop    %ebp
  800621:	c3                   	ret    

00800622 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800622:	55                   	push   %ebp
  800623:	89 e5                	mov    %esp,%ebp
  800625:	53                   	push   %ebx
  800626:	83 ec 14             	sub    $0x14,%esp
  800629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	e8 86 fd ff ff       	call   8003bc <fd_lookup>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	89 c2                	mov    %eax,%edx
  80063b:	85 c0                	test   %eax,%eax
  80063d:	78 6d                	js     8006ac <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800645:	50                   	push   %eax
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	ff 30                	pushl  (%eax)
  80064b:	e8 c2 fd ff ff       	call   800412 <dev_lookup>
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	85 c0                	test   %eax,%eax
  800655:	78 4c                	js     8006a3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800657:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065a:	8b 42 08             	mov    0x8(%edx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	75 21                	jne    800686 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 08 40 80 00       	mov    0x804008,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 99 1f 80 00       	push   $0x801f99
  800677:	e8 d5 0a 00 00       	call   801151 <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800684:	eb 26                	jmp    8006ac <read+0x8a>
	}
	if (!dev->dev_read)
  800686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800689:	8b 40 08             	mov    0x8(%eax),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 17                	je     8006a7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 10             	pushl  0x10(%ebp)
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	52                   	push   %edx
  80069a:	ff d0                	call   *%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb 09                	jmp    8006ac <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a3:	89 c2                	mov    %eax,%edx
  8006a5:	eb 05                	jmp    8006ac <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ac:	89 d0                	mov    %edx,%eax
  8006ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b1:	c9                   	leave  
  8006b2:	c3                   	ret    

008006b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 21                	jmp    8006ea <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 45 ff ff ff       	call   800622 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 10                	js     8006f4 <readn+0x41>
			return m;
		if (m == 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 0a                	je     8006f2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e8:	01 c3                	add    %eax,%ebx
  8006ea:	39 f3                	cmp    %esi,%ebx
  8006ec:	72 db                	jb     8006c9 <readn+0x16>
  8006ee:	89 d8                	mov    %ebx,%eax
  8006f0:	eb 02                	jmp    8006f4 <readn+0x41>
  8006f2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ac fc ff ff       	call   8003bc <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	89 c2                	mov    %eax,%edx
  800715:	85 c0                	test   %eax,%eax
  800717:	78 68                	js     800781 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 e8 fc ff ff       	call   800412 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 47                	js     800778 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	75 21                	jne    80075b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 08 40 80 00       	mov    0x804008,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 b5 1f 80 00       	push   $0x801fb5
  80074c:	e8 00 0a 00 00       	call   801151 <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800759:	eb 26                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075e:	8b 52 0c             	mov    0xc(%edx),%edx
  800761:	85 d2                	test   %edx,%edx
  800763:	74 17                	je     80077c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	50                   	push   %eax
  80076f:	ff d2                	call   *%edx
  800771:	89 c2                	mov    %eax,%edx
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb 09                	jmp    800781 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800778:	89 c2                	mov    %eax,%edx
  80077a:	eb 05                	jmp    800781 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800781:	89 d0                	mov    %edx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <seek>:

int
seek(int fdnum, off_t offset)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 08             	pushl  0x8(%ebp)
  800795:	e8 22 fc ff ff       	call   8003bc <fd_lookup>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 0e                	js     8007af <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 14             	sub    $0x14,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 f7 fb ff ff       	call   8003bc <fd_lookup>
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 65                	js     800833 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	ff 30                	pushl  (%eax)
  8007da:	e8 33 fc ff ff       	call   800412 <dev_lookup>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	78 44                	js     80082a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ed:	75 21                	jne    800810 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ef:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 78 1f 80 00       	push   $0x801f78
  800801:	e8 4b 09 00 00       	call   801151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080e:	eb 23                	jmp    800833 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 14                	je     80082e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	89 c2                	mov    %eax,%edx
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	eb 09                	jmp    800833 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	eb 05                	jmp    800833 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800833:	89 d0                	mov    %edx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 6c fb ff ff       	call   8003bc <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	89 c2                	mov    %eax,%edx
  800855:	85 c0                	test   %eax,%eax
  800857:	78 58                	js     8008b1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	50                   	push   %eax
  800860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800863:	ff 30                	pushl  (%eax)
  800865:	e8 a8 fb ff ff       	call   800412 <dev_lookup>
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	85 c0                	test   %eax,%eax
  80086f:	78 37                	js     8008a8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800874:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800878:	74 32                	je     8008ac <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800884:	00 00 00 
	stat->st_isdir = 0;
  800887:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088e:	00 00 00 
	stat->st_dev = dev;
  800891:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	ff 75 f0             	pushl  -0x10(%ebp)
  80089e:	ff 50 14             	call   *0x14(%eax)
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	6a 00                	push   $0x0
  8008c2:	ff 75 08             	pushl  0x8(%ebp)
  8008c5:	e8 2b 02 00 00       	call   800af5 <open>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 1b                	js     8008ee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	ff 75 0c             	pushl  0xc(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	e8 5b ff ff ff       	call   80083a <fstat>
  8008df:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 fd fb ff ff       	call   8004e6 <close>
	return r;
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 f0                	mov    %esi,%eax
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	89 c6                	mov    %eax,%esi
  8008fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800905:	75 12                	jne    800919 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 f1 12 00 00       	call   801c02 <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800919:	6a 07                	push   $0x7
  80091b:	68 00 50 80 00       	push   $0x805000
  800920:	56                   	push   %esi
  800921:	ff 35 00 40 80 00    	pushl  0x804000
  800927:	e8 80 12 00 00       	call   801bac <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80092c:	83 c4 0c             	add    $0xc,%esp
  80092f:	6a 00                	push   $0x0
  800931:	53                   	push   %ebx
  800932:	6a 00                	push   $0x0
  800934:	e8 0a 12 00 00       	call   801b43 <ipc_recv>
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 02 00 00 00       	mov    $0x2,%eax
  800963:	e8 8d ff ff ff       	call   8008f5 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 6b ff ff ff       	call   8008f5 <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	83 ec 04             	sub    $0x4,%esp
  800993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ab:	e8 45 ff ff ff       	call   8008f5 <fsipc>
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 2c                	js     8009e0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	68 00 50 80 00       	push   $0x805000
  8009bc:	53                   	push   %ebx
  8009bd:	e8 c3 0d 00 00       	call   801785 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cd:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 08             	sub    $0x8,%esp
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f4:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8009f9:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 40 0c             	mov    0xc(%eax),%eax
  800a02:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a07:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0d:	53                   	push   %ebx
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	68 08 50 80 00       	push   $0x805008
  800a16:	e8 fc 0e 00 00       	call   801917 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 04 00 00 00       	mov    $0x4,%eax
  800a25:	e8 cb fe ff ff       	call   8008f5 <fsipc>
  800a2a:	83 c4 10             	add    $0x10,%esp
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	78 3d                	js     800a6e <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a31:	39 d8                	cmp    %ebx,%eax
  800a33:	76 19                	jbe    800a4e <devfile_write+0x69>
  800a35:	68 e4 1f 80 00       	push   $0x801fe4
  800a3a:	68 eb 1f 80 00       	push   $0x801feb
  800a3f:	68 9f 00 00 00       	push   $0x9f
  800a44:	68 00 20 80 00       	push   $0x802000
  800a49:	e8 2a 06 00 00       	call   801078 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a4e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a53:	76 19                	jbe    800a6e <devfile_write+0x89>
  800a55:	68 18 20 80 00       	push   $0x802018
  800a5a:	68 eb 1f 80 00       	push   $0x801feb
  800a5f:	68 a0 00 00 00       	push   $0xa0
  800a64:	68 00 20 80 00       	push   $0x802000
  800a69:	e8 0a 06 00 00       	call   801078 <_panic>

	return r;
}
  800a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a81:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a86:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 03 00 00 00       	mov    $0x3,%eax
  800a96:	e8 5a fe ff ff       	call   8008f5 <fsipc>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	78 4b                	js     800aec <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 16                	jae    800abb <devfile_read+0x48>
  800aa5:	68 e4 1f 80 00       	push   $0x801fe4
  800aaa:	68 eb 1f 80 00       	push   $0x801feb
  800aaf:	6a 7e                	push   $0x7e
  800ab1:	68 00 20 80 00       	push   $0x802000
  800ab6:	e8 bd 05 00 00       	call   801078 <_panic>
	assert(r <= PGSIZE);
  800abb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac0:	7e 16                	jle    800ad8 <devfile_read+0x65>
  800ac2:	68 0b 20 80 00       	push   $0x80200b
  800ac7:	68 eb 1f 80 00       	push   $0x801feb
  800acc:	6a 7f                	push   $0x7f
  800ace:	68 00 20 80 00       	push   $0x802000
  800ad3:	e8 a0 05 00 00       	call   801078 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad8:	83 ec 04             	sub    $0x4,%esp
  800adb:	50                   	push   %eax
  800adc:	68 00 50 80 00       	push   $0x805000
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	e8 2e 0e 00 00       	call   801917 <memmove>
	return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
}
  800aec:	89 d8                	mov    %ebx,%eax
  800aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	83 ec 20             	sub    $0x20,%esp
  800afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aff:	53                   	push   %ebx
  800b00:	e8 47 0c 00 00       	call   80174c <strlen>
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0d:	7f 67                	jg     800b76 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b15:	50                   	push   %eax
  800b16:	e8 52 f8 ff ff       	call   80036d <fd_alloc>
  800b1b:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 57                	js     800b7b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	53                   	push   %ebx
  800b28:	68 00 50 80 00       	push   $0x805000
  800b2d:	e8 53 0c 00 00       	call   801785 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	e8 ae fd ff ff       	call   8008f5 <fsipc>
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	79 14                	jns    800b64 <open+0x6f>
		fd_close(fd, 0);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	6a 00                	push   $0x0
  800b55:	ff 75 f4             	pushl  -0xc(%ebp)
  800b58:	e8 08 f9 ff ff       	call   800465 <fd_close>
		return r;
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	89 da                	mov    %ebx,%edx
  800b62:	eb 17                	jmp    800b7b <open+0x86>
	}

	return fd2num(fd);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6a:	e8 d7 f7 ff ff       	call   800346 <fd2num>
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	eb 05                	jmp    800b7b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b76:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b92:	e8 5e fd ff ff       	call   8008f5 <fsipc>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	ff 75 08             	pushl  0x8(%ebp)
  800ba7:	e8 aa f7 ff ff       	call   800356 <fd2data>
  800bac:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bae:	83 c4 08             	add    $0x8,%esp
  800bb1:	68 45 20 80 00       	push   $0x802045
  800bb6:	53                   	push   %ebx
  800bb7:	e8 c9 0b 00 00       	call   801785 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbc:	8b 46 04             	mov    0x4(%esi),%eax
  800bbf:	2b 06                	sub    (%esi),%eax
  800bc1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bce:	00 00 00 
	stat->st_dev = &devpipe;
  800bd1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd8:	30 80 00 
	return 0;
}
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800be0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf1:	53                   	push   %ebx
  800bf2:	6a 00                	push   $0x0
  800bf4:	e8 e1 f5 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf9:	89 1c 24             	mov    %ebx,(%esp)
  800bfc:	e8 55 f7 ff ff       	call   800356 <fd2data>
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 00                	push   $0x0
  800c07:	e8 ce f5 ff ff       	call   8001da <sys_page_unmap>
}
  800c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 1c             	sub    $0x1c,%esp
  800c1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c1f:	a1 08 40 80 00       	mov    0x804008,%eax
  800c24:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2d:	e8 09 10 00 00       	call   801c3b <pageref>
  800c32:	89 c3                	mov    %eax,%ebx
  800c34:	89 3c 24             	mov    %edi,(%esp)
  800c37:	e8 ff 0f 00 00       	call   801c3b <pageref>
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	39 c3                	cmp    %eax,%ebx
  800c41:	0f 94 c1             	sete   %cl
  800c44:	0f b6 c9             	movzbl %cl,%ecx
  800c47:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c50:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c53:	39 ce                	cmp    %ecx,%esi
  800c55:	74 1b                	je     800c72 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c57:	39 c3                	cmp    %eax,%ebx
  800c59:	75 c4                	jne    800c1f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5b:	8b 42 58             	mov    0x58(%edx),%eax
  800c5e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c61:	50                   	push   %eax
  800c62:	56                   	push   %esi
  800c63:	68 4c 20 80 00       	push   $0x80204c
  800c68:	e8 e4 04 00 00       	call   801151 <cprintf>
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	eb ad                	jmp    800c1f <_pipeisclosed+0xe>
	}
}
  800c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 28             	sub    $0x28,%esp
  800c86:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c89:	56                   	push   %esi
  800c8a:	e8 c7 f6 ff ff       	call   800356 <fd2data>
  800c8f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	bf 00 00 00 00       	mov    $0x0,%edi
  800c99:	eb 4b                	jmp    800ce6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9b:	89 da                	mov    %ebx,%edx
  800c9d:	89 f0                	mov    %esi,%eax
  800c9f:	e8 6d ff ff ff       	call   800c11 <_pipeisclosed>
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	75 48                	jne    800cf0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca8:	e8 89 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cad:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb0:	8b 0b                	mov    (%ebx),%ecx
  800cb2:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb5:	39 d0                	cmp    %edx,%eax
  800cb7:	73 e2                	jae    800c9b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc3:	89 c2                	mov    %eax,%edx
  800cc5:	c1 fa 1f             	sar    $0x1f,%edx
  800cc8:	89 d1                	mov    %edx,%ecx
  800cca:	c1 e9 1b             	shr    $0x1b,%ecx
  800ccd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd0:	83 e2 1f             	and    $0x1f,%edx
  800cd3:	29 ca                	sub    %ecx,%edx
  800cd5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cdd:	83 c0 01             	add    $0x1,%eax
  800ce0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce3:	83 c7 01             	add    $0x1,%edi
  800ce6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce9:	75 c2                	jne    800cad <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ceb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cee:	eb 05                	jmp    800cf5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 18             	sub    $0x18,%esp
  800d06:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d09:	57                   	push   %edi
  800d0a:	e8 47 f6 ff ff       	call   800356 <fd2data>
  800d0f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	eb 3d                	jmp    800d58 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1b:	85 db                	test   %ebx,%ebx
  800d1d:	74 04                	je     800d23 <devpipe_read+0x26>
				return i;
  800d1f:	89 d8                	mov    %ebx,%eax
  800d21:	eb 44                	jmp    800d67 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d23:	89 f2                	mov    %esi,%edx
  800d25:	89 f8                	mov    %edi,%eax
  800d27:	e8 e5 fe ff ff       	call   800c11 <_pipeisclosed>
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	75 32                	jne    800d62 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d30:	e8 01 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d35:	8b 06                	mov    (%esi),%eax
  800d37:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3a:	74 df                	je     800d1b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3c:	99                   	cltd   
  800d3d:	c1 ea 1b             	shr    $0x1b,%edx
  800d40:	01 d0                	add    %edx,%eax
  800d42:	83 e0 1f             	and    $0x1f,%eax
  800d45:	29 d0                	sub    %edx,%eax
  800d47:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d52:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d55:	83 c3 01             	add    $0x1,%ebx
  800d58:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5b:	75 d8                	jne    800d35 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d60:	eb 05                	jmp    800d67 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7a:	50                   	push   %eax
  800d7b:	e8 ed f5 ff ff       	call   80036d <fd_alloc>
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	89 c2                	mov    %eax,%edx
  800d85:	85 c0                	test   %eax,%eax
  800d87:	0f 88 2c 01 00 00    	js     800eb9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	68 07 04 00 00       	push   $0x407
  800d95:	ff 75 f4             	pushl  -0xc(%ebp)
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 b6 f3 ff ff       	call   800155 <sys_page_alloc>
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	89 c2                	mov    %eax,%edx
  800da4:	85 c0                	test   %eax,%eax
  800da6:	0f 88 0d 01 00 00    	js     800eb9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db2:	50                   	push   %eax
  800db3:	e8 b5 f5 ff ff       	call   80036d <fd_alloc>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	0f 88 e2 00 00 00    	js     800ea7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc5:	83 ec 04             	sub    $0x4,%esp
  800dc8:	68 07 04 00 00       	push   $0x407
  800dcd:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd0:	6a 00                	push   $0x0
  800dd2:	e8 7e f3 ff ff       	call   800155 <sys_page_alloc>
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	0f 88 c3 00 00 00    	js     800ea7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dea:	e8 67 f5 ff ff       	call   800356 <fd2data>
  800def:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df1:	83 c4 0c             	add    $0xc,%esp
  800df4:	68 07 04 00 00       	push   $0x407
  800df9:	50                   	push   %eax
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 54 f3 ff ff       	call   800155 <sys_page_alloc>
  800e01:	89 c3                	mov    %eax,%ebx
  800e03:	83 c4 10             	add    $0x10,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	0f 88 89 00 00 00    	js     800e97 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	ff 75 f0             	pushl  -0x10(%ebp)
  800e14:	e8 3d f5 ff ff       	call   800356 <fd2data>
  800e19:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e20:	50                   	push   %eax
  800e21:	6a 00                	push   $0x0
  800e23:	56                   	push   %esi
  800e24:	6a 00                	push   $0x0
  800e26:	e8 6d f3 ff ff       	call   800198 <sys_page_map>
  800e2b:	89 c3                	mov    %eax,%ebx
  800e2d:	83 c4 20             	add    $0x20,%esp
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 55                	js     800e89 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e34:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e42:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e49:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e52:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e57:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	ff 75 f4             	pushl  -0xc(%ebp)
  800e64:	e8 dd f4 ff ff       	call   800346 <fd2num>
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6e:	83 c4 04             	add    $0x4,%esp
  800e71:	ff 75 f0             	pushl  -0x10(%ebp)
  800e74:	e8 cd f4 ff ff       	call   800346 <fd2num>
  800e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	ba 00 00 00 00       	mov    $0x0,%edx
  800e87:	eb 30                	jmp    800eb9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	56                   	push   %esi
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 46 f3 ff ff       	call   8001da <sys_page_unmap>
  800e94:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 36 f3 ff ff       	call   8001da <sys_page_unmap>
  800ea4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	ff 75 f4             	pushl  -0xc(%ebp)
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 26 f3 ff ff       	call   8001da <sys_page_unmap>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb9:	89 d0                	mov    %edx,%eax
  800ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	ff 75 08             	pushl  0x8(%ebp)
  800ecf:	e8 e8 f4 ff ff       	call   8003bc <fd_lookup>
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 18                	js     800ef3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee1:	e8 70 f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eeb:	e8 21 fd ff ff       	call   800c11 <_pipeisclosed>
  800ef0:	83 c4 10             	add    $0x10,%esp
}
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f05:	68 64 20 80 00       	push   $0x802064
  800f0a:	ff 75 0c             	pushl  0xc(%ebp)
  800f0d:	e8 73 08 00 00       	call   801785 <strcpy>
	return 0;
}
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f25:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f30:	eb 2d                	jmp    800f5f <devcons_write+0x46>
		m = n - tot;
  800f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f35:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f37:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f3f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	53                   	push   %ebx
  800f46:	03 45 0c             	add    0xc(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	57                   	push   %edi
  800f4b:	e8 c7 09 00 00       	call   801917 <memmove>
		sys_cputs(buf, m);
  800f50:	83 c4 08             	add    $0x8,%esp
  800f53:	53                   	push   %ebx
  800f54:	57                   	push   %edi
  800f55:	e8 3f f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5a:	01 de                	add    %ebx,%esi
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f64:	72 cc                	jb     800f32 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7d:	74 2a                	je     800fa9 <devcons_read+0x3b>
  800f7f:	eb 05                	jmp    800f86 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f81:	e8 b0 f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f86:	e8 2c f1 ff ff       	call   8000b7 <sys_cgetc>
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	74 f2                	je     800f81 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 16                	js     800fa9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f93:	83 f8 04             	cmp    $0x4,%eax
  800f96:	74 0c                	je     800fa4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9b:	88 02                	mov    %al,(%edx)
	return 1;
  800f9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa2:	eb 05                	jmp    800fa9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb7:	6a 01                	push   $0x1
  800fb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	e8 d7 f0 ff ff       	call   800099 <sys_cputs>
}
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <getchar>:

int
getchar(void)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fcd:	6a 01                	push   $0x1
  800fcf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 48 f6 ff ff       	call   800622 <read>
	if (r < 0)
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 0f                	js     800ff0 <getchar+0x29>
		return r;
	if (r < 1)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	7e 06                	jle    800feb <getchar+0x24>
		return -E_EOF;
	return c;
  800fe5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe9:	eb 05                	jmp    800ff0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800feb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	ff 75 08             	pushl  0x8(%ebp)
  800fff:	e8 b8 f3 ff ff       	call   8003bc <fd_lookup>
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	78 11                	js     80101c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801014:	39 10                	cmp    %edx,(%eax)
  801016:	0f 94 c0             	sete   %al
  801019:	0f b6 c0             	movzbl %al,%eax
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <opencons>:

int
opencons(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	e8 40 f3 ff ff       	call   80036d <fd_alloc>
  80102d:	83 c4 10             	add    $0x10,%esp
		return r;
  801030:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	78 3e                	js     801074 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	68 07 04 00 00       	push   $0x407
  80103e:	ff 75 f4             	pushl  -0xc(%ebp)
  801041:	6a 00                	push   $0x0
  801043:	e8 0d f1 ff ff       	call   800155 <sys_page_alloc>
  801048:	83 c4 10             	add    $0x10,%esp
		return r;
  80104b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 23                	js     801074 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801051:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	50                   	push   %eax
  80106a:	e8 d7 f2 ff ff       	call   800346 <fd2num>
  80106f:	89 c2                	mov    %eax,%edx
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	89 d0                	mov    %edx,%eax
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801080:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801086:	e8 8c f0 ff ff       	call   800117 <sys_getenvid>
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	ff 75 0c             	pushl  0xc(%ebp)
  801091:	ff 75 08             	pushl  0x8(%ebp)
  801094:	56                   	push   %esi
  801095:	50                   	push   %eax
  801096:	68 70 20 80 00       	push   $0x802070
  80109b:	e8 b1 00 00 00       	call   801151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a0:	83 c4 18             	add    $0x18,%esp
  8010a3:	53                   	push   %ebx
  8010a4:	ff 75 10             	pushl  0x10(%ebp)
  8010a7:	e8 54 00 00 00       	call   801100 <vcprintf>
	cprintf("\n");
  8010ac:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010b3:	e8 99 00 00 00       	call   801151 <cprintf>
  8010b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bb:	cc                   	int3   
  8010bc:	eb fd                	jmp    8010bb <_panic+0x43>

008010be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c8:	8b 13                	mov    (%ebx),%edx
  8010ca:	8d 42 01             	lea    0x1(%edx),%eax
  8010cd:	89 03                	mov    %eax,(%ebx)
  8010cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010db:	75 1a                	jne    8010f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	68 ff 00 00 00       	push   $0xff
  8010e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e8:	50                   	push   %eax
  8010e9:	e8 ab ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801110:	00 00 00 
	b.cnt = 0;
  801113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111d:	ff 75 0c             	pushl  0xc(%ebp)
  801120:	ff 75 08             	pushl  0x8(%ebp)
  801123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	68 be 10 80 00       	push   $0x8010be
  80112f:	e8 54 01 00 00       	call   801288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801134:	83 c4 08             	add    $0x8,%esp
  801137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	e8 50 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  801149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114f:	c9                   	leave  
  801150:	c3                   	ret    

00801151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115a:	50                   	push   %eax
  80115b:	ff 75 08             	pushl  0x8(%ebp)
  80115e:	e8 9d ff ff ff       	call   801100 <vcprintf>
	va_end(ap);

	return cnt;
}
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 1c             	sub    $0x1c,%esp
  80116e:	89 c7                	mov    %eax,%edi
  801170:	89 d6                	mov    %edx,%esi
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	8b 55 0c             	mov    0xc(%ebp),%edx
  801178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118c:	39 d3                	cmp    %edx,%ebx
  80118e:	72 05                	jb     801195 <printnum+0x30>
  801190:	39 45 10             	cmp    %eax,0x10(%ebp)
  801193:	77 45                	ja     8011da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	ff 75 18             	pushl  0x18(%ebp)
  80119b:	8b 45 14             	mov    0x14(%ebp),%eax
  80119e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a1:	53                   	push   %ebx
  8011a2:	ff 75 10             	pushl  0x10(%ebp)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b4:	e8 c7 0a 00 00       	call   801c80 <__udivdi3>
  8011b9:	83 c4 18             	add    $0x18,%esp
  8011bc:	52                   	push   %edx
  8011bd:	50                   	push   %eax
  8011be:	89 f2                	mov    %esi,%edx
  8011c0:	89 f8                	mov    %edi,%eax
  8011c2:	e8 9e ff ff ff       	call   801165 <printnum>
  8011c7:	83 c4 20             	add    $0x20,%esp
  8011ca:	eb 18                	jmp    8011e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	56                   	push   %esi
  8011d0:	ff 75 18             	pushl  0x18(%ebp)
  8011d3:	ff d7                	call   *%edi
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	eb 03                	jmp    8011dd <printnum+0x78>
  8011da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011dd:	83 eb 01             	sub    $0x1,%ebx
  8011e0:	85 db                	test   %ebx,%ebx
  8011e2:	7f e8                	jg     8011cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f7:	e8 b4 0b 00 00       	call   801db0 <__umoddi3>
  8011fc:	83 c4 14             	add    $0x14,%esp
  8011ff:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  801206:	50                   	push   %eax
  801207:	ff d7                	call   *%edi
}
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801217:	83 fa 01             	cmp    $0x1,%edx
  80121a:	7e 0e                	jle    80122a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121c:	8b 10                	mov    (%eax),%edx
  80121e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801221:	89 08                	mov    %ecx,(%eax)
  801223:	8b 02                	mov    (%edx),%eax
  801225:	8b 52 04             	mov    0x4(%edx),%edx
  801228:	eb 22                	jmp    80124c <getuint+0x38>
	else if (lflag)
  80122a:	85 d2                	test   %edx,%edx
  80122c:	74 10                	je     80123e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	8d 4a 04             	lea    0x4(%edx),%ecx
  801233:	89 08                	mov    %ecx,(%eax)
  801235:	8b 02                	mov    (%edx),%eax
  801237:	ba 00 00 00 00       	mov    $0x0,%edx
  80123c:	eb 0e                	jmp    80124c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80123e:	8b 10                	mov    (%eax),%edx
  801240:	8d 4a 04             	lea    0x4(%edx),%ecx
  801243:	89 08                	mov    %ecx,(%eax)
  801245:	8b 02                	mov    (%edx),%eax
  801247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801258:	8b 10                	mov    (%eax),%edx
  80125a:	3b 50 04             	cmp    0x4(%eax),%edx
  80125d:	73 0a                	jae    801269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80125f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801262:	89 08                	mov    %ecx,(%eax)
  801264:	8b 45 08             	mov    0x8(%ebp),%eax
  801267:	88 02                	mov    %al,(%edx)
}
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801274:	50                   	push   %eax
  801275:	ff 75 10             	pushl  0x10(%ebp)
  801278:	ff 75 0c             	pushl  0xc(%ebp)
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 05 00 00 00       	call   801288 <vprintfmt>
	va_end(ap);
}
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 2c             	sub    $0x2c,%esp
  801291:	8b 75 08             	mov    0x8(%ebp),%esi
  801294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129a:	eb 12                	jmp    8012ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129c:	85 c0                	test   %eax,%eax
  80129e:	0f 84 38 04 00 00    	je     8016dc <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	53                   	push   %ebx
  8012a8:	50                   	push   %eax
  8012a9:	ff d6                	call   *%esi
  8012ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012ae:	83 c7 01             	add    $0x1,%edi
  8012b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b5:	83 f8 25             	cmp    $0x25,%eax
  8012b8:	75 e2                	jne    80129c <vprintfmt+0x14>
  8012ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d8:	eb 07                	jmp    8012e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	8d 47 01             	lea    0x1(%edi),%eax
  8012e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e7:	0f b6 07             	movzbl (%edi),%eax
  8012ea:	0f b6 c8             	movzbl %al,%ecx
  8012ed:	83 e8 23             	sub    $0x23,%eax
  8012f0:	3c 55                	cmp    $0x55,%al
  8012f2:	0f 87 c9 03 00 00    	ja     8016c1 <vprintfmt+0x439>
  8012f8:	0f b6 c0             	movzbl %al,%eax
  8012fb:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801309:	eb d6                	jmp    8012e1 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80130b:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801312:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801315:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801318:	eb 94                	jmp    8012ae <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80131a:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801321:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801327:	eb 85                	jmp    8012ae <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801329:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  801330:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801336:	e9 73 ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80133b:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801342:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801348:	e9 61 ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80134d:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801354:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80135a:	e9 4f ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80135f:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801366:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80136c:	e9 3d ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801371:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801378:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80137e:	e9 2b ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801383:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  80138a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  801390:	e9 19 ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  801395:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  80139c:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013a2:	e9 07 ff ff ff       	jmp    8012ae <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013a7:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013ae:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013b4:	e9 f5 fe ff ff       	jmp    8012ae <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013c7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013cb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013ce:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013d1:	83 fa 09             	cmp    $0x9,%edx
  8013d4:	77 3f                	ja     801415 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013d6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013d9:	eb e9                	jmp    8013c4 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013db:	8b 45 14             	mov    0x14(%ebp),%eax
  8013de:	8d 48 04             	lea    0x4(%eax),%ecx
  8013e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013e4:	8b 00                	mov    (%eax),%eax
  8013e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013ec:	eb 2d                	jmp    80141b <vprintfmt+0x193>
  8013ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f8:	0f 49 c8             	cmovns %eax,%ecx
  8013fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801401:	e9 db fe ff ff       	jmp    8012e1 <vprintfmt+0x59>
  801406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801409:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801410:	e9 cc fe ff ff       	jmp    8012e1 <vprintfmt+0x59>
  801415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801418:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80141b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141f:	0f 89 bc fe ff ff    	jns    8012e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  801425:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801432:	e9 aa fe ff ff       	jmp    8012e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801437:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80143d:	e9 9f fe ff ff       	jmp    8012e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801442:	8b 45 14             	mov    0x14(%ebp),%eax
  801445:	8d 50 04             	lea    0x4(%eax),%edx
  801448:	89 55 14             	mov    %edx,0x14(%ebp)
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	53                   	push   %ebx
  80144f:	ff 30                	pushl  (%eax)
  801451:	ff d6                	call   *%esi
			break;
  801453:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801459:	e9 50 fe ff ff       	jmp    8012ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80145e:	8b 45 14             	mov    0x14(%ebp),%eax
  801461:	8d 50 04             	lea    0x4(%eax),%edx
  801464:	89 55 14             	mov    %edx,0x14(%ebp)
  801467:	8b 00                	mov    (%eax),%eax
  801469:	99                   	cltd   
  80146a:	31 d0                	xor    %edx,%eax
  80146c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80146e:	83 f8 0f             	cmp    $0xf,%eax
  801471:	7f 0b                	jg     80147e <vprintfmt+0x1f6>
  801473:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80147a:	85 d2                	test   %edx,%edx
  80147c:	75 18                	jne    801496 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80147e:	50                   	push   %eax
  80147f:	68 ab 20 80 00       	push   $0x8020ab
  801484:	53                   	push   %ebx
  801485:	56                   	push   %esi
  801486:	e8 e0 fd ff ff       	call   80126b <printfmt>
  80148b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80148e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801491:	e9 18 fe ff ff       	jmp    8012ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801496:	52                   	push   %edx
  801497:	68 fd 1f 80 00       	push   $0x801ffd
  80149c:	53                   	push   %ebx
  80149d:	56                   	push   %esi
  80149e:	e8 c8 fd ff ff       	call   80126b <printfmt>
  8014a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a9:	e9 00 fe ff ff       	jmp    8012ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b1:	8d 50 04             	lea    0x4(%eax),%edx
  8014b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014b9:	85 ff                	test   %edi,%edi
  8014bb:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014c7:	0f 8e 94 00 00 00    	jle    801561 <vprintfmt+0x2d9>
  8014cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014d1:	0f 84 98 00 00 00    	je     80156f <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	ff 75 d0             	pushl  -0x30(%ebp)
  8014dd:	57                   	push   %edi
  8014de:	e8 81 02 00 00       	call   801764 <strnlen>
  8014e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014e6:	29 c1                	sub    %eax,%ecx
  8014e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8014f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8014f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8014fa:	eb 0f                	jmp    80150b <vprintfmt+0x283>
					putch(padc, putdat);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	53                   	push   %ebx
  801500:	ff 75 e0             	pushl  -0x20(%ebp)
  801503:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801505:	83 ef 01             	sub    $0x1,%edi
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 ff                	test   %edi,%edi
  80150d:	7f ed                	jg     8014fc <vprintfmt+0x274>
  80150f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801512:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801515:	85 c9                	test   %ecx,%ecx
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
  80151c:	0f 49 c1             	cmovns %ecx,%eax
  80151f:	29 c1                	sub    %eax,%ecx
  801521:	89 75 08             	mov    %esi,0x8(%ebp)
  801524:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80152a:	89 cb                	mov    %ecx,%ebx
  80152c:	eb 4d                	jmp    80157b <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80152e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801532:	74 1b                	je     80154f <vprintfmt+0x2c7>
  801534:	0f be c0             	movsbl %al,%eax
  801537:	83 e8 20             	sub    $0x20,%eax
  80153a:	83 f8 5e             	cmp    $0x5e,%eax
  80153d:	76 10                	jbe    80154f <vprintfmt+0x2c7>
					putch('?', putdat);
  80153f:	83 ec 08             	sub    $0x8,%esp
  801542:	ff 75 0c             	pushl  0xc(%ebp)
  801545:	6a 3f                	push   $0x3f
  801547:	ff 55 08             	call   *0x8(%ebp)
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	eb 0d                	jmp    80155c <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	52                   	push   %edx
  801556:	ff 55 08             	call   *0x8(%ebp)
  801559:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80155c:	83 eb 01             	sub    $0x1,%ebx
  80155f:	eb 1a                	jmp    80157b <vprintfmt+0x2f3>
  801561:	89 75 08             	mov    %esi,0x8(%ebp)
  801564:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80156a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80156d:	eb 0c                	jmp    80157b <vprintfmt+0x2f3>
  80156f:	89 75 08             	mov    %esi,0x8(%ebp)
  801572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80157b:	83 c7 01             	add    $0x1,%edi
  80157e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801582:	0f be d0             	movsbl %al,%edx
  801585:	85 d2                	test   %edx,%edx
  801587:	74 23                	je     8015ac <vprintfmt+0x324>
  801589:	85 f6                	test   %esi,%esi
  80158b:	78 a1                	js     80152e <vprintfmt+0x2a6>
  80158d:	83 ee 01             	sub    $0x1,%esi
  801590:	79 9c                	jns    80152e <vprintfmt+0x2a6>
  801592:	89 df                	mov    %ebx,%edi
  801594:	8b 75 08             	mov    0x8(%ebp),%esi
  801597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80159a:	eb 18                	jmp    8015b4 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	53                   	push   %ebx
  8015a0:	6a 20                	push   $0x20
  8015a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015a4:	83 ef 01             	sub    $0x1,%edi
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb 08                	jmp    8015b4 <vprintfmt+0x32c>
  8015ac:	89 df                	mov    %ebx,%edi
  8015ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b4:	85 ff                	test   %edi,%edi
  8015b6:	7f e4                	jg     80159c <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015bb:	e9 ee fc ff ff       	jmp    8012ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015c0:	83 fa 01             	cmp    $0x1,%edx
  8015c3:	7e 16                	jle    8015db <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c8:	8d 50 08             	lea    0x8(%eax),%edx
  8015cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8015ce:	8b 50 04             	mov    0x4(%eax),%edx
  8015d1:	8b 00                	mov    (%eax),%eax
  8015d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015d9:	eb 32                	jmp    80160d <vprintfmt+0x385>
	else if (lflag)
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	74 18                	je     8015f7 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015df:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e2:	8d 50 04             	lea    0x4(%eax),%edx
  8015e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8015e8:	8b 00                	mov    (%eax),%eax
  8015ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ed:	89 c1                	mov    %eax,%ecx
  8015ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8015f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015f5:	eb 16                	jmp    80160d <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8015f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fa:	8d 50 04             	lea    0x4(%eax),%edx
  8015fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801600:	8b 00                	mov    (%eax),%eax
  801602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801605:	89 c1                	mov    %eax,%ecx
  801607:	c1 f9 1f             	sar    $0x1f,%ecx
  80160a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80160d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801610:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801613:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801618:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80161c:	79 6f                	jns    80168d <vprintfmt+0x405>
				putch('-', putdat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	6a 2d                	push   $0x2d
  801624:	ff d6                	call   *%esi
				num = -(long long) num;
  801626:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801629:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80162c:	f7 d8                	neg    %eax
  80162e:	83 d2 00             	adc    $0x0,%edx
  801631:	f7 da                	neg    %edx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 55                	jmp    80168d <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801638:	8d 45 14             	lea    0x14(%ebp),%eax
  80163b:	e8 d4 fb ff ff       	call   801214 <getuint>
			base = 10;
  801640:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801645:	eb 46                	jmp    80168d <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801647:	8d 45 14             	lea    0x14(%ebp),%eax
  80164a:	e8 c5 fb ff ff       	call   801214 <getuint>
			base = 8;
  80164f:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801654:	eb 37                	jmp    80168d <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	53                   	push   %ebx
  80165a:	6a 30                	push   $0x30
  80165c:	ff d6                	call   *%esi
			putch('x', putdat);
  80165e:	83 c4 08             	add    $0x8,%esp
  801661:	53                   	push   %ebx
  801662:	6a 78                	push   $0x78
  801664:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801666:	8b 45 14             	mov    0x14(%ebp),%eax
  801669:	8d 50 04             	lea    0x4(%eax),%edx
  80166c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80166f:	8b 00                	mov    (%eax),%eax
  801671:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801676:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801679:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80167e:	eb 0d                	jmp    80168d <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801680:	8d 45 14             	lea    0x14(%ebp),%eax
  801683:	e8 8c fb ff ff       	call   801214 <getuint>
			base = 16;
  801688:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801694:	51                   	push   %ecx
  801695:	ff 75 e0             	pushl  -0x20(%ebp)
  801698:	57                   	push   %edi
  801699:	52                   	push   %edx
  80169a:	50                   	push   %eax
  80169b:	89 da                	mov    %ebx,%edx
  80169d:	89 f0                	mov    %esi,%eax
  80169f:	e8 c1 fa ff ff       	call   801165 <printnum>
			break;
  8016a4:	83 c4 20             	add    $0x20,%esp
  8016a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016aa:	e9 ff fb ff ff       	jmp    8012ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	51                   	push   %ecx
  8016b4:	ff d6                	call   *%esi
			break;
  8016b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016bc:	e9 ed fb ff ff       	jmp    8012ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	53                   	push   %ebx
  8016c5:	6a 25                	push   $0x25
  8016c7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	eb 03                	jmp    8016d1 <vprintfmt+0x449>
  8016ce:	83 ef 01             	sub    $0x1,%edi
  8016d1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016d5:	75 f7                	jne    8016ce <vprintfmt+0x446>
  8016d7:	e9 d2 fb ff ff       	jmp    8012ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5f                   	pop    %edi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	83 ec 18             	sub    $0x18,%esp
  8016ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801701:	85 c0                	test   %eax,%eax
  801703:	74 26                	je     80172b <vsnprintf+0x47>
  801705:	85 d2                	test   %edx,%edx
  801707:	7e 22                	jle    80172b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801709:	ff 75 14             	pushl  0x14(%ebp)
  80170c:	ff 75 10             	pushl  0x10(%ebp)
  80170f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	68 4e 12 80 00       	push   $0x80124e
  801718:	e8 6b fb ff ff       	call   801288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80171d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	eb 05                	jmp    801730 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80172b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80173b:	50                   	push   %eax
  80173c:	ff 75 10             	pushl  0x10(%ebp)
  80173f:	ff 75 0c             	pushl  0xc(%ebp)
  801742:	ff 75 08             	pushl  0x8(%ebp)
  801745:	e8 9a ff ff ff       	call   8016e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801752:	b8 00 00 00 00       	mov    $0x0,%eax
  801757:	eb 03                	jmp    80175c <strlen+0x10>
		n++;
  801759:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80175c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801760:	75 f7                	jne    801759 <strlen+0xd>
		n++;
	return n;
}
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	eb 03                	jmp    801777 <strnlen+0x13>
		n++;
  801774:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801777:	39 c2                	cmp    %eax,%edx
  801779:	74 08                	je     801783 <strnlen+0x1f>
  80177b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80177f:	75 f3                	jne    801774 <strnlen+0x10>
  801781:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80178f:	89 c2                	mov    %eax,%edx
  801791:	83 c2 01             	add    $0x1,%edx
  801794:	83 c1 01             	add    $0x1,%ecx
  801797:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80179b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80179e:	84 db                	test   %bl,%bl
  8017a0:	75 ef                	jne    801791 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017a2:	5b                   	pop    %ebx
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017ac:	53                   	push   %ebx
  8017ad:	e8 9a ff ff ff       	call   80174c <strlen>
  8017b2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	01 d8                	add    %ebx,%eax
  8017ba:	50                   	push   %eax
  8017bb:	e8 c5 ff ff ff       	call   801785 <strcpy>
	return dst;
}
  8017c0:	89 d8                	mov    %ebx,%eax
  8017c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    

008017c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
  8017cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8017cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d2:	89 f3                	mov    %esi,%ebx
  8017d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017d7:	89 f2                	mov    %esi,%edx
  8017d9:	eb 0f                	jmp    8017ea <strncpy+0x23>
		*dst++ = *src;
  8017db:	83 c2 01             	add    $0x1,%edx
  8017de:	0f b6 01             	movzbl (%ecx),%eax
  8017e1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017e4:	80 39 01             	cmpb   $0x1,(%ecx)
  8017e7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017ea:	39 da                	cmp    %ebx,%edx
  8017ec:	75 ed                	jne    8017db <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017ee:	89 f0                	mov    %esi,%eax
  8017f0:	5b                   	pop    %ebx
  8017f1:	5e                   	pop    %esi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	56                   	push   %esi
  8017f8:	53                   	push   %ebx
  8017f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ff:	8b 55 10             	mov    0x10(%ebp),%edx
  801802:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801804:	85 d2                	test   %edx,%edx
  801806:	74 21                	je     801829 <strlcpy+0x35>
  801808:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80180c:	89 f2                	mov    %esi,%edx
  80180e:	eb 09                	jmp    801819 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801810:	83 c2 01             	add    $0x1,%edx
  801813:	83 c1 01             	add    $0x1,%ecx
  801816:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801819:	39 c2                	cmp    %eax,%edx
  80181b:	74 09                	je     801826 <strlcpy+0x32>
  80181d:	0f b6 19             	movzbl (%ecx),%ebx
  801820:	84 db                	test   %bl,%bl
  801822:	75 ec                	jne    801810 <strlcpy+0x1c>
  801824:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801829:	29 f0                	sub    %esi,%eax
}
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801838:	eb 06                	jmp    801840 <strcmp+0x11>
		p++, q++;
  80183a:	83 c1 01             	add    $0x1,%ecx
  80183d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801840:	0f b6 01             	movzbl (%ecx),%eax
  801843:	84 c0                	test   %al,%al
  801845:	74 04                	je     80184b <strcmp+0x1c>
  801847:	3a 02                	cmp    (%edx),%al
  801849:	74 ef                	je     80183a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80184b:	0f b6 c0             	movzbl %al,%eax
  80184e:	0f b6 12             	movzbl (%edx),%edx
  801851:	29 d0                	sub    %edx,%eax
}
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	53                   	push   %ebx
  801859:	8b 45 08             	mov    0x8(%ebp),%eax
  80185c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801864:	eb 06                	jmp    80186c <strncmp+0x17>
		n--, p++, q++;
  801866:	83 c0 01             	add    $0x1,%eax
  801869:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80186c:	39 d8                	cmp    %ebx,%eax
  80186e:	74 15                	je     801885 <strncmp+0x30>
  801870:	0f b6 08             	movzbl (%eax),%ecx
  801873:	84 c9                	test   %cl,%cl
  801875:	74 04                	je     80187b <strncmp+0x26>
  801877:	3a 0a                	cmp    (%edx),%cl
  801879:	74 eb                	je     801866 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80187b:	0f b6 00             	movzbl (%eax),%eax
  80187e:	0f b6 12             	movzbl (%edx),%edx
  801881:	29 d0                	sub    %edx,%eax
  801883:	eb 05                	jmp    80188a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80188a:	5b                   	pop    %ebx
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801897:	eb 07                	jmp    8018a0 <strchr+0x13>
		if (*s == c)
  801899:	38 ca                	cmp    %cl,%dl
  80189b:	74 0f                	je     8018ac <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80189d:	83 c0 01             	add    $0x1,%eax
  8018a0:	0f b6 10             	movzbl (%eax),%edx
  8018a3:	84 d2                	test   %dl,%dl
  8018a5:	75 f2                	jne    801899 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018b8:	eb 03                	jmp    8018bd <strfind+0xf>
  8018ba:	83 c0 01             	add    $0x1,%eax
  8018bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018c0:	38 ca                	cmp    %cl,%dl
  8018c2:	74 04                	je     8018c8 <strfind+0x1a>
  8018c4:	84 d2                	test   %dl,%dl
  8018c6:	75 f2                	jne    8018ba <strfind+0xc>
			break;
	return (char *) s;
}
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	57                   	push   %edi
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018d6:	85 c9                	test   %ecx,%ecx
  8018d8:	74 36                	je     801910 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018e0:	75 28                	jne    80190a <memset+0x40>
  8018e2:	f6 c1 03             	test   $0x3,%cl
  8018e5:	75 23                	jne    80190a <memset+0x40>
		c &= 0xFF;
  8018e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018eb:	89 d3                	mov    %edx,%ebx
  8018ed:	c1 e3 08             	shl    $0x8,%ebx
  8018f0:	89 d6                	mov    %edx,%esi
  8018f2:	c1 e6 18             	shl    $0x18,%esi
  8018f5:	89 d0                	mov    %edx,%eax
  8018f7:	c1 e0 10             	shl    $0x10,%eax
  8018fa:	09 f0                	or     %esi,%eax
  8018fc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018fe:	89 d8                	mov    %ebx,%eax
  801900:	09 d0                	or     %edx,%eax
  801902:	c1 e9 02             	shr    $0x2,%ecx
  801905:	fc                   	cld    
  801906:	f3 ab                	rep stos %eax,%es:(%edi)
  801908:	eb 06                	jmp    801910 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80190a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190d:	fc                   	cld    
  80190e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801910:	89 f8                	mov    %edi,%eax
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5f                   	pop    %edi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	57                   	push   %edi
  80191b:	56                   	push   %esi
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801925:	39 c6                	cmp    %eax,%esi
  801927:	73 35                	jae    80195e <memmove+0x47>
  801929:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80192c:	39 d0                	cmp    %edx,%eax
  80192e:	73 2e                	jae    80195e <memmove+0x47>
		s += n;
		d += n;
  801930:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801933:	89 d6                	mov    %edx,%esi
  801935:	09 fe                	or     %edi,%esi
  801937:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80193d:	75 13                	jne    801952 <memmove+0x3b>
  80193f:	f6 c1 03             	test   $0x3,%cl
  801942:	75 0e                	jne    801952 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801944:	83 ef 04             	sub    $0x4,%edi
  801947:	8d 72 fc             	lea    -0x4(%edx),%esi
  80194a:	c1 e9 02             	shr    $0x2,%ecx
  80194d:	fd                   	std    
  80194e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801950:	eb 09                	jmp    80195b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801952:	83 ef 01             	sub    $0x1,%edi
  801955:	8d 72 ff             	lea    -0x1(%edx),%esi
  801958:	fd                   	std    
  801959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80195b:	fc                   	cld    
  80195c:	eb 1d                	jmp    80197b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80195e:	89 f2                	mov    %esi,%edx
  801960:	09 c2                	or     %eax,%edx
  801962:	f6 c2 03             	test   $0x3,%dl
  801965:	75 0f                	jne    801976 <memmove+0x5f>
  801967:	f6 c1 03             	test   $0x3,%cl
  80196a:	75 0a                	jne    801976 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80196c:	c1 e9 02             	shr    $0x2,%ecx
  80196f:	89 c7                	mov    %eax,%edi
  801971:	fc                   	cld    
  801972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801974:	eb 05                	jmp    80197b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801976:	89 c7                	mov    %eax,%edi
  801978:	fc                   	cld    
  801979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80197b:	5e                   	pop    %esi
  80197c:	5f                   	pop    %edi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801982:	ff 75 10             	pushl  0x10(%ebp)
  801985:	ff 75 0c             	pushl  0xc(%ebp)
  801988:	ff 75 08             	pushl  0x8(%ebp)
  80198b:	e8 87 ff ff ff       	call   801917 <memmove>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199d:	89 c6                	mov    %eax,%esi
  80199f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019a2:	eb 1a                	jmp    8019be <memcmp+0x2c>
		if (*s1 != *s2)
  8019a4:	0f b6 08             	movzbl (%eax),%ecx
  8019a7:	0f b6 1a             	movzbl (%edx),%ebx
  8019aa:	38 d9                	cmp    %bl,%cl
  8019ac:	74 0a                	je     8019b8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019ae:	0f b6 c1             	movzbl %cl,%eax
  8019b1:	0f b6 db             	movzbl %bl,%ebx
  8019b4:	29 d8                	sub    %ebx,%eax
  8019b6:	eb 0f                	jmp    8019c7 <memcmp+0x35>
		s1++, s2++;
  8019b8:	83 c0 01             	add    $0x1,%eax
  8019bb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019be:	39 f0                	cmp    %esi,%eax
  8019c0:	75 e2                	jne    8019a4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	53                   	push   %ebx
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019d2:	89 c1                	mov    %eax,%ecx
  8019d4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019d7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019db:	eb 0a                	jmp    8019e7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019dd:	0f b6 10             	movzbl (%eax),%edx
  8019e0:	39 da                	cmp    %ebx,%edx
  8019e2:	74 07                	je     8019eb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e4:	83 c0 01             	add    $0x1,%eax
  8019e7:	39 c8                	cmp    %ecx,%eax
  8019e9:	72 f2                	jb     8019dd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019eb:	5b                   	pop    %ebx
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	53                   	push   %ebx
  8019f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019fa:	eb 03                	jmp    8019ff <strtol+0x11>
		s++;
  8019fc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019ff:	0f b6 01             	movzbl (%ecx),%eax
  801a02:	3c 20                	cmp    $0x20,%al
  801a04:	74 f6                	je     8019fc <strtol+0xe>
  801a06:	3c 09                	cmp    $0x9,%al
  801a08:	74 f2                	je     8019fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a0a:	3c 2b                	cmp    $0x2b,%al
  801a0c:	75 0a                	jne    801a18 <strtol+0x2a>
		s++;
  801a0e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a11:	bf 00 00 00 00       	mov    $0x0,%edi
  801a16:	eb 11                	jmp    801a29 <strtol+0x3b>
  801a18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a1d:	3c 2d                	cmp    $0x2d,%al
  801a1f:	75 08                	jne    801a29 <strtol+0x3b>
		s++, neg = 1;
  801a21:	83 c1 01             	add    $0x1,%ecx
  801a24:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a2f:	75 15                	jne    801a46 <strtol+0x58>
  801a31:	80 39 30             	cmpb   $0x30,(%ecx)
  801a34:	75 10                	jne    801a46 <strtol+0x58>
  801a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a3a:	75 7c                	jne    801ab8 <strtol+0xca>
		s += 2, base = 16;
  801a3c:	83 c1 02             	add    $0x2,%ecx
  801a3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a44:	eb 16                	jmp    801a5c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a46:	85 db                	test   %ebx,%ebx
  801a48:	75 12                	jne    801a5c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  801a52:	75 08                	jne    801a5c <strtol+0x6e>
		s++, base = 8;
  801a54:	83 c1 01             	add    $0x1,%ecx
  801a57:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a61:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a64:	0f b6 11             	movzbl (%ecx),%edx
  801a67:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a6a:	89 f3                	mov    %esi,%ebx
  801a6c:	80 fb 09             	cmp    $0x9,%bl
  801a6f:	77 08                	ja     801a79 <strtol+0x8b>
			dig = *s - '0';
  801a71:	0f be d2             	movsbl %dl,%edx
  801a74:	83 ea 30             	sub    $0x30,%edx
  801a77:	eb 22                	jmp    801a9b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a79:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a7c:	89 f3                	mov    %esi,%ebx
  801a7e:	80 fb 19             	cmp    $0x19,%bl
  801a81:	77 08                	ja     801a8b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a83:	0f be d2             	movsbl %dl,%edx
  801a86:	83 ea 57             	sub    $0x57,%edx
  801a89:	eb 10                	jmp    801a9b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a8b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a8e:	89 f3                	mov    %esi,%ebx
  801a90:	80 fb 19             	cmp    $0x19,%bl
  801a93:	77 16                	ja     801aab <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a95:	0f be d2             	movsbl %dl,%edx
  801a98:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a9e:	7d 0b                	jge    801aab <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801aa0:	83 c1 01             	add    $0x1,%ecx
  801aa3:	0f af 45 10          	imul   0x10(%ebp),%eax
  801aa7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801aa9:	eb b9                	jmp    801a64 <strtol+0x76>

	if (endptr)
  801aab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801aaf:	74 0d                	je     801abe <strtol+0xd0>
		*endptr = (char *) s;
  801ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab4:	89 0e                	mov    %ecx,(%esi)
  801ab6:	eb 06                	jmp    801abe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ab8:	85 db                	test   %ebx,%ebx
  801aba:	74 98                	je     801a54 <strtol+0x66>
  801abc:	eb 9e                	jmp    801a5c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801abe:	89 c2                	mov    %eax,%edx
  801ac0:	f7 da                	neg    %edx
  801ac2:	85 ff                	test   %edi,%edi
  801ac4:	0f 45 c2             	cmovne %edx,%eax
}
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 04             	sub    $0x4,%esp
  801ad5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801ad8:	57                   	push   %edi
  801ad9:	e8 6e fc ff ff       	call   80174c <strlen>
  801ade:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801ae1:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801ae4:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801aee:	eb 46                	jmp    801b36 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801af0:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801af4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801af7:	80 f9 09             	cmp    $0x9,%cl
  801afa:	77 08                	ja     801b04 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801afc:	0f be d2             	movsbl %dl,%edx
  801aff:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b02:	eb 27                	jmp    801b2b <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b04:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b07:	80 f9 05             	cmp    $0x5,%cl
  801b0a:	77 08                	ja     801b14 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b0c:	0f be d2             	movsbl %dl,%edx
  801b0f:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b12:	eb 17                	jmp    801b2b <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b14:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b17:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b1f:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b23:	77 06                	ja     801b2b <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b25:	0f be d2             	movsbl %dl,%edx
  801b28:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b2b:	0f af ce             	imul   %esi,%ecx
  801b2e:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b30:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b33:	83 eb 01             	sub    $0x1,%ebx
  801b36:	83 fb 01             	cmp    $0x1,%ebx
  801b39:	7f b5                	jg     801af0 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	8b 75 08             	mov    0x8(%ebp),%esi
  801b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b51:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b53:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b58:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	50                   	push   %eax
  801b5f:	e8 a1 e7 ff ff       	call   800305 <sys_ipc_recv>
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	79 16                	jns    801b81 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b6b:	85 f6                	test   %esi,%esi
  801b6d:	74 06                	je     801b75 <ipc_recv+0x32>
			*from_env_store = 0;
  801b6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b75:	85 db                	test   %ebx,%ebx
  801b77:	74 2c                	je     801ba5 <ipc_recv+0x62>
			*perm_store = 0;
  801b79:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b7f:	eb 24                	jmp    801ba5 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b81:	85 f6                	test   %esi,%esi
  801b83:	74 0a                	je     801b8f <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b85:	a1 08 40 80 00       	mov    0x804008,%eax
  801b8a:	8b 40 74             	mov    0x74(%eax),%eax
  801b8d:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b8f:	85 db                	test   %ebx,%ebx
  801b91:	74 0a                	je     801b9d <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801b93:	a1 08 40 80 00       	mov    0x804008,%eax
  801b98:	8b 40 78             	mov    0x78(%eax),%eax
  801b9b:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801b9d:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ba5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	57                   	push   %edi
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bbe:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bc0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bc5:	0f 44 d8             	cmove  %eax,%ebx
  801bc8:	eb 1e                	jmp    801be8 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bcd:	74 14                	je     801be3 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	68 a0 23 80 00       	push   $0x8023a0
  801bd7:	6a 44                	push   $0x44
  801bd9:	68 cc 23 80 00       	push   $0x8023cc
  801bde:	e8 95 f4 ff ff       	call   801078 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801be3:	e8 4e e5 ff ff       	call   800136 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801be8:	ff 75 14             	pushl  0x14(%ebp)
  801beb:	53                   	push   %ebx
  801bec:	56                   	push   %esi
  801bed:	57                   	push   %edi
  801bee:	e8 ef e6 ff ff       	call   8002e2 <sys_ipc_try_send>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 d0                	js     801bca <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c0d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c10:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c16:	8b 52 50             	mov    0x50(%edx),%edx
  801c19:	39 ca                	cmp    %ecx,%edx
  801c1b:	75 0d                	jne    801c2a <ipc_find_env+0x28>
			return envs[i].env_id;
  801c1d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c20:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c25:	8b 40 48             	mov    0x48(%eax),%eax
  801c28:	eb 0f                	jmp    801c39 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c32:	75 d9                	jne    801c0d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c41:	89 d0                	mov    %edx,%eax
  801c43:	c1 e8 16             	shr    $0x16,%eax
  801c46:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c4d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c52:	f6 c1 01             	test   $0x1,%cl
  801c55:	74 1d                	je     801c74 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c57:	c1 ea 0c             	shr    $0xc,%edx
  801c5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c61:	f6 c2 01             	test   $0x1,%dl
  801c64:	74 0e                	je     801c74 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c66:	c1 ea 0c             	shr    $0xc,%edx
  801c69:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c70:	ef 
  801c71:	0f b7 c0             	movzwl %ax,%eax
}
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 f6                	test   %esi,%esi
  801c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9d:	89 ca                	mov    %ecx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	75 3d                	jne    801ce0 <__udivdi3+0x60>
  801ca3:	39 cf                	cmp    %ecx,%edi
  801ca5:	0f 87 c5 00 00 00    	ja     801d70 <__udivdi3+0xf0>
  801cab:	85 ff                	test   %edi,%edi
  801cad:	89 fd                	mov    %edi,%ebp
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x3c>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp
  801cbc:	89 c8                	mov    %ecx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	89 cf                	mov    %ecx,%edi
  801cc8:	f7 f5                	div    %ebp
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	77 74                	ja     801d58 <__udivdi3+0xd8>
  801ce4:	0f bd fe             	bsr    %esi,%edi
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	0f 84 98 00 00 00    	je     801d88 <__udivdi3+0x108>
  801cf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	29 fb                	sub    %edi,%ebx
  801cfb:	d3 e6                	shl    %cl,%esi
  801cfd:	89 d9                	mov    %ebx,%ecx
  801cff:	d3 ed                	shr    %cl,%ebp
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e0                	shl    %cl,%eax
  801d05:	09 ee                	or     %ebp,%esi
  801d07:	89 d9                	mov    %ebx,%ecx
  801d09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0d:	89 d5                	mov    %edx,%ebp
  801d0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d13:	d3 ed                	shr    %cl,%ebp
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e2                	shl    %cl,%edx
  801d19:	89 d9                	mov    %ebx,%ecx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	89 ea                	mov    %ebp,%edx
  801d23:	f7 f6                	div    %esi
  801d25:	89 d5                	mov    %edx,%ebp
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	f7 64 24 0c          	mull   0xc(%esp)
  801d2d:	39 d5                	cmp    %edx,%ebp
  801d2f:	72 10                	jb     801d41 <__udivdi3+0xc1>
  801d31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e6                	shl    %cl,%esi
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	73 07                	jae    801d44 <__udivdi3+0xc4>
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	75 03                	jne    801d44 <__udivdi3+0xc4>
  801d41:	83 eb 01             	sub    $0x1,%ebx
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	31 ff                	xor    %edi,%edi
  801d5a:	31 db                	xor    %ebx,%ebx
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	89 fa                	mov    %edi,%edx
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
  801d68:	90                   	nop
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	f7 f7                	div    %edi
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 fa                	mov    %edi,%edx
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	39 ce                	cmp    %ecx,%esi
  801d8a:	72 0c                	jb     801d98 <__udivdi3+0x118>
  801d8c:	31 db                	xor    %ebx,%ebx
  801d8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d92:	0f 87 34 ff ff ff    	ja     801ccc <__udivdi3+0x4c>
  801d98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d9d:	e9 2a ff ff ff       	jmp    801ccc <__udivdi3+0x4c>
  801da2:	66 90                	xchg   %ax,%ax
  801da4:	66 90                	xchg   %ax,%ax
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	66 90                	xchg   %ax,%ax
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 d2                	test   %edx,%edx
  801dc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd1:	89 f3                	mov    %esi,%ebx
  801dd3:	89 3c 24             	mov    %edi,(%esp)
  801dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dda:	75 1c                	jne    801df8 <__umoddi3+0x48>
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	76 50                	jbe    801e30 <__umoddi3+0x80>
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	f7 f7                	div    %edi
  801de6:	89 d0                	mov    %edx,%eax
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	39 f2                	cmp    %esi,%edx
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	77 52                	ja     801e50 <__umoddi3+0xa0>
  801dfe:	0f bd ea             	bsr    %edx,%ebp
  801e01:	83 f5 1f             	xor    $0x1f,%ebp
  801e04:	75 5a                	jne    801e60 <__umoddi3+0xb0>
  801e06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	39 0c 24             	cmp    %ecx,(%esp)
  801e13:	0f 86 d7 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e21:	83 c4 1c             	add    $0x1c,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	85 ff                	test   %edi,%edi
  801e32:	89 fd                	mov    %edi,%ebp
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 f0                	mov    %esi,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 c8                	mov    %ecx,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	eb 99                	jmp    801de8 <__umoddi3+0x38>
  801e4f:	90                   	nop
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	83 c4 1c             	add    $0x1c,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	8b 34 24             	mov    (%esp),%esi
  801e63:	bf 20 00 00 00       	mov    $0x20,%edi
  801e68:	89 e9                	mov    %ebp,%ecx
  801e6a:	29 ef                	sub    %ebp,%edi
  801e6c:	d3 e0                	shl    %cl,%eax
  801e6e:	89 f9                	mov    %edi,%ecx
  801e70:	89 f2                	mov    %esi,%edx
  801e72:	d3 ea                	shr    %cl,%edx
  801e74:	89 e9                	mov    %ebp,%ecx
  801e76:	09 c2                	or     %eax,%edx
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	89 14 24             	mov    %edx,(%esp)
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	d3 e2                	shl    %cl,%edx
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	89 c6                	mov    %eax,%esi
  801e91:	d3 e3                	shl    %cl,%ebx
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 d0                	mov    %edx,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	09 d8                	or     %ebx,%eax
  801e9d:	89 d3                	mov    %edx,%ebx
  801e9f:	89 f2                	mov    %esi,%edx
  801ea1:	f7 34 24             	divl   (%esp)
  801ea4:	89 d6                	mov    %edx,%esi
  801ea6:	d3 e3                	shl    %cl,%ebx
  801ea8:	f7 64 24 04          	mull   0x4(%esp)
  801eac:	39 d6                	cmp    %edx,%esi
  801eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb2:	89 d1                	mov    %edx,%ecx
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	72 08                	jb     801ec0 <__umoddi3+0x110>
  801eb8:	75 11                	jne    801ecb <__umoddi3+0x11b>
  801eba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ebe:	73 0b                	jae    801ecb <__umoddi3+0x11b>
  801ec0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ec4:	1b 14 24             	sbb    (%esp),%edx
  801ec7:	89 d1                	mov    %edx,%ecx
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ecf:	29 da                	sub    %ebx,%edx
  801ed1:	19 ce                	sbb    %ecx,%esi
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 f0                	mov    %esi,%eax
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	d3 ea                	shr    %cl,%edx
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	09 d0                	or     %edx,%eax
  801ee3:	89 f2                	mov    %esi,%edx
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 f9                	sub    %edi,%ecx
  801ef2:	19 d6                	sbb    %edx,%esi
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801efc:	e9 18 ff ff ff       	jmp    801e19 <__umoddi3+0x69>
