
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 2a 1f 80 00       	push   $0x801f2a
  800108:	6a 23                	push   $0x23
  80010a:	68 47 1f 80 00       	push   $0x801f47
  80010f:	e8 69 0f 00 00       	call   80107d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 2a 1f 80 00       	push   $0x801f2a
  800189:	6a 23                	push   $0x23
  80018b:	68 47 1f 80 00       	push   $0x801f47
  800190:	e8 e8 0e 00 00       	call   80107d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 2a 1f 80 00       	push   $0x801f2a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 47 1f 80 00       	push   $0x801f47
  8001d2:	e8 a6 0e 00 00       	call   80107d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 2a 1f 80 00       	push   $0x801f2a
  80020d:	6a 23                	push   $0x23
  80020f:	68 47 1f 80 00       	push   $0x801f47
  800214:	e8 64 0e 00 00       	call   80107d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 2a 1f 80 00       	push   $0x801f2a
  80024f:	6a 23                	push   $0x23
  800251:	68 47 1f 80 00       	push   $0x801f47
  800256:	e8 22 0e 00 00       	call   80107d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 0a 00 00 00       	mov    $0xa,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 0a                	push   $0xa
  80028c:	68 2a 1f 80 00       	push   $0x801f2a
  800291:	6a 23                	push   $0x23
  800293:	68 47 1f 80 00       	push   $0x801f47
  800298:	e8 e0 0d 00 00       	call   80107d <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 09                	push   $0x9
  8002ce:	68 2a 1f 80 00       	push   $0x801f2a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 47 1f 80 00       	push   $0x801f47
  8002da:	e8 9e 0d 00 00       	call   80107d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 2a 1f 80 00       	push   $0x801f2a
  800337:	6a 23                	push   $0x23
  800339:	68 47 1f 80 00       	push   $0x801f47
  80033e:	e8 3a 0d 00 00       	call   80107d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 08 40 80 00       	mov    0x804008,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 58 1f 80 00       	push   $0x801f58
  800452:	e8 ff 0c 00 00       	call   801156 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2) 
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0); 
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close) 
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 08 40 80 00       	mov    0x804008,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 99 1f 80 00       	push   $0x801f99
  80067c:	e8 d5 0a 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 08 40 80 00       	mov    0x804008,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 b5 1f 80 00       	push   $0x801fb5
  800751:	e8 00 0a 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 78 1f 80 00       	push   $0x801f78
  800806:	e8 4b 09 00 00       	call   801156 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 2b 02 00 00       	call   800afa <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 f1 12 00 00       	call   801c07 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 80 12 00 00       	call   801bb1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 0a 12 00 00       	call   801b48 <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 c3 0d 00 00       	call   80178a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 08             	sub    $0x8,%esp
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f9:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8009fe:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 40 0c             	mov    0xc(%eax),%eax
  800a07:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a0c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a12:	53                   	push   %ebx
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	68 08 50 80 00       	push   $0x805008
  800a1b:	e8 fc 0e 00 00       	call   80191c <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a20:	ba 00 00 00 00       	mov    $0x0,%edx
  800a25:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2a:	e8 cb fe ff ff       	call   8008fa <fsipc>
  800a2f:	83 c4 10             	add    $0x10,%esp
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 3d                	js     800a73 <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a36:	39 d8                	cmp    %ebx,%eax
  800a38:	76 19                	jbe    800a53 <devfile_write+0x69>
  800a3a:	68 e4 1f 80 00       	push   $0x801fe4
  800a3f:	68 eb 1f 80 00       	push   $0x801feb
  800a44:	68 9f 00 00 00       	push   $0x9f
  800a49:	68 00 20 80 00       	push   $0x802000
  800a4e:	e8 2a 06 00 00       	call   80107d <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a53:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a58:	76 19                	jbe    800a73 <devfile_write+0x89>
  800a5a:	68 18 20 80 00       	push   $0x802018
  800a5f:	68 eb 1f 80 00       	push   $0x801feb
  800a64:	68 a0 00 00 00       	push   $0xa0
  800a69:	68 00 20 80 00       	push   $0x802000
  800a6e:	e8 0a 06 00 00       	call   80107d <_panic>

	return r;
}
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 40 0c             	mov    0xc(%eax),%eax
  800a86:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9b:	e8 5a fe ff ff       	call   8008fa <fsipc>
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	78 4b                	js     800af1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 16                	jae    800ac0 <devfile_read+0x48>
  800aaa:	68 e4 1f 80 00       	push   $0x801fe4
  800aaf:	68 eb 1f 80 00       	push   $0x801feb
  800ab4:	6a 7e                	push   $0x7e
  800ab6:	68 00 20 80 00       	push   $0x802000
  800abb:	e8 bd 05 00 00       	call   80107d <_panic>
	assert(r <= PGSIZE);
  800ac0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac5:	7e 16                	jle    800add <devfile_read+0x65>
  800ac7:	68 0b 20 80 00       	push   $0x80200b
  800acc:	68 eb 1f 80 00       	push   $0x801feb
  800ad1:	6a 7f                	push   $0x7f
  800ad3:	68 00 20 80 00       	push   $0x802000
  800ad8:	e8 a0 05 00 00       	call   80107d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800add:	83 ec 04             	sub    $0x4,%esp
  800ae0:	50                   	push   %eax
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	e8 2e 0e 00 00       	call   80191c <memmove>
	return r;
  800aee:	83 c4 10             	add    $0x10,%esp
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 20             	sub    $0x20,%esp
  800b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b04:	53                   	push   %ebx
  800b05:	e8 47 0c 00 00       	call   801751 <strlen>
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b12:	7f 67                	jg     800b7b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	e8 52 f8 ff ff       	call   800372 <fd_alloc>
  800b20:	83 c4 10             	add    $0x10,%esp
		return r;
  800b23:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	78 57                	js     800b80 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	53                   	push   %ebx
  800b2d:	68 00 50 80 00       	push   $0x805000
  800b32:	e8 53 0c 00 00       	call   80178a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	e8 ae fd ff ff       	call   8008fa <fsipc>
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	85 c0                	test   %eax,%eax
  800b53:	79 14                	jns    800b69 <open+0x6f>
		fd_close(fd, 0);
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	6a 00                	push   $0x0
  800b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5d:	e8 08 f9 ff ff       	call   80046a <fd_close>
		return r;
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	89 da                	mov    %ebx,%edx
  800b67:	eb 17                	jmp    800b80 <open+0x86>
	}

	return fd2num(fd);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6f:	e8 d7 f7 ff ff       	call   80034b <fd2num>
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	eb 05                	jmp    800b80 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b80:	89 d0                	mov    %edx,%eax
  800b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 08 00 00 00       	mov    $0x8,%eax
  800b97:	e8 5e fd ff ff       	call   8008fa <fsipc>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	ff 75 08             	pushl  0x8(%ebp)
  800bac:	e8 aa f7 ff ff       	call   80035b <fd2data>
  800bb1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb3:	83 c4 08             	add    $0x8,%esp
  800bb6:	68 45 20 80 00       	push   $0x802045
  800bbb:	53                   	push   %ebx
  800bbc:	e8 c9 0b 00 00       	call   80178a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc1:	8b 46 04             	mov    0x4(%esi),%eax
  800bc4:	2b 06                	sub    (%esi),%eax
  800bc6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bcc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd3:	00 00 00 
	stat->st_dev = &devpipe;
  800bd6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bdd:	30 80 00 
	return 0;
}
  800be0:	b8 00 00 00 00       	mov    $0x0,%eax
  800be5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf6:	53                   	push   %ebx
  800bf7:	6a 00                	push   $0x0
  800bf9:	e8 e1 f5 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bfe:	89 1c 24             	mov    %ebx,(%esp)
  800c01:	e8 55 f7 ff ff       	call   80035b <fd2data>
  800c06:	83 c4 08             	add    $0x8,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 00                	push   $0x0
  800c0c:	e8 ce f5 ff ff       	call   8001df <sys_page_unmap>
}
  800c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 1c             	sub    $0x1c,%esp
  800c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c22:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c24:	a1 08 40 80 00       	mov    0x804008,%eax
  800c29:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	ff 75 e0             	pushl  -0x20(%ebp)
  800c32:	e8 09 10 00 00       	call   801c40 <pageref>
  800c37:	89 c3                	mov    %eax,%ebx
  800c39:	89 3c 24             	mov    %edi,(%esp)
  800c3c:	e8 ff 0f 00 00       	call   801c40 <pageref>
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	39 c3                	cmp    %eax,%ebx
  800c46:	0f 94 c1             	sete   %cl
  800c49:	0f b6 c9             	movzbl %cl,%ecx
  800c4c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c55:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c58:	39 ce                	cmp    %ecx,%esi
  800c5a:	74 1b                	je     800c77 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c5c:	39 c3                	cmp    %eax,%ebx
  800c5e:	75 c4                	jne    800c24 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c60:	8b 42 58             	mov    0x58(%edx),%eax
  800c63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c66:	50                   	push   %eax
  800c67:	56                   	push   %esi
  800c68:	68 4c 20 80 00       	push   $0x80204c
  800c6d:	e8 e4 04 00 00       	call   801156 <cprintf>
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	eb ad                	jmp    800c24 <_pipeisclosed+0xe>
	}
}
  800c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 28             	sub    $0x28,%esp
  800c8b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8e:	56                   	push   %esi
  800c8f:	e8 c7 f6 ff ff       	call   80035b <fd2data>
  800c94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9e:	eb 4b                	jmp    800ceb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca0:	89 da                	mov    %ebx,%edx
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	e8 6d ff ff ff       	call   800c16 <_pipeisclosed>
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	75 48                	jne    800cf5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cad:	e8 89 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb5:	8b 0b                	mov    (%ebx),%ecx
  800cb7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cba:	39 d0                	cmp    %edx,%eax
  800cbc:	73 e2                	jae    800ca0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc8:	89 c2                	mov    %eax,%edx
  800cca:	c1 fa 1f             	sar    $0x1f,%edx
  800ccd:	89 d1                	mov    %edx,%ecx
  800ccf:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd5:	83 e2 1f             	and    $0x1f,%edx
  800cd8:	29 ca                	sub    %ecx,%edx
  800cda:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cde:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce2:	83 c0 01             	add    $0x1,%eax
  800ce5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce8:	83 c7 01             	add    $0x1,%edi
  800ceb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cee:	75 c2                	jne    800cb2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf3:	eb 05                	jmp    800cfa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 18             	sub    $0x18,%esp
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0e:	57                   	push   %edi
  800d0f:	e8 47 f6 ff ff       	call   80035b <fd2data>
  800d14:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	eb 3d                	jmp    800d5d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d20:	85 db                	test   %ebx,%ebx
  800d22:	74 04                	je     800d28 <devpipe_read+0x26>
				return i;
  800d24:	89 d8                	mov    %ebx,%eax
  800d26:	eb 44                	jmp    800d6c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	e8 e5 fe ff ff       	call   800c16 <_pipeisclosed>
  800d31:	85 c0                	test   %eax,%eax
  800d33:	75 32                	jne    800d67 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d35:	e8 01 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3a:	8b 06                	mov    (%esi),%eax
  800d3c:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3f:	74 df                	je     800d20 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d41:	99                   	cltd   
  800d42:	c1 ea 1b             	shr    $0x1b,%edx
  800d45:	01 d0                	add    %edx,%eax
  800d47:	83 e0 1f             	and    $0x1f,%eax
  800d4a:	29 d0                	sub    %edx,%eax
  800d4c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d57:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5a:	83 c3 01             	add    $0x1,%ebx
  800d5d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d60:	75 d8                	jne    800d3a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d62:	8b 45 10             	mov    0x10(%ebp),%eax
  800d65:	eb 05                	jmp    800d6c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 ed f5 ff ff       	call   800372 <fd_alloc>
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 2c 01 00 00    	js     800ebe <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 b6 f3 ff ff       	call   80015a <sys_page_alloc>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 0d 01 00 00    	js     800ebe <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db7:	50                   	push   %eax
  800db8:	e8 b5 f5 ff ff       	call   800372 <fd_alloc>
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	0f 88 e2 00 00 00    	js     800eac <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 07 04 00 00       	push   $0x407
  800dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 7e f3 ff ff       	call   80015a <sys_page_alloc>
  800ddc:	89 c3                	mov    %eax,%ebx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	0f 88 c3 00 00 00    	js     800eac <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	ff 75 f4             	pushl  -0xc(%ebp)
  800def:	e8 67 f5 ff ff       	call   80035b <fd2data>
  800df4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df6:	83 c4 0c             	add    $0xc,%esp
  800df9:	68 07 04 00 00       	push   $0x407
  800dfe:	50                   	push   %eax
  800dff:	6a 00                	push   $0x0
  800e01:	e8 54 f3 ff ff       	call   80015a <sys_page_alloc>
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	0f 88 89 00 00 00    	js     800e9c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	ff 75 f0             	pushl  -0x10(%ebp)
  800e19:	e8 3d f5 ff ff       	call   80035b <fd2data>
  800e1e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e25:	50                   	push   %eax
  800e26:	6a 00                	push   $0x0
  800e28:	56                   	push   %esi
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 6d f3 ff ff       	call   80019d <sys_page_map>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	83 c4 20             	add    $0x20,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 55                	js     800e8e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	ff 75 f4             	pushl  -0xc(%ebp)
  800e69:	e8 dd f4 ff ff       	call   80034b <fd2num>
  800e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e71:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e73:	83 c4 04             	add    $0x4,%esp
  800e76:	ff 75 f0             	pushl  -0x10(%ebp)
  800e79:	e8 cd f4 ff ff       	call   80034b <fd2num>
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8c:	eb 30                	jmp    800ebe <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	56                   	push   %esi
  800e92:	6a 00                	push   $0x0
  800e94:	e8 46 f3 ff ff       	call   8001df <sys_page_unmap>
  800e99:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 36 f3 ff ff       	call   8001df <sys_page_unmap>
  800ea9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 26 f3 ff ff       	call   8001df <sys_page_unmap>
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ebe:	89 d0                	mov    %edx,%eax
  800ec0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed0:	50                   	push   %eax
  800ed1:	ff 75 08             	pushl  0x8(%ebp)
  800ed4:	e8 e8 f4 ff ff       	call   8003c1 <fd_lookup>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 18                	js     800ef8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee6:	e8 70 f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef0:	e8 21 fd ff ff       	call   800c16 <_pipeisclosed>
  800ef5:	83 c4 10             	add    $0x10,%esp
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0a:	68 64 20 80 00       	push   $0x802064
  800f0f:	ff 75 0c             	pushl  0xc(%ebp)
  800f12:	e8 73 08 00 00       	call   80178a <strcpy>
	return 0;
}
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f35:	eb 2d                	jmp    800f64 <devcons_write+0x46>
		m = n - tot;
  800f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f3c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f44:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	53                   	push   %ebx
  800f4b:	03 45 0c             	add    0xc(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	57                   	push   %edi
  800f50:	e8 c7 09 00 00       	call   80191c <memmove>
		sys_cputs(buf, m);
  800f55:	83 c4 08             	add    $0x8,%esp
  800f58:	53                   	push   %ebx
  800f59:	57                   	push   %edi
  800f5a:	e8 3f f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5f:	01 de                	add    %ebx,%esi
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	89 f0                	mov    %esi,%eax
  800f66:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f69:	72 cc                	jb     800f37 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f82:	74 2a                	je     800fae <devcons_read+0x3b>
  800f84:	eb 05                	jmp    800f8b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f86:	e8 b0 f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f8b:	e8 2c f1 ff ff       	call   8000bc <sys_cgetc>
  800f90:	85 c0                	test   %eax,%eax
  800f92:	74 f2                	je     800f86 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 16                	js     800fae <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f98:	83 f8 04             	cmp    $0x4,%eax
  800f9b:	74 0c                	je     800fa9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa0:	88 02                	mov    %al,(%edx)
	return 1;
  800fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa7:	eb 05                	jmp    800fae <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fbc:	6a 01                	push   $0x1
  800fbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	e8 d7 f0 ff ff       	call   80009e <sys_cputs>
}
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <getchar>:

int
getchar(void)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd2:	6a 01                	push   $0x1
  800fd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 48 f6 ff ff       	call   800627 <read>
	if (r < 0)
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 0f                	js     800ff5 <getchar+0x29>
		return r;
	if (r < 1)
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	7e 06                	jle    800ff0 <getchar+0x24>
		return -E_EOF;
	return c;
  800fea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fee:	eb 05                	jmp    800ff5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	e8 b8 f3 ff ff       	call   8003c1 <fd_lookup>
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 11                	js     801021 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801019:	39 10                	cmp    %edx,(%eax)
  80101b:	0f 94 c0             	sete   %al
  80101e:	0f b6 c0             	movzbl %al,%eax
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <opencons>:

int
opencons(void)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	e8 40 f3 ff ff       	call   800372 <fd_alloc>
  801032:	83 c4 10             	add    $0x10,%esp
		return r;
  801035:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	78 3e                	js     801079 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	68 07 04 00 00       	push   $0x407
  801043:	ff 75 f4             	pushl  -0xc(%ebp)
  801046:	6a 00                	push   $0x0
  801048:	e8 0d f1 ff ff       	call   80015a <sys_page_alloc>
  80104d:	83 c4 10             	add    $0x10,%esp
		return r;
  801050:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801052:	85 c0                	test   %eax,%eax
  801054:	78 23                	js     801079 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801056:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801064:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	50                   	push   %eax
  80106f:	e8 d7 f2 ff ff       	call   80034b <fd2num>
  801074:	89 c2                	mov    %eax,%edx
  801076:	83 c4 10             	add    $0x10,%esp
}
  801079:	89 d0                	mov    %edx,%eax
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801082:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801085:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108b:	e8 8c f0 ff ff       	call   80011c <sys_getenvid>
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	ff 75 0c             	pushl  0xc(%ebp)
  801096:	ff 75 08             	pushl  0x8(%ebp)
  801099:	56                   	push   %esi
  80109a:	50                   	push   %eax
  80109b:	68 70 20 80 00       	push   $0x802070
  8010a0:	e8 b1 00 00 00       	call   801156 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a5:	83 c4 18             	add    $0x18,%esp
  8010a8:	53                   	push   %ebx
  8010a9:	ff 75 10             	pushl  0x10(%ebp)
  8010ac:	e8 54 00 00 00       	call   801105 <vcprintf>
	cprintf("\n");
  8010b1:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010b8:	e8 99 00 00 00       	call   801156 <cprintf>
  8010bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c0:	cc                   	int3   
  8010c1:	eb fd                	jmp    8010c0 <_panic+0x43>

008010c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010cd:	8b 13                	mov    (%ebx),%edx
  8010cf:	8d 42 01             	lea    0x1(%edx),%eax
  8010d2:	89 03                	mov    %eax,(%ebx)
  8010d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e0:	75 1a                	jne    8010fc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	68 ff 00 00 00       	push   $0xff
  8010ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ed:	50                   	push   %eax
  8010ee:	e8 ab ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801115:	00 00 00 
	b.cnt = 0;
  801118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801122:	ff 75 0c             	pushl  0xc(%ebp)
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	68 c3 10 80 00       	push   $0x8010c3
  801134:	e8 54 01 00 00       	call   80128d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	e8 50 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80114e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80115c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115f:	50                   	push   %eax
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	e8 9d ff ff ff       	call   801105 <vcprintf>
	va_end(ap);

	return cnt;
}
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 1c             	sub    $0x1c,%esp
  801173:	89 c7                	mov    %eax,%edi
  801175:	89 d6                	mov    %edx,%esi
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801180:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801183:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801191:	39 d3                	cmp    %edx,%ebx
  801193:	72 05                	jb     80119a <printnum+0x30>
  801195:	39 45 10             	cmp    %eax,0x10(%ebp)
  801198:	77 45                	ja     8011df <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	ff 75 18             	pushl  0x18(%ebp)
  8011a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a6:	53                   	push   %ebx
  8011a7:	ff 75 10             	pushl  0x10(%ebp)
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b9:	e8 c2 0a 00 00       	call   801c80 <__udivdi3>
  8011be:	83 c4 18             	add    $0x18,%esp
  8011c1:	52                   	push   %edx
  8011c2:	50                   	push   %eax
  8011c3:	89 f2                	mov    %esi,%edx
  8011c5:	89 f8                	mov    %edi,%eax
  8011c7:	e8 9e ff ff ff       	call   80116a <printnum>
  8011cc:	83 c4 20             	add    $0x20,%esp
  8011cf:	eb 18                	jmp    8011e9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	56                   	push   %esi
  8011d5:	ff 75 18             	pushl  0x18(%ebp)
  8011d8:	ff d7                	call   *%edi
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 03                	jmp    8011e2 <printnum+0x78>
  8011df:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011e2:	83 eb 01             	sub    $0x1,%ebx
  8011e5:	85 db                	test   %ebx,%ebx
  8011e7:	7f e8                	jg     8011d1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	56                   	push   %esi
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8011fc:	e8 af 0b 00 00       	call   801db0 <__umoddi3>
  801201:	83 c4 14             	add    $0x14,%esp
  801204:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  80120b:	50                   	push   %eax
  80120c:	ff d7                	call   *%edi
}
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80121c:	83 fa 01             	cmp    $0x1,%edx
  80121f:	7e 0e                	jle    80122f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801221:	8b 10                	mov    (%eax),%edx
  801223:	8d 4a 08             	lea    0x8(%edx),%ecx
  801226:	89 08                	mov    %ecx,(%eax)
  801228:	8b 02                	mov    (%edx),%eax
  80122a:	8b 52 04             	mov    0x4(%edx),%edx
  80122d:	eb 22                	jmp    801251 <getuint+0x38>
	else if (lflag)
  80122f:	85 d2                	test   %edx,%edx
  801231:	74 10                	je     801243 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801233:	8b 10                	mov    (%eax),%edx
  801235:	8d 4a 04             	lea    0x4(%edx),%ecx
  801238:	89 08                	mov    %ecx,(%eax)
  80123a:	8b 02                	mov    (%edx),%eax
  80123c:	ba 00 00 00 00       	mov    $0x0,%edx
  801241:	eb 0e                	jmp    801251 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801243:	8b 10                	mov    (%eax),%edx
  801245:	8d 4a 04             	lea    0x4(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801259:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125d:	8b 10                	mov    (%eax),%edx
  80125f:	3b 50 04             	cmp    0x4(%eax),%edx
  801262:	73 0a                	jae    80126e <sprintputch+0x1b>
		*b->buf++ = ch;
  801264:	8d 4a 01             	lea    0x1(%edx),%ecx
  801267:	89 08                	mov    %ecx,(%eax)
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
  80126c:	88 02                	mov    %al,(%edx)
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801276:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801279:	50                   	push   %eax
  80127a:	ff 75 10             	pushl  0x10(%ebp)
  80127d:	ff 75 0c             	pushl  0xc(%ebp)
  801280:	ff 75 08             	pushl  0x8(%ebp)
  801283:	e8 05 00 00 00       	call   80128d <vprintfmt>
	va_end(ap);
}
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	c9                   	leave  
  80128c:	c3                   	ret    

0080128d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 2c             	sub    $0x2c,%esp
  801296:	8b 75 08             	mov    0x8(%ebp),%esi
  801299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80129c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129f:	eb 12                	jmp    8012b3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	0f 84 38 04 00 00    	je     8016e1 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	50                   	push   %eax
  8012ae:	ff d6                	call   *%esi
  8012b0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b3:	83 c7 01             	add    $0x1,%edi
  8012b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ba:	83 f8 25             	cmp    $0x25,%eax
  8012bd:	75 e2                	jne    8012a1 <vprintfmt+0x14>
  8012bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012dd:	eb 07                	jmp    8012e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8d 47 01             	lea    0x1(%edi),%eax
  8012e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ec:	0f b6 07             	movzbl (%edi),%eax
  8012ef:	0f b6 c8             	movzbl %al,%ecx
  8012f2:	83 e8 23             	sub    $0x23,%eax
  8012f5:	3c 55                	cmp    $0x55,%al
  8012f7:	0f 87 c9 03 00 00    	ja     8016c6 <vprintfmt+0x439>
  8012fd:	0f b6 c0             	movzbl %al,%eax
  801300:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80130a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130e:	eb d6                	jmp    8012e6 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  801310:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801317:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  80131d:	eb 94                	jmp    8012b3 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80131f:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801326:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  80132c:	eb 85                	jmp    8012b3 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80132e:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  801335:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  80133b:	e9 73 ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  801340:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801347:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  80134d:	e9 61 ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  801352:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801359:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80135f:	e9 4f ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  801364:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  80136b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  801371:	e9 3d ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801376:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  80137d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  801383:	e9 2b ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801388:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  80138f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  801395:	e9 19 ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  80139a:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013a1:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013a7:	e9 07 ff ff ff       	jmp    8012b3 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013ac:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013b3:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013b9:	e9 f5 fe ff ff       	jmp    8012b3 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013c9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013cc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013d0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013d3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013d6:	83 fa 09             	cmp    $0x9,%edx
  8013d9:	77 3f                	ja     80141a <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013db:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013de:	eb e9                	jmp    8013c9 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e3:	8d 48 04             	lea    0x4(%eax),%ecx
  8013e6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013e9:	8b 00                	mov    (%eax),%eax
  8013eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013f1:	eb 2d                	jmp    801420 <vprintfmt+0x193>
  8013f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013fd:	0f 49 c8             	cmovns %eax,%ecx
  801400:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801406:	e9 db fe ff ff       	jmp    8012e6 <vprintfmt+0x59>
  80140b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80140e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801415:	e9 cc fe ff ff       	jmp    8012e6 <vprintfmt+0x59>
  80141a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801424:	0f 89 bc fe ff ff    	jns    8012e6 <vprintfmt+0x59>
				width = precision, precision = -1;
  80142a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80142d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801430:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801437:	e9 aa fe ff ff       	jmp    8012e6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80143c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801442:	e9 9f fe ff ff       	jmp    8012e6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801447:	8b 45 14             	mov    0x14(%ebp),%eax
  80144a:	8d 50 04             	lea    0x4(%eax),%edx
  80144d:	89 55 14             	mov    %edx,0x14(%ebp)
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	53                   	push   %ebx
  801454:	ff 30                	pushl  (%eax)
  801456:	ff d6                	call   *%esi
			break;
  801458:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80145b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80145e:	e9 50 fe ff ff       	jmp    8012b3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801463:	8b 45 14             	mov    0x14(%ebp),%eax
  801466:	8d 50 04             	lea    0x4(%eax),%edx
  801469:	89 55 14             	mov    %edx,0x14(%ebp)
  80146c:	8b 00                	mov    (%eax),%eax
  80146e:	99                   	cltd   
  80146f:	31 d0                	xor    %edx,%eax
  801471:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801473:	83 f8 0f             	cmp    $0xf,%eax
  801476:	7f 0b                	jg     801483 <vprintfmt+0x1f6>
  801478:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80147f:	85 d2                	test   %edx,%edx
  801481:	75 18                	jne    80149b <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  801483:	50                   	push   %eax
  801484:	68 ab 20 80 00       	push   $0x8020ab
  801489:	53                   	push   %ebx
  80148a:	56                   	push   %esi
  80148b:	e8 e0 fd ff ff       	call   801270 <printfmt>
  801490:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801496:	e9 18 fe ff ff       	jmp    8012b3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80149b:	52                   	push   %edx
  80149c:	68 fd 1f 80 00       	push   $0x801ffd
  8014a1:	53                   	push   %ebx
  8014a2:	56                   	push   %esi
  8014a3:	e8 c8 fd ff ff       	call   801270 <printfmt>
  8014a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ae:	e9 00 fe ff ff       	jmp    8012b3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b6:	8d 50 04             	lea    0x4(%eax),%edx
  8014b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014bc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014be:	85 ff                	test   %edi,%edi
  8014c0:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014c5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014cc:	0f 8e 94 00 00 00    	jle    801566 <vprintfmt+0x2d9>
  8014d2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014d6:	0f 84 98 00 00 00    	je     801574 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	ff 75 d0             	pushl  -0x30(%ebp)
  8014e2:	57                   	push   %edi
  8014e3:	e8 81 02 00 00       	call   801769 <strnlen>
  8014e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014eb:	29 c1                	sub    %eax,%ecx
  8014ed:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014f0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014f3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8014f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014fa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8014fd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8014ff:	eb 0f                	jmp    801510 <vprintfmt+0x283>
					putch(padc, putdat);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	53                   	push   %ebx
  801505:	ff 75 e0             	pushl  -0x20(%ebp)
  801508:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80150a:	83 ef 01             	sub    $0x1,%edi
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	85 ff                	test   %edi,%edi
  801512:	7f ed                	jg     801501 <vprintfmt+0x274>
  801514:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801517:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80151a:	85 c9                	test   %ecx,%ecx
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
  801521:	0f 49 c1             	cmovns %ecx,%eax
  801524:	29 c1                	sub    %eax,%ecx
  801526:	89 75 08             	mov    %esi,0x8(%ebp)
  801529:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80152c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80152f:	89 cb                	mov    %ecx,%ebx
  801531:	eb 4d                	jmp    801580 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801533:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801537:	74 1b                	je     801554 <vprintfmt+0x2c7>
  801539:	0f be c0             	movsbl %al,%eax
  80153c:	83 e8 20             	sub    $0x20,%eax
  80153f:	83 f8 5e             	cmp    $0x5e,%eax
  801542:	76 10                	jbe    801554 <vprintfmt+0x2c7>
					putch('?', putdat);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	ff 75 0c             	pushl  0xc(%ebp)
  80154a:	6a 3f                	push   $0x3f
  80154c:	ff 55 08             	call   *0x8(%ebp)
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb 0d                	jmp    801561 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	ff 75 0c             	pushl  0xc(%ebp)
  80155a:	52                   	push   %edx
  80155b:	ff 55 08             	call   *0x8(%ebp)
  80155e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801561:	83 eb 01             	sub    $0x1,%ebx
  801564:	eb 1a                	jmp    801580 <vprintfmt+0x2f3>
  801566:	89 75 08             	mov    %esi,0x8(%ebp)
  801569:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80156c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80156f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801572:	eb 0c                	jmp    801580 <vprintfmt+0x2f3>
  801574:	89 75 08             	mov    %esi,0x8(%ebp)
  801577:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80157a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80157d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801580:	83 c7 01             	add    $0x1,%edi
  801583:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801587:	0f be d0             	movsbl %al,%edx
  80158a:	85 d2                	test   %edx,%edx
  80158c:	74 23                	je     8015b1 <vprintfmt+0x324>
  80158e:	85 f6                	test   %esi,%esi
  801590:	78 a1                	js     801533 <vprintfmt+0x2a6>
  801592:	83 ee 01             	sub    $0x1,%esi
  801595:	79 9c                	jns    801533 <vprintfmt+0x2a6>
  801597:	89 df                	mov    %ebx,%edi
  801599:	8b 75 08             	mov    0x8(%ebp),%esi
  80159c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80159f:	eb 18                	jmp    8015b9 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	6a 20                	push   $0x20
  8015a7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015a9:	83 ef 01             	sub    $0x1,%edi
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 08                	jmp    8015b9 <vprintfmt+0x32c>
  8015b1:	89 df                	mov    %ebx,%edi
  8015b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b9:	85 ff                	test   %edi,%edi
  8015bb:	7f e4                	jg     8015a1 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c0:	e9 ee fc ff ff       	jmp    8012b3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015c5:	83 fa 01             	cmp    $0x1,%edx
  8015c8:	7e 16                	jle    8015e0 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cd:	8d 50 08             	lea    0x8(%eax),%edx
  8015d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8015d3:	8b 50 04             	mov    0x4(%eax),%edx
  8015d6:	8b 00                	mov    (%eax),%eax
  8015d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015de:	eb 32                	jmp    801612 <vprintfmt+0x385>
	else if (lflag)
  8015e0:	85 d2                	test   %edx,%edx
  8015e2:	74 18                	je     8015fc <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e7:	8d 50 04             	lea    0x4(%eax),%edx
  8015ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8015ed:	8b 00                	mov    (%eax),%eax
  8015ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f2:	89 c1                	mov    %eax,%ecx
  8015f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8015f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015fa:	eb 16                	jmp    801612 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8015fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ff:	8d 50 04             	lea    0x4(%eax),%edx
  801602:	89 55 14             	mov    %edx,0x14(%ebp)
  801605:	8b 00                	mov    (%eax),%eax
  801607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80160a:	89 c1                	mov    %eax,%ecx
  80160c:	c1 f9 1f             	sar    $0x1f,%ecx
  80160f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801615:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801618:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80161d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801621:	79 6f                	jns    801692 <vprintfmt+0x405>
				putch('-', putdat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	6a 2d                	push   $0x2d
  801629:	ff d6                	call   *%esi
				num = -(long long) num;
  80162b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80162e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801631:	f7 d8                	neg    %eax
  801633:	83 d2 00             	adc    $0x0,%edx
  801636:	f7 da                	neg    %edx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb 55                	jmp    801692 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80163d:	8d 45 14             	lea    0x14(%ebp),%eax
  801640:	e8 d4 fb ff ff       	call   801219 <getuint>
			base = 10;
  801645:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80164a:	eb 46                	jmp    801692 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80164c:	8d 45 14             	lea    0x14(%ebp),%eax
  80164f:	e8 c5 fb ff ff       	call   801219 <getuint>
			base = 8;
  801654:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801659:	eb 37                	jmp    801692 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	53                   	push   %ebx
  80165f:	6a 30                	push   $0x30
  801661:	ff d6                	call   *%esi
			putch('x', putdat);
  801663:	83 c4 08             	add    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	6a 78                	push   $0x78
  801669:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80166b:	8b 45 14             	mov    0x14(%ebp),%eax
  80166e:	8d 50 04             	lea    0x4(%eax),%edx
  801671:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801674:	8b 00                	mov    (%eax),%eax
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80167b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80167e:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  801683:	eb 0d                	jmp    801692 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801685:	8d 45 14             	lea    0x14(%ebp),%eax
  801688:	e8 8c fb ff ff       	call   801219 <getuint>
			base = 16;
  80168d:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801699:	51                   	push   %ecx
  80169a:	ff 75 e0             	pushl  -0x20(%ebp)
  80169d:	57                   	push   %edi
  80169e:	52                   	push   %edx
  80169f:	50                   	push   %eax
  8016a0:	89 da                	mov    %ebx,%edx
  8016a2:	89 f0                	mov    %esi,%eax
  8016a4:	e8 c1 fa ff ff       	call   80116a <printnum>
			break;
  8016a9:	83 c4 20             	add    $0x20,%esp
  8016ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016af:	e9 ff fb ff ff       	jmp    8012b3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	53                   	push   %ebx
  8016b8:	51                   	push   %ecx
  8016b9:	ff d6                	call   *%esi
			break;
  8016bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016c1:	e9 ed fb ff ff       	jmp    8012b3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	53                   	push   %ebx
  8016ca:	6a 25                	push   $0x25
  8016cc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	eb 03                	jmp    8016d6 <vprintfmt+0x449>
  8016d3:	83 ef 01             	sub    $0x1,%edi
  8016d6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016da:	75 f7                	jne    8016d3 <vprintfmt+0x446>
  8016dc:	e9 d2 fb ff ff       	jmp    8012b3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5e                   	pop    %esi
  8016e6:	5f                   	pop    %edi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 18             	sub    $0x18,%esp
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801706:	85 c0                	test   %eax,%eax
  801708:	74 26                	je     801730 <vsnprintf+0x47>
  80170a:	85 d2                	test   %edx,%edx
  80170c:	7e 22                	jle    801730 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80170e:	ff 75 14             	pushl  0x14(%ebp)
  801711:	ff 75 10             	pushl  0x10(%ebp)
  801714:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	68 53 12 80 00       	push   $0x801253
  80171d:	e8 6b fb ff ff       	call   80128d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801725:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	eb 05                	jmp    801735 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80173d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801740:	50                   	push   %eax
  801741:	ff 75 10             	pushl  0x10(%ebp)
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	ff 75 08             	pushl  0x8(%ebp)
  80174a:	e8 9a ff ff ff       	call   8016e9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801757:	b8 00 00 00 00       	mov    $0x0,%eax
  80175c:	eb 03                	jmp    801761 <strlen+0x10>
		n++;
  80175e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801761:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801765:	75 f7                	jne    80175e <strlen+0xd>
		n++;
	return n;
}
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801772:	ba 00 00 00 00       	mov    $0x0,%edx
  801777:	eb 03                	jmp    80177c <strnlen+0x13>
		n++;
  801779:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80177c:	39 c2                	cmp    %eax,%edx
  80177e:	74 08                	je     801788 <strnlen+0x1f>
  801780:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801784:	75 f3                	jne    801779 <strnlen+0x10>
  801786:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801794:	89 c2                	mov    %eax,%edx
  801796:	83 c2 01             	add    $0x1,%edx
  801799:	83 c1 01             	add    $0x1,%ecx
  80179c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017a0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017a3:	84 db                	test   %bl,%bl
  8017a5:	75 ef                	jne    801796 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017a7:	5b                   	pop    %ebx
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017b1:	53                   	push   %ebx
  8017b2:	e8 9a ff ff ff       	call   801751 <strlen>
  8017b7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017ba:	ff 75 0c             	pushl  0xc(%ebp)
  8017bd:	01 d8                	add    %ebx,%eax
  8017bf:	50                   	push   %eax
  8017c0:	e8 c5 ff ff ff       	call   80178a <strcpy>
	return dst;
}
  8017c5:	89 d8                	mov    %ebx,%eax
  8017c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d7:	89 f3                	mov    %esi,%ebx
  8017d9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017dc:	89 f2                	mov    %esi,%edx
  8017de:	eb 0f                	jmp    8017ef <strncpy+0x23>
		*dst++ = *src;
  8017e0:	83 c2 01             	add    $0x1,%edx
  8017e3:	0f b6 01             	movzbl (%ecx),%eax
  8017e6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017e9:	80 39 01             	cmpb   $0x1,(%ecx)
  8017ec:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017ef:	39 da                	cmp    %ebx,%edx
  8017f1:	75 ed                	jne    8017e0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017f3:	89 f0                	mov    %esi,%eax
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
  8017fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801804:	8b 55 10             	mov    0x10(%ebp),%edx
  801807:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801809:	85 d2                	test   %edx,%edx
  80180b:	74 21                	je     80182e <strlcpy+0x35>
  80180d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801811:	89 f2                	mov    %esi,%edx
  801813:	eb 09                	jmp    80181e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801815:	83 c2 01             	add    $0x1,%edx
  801818:	83 c1 01             	add    $0x1,%ecx
  80181b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80181e:	39 c2                	cmp    %eax,%edx
  801820:	74 09                	je     80182b <strlcpy+0x32>
  801822:	0f b6 19             	movzbl (%ecx),%ebx
  801825:	84 db                	test   %bl,%bl
  801827:	75 ec                	jne    801815 <strlcpy+0x1c>
  801829:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80182b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80182e:	29 f0                	sub    %esi,%eax
}
  801830:	5b                   	pop    %ebx
  801831:	5e                   	pop    %esi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80183d:	eb 06                	jmp    801845 <strcmp+0x11>
		p++, q++;
  80183f:	83 c1 01             	add    $0x1,%ecx
  801842:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801845:	0f b6 01             	movzbl (%ecx),%eax
  801848:	84 c0                	test   %al,%al
  80184a:	74 04                	je     801850 <strcmp+0x1c>
  80184c:	3a 02                	cmp    (%edx),%al
  80184e:	74 ef                	je     80183f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801850:	0f b6 c0             	movzbl %al,%eax
  801853:	0f b6 12             	movzbl (%edx),%edx
  801856:	29 d0                	sub    %edx,%eax
}
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	8b 45 08             	mov    0x8(%ebp),%eax
  801861:	8b 55 0c             	mov    0xc(%ebp),%edx
  801864:	89 c3                	mov    %eax,%ebx
  801866:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801869:	eb 06                	jmp    801871 <strncmp+0x17>
		n--, p++, q++;
  80186b:	83 c0 01             	add    $0x1,%eax
  80186e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801871:	39 d8                	cmp    %ebx,%eax
  801873:	74 15                	je     80188a <strncmp+0x30>
  801875:	0f b6 08             	movzbl (%eax),%ecx
  801878:	84 c9                	test   %cl,%cl
  80187a:	74 04                	je     801880 <strncmp+0x26>
  80187c:	3a 0a                	cmp    (%edx),%cl
  80187e:	74 eb                	je     80186b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801880:	0f b6 00             	movzbl (%eax),%eax
  801883:	0f b6 12             	movzbl (%edx),%edx
  801886:	29 d0                	sub    %edx,%eax
  801888:	eb 05                	jmp    80188f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80188a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80188f:	5b                   	pop    %ebx
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	8b 45 08             	mov    0x8(%ebp),%eax
  801898:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80189c:	eb 07                	jmp    8018a5 <strchr+0x13>
		if (*s == c)
  80189e:	38 ca                	cmp    %cl,%dl
  8018a0:	74 0f                	je     8018b1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018a2:	83 c0 01             	add    $0x1,%eax
  8018a5:	0f b6 10             	movzbl (%eax),%edx
  8018a8:	84 d2                	test   %dl,%dl
  8018aa:	75 f2                	jne    80189e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018bd:	eb 03                	jmp    8018c2 <strfind+0xf>
  8018bf:	83 c0 01             	add    $0x1,%eax
  8018c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018c5:	38 ca                	cmp    %cl,%dl
  8018c7:	74 04                	je     8018cd <strfind+0x1a>
  8018c9:	84 d2                	test   %dl,%dl
  8018cb:	75 f2                	jne    8018bf <strfind+0xc>
			break;
	return (char *) s;
}
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	57                   	push   %edi
  8018d3:	56                   	push   %esi
  8018d4:	53                   	push   %ebx
  8018d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018db:	85 c9                	test   %ecx,%ecx
  8018dd:	74 36                	je     801915 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018e5:	75 28                	jne    80190f <memset+0x40>
  8018e7:	f6 c1 03             	test   $0x3,%cl
  8018ea:	75 23                	jne    80190f <memset+0x40>
		c &= 0xFF;
  8018ec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018f0:	89 d3                	mov    %edx,%ebx
  8018f2:	c1 e3 08             	shl    $0x8,%ebx
  8018f5:	89 d6                	mov    %edx,%esi
  8018f7:	c1 e6 18             	shl    $0x18,%esi
  8018fa:	89 d0                	mov    %edx,%eax
  8018fc:	c1 e0 10             	shl    $0x10,%eax
  8018ff:	09 f0                	or     %esi,%eax
  801901:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801903:	89 d8                	mov    %ebx,%eax
  801905:	09 d0                	or     %edx,%eax
  801907:	c1 e9 02             	shr    $0x2,%ecx
  80190a:	fc                   	cld    
  80190b:	f3 ab                	rep stos %eax,%es:(%edi)
  80190d:	eb 06                	jmp    801915 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80190f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801912:	fc                   	cld    
  801913:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801915:	89 f8                	mov    %edi,%eax
  801917:	5b                   	pop    %ebx
  801918:	5e                   	pop    %esi
  801919:	5f                   	pop    %edi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	8b 75 0c             	mov    0xc(%ebp),%esi
  801927:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80192a:	39 c6                	cmp    %eax,%esi
  80192c:	73 35                	jae    801963 <memmove+0x47>
  80192e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801931:	39 d0                	cmp    %edx,%eax
  801933:	73 2e                	jae    801963 <memmove+0x47>
		s += n;
		d += n;
  801935:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801938:	89 d6                	mov    %edx,%esi
  80193a:	09 fe                	or     %edi,%esi
  80193c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801942:	75 13                	jne    801957 <memmove+0x3b>
  801944:	f6 c1 03             	test   $0x3,%cl
  801947:	75 0e                	jne    801957 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801949:	83 ef 04             	sub    $0x4,%edi
  80194c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80194f:	c1 e9 02             	shr    $0x2,%ecx
  801952:	fd                   	std    
  801953:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801955:	eb 09                	jmp    801960 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801957:	83 ef 01             	sub    $0x1,%edi
  80195a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80195d:	fd                   	std    
  80195e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801960:	fc                   	cld    
  801961:	eb 1d                	jmp    801980 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801963:	89 f2                	mov    %esi,%edx
  801965:	09 c2                	or     %eax,%edx
  801967:	f6 c2 03             	test   $0x3,%dl
  80196a:	75 0f                	jne    80197b <memmove+0x5f>
  80196c:	f6 c1 03             	test   $0x3,%cl
  80196f:	75 0a                	jne    80197b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801971:	c1 e9 02             	shr    $0x2,%ecx
  801974:	89 c7                	mov    %eax,%edi
  801976:	fc                   	cld    
  801977:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801979:	eb 05                	jmp    801980 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80197b:	89 c7                	mov    %eax,%edi
  80197d:	fc                   	cld    
  80197e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801980:	5e                   	pop    %esi
  801981:	5f                   	pop    %edi
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801987:	ff 75 10             	pushl  0x10(%ebp)
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	ff 75 08             	pushl  0x8(%ebp)
  801990:	e8 87 ff ff ff       	call   80191c <memmove>
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a2:	89 c6                	mov    %eax,%esi
  8019a4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019a7:	eb 1a                	jmp    8019c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8019a9:	0f b6 08             	movzbl (%eax),%ecx
  8019ac:	0f b6 1a             	movzbl (%edx),%ebx
  8019af:	38 d9                	cmp    %bl,%cl
  8019b1:	74 0a                	je     8019bd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019b3:	0f b6 c1             	movzbl %cl,%eax
  8019b6:	0f b6 db             	movzbl %bl,%ebx
  8019b9:	29 d8                	sub    %ebx,%eax
  8019bb:	eb 0f                	jmp    8019cc <memcmp+0x35>
		s1++, s2++;
  8019bd:	83 c0 01             	add    $0x1,%eax
  8019c0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019c3:	39 f0                	cmp    %esi,%eax
  8019c5:	75 e2                	jne    8019a9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	53                   	push   %ebx
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019d7:	89 c1                	mov    %eax,%ecx
  8019d9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019dc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e0:	eb 0a                	jmp    8019ec <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019e2:	0f b6 10             	movzbl (%eax),%edx
  8019e5:	39 da                	cmp    %ebx,%edx
  8019e7:	74 07                	je     8019f0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e9:	83 c0 01             	add    $0x1,%eax
  8019ec:	39 c8                	cmp    %ecx,%eax
  8019ee:	72 f2                	jb     8019e2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019f0:	5b                   	pop    %ebx
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	57                   	push   %edi
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019ff:	eb 03                	jmp    801a04 <strtol+0x11>
		s++;
  801a01:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a04:	0f b6 01             	movzbl (%ecx),%eax
  801a07:	3c 20                	cmp    $0x20,%al
  801a09:	74 f6                	je     801a01 <strtol+0xe>
  801a0b:	3c 09                	cmp    $0x9,%al
  801a0d:	74 f2                	je     801a01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a0f:	3c 2b                	cmp    $0x2b,%al
  801a11:	75 0a                	jne    801a1d <strtol+0x2a>
		s++;
  801a13:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a16:	bf 00 00 00 00       	mov    $0x0,%edi
  801a1b:	eb 11                	jmp    801a2e <strtol+0x3b>
  801a1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a22:	3c 2d                	cmp    $0x2d,%al
  801a24:	75 08                	jne    801a2e <strtol+0x3b>
		s++, neg = 1;
  801a26:	83 c1 01             	add    $0x1,%ecx
  801a29:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a34:	75 15                	jne    801a4b <strtol+0x58>
  801a36:	80 39 30             	cmpb   $0x30,(%ecx)
  801a39:	75 10                	jne    801a4b <strtol+0x58>
  801a3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a3f:	75 7c                	jne    801abd <strtol+0xca>
		s += 2, base = 16;
  801a41:	83 c1 02             	add    $0x2,%ecx
  801a44:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a49:	eb 16                	jmp    801a61 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a4b:	85 db                	test   %ebx,%ebx
  801a4d:	75 12                	jne    801a61 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a4f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a54:	80 39 30             	cmpb   $0x30,(%ecx)
  801a57:	75 08                	jne    801a61 <strtol+0x6e>
		s++, base = 8;
  801a59:	83 c1 01             	add    $0x1,%ecx
  801a5c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a61:	b8 00 00 00 00       	mov    $0x0,%eax
  801a66:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a69:	0f b6 11             	movzbl (%ecx),%edx
  801a6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a6f:	89 f3                	mov    %esi,%ebx
  801a71:	80 fb 09             	cmp    $0x9,%bl
  801a74:	77 08                	ja     801a7e <strtol+0x8b>
			dig = *s - '0';
  801a76:	0f be d2             	movsbl %dl,%edx
  801a79:	83 ea 30             	sub    $0x30,%edx
  801a7c:	eb 22                	jmp    801aa0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a7e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a81:	89 f3                	mov    %esi,%ebx
  801a83:	80 fb 19             	cmp    $0x19,%bl
  801a86:	77 08                	ja     801a90 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a88:	0f be d2             	movsbl %dl,%edx
  801a8b:	83 ea 57             	sub    $0x57,%edx
  801a8e:	eb 10                	jmp    801aa0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a90:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a93:	89 f3                	mov    %esi,%ebx
  801a95:	80 fb 19             	cmp    $0x19,%bl
  801a98:	77 16                	ja     801ab0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a9a:	0f be d2             	movsbl %dl,%edx
  801a9d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801aa0:	3b 55 10             	cmp    0x10(%ebp),%edx
  801aa3:	7d 0b                	jge    801ab0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801aa5:	83 c1 01             	add    $0x1,%ecx
  801aa8:	0f af 45 10          	imul   0x10(%ebp),%eax
  801aac:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801aae:	eb b9                	jmp    801a69 <strtol+0x76>

	if (endptr)
  801ab0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ab4:	74 0d                	je     801ac3 <strtol+0xd0>
		*endptr = (char *) s;
  801ab6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab9:	89 0e                	mov    %ecx,(%esi)
  801abb:	eb 06                	jmp    801ac3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801abd:	85 db                	test   %ebx,%ebx
  801abf:	74 98                	je     801a59 <strtol+0x66>
  801ac1:	eb 9e                	jmp    801a61 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ac3:	89 c2                	mov    %eax,%edx
  801ac5:	f7 da                	neg    %edx
  801ac7:	85 ff                	test   %edi,%edi
  801ac9:	0f 45 c2             	cmovne %edx,%eax
}
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	57                   	push   %edi
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 04             	sub    $0x4,%esp
  801ada:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801add:	57                   	push   %edi
  801ade:	e8 6e fc ff ff       	call   801751 <strlen>
  801ae3:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801ae6:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801ae9:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801af3:	eb 46                	jmp    801b3b <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801af5:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801af9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801afc:	80 f9 09             	cmp    $0x9,%cl
  801aff:	77 08                	ja     801b09 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b01:	0f be d2             	movsbl %dl,%edx
  801b04:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b07:	eb 27                	jmp    801b30 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b09:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b0c:	80 f9 05             	cmp    $0x5,%cl
  801b0f:	77 08                	ja     801b19 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b11:	0f be d2             	movsbl %dl,%edx
  801b14:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b17:	eb 17                	jmp    801b30 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b19:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b1c:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b1f:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b24:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b28:	77 06                	ja     801b30 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b2a:	0f be d2             	movsbl %dl,%edx
  801b2d:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b30:	0f af ce             	imul   %esi,%ecx
  801b33:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b35:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b38:	83 eb 01             	sub    $0x1,%ebx
  801b3b:	83 fb 01             	cmp    $0x1,%ebx
  801b3e:	7f b5                	jg     801af5 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	56                   	push   %esi
  801b4c:	53                   	push   %ebx
  801b4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b56:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b58:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b5d:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b60:	83 ec 0c             	sub    $0xc,%esp
  801b63:	50                   	push   %eax
  801b64:	e8 a1 e7 ff ff       	call   80030a <sys_ipc_recv>
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	79 16                	jns    801b86 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b70:	85 f6                	test   %esi,%esi
  801b72:	74 06                	je     801b7a <ipc_recv+0x32>
			*from_env_store = 0;
  801b74:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b7a:	85 db                	test   %ebx,%ebx
  801b7c:	74 2c                	je     801baa <ipc_recv+0x62>
			*perm_store = 0;
  801b7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b84:	eb 24                	jmp    801baa <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b86:	85 f6                	test   %esi,%esi
  801b88:	74 0a                	je     801b94 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b8a:	a1 08 40 80 00       	mov    0x804008,%eax
  801b8f:	8b 40 74             	mov    0x74(%eax),%eax
  801b92:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b94:	85 db                	test   %ebx,%ebx
  801b96:	74 0a                	je     801ba2 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801b98:	a1 08 40 80 00       	mov    0x804008,%eax
  801b9d:	8b 40 78             	mov    0x78(%eax),%eax
  801ba0:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801ba2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	57                   	push   %edi
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bc3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bc5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bca:	0f 44 d8             	cmove  %eax,%ebx
  801bcd:	eb 1e                	jmp    801bed <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bcf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bd2:	74 14                	je     801be8 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bd4:	83 ec 04             	sub    $0x4,%esp
  801bd7:	68 a0 23 80 00       	push   $0x8023a0
  801bdc:	6a 44                	push   $0x44
  801bde:	68 cc 23 80 00       	push   $0x8023cc
  801be3:	e8 95 f4 ff ff       	call   80107d <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801be8:	e8 4e e5 ff ff       	call   80013b <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bed:	ff 75 14             	pushl  0x14(%ebp)
  801bf0:	53                   	push   %ebx
  801bf1:	56                   	push   %esi
  801bf2:	57                   	push   %edi
  801bf3:	e8 ef e6 ff ff       	call   8002e7 <sys_ipc_try_send>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 d0                	js     801bcf <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c12:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c15:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1b:	8b 52 50             	mov    0x50(%edx),%edx
  801c1e:	39 ca                	cmp    %ecx,%edx
  801c20:	75 0d                	jne    801c2f <ipc_find_env+0x28>
			return envs[i].env_id;
  801c22:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c25:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c2a:	8b 40 48             	mov    0x48(%eax),%eax
  801c2d:	eb 0f                	jmp    801c3e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2f:	83 c0 01             	add    $0x1,%eax
  801c32:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c37:	75 d9                	jne    801c12 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c46:	89 d0                	mov    %edx,%eax
  801c48:	c1 e8 16             	shr    $0x16,%eax
  801c4b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c57:	f6 c1 01             	test   $0x1,%cl
  801c5a:	74 1d                	je     801c79 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c5c:	c1 ea 0c             	shr    $0xc,%edx
  801c5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c66:	f6 c2 01             	test   $0x1,%dl
  801c69:	74 0e                	je     801c79 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c6b:	c1 ea 0c             	shr    $0xc,%edx
  801c6e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c75:	ef 
  801c76:	0f b7 c0             	movzwl %ax,%eax
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

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
