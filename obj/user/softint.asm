
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 2a 1f 80 00       	push   $0x801f2a
  800104:	6a 23                	push   $0x23
  800106:	68 47 1f 80 00       	push   $0x801f47
  80010b:	e8 69 0f 00 00       	call   801079 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 2a 1f 80 00       	push   $0x801f2a
  800185:	6a 23                	push   $0x23
  800187:	68 47 1f 80 00       	push   $0x801f47
  80018c:	e8 e8 0e 00 00       	call   801079 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 2a 1f 80 00       	push   $0x801f2a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 47 1f 80 00       	push   $0x801f47
  8001ce:	e8 a6 0e 00 00       	call   801079 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 2a 1f 80 00       	push   $0x801f2a
  800209:	6a 23                	push   $0x23
  80020b:	68 47 1f 80 00       	push   $0x801f47
  800210:	e8 64 0e 00 00       	call   801079 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 2a 1f 80 00       	push   $0x801f2a
  80024b:	6a 23                	push   $0x23
  80024d:	68 47 1f 80 00       	push   $0x801f47
  800252:	e8 22 0e 00 00       	call   801079 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 0a                	push   $0xa
  800288:	68 2a 1f 80 00       	push   $0x801f2a
  80028d:	6a 23                	push   $0x23
  80028f:	68 47 1f 80 00       	push   $0x801f47
  800294:	e8 e0 0d 00 00       	call   801079 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 09                	push   $0x9
  8002ca:	68 2a 1f 80 00       	push   $0x801f2a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 47 1f 80 00       	push   $0x801f47
  8002d6:	e8 9e 0d 00 00       	call   801079 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 2a 1f 80 00       	push   $0x801f2a
  800333:	6a 23                	push   $0x23
  800335:	68 47 1f 80 00       	push   $0x801f47
  80033a:	e8 3a 0d 00 00       	call   801079 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 08 40 80 00       	mov    0x804008,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 58 1f 80 00       	push   $0x801f58
  80044e:	e8 ff 0c 00 00       	call   801152 <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2) 
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0); 
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close) 
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 08 40 80 00       	mov    0x804008,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 99 1f 80 00       	push   $0x801f99
  800678:	e8 d5 0a 00 00       	call   801152 <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 08 40 80 00       	mov    0x804008,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 b5 1f 80 00       	push   $0x801fb5
  80074d:	e8 00 0a 00 00       	call   801152 <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 78 1f 80 00       	push   $0x801f78
  800802:	e8 4b 09 00 00       	call   801152 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 2b 02 00 00       	call   800af6 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 f1 12 00 00       	call   801c03 <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 80 12 00 00       	call   801bad <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 0a 12 00 00       	call   801b44 <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 c3 0d 00 00       	call   801786 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 08             	sub    $0x8,%esp
  8009ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f5:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8009fa:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 40 0c             	mov    0xc(%eax),%eax
  800a03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a08:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0e:	53                   	push   %ebx
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	68 08 50 80 00       	push   $0x805008
  800a17:	e8 fc 0e 00 00       	call   801918 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a21:	b8 04 00 00 00       	mov    $0x4,%eax
  800a26:	e8 cb fe ff ff       	call   8008f6 <fsipc>
  800a2b:	83 c4 10             	add    $0x10,%esp
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 3d                	js     800a6f <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a32:	39 d8                	cmp    %ebx,%eax
  800a34:	76 19                	jbe    800a4f <devfile_write+0x69>
  800a36:	68 e4 1f 80 00       	push   $0x801fe4
  800a3b:	68 eb 1f 80 00       	push   $0x801feb
  800a40:	68 9f 00 00 00       	push   $0x9f
  800a45:	68 00 20 80 00       	push   $0x802000
  800a4a:	e8 2a 06 00 00       	call   801079 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a4f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a54:	76 19                	jbe    800a6f <devfile_write+0x89>
  800a56:	68 18 20 80 00       	push   $0x802018
  800a5b:	68 eb 1f 80 00       	push   $0x801feb
  800a60:	68 a0 00 00 00       	push   $0xa0
  800a65:	68 00 20 80 00       	push   $0x802000
  800a6a:	e8 0a 06 00 00       	call   801079 <_panic>

	return r;
}
  800a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a82:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a87:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 03 00 00 00       	mov    $0x3,%eax
  800a97:	e8 5a fe ff ff       	call   8008f6 <fsipc>
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	78 4b                	js     800aed <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 16                	jae    800abc <devfile_read+0x48>
  800aa6:	68 e4 1f 80 00       	push   $0x801fe4
  800aab:	68 eb 1f 80 00       	push   $0x801feb
  800ab0:	6a 7e                	push   $0x7e
  800ab2:	68 00 20 80 00       	push   $0x802000
  800ab7:	e8 bd 05 00 00       	call   801079 <_panic>
	assert(r <= PGSIZE);
  800abc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac1:	7e 16                	jle    800ad9 <devfile_read+0x65>
  800ac3:	68 0b 20 80 00       	push   $0x80200b
  800ac8:	68 eb 1f 80 00       	push   $0x801feb
  800acd:	6a 7f                	push   $0x7f
  800acf:	68 00 20 80 00       	push   $0x802000
  800ad4:	e8 a0 05 00 00       	call   801079 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad9:	83 ec 04             	sub    $0x4,%esp
  800adc:	50                   	push   %eax
  800add:	68 00 50 80 00       	push   $0x805000
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	e8 2e 0e 00 00       	call   801918 <memmove>
	return r;
  800aea:	83 c4 10             	add    $0x10,%esp
}
  800aed:	89 d8                	mov    %ebx,%eax
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	53                   	push   %ebx
  800afa:	83 ec 20             	sub    $0x20,%esp
  800afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b00:	53                   	push   %ebx
  800b01:	e8 47 0c 00 00       	call   80174d <strlen>
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0e:	7f 67                	jg     800b77 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b16:	50                   	push   %eax
  800b17:	e8 52 f8 ff ff       	call   80036e <fd_alloc>
  800b1c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 57                	js     800b7c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	68 00 50 80 00       	push   $0x805000
  800b2e:	e8 53 0c 00 00       	call   801786 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	e8 ae fd ff ff       	call   8008f6 <fsipc>
  800b48:	89 c3                	mov    %eax,%ebx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	79 14                	jns    800b65 <open+0x6f>
		fd_close(fd, 0);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	6a 00                	push   $0x0
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 08 f9 ff ff       	call   800466 <fd_close>
		return r;
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	89 da                	mov    %ebx,%edx
  800b63:	eb 17                	jmp    800b7c <open+0x86>
	}

	return fd2num(fd);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6b:	e8 d7 f7 ff ff       	call   800347 <fd2num>
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 05                	jmp    800b7c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b77:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b93:	e8 5e fd ff ff       	call   8008f6 <fsipc>
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	ff 75 08             	pushl  0x8(%ebp)
  800ba8:	e8 aa f7 ff ff       	call   800357 <fd2data>
  800bad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800baf:	83 c4 08             	add    $0x8,%esp
  800bb2:	68 45 20 80 00       	push   $0x802045
  800bb7:	53                   	push   %ebx
  800bb8:	e8 c9 0b 00 00       	call   801786 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbd:	8b 46 04             	mov    0x4(%esi),%eax
  800bc0:	2b 06                	sub    (%esi),%eax
  800bc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bcf:	00 00 00 
	stat->st_dev = &devpipe;
  800bd2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd9:	30 80 00 
	return 0;
}
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf2:	53                   	push   %ebx
  800bf3:	6a 00                	push   $0x0
  800bf5:	e8 e1 f5 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bfa:	89 1c 24             	mov    %ebx,(%esp)
  800bfd:	e8 55 f7 ff ff       	call   800357 <fd2data>
  800c02:	83 c4 08             	add    $0x8,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 00                	push   $0x0
  800c08:	e8 ce f5 ff ff       	call   8001db <sys_page_unmap>
}
  800c0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c20:	a1 08 40 80 00       	mov    0x804008,%eax
  800c25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2e:	e8 09 10 00 00       	call   801c3c <pageref>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	89 3c 24             	mov    %edi,(%esp)
  800c38:	e8 ff 0f 00 00       	call   801c3c <pageref>
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	39 c3                	cmp    %eax,%ebx
  800c42:	0f 94 c1             	sete   %cl
  800c45:	0f b6 c9             	movzbl %cl,%ecx
  800c48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c54:	39 ce                	cmp    %ecx,%esi
  800c56:	74 1b                	je     800c73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c58:	39 c3                	cmp    %eax,%ebx
  800c5a:	75 c4                	jne    800c20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5c:	8b 42 58             	mov    0x58(%edx),%eax
  800c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c62:	50                   	push   %eax
  800c63:	56                   	push   %esi
  800c64:	68 4c 20 80 00       	push   $0x80204c
  800c69:	e8 e4 04 00 00       	call   801152 <cprintf>
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	eb ad                	jmp    800c20 <_pipeisclosed+0xe>
	}
}
  800c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 28             	sub    $0x28,%esp
  800c87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8a:	56                   	push   %esi
  800c8b:	e8 c7 f6 ff ff       	call   800357 <fd2data>
  800c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9a:	eb 4b                	jmp    800ce7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9c:	89 da                	mov    %ebx,%edx
  800c9e:	89 f0                	mov    %esi,%eax
  800ca0:	e8 6d ff ff ff       	call   800c12 <_pipeisclosed>
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	75 48                	jne    800cf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca9:	e8 89 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cae:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb1:	8b 0b                	mov    (%ebx),%ecx
  800cb3:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	73 e2                	jae    800c9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc4:	89 c2                	mov    %eax,%edx
  800cc6:	c1 fa 1f             	sar    $0x1f,%edx
  800cc9:	89 d1                	mov    %edx,%ecx
  800ccb:	c1 e9 1b             	shr    $0x1b,%ecx
  800cce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd1:	83 e2 1f             	and    $0x1f,%edx
  800cd4:	29 ca                	sub    %ecx,%edx
  800cd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cde:	83 c0 01             	add    $0x1,%eax
  800ce1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce4:	83 c7 01             	add    $0x1,%edi
  800ce7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cea:	75 c2                	jne    800cae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cec:	8b 45 10             	mov    0x10(%ebp),%eax
  800cef:	eb 05                	jmp    800cf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 18             	sub    $0x18,%esp
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0a:	57                   	push   %edi
  800d0b:	e8 47 f6 ff ff       	call   800357 <fd2data>
  800d10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	eb 3d                	jmp    800d59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1c:	85 db                	test   %ebx,%ebx
  800d1e:	74 04                	je     800d24 <devpipe_read+0x26>
				return i;
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	eb 44                	jmp    800d68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	89 f8                	mov    %edi,%eax
  800d28:	e8 e5 fe ff ff       	call   800c12 <_pipeisclosed>
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	75 32                	jne    800d63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d31:	e8 01 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d36:	8b 06                	mov    (%esi),%eax
  800d38:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3b:	74 df                	je     800d1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3d:	99                   	cltd   
  800d3e:	c1 ea 1b             	shr    $0x1b,%edx
  800d41:	01 d0                	add    %edx,%eax
  800d43:	83 e0 1f             	and    $0x1f,%eax
  800d46:	29 d0                	sub    %edx,%eax
  800d48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d56:	83 c3 01             	add    $0x1,%ebx
  800d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5c:	75 d8                	jne    800d36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d61:	eb 05                	jmp    800d68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 ed f5 ff ff       	call   80036e <fd_alloc>
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 2c 01 00 00    	js     800eba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f4             	pushl  -0xc(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 b6 f3 ff ff       	call   800156 <sys_page_alloc>
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	89 c2                	mov    %eax,%edx
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 0d 01 00 00    	js     800eba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db3:	50                   	push   %eax
  800db4:	e8 b5 f5 ff ff       	call   80036e <fd_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 e2 00 00 00    	js     800ea8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	68 07 04 00 00       	push   $0x407
  800dce:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 7e f3 ff ff       	call   800156 <sys_page_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 c3 00 00 00    	js     800ea8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	ff 75 f4             	pushl  -0xc(%ebp)
  800deb:	e8 67 f5 ff ff       	call   800357 <fd2data>
  800df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 c4 0c             	add    $0xc,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	50                   	push   %eax
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 54 f3 ff ff       	call   800156 <sys_page_alloc>
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	0f 88 89 00 00 00    	js     800e98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	ff 75 f0             	pushl  -0x10(%ebp)
  800e15:	e8 3d f5 ff ff       	call   800357 <fd2data>
  800e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e21:	50                   	push   %eax
  800e22:	6a 00                	push   $0x0
  800e24:	56                   	push   %esi
  800e25:	6a 00                	push   $0x0
  800e27:	e8 6d f3 ff ff       	call   800199 <sys_page_map>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	83 c4 20             	add    $0x20,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 55                	js     800e8a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	e8 dd f4 ff ff       	call   800347 <fd2num>
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6f:	83 c4 04             	add    $0x4,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	e8 cd f4 ff ff       	call   800347 <fd2num>
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	ba 00 00 00 00       	mov    $0x0,%edx
  800e88:	eb 30                	jmp    800eba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	56                   	push   %esi
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 46 f3 ff ff       	call   8001db <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 36 f3 ff ff       	call   8001db <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	6a 00                	push   $0x0
  800eb0:	e8 26 f3 ff ff       	call   8001db <sys_page_unmap>
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecc:	50                   	push   %eax
  800ecd:	ff 75 08             	pushl  0x8(%ebp)
  800ed0:	e8 e8 f4 ff ff       	call   8003bd <fd_lookup>
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 18                	js     800ef4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee2:	e8 70 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eec:	e8 21 fd ff ff       	call   800c12 <_pipeisclosed>
  800ef1:	83 c4 10             	add    $0x10,%esp
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f06:	68 64 20 80 00       	push   $0x802064
  800f0b:	ff 75 0c             	pushl  0xc(%ebp)
  800f0e:	e8 73 08 00 00       	call   801786 <strcpy>
	return 0;
}
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f31:	eb 2d                	jmp    800f60 <devcons_write+0x46>
		m = n - tot;
  800f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	53                   	push   %ebx
  800f47:	03 45 0c             	add    0xc(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	57                   	push   %edi
  800f4c:	e8 c7 09 00 00       	call   801918 <memmove>
		sys_cputs(buf, m);
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	53                   	push   %ebx
  800f55:	57                   	push   %edi
  800f56:	e8 3f f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5b:	01 de                	add    %ebx,%esi
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f65:	72 cc                	jb     800f33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7e:	74 2a                	je     800faa <devcons_read+0x3b>
  800f80:	eb 05                	jmp    800f87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f82:	e8 b0 f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f87:	e8 2c f1 ff ff       	call   8000b8 <sys_cgetc>
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	74 f2                	je     800f82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 16                	js     800faa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f94:	83 f8 04             	cmp    $0x4,%eax
  800f97:	74 0c                	je     800fa5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9c:	88 02                	mov    %al,(%edx)
	return 1;
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	eb 05                	jmp    800faa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb8:	6a 01                	push   $0x1
  800fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	e8 d7 f0 ff ff       	call   80009a <sys_cputs>
}
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <getchar>:

int
getchar(void)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fce:	6a 01                	push   $0x1
  800fd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 48 f6 ff ff       	call   800623 <read>
	if (r < 0)
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 0f                	js     800ff1 <getchar+0x29>
		return r;
	if (r < 1)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	7e 06                	jle    800fec <getchar+0x24>
		return -E_EOF;
	return c;
  800fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fea:	eb 05                	jmp    800ff1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	e8 b8 f3 ff ff       	call   8003bd <fd_lookup>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 11                	js     80101d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801015:	39 10                	cmp    %edx,(%eax)
  801017:	0f 94 c0             	sete   %al
  80101a:	0f b6 c0             	movzbl %al,%eax
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <opencons>:

int
opencons(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	e8 40 f3 ff ff       	call   80036e <fd_alloc>
  80102e:	83 c4 10             	add    $0x10,%esp
		return r;
  801031:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	78 3e                	js     801075 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	68 07 04 00 00       	push   $0x407
  80103f:	ff 75 f4             	pushl  -0xc(%ebp)
  801042:	6a 00                	push   $0x0
  801044:	e8 0d f1 ff ff       	call   800156 <sys_page_alloc>
  801049:	83 c4 10             	add    $0x10,%esp
		return r;
  80104c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 23                	js     801075 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801060:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	50                   	push   %eax
  80106b:	e8 d7 f2 ff ff       	call   800347 <fd2num>
  801070:	89 c2                	mov    %eax,%edx
  801072:	83 c4 10             	add    $0x10,%esp
}
  801075:	89 d0                	mov    %edx,%eax
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801081:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801087:	e8 8c f0 ff ff       	call   800118 <sys_getenvid>
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	ff 75 0c             	pushl  0xc(%ebp)
  801092:	ff 75 08             	pushl  0x8(%ebp)
  801095:	56                   	push   %esi
  801096:	50                   	push   %eax
  801097:	68 70 20 80 00       	push   $0x802070
  80109c:	e8 b1 00 00 00       	call   801152 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a1:	83 c4 18             	add    $0x18,%esp
  8010a4:	53                   	push   %ebx
  8010a5:	ff 75 10             	pushl  0x10(%ebp)
  8010a8:	e8 54 00 00 00       	call   801101 <vcprintf>
	cprintf("\n");
  8010ad:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010b4:	e8 99 00 00 00       	call   801152 <cprintf>
  8010b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bc:	cc                   	int3   
  8010bd:	eb fd                	jmp    8010bc <_panic+0x43>

008010bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c9:	8b 13                	mov    (%ebx),%edx
  8010cb:	8d 42 01             	lea    0x1(%edx),%eax
  8010ce:	89 03                	mov    %eax,(%ebx)
  8010d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010dc:	75 1a                	jne    8010f8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	68 ff 00 00 00       	push   $0xff
  8010e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e9:	50                   	push   %eax
  8010ea:	e8 ab ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801111:	00 00 00 
	b.cnt = 0;
  801114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111e:	ff 75 0c             	pushl  0xc(%ebp)
  801121:	ff 75 08             	pushl  0x8(%ebp)
  801124:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	68 bf 10 80 00       	push   $0x8010bf
  801130:	e8 54 01 00 00       	call   801289 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	e8 50 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  80114a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801158:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115b:	50                   	push   %eax
  80115c:	ff 75 08             	pushl  0x8(%ebp)
  80115f:	e8 9d ff ff ff       	call   801101 <vcprintf>
	va_end(ap);

	return cnt;
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 1c             	sub    $0x1c,%esp
  80116f:	89 c7                	mov    %eax,%edi
  801171:	89 d6                	mov    %edx,%esi
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	8b 55 0c             	mov    0xc(%ebp),%edx
  801179:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118d:	39 d3                	cmp    %edx,%ebx
  80118f:	72 05                	jb     801196 <printnum+0x30>
  801191:	39 45 10             	cmp    %eax,0x10(%ebp)
  801194:	77 45                	ja     8011db <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	ff 75 18             	pushl  0x18(%ebp)
  80119c:	8b 45 14             	mov    0x14(%ebp),%eax
  80119f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a2:	53                   	push   %ebx
  8011a3:	ff 75 10             	pushl  0x10(%ebp)
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8011af:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b5:	e8 c6 0a 00 00       	call   801c80 <__udivdi3>
  8011ba:	83 c4 18             	add    $0x18,%esp
  8011bd:	52                   	push   %edx
  8011be:	50                   	push   %eax
  8011bf:	89 f2                	mov    %esi,%edx
  8011c1:	89 f8                	mov    %edi,%eax
  8011c3:	e8 9e ff ff ff       	call   801166 <printnum>
  8011c8:	83 c4 20             	add    $0x20,%esp
  8011cb:	eb 18                	jmp    8011e5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	56                   	push   %esi
  8011d1:	ff 75 18             	pushl  0x18(%ebp)
  8011d4:	ff d7                	call   *%edi
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 03                	jmp    8011de <printnum+0x78>
  8011db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011de:	83 eb 01             	sub    $0x1,%ebx
  8011e1:	85 db                	test   %ebx,%ebx
  8011e3:	7f e8                	jg     8011cd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	56                   	push   %esi
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f8:	e8 b3 0b 00 00       	call   801db0 <__umoddi3>
  8011fd:	83 c4 14             	add    $0x14,%esp
  801200:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  801207:	50                   	push   %eax
  801208:	ff d7                	call   *%edi
}
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801218:	83 fa 01             	cmp    $0x1,%edx
  80121b:	7e 0e                	jle    80122b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121d:	8b 10                	mov    (%eax),%edx
  80121f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801222:	89 08                	mov    %ecx,(%eax)
  801224:	8b 02                	mov    (%edx),%eax
  801226:	8b 52 04             	mov    0x4(%edx),%edx
  801229:	eb 22                	jmp    80124d <getuint+0x38>
	else if (lflag)
  80122b:	85 d2                	test   %edx,%edx
  80122d:	74 10                	je     80123f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	8d 4a 04             	lea    0x4(%edx),%ecx
  801234:	89 08                	mov    %ecx,(%eax)
  801236:	8b 02                	mov    (%edx),%eax
  801238:	ba 00 00 00 00       	mov    $0x0,%edx
  80123d:	eb 0e                	jmp    80124d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80123f:	8b 10                	mov    (%eax),%edx
  801241:	8d 4a 04             	lea    0x4(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 02                	mov    (%edx),%eax
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801255:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801259:	8b 10                	mov    (%eax),%edx
  80125b:	3b 50 04             	cmp    0x4(%eax),%edx
  80125e:	73 0a                	jae    80126a <sprintputch+0x1b>
		*b->buf++ = ch;
  801260:	8d 4a 01             	lea    0x1(%edx),%ecx
  801263:	89 08                	mov    %ecx,(%eax)
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	88 02                	mov    %al,(%edx)
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801275:	50                   	push   %eax
  801276:	ff 75 10             	pushl  0x10(%ebp)
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 05 00 00 00       	call   801289 <vprintfmt>
	va_end(ap);
}
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 2c             	sub    $0x2c,%esp
  801292:	8b 75 08             	mov    0x8(%ebp),%esi
  801295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801298:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129b:	eb 12                	jmp    8012af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129d:	85 c0                	test   %eax,%eax
  80129f:	0f 84 38 04 00 00    	je     8016dd <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	53                   	push   %ebx
  8012a9:	50                   	push   %eax
  8012aa:	ff d6                	call   *%esi
  8012ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012af:	83 c7 01             	add    $0x1,%edi
  8012b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b6:	83 f8 25             	cmp    $0x25,%eax
  8012b9:	75 e2                	jne    80129d <vprintfmt+0x14>
  8012bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	eb 07                	jmp    8012e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	8d 47 01             	lea    0x1(%edi),%eax
  8012e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e8:	0f b6 07             	movzbl (%edi),%eax
  8012eb:	0f b6 c8             	movzbl %al,%ecx
  8012ee:	83 e8 23             	sub    $0x23,%eax
  8012f1:	3c 55                	cmp    $0x55,%al
  8012f3:	0f 87 c9 03 00 00    	ja     8016c2 <vprintfmt+0x439>
  8012f9:	0f b6 c0             	movzbl %al,%eax
  8012fc:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801306:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130a:	eb d6                	jmp    8012e2 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80130c:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801313:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801319:	eb 94                	jmp    8012af <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  80131b:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801322:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801328:	eb 85                	jmp    8012af <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  80132a:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  801331:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801337:	e9 73 ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80133c:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801343:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801349:	e9 61 ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80134e:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801355:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  80135b:	e9 4f ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  801360:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801367:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80136d:	e9 3d ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801372:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801379:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80137f:	e9 2b ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801384:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  80138b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  801391:	e9 19 ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  801396:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  80139d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013a3:	e9 07 ff ff ff       	jmp    8012af <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013a8:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013af:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013b5:	e9 f5 fe ff ff       	jmp    8012af <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013cc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013d2:	83 fa 09             	cmp    $0x9,%edx
  8013d5:	77 3f                	ja     801416 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013da:	eb e9                	jmp    8013c5 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013df:	8d 48 04             	lea    0x4(%eax),%ecx
  8013e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013e5:	8b 00                	mov    (%eax),%eax
  8013e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013ed:	eb 2d                	jmp    80141c <vprintfmt+0x193>
  8013ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f9:	0f 49 c8             	cmovns %eax,%ecx
  8013fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801402:	e9 db fe ff ff       	jmp    8012e2 <vprintfmt+0x59>
  801407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80140a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801411:	e9 cc fe ff ff       	jmp    8012e2 <vprintfmt+0x59>
  801416:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801419:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80141c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801420:	0f 89 bc fe ff ff    	jns    8012e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801426:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801429:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801433:	e9 aa fe ff ff       	jmp    8012e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801438:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80143e:	e9 9f fe ff ff       	jmp    8012e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801443:	8b 45 14             	mov    0x14(%ebp),%eax
  801446:	8d 50 04             	lea    0x4(%eax),%edx
  801449:	89 55 14             	mov    %edx,0x14(%ebp)
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	53                   	push   %ebx
  801450:	ff 30                	pushl  (%eax)
  801452:	ff d6                	call   *%esi
			break;
  801454:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80145a:	e9 50 fe ff ff       	jmp    8012af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80145f:	8b 45 14             	mov    0x14(%ebp),%eax
  801462:	8d 50 04             	lea    0x4(%eax),%edx
  801465:	89 55 14             	mov    %edx,0x14(%ebp)
  801468:	8b 00                	mov    (%eax),%eax
  80146a:	99                   	cltd   
  80146b:	31 d0                	xor    %edx,%eax
  80146d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80146f:	83 f8 0f             	cmp    $0xf,%eax
  801472:	7f 0b                	jg     80147f <vprintfmt+0x1f6>
  801474:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  80147b:	85 d2                	test   %edx,%edx
  80147d:	75 18                	jne    801497 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80147f:	50                   	push   %eax
  801480:	68 ab 20 80 00       	push   $0x8020ab
  801485:	53                   	push   %ebx
  801486:	56                   	push   %esi
  801487:	e8 e0 fd ff ff       	call   80126c <printfmt>
  80148c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80148f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801492:	e9 18 fe ff ff       	jmp    8012af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801497:	52                   	push   %edx
  801498:	68 fd 1f 80 00       	push   $0x801ffd
  80149d:	53                   	push   %ebx
  80149e:	56                   	push   %esi
  80149f:	e8 c8 fd ff ff       	call   80126c <printfmt>
  8014a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014aa:	e9 00 fe ff ff       	jmp    8012af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014af:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b2:	8d 50 04             	lea    0x4(%eax),%edx
  8014b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014ba:	85 ff                	test   %edi,%edi
  8014bc:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014c8:	0f 8e 94 00 00 00    	jle    801562 <vprintfmt+0x2d9>
  8014ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014d2:	0f 84 98 00 00 00    	je     801570 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	ff 75 d0             	pushl  -0x30(%ebp)
  8014de:	57                   	push   %edi
  8014df:	e8 81 02 00 00       	call   801765 <strnlen>
  8014e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014e7:	29 c1                	sub    %eax,%ecx
  8014e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8014f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8014f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8014fb:	eb 0f                	jmp    80150c <vprintfmt+0x283>
					putch(padc, putdat);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	53                   	push   %ebx
  801501:	ff 75 e0             	pushl  -0x20(%ebp)
  801504:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801506:	83 ef 01             	sub    $0x1,%edi
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	85 ff                	test   %edi,%edi
  80150e:	7f ed                	jg     8014fd <vprintfmt+0x274>
  801510:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801513:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801516:	85 c9                	test   %ecx,%ecx
  801518:	b8 00 00 00 00       	mov    $0x0,%eax
  80151d:	0f 49 c1             	cmovns %ecx,%eax
  801520:	29 c1                	sub    %eax,%ecx
  801522:	89 75 08             	mov    %esi,0x8(%ebp)
  801525:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80152b:	89 cb                	mov    %ecx,%ebx
  80152d:	eb 4d                	jmp    80157c <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80152f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801533:	74 1b                	je     801550 <vprintfmt+0x2c7>
  801535:	0f be c0             	movsbl %al,%eax
  801538:	83 e8 20             	sub    $0x20,%eax
  80153b:	83 f8 5e             	cmp    $0x5e,%eax
  80153e:	76 10                	jbe    801550 <vprintfmt+0x2c7>
					putch('?', putdat);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	6a 3f                	push   $0x3f
  801548:	ff 55 08             	call   *0x8(%ebp)
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	eb 0d                	jmp    80155d <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	ff 75 0c             	pushl  0xc(%ebp)
  801556:	52                   	push   %edx
  801557:	ff 55 08             	call   *0x8(%ebp)
  80155a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80155d:	83 eb 01             	sub    $0x1,%ebx
  801560:	eb 1a                	jmp    80157c <vprintfmt+0x2f3>
  801562:	89 75 08             	mov    %esi,0x8(%ebp)
  801565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80156b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80156e:	eb 0c                	jmp    80157c <vprintfmt+0x2f3>
  801570:	89 75 08             	mov    %esi,0x8(%ebp)
  801573:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80157c:	83 c7 01             	add    $0x1,%edi
  80157f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801583:	0f be d0             	movsbl %al,%edx
  801586:	85 d2                	test   %edx,%edx
  801588:	74 23                	je     8015ad <vprintfmt+0x324>
  80158a:	85 f6                	test   %esi,%esi
  80158c:	78 a1                	js     80152f <vprintfmt+0x2a6>
  80158e:	83 ee 01             	sub    $0x1,%esi
  801591:	79 9c                	jns    80152f <vprintfmt+0x2a6>
  801593:	89 df                	mov    %ebx,%edi
  801595:	8b 75 08             	mov    0x8(%ebp),%esi
  801598:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80159b:	eb 18                	jmp    8015b5 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	6a 20                	push   $0x20
  8015a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015a5:	83 ef 01             	sub    $0x1,%edi
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	eb 08                	jmp    8015b5 <vprintfmt+0x32c>
  8015ad:	89 df                	mov    %ebx,%edi
  8015af:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b5:	85 ff                	test   %edi,%edi
  8015b7:	7f e4                	jg     80159d <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015bc:	e9 ee fc ff ff       	jmp    8012af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015c1:	83 fa 01             	cmp    $0x1,%edx
  8015c4:	7e 16                	jle    8015dc <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c9:	8d 50 08             	lea    0x8(%eax),%edx
  8015cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8015cf:	8b 50 04             	mov    0x4(%eax),%edx
  8015d2:	8b 00                	mov    (%eax),%eax
  8015d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015da:	eb 32                	jmp    80160e <vprintfmt+0x385>
	else if (lflag)
  8015dc:	85 d2                	test   %edx,%edx
  8015de:	74 18                	je     8015f8 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e3:	8d 50 04             	lea    0x4(%eax),%edx
  8015e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8015e9:	8b 00                	mov    (%eax),%eax
  8015eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ee:	89 c1                	mov    %eax,%ecx
  8015f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8015f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015f6:	eb 16                	jmp    80160e <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8015f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fb:	8d 50 04             	lea    0x4(%eax),%edx
  8015fe:	89 55 14             	mov    %edx,0x14(%ebp)
  801601:	8b 00                	mov    (%eax),%eax
  801603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801606:	89 c1                	mov    %eax,%ecx
  801608:	c1 f9 1f             	sar    $0x1f,%ecx
  80160b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80160e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801611:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801614:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801619:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80161d:	79 6f                	jns    80168e <vprintfmt+0x405>
				putch('-', putdat);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	53                   	push   %ebx
  801623:	6a 2d                	push   $0x2d
  801625:	ff d6                	call   *%esi
				num = -(long long) num;
  801627:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80162a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80162d:	f7 d8                	neg    %eax
  80162f:	83 d2 00             	adc    $0x0,%edx
  801632:	f7 da                	neg    %edx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	eb 55                	jmp    80168e <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801639:	8d 45 14             	lea    0x14(%ebp),%eax
  80163c:	e8 d4 fb ff ff       	call   801215 <getuint>
			base = 10;
  801641:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801646:	eb 46                	jmp    80168e <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801648:	8d 45 14             	lea    0x14(%ebp),%eax
  80164b:	e8 c5 fb ff ff       	call   801215 <getuint>
			base = 8;
  801650:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801655:	eb 37                	jmp    80168e <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	53                   	push   %ebx
  80165b:	6a 30                	push   $0x30
  80165d:	ff d6                	call   *%esi
			putch('x', putdat);
  80165f:	83 c4 08             	add    $0x8,%esp
  801662:	53                   	push   %ebx
  801663:	6a 78                	push   $0x78
  801665:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801667:	8b 45 14             	mov    0x14(%ebp),%eax
  80166a:	8d 50 04             	lea    0x4(%eax),%edx
  80166d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801670:	8b 00                	mov    (%eax),%eax
  801672:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801677:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80167a:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80167f:	eb 0d                	jmp    80168e <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801681:	8d 45 14             	lea    0x14(%ebp),%eax
  801684:	e8 8c fb ff ff       	call   801215 <getuint>
			base = 16;
  801689:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801695:	51                   	push   %ecx
  801696:	ff 75 e0             	pushl  -0x20(%ebp)
  801699:	57                   	push   %edi
  80169a:	52                   	push   %edx
  80169b:	50                   	push   %eax
  80169c:	89 da                	mov    %ebx,%edx
  80169e:	89 f0                	mov    %esi,%eax
  8016a0:	e8 c1 fa ff ff       	call   801166 <printnum>
			break;
  8016a5:	83 c4 20             	add    $0x20,%esp
  8016a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016ab:	e9 ff fb ff ff       	jmp    8012af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	53                   	push   %ebx
  8016b4:	51                   	push   %ecx
  8016b5:	ff d6                	call   *%esi
			break;
  8016b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016bd:	e9 ed fb ff ff       	jmp    8012af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	53                   	push   %ebx
  8016c6:	6a 25                	push   $0x25
  8016c8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	eb 03                	jmp    8016d2 <vprintfmt+0x449>
  8016cf:	83 ef 01             	sub    $0x1,%edi
  8016d2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016d6:	75 f7                	jne    8016cf <vprintfmt+0x446>
  8016d8:	e9 d2 fb ff ff       	jmp    8012af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	83 ec 18             	sub    $0x18,%esp
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801702:	85 c0                	test   %eax,%eax
  801704:	74 26                	je     80172c <vsnprintf+0x47>
  801706:	85 d2                	test   %edx,%edx
  801708:	7e 22                	jle    80172c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80170a:	ff 75 14             	pushl  0x14(%ebp)
  80170d:	ff 75 10             	pushl  0x10(%ebp)
  801710:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	68 4f 12 80 00       	push   $0x80124f
  801719:	e8 6b fb ff ff       	call   801289 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80171e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801721:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	eb 05                	jmp    801731 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80172c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801739:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80173c:	50                   	push   %eax
  80173d:	ff 75 10             	pushl  0x10(%ebp)
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	ff 75 08             	pushl  0x8(%ebp)
  801746:	e8 9a ff ff ff       	call   8016e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
  801758:	eb 03                	jmp    80175d <strlen+0x10>
		n++;
  80175a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80175d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801761:	75 f7                	jne    80175a <strlen+0xd>
		n++;
	return n;
}
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	eb 03                	jmp    801778 <strnlen+0x13>
		n++;
  801775:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801778:	39 c2                	cmp    %eax,%edx
  80177a:	74 08                	je     801784 <strnlen+0x1f>
  80177c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801780:	75 f3                	jne    801775 <strnlen+0x10>
  801782:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801790:	89 c2                	mov    %eax,%edx
  801792:	83 c2 01             	add    $0x1,%edx
  801795:	83 c1 01             	add    $0x1,%ecx
  801798:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80179c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80179f:	84 db                	test   %bl,%bl
  8017a1:	75 ef                	jne    801792 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017a3:	5b                   	pop    %ebx
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017ad:	53                   	push   %ebx
  8017ae:	e8 9a ff ff ff       	call   80174d <strlen>
  8017b3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017b6:	ff 75 0c             	pushl  0xc(%ebp)
  8017b9:	01 d8                	add    %ebx,%eax
  8017bb:	50                   	push   %eax
  8017bc:	e8 c5 ff ff ff       	call   801786 <strcpy>
	return dst;
}
  8017c1:	89 d8                	mov    %ebx,%eax
  8017c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c6:	c9                   	leave  
  8017c7:	c3                   	ret    

008017c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d3:	89 f3                	mov    %esi,%ebx
  8017d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017d8:	89 f2                	mov    %esi,%edx
  8017da:	eb 0f                	jmp    8017eb <strncpy+0x23>
		*dst++ = *src;
  8017dc:	83 c2 01             	add    $0x1,%edx
  8017df:	0f b6 01             	movzbl (%ecx),%eax
  8017e2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017e5:	80 39 01             	cmpb   $0x1,(%ecx)
  8017e8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017eb:	39 da                	cmp    %ebx,%edx
  8017ed:	75 ed                	jne    8017dc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017ef:	89 f0                	mov    %esi,%eax
  8017f1:	5b                   	pop    %ebx
  8017f2:	5e                   	pop    %esi
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	56                   	push   %esi
  8017f9:	53                   	push   %ebx
  8017fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801800:	8b 55 10             	mov    0x10(%ebp),%edx
  801803:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801805:	85 d2                	test   %edx,%edx
  801807:	74 21                	je     80182a <strlcpy+0x35>
  801809:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80180d:	89 f2                	mov    %esi,%edx
  80180f:	eb 09                	jmp    80181a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801811:	83 c2 01             	add    $0x1,%edx
  801814:	83 c1 01             	add    $0x1,%ecx
  801817:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80181a:	39 c2                	cmp    %eax,%edx
  80181c:	74 09                	je     801827 <strlcpy+0x32>
  80181e:	0f b6 19             	movzbl (%ecx),%ebx
  801821:	84 db                	test   %bl,%bl
  801823:	75 ec                	jne    801811 <strlcpy+0x1c>
  801825:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801827:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80182a:	29 f0                	sub    %esi,%eax
}
  80182c:	5b                   	pop    %ebx
  80182d:	5e                   	pop    %esi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801836:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801839:	eb 06                	jmp    801841 <strcmp+0x11>
		p++, q++;
  80183b:	83 c1 01             	add    $0x1,%ecx
  80183e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801841:	0f b6 01             	movzbl (%ecx),%eax
  801844:	84 c0                	test   %al,%al
  801846:	74 04                	je     80184c <strcmp+0x1c>
  801848:	3a 02                	cmp    (%edx),%al
  80184a:	74 ef                	je     80183b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80184c:	0f b6 c0             	movzbl %al,%eax
  80184f:	0f b6 12             	movzbl (%edx),%edx
  801852:	29 d0                	sub    %edx,%eax
}
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	53                   	push   %ebx
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801860:	89 c3                	mov    %eax,%ebx
  801862:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801865:	eb 06                	jmp    80186d <strncmp+0x17>
		n--, p++, q++;
  801867:	83 c0 01             	add    $0x1,%eax
  80186a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80186d:	39 d8                	cmp    %ebx,%eax
  80186f:	74 15                	je     801886 <strncmp+0x30>
  801871:	0f b6 08             	movzbl (%eax),%ecx
  801874:	84 c9                	test   %cl,%cl
  801876:	74 04                	je     80187c <strncmp+0x26>
  801878:	3a 0a                	cmp    (%edx),%cl
  80187a:	74 eb                	je     801867 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80187c:	0f b6 00             	movzbl (%eax),%eax
  80187f:	0f b6 12             	movzbl (%edx),%edx
  801882:	29 d0                	sub    %edx,%eax
  801884:	eb 05                	jmp    80188b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80188b:	5b                   	pop    %ebx
  80188c:	5d                   	pop    %ebp
  80188d:	c3                   	ret    

0080188e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	8b 45 08             	mov    0x8(%ebp),%eax
  801894:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801898:	eb 07                	jmp    8018a1 <strchr+0x13>
		if (*s == c)
  80189a:	38 ca                	cmp    %cl,%dl
  80189c:	74 0f                	je     8018ad <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80189e:	83 c0 01             	add    $0x1,%eax
  8018a1:	0f b6 10             	movzbl (%eax),%edx
  8018a4:	84 d2                	test   %dl,%dl
  8018a6:	75 f2                	jne    80189a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018b9:	eb 03                	jmp    8018be <strfind+0xf>
  8018bb:	83 c0 01             	add    $0x1,%eax
  8018be:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018c1:	38 ca                	cmp    %cl,%dl
  8018c3:	74 04                	je     8018c9 <strfind+0x1a>
  8018c5:	84 d2                	test   %dl,%dl
  8018c7:	75 f2                	jne    8018bb <strfind+0xc>
			break;
	return (char *) s;
}
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	57                   	push   %edi
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018d7:	85 c9                	test   %ecx,%ecx
  8018d9:	74 36                	je     801911 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018db:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018e1:	75 28                	jne    80190b <memset+0x40>
  8018e3:	f6 c1 03             	test   $0x3,%cl
  8018e6:	75 23                	jne    80190b <memset+0x40>
		c &= 0xFF;
  8018e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018ec:	89 d3                	mov    %edx,%ebx
  8018ee:	c1 e3 08             	shl    $0x8,%ebx
  8018f1:	89 d6                	mov    %edx,%esi
  8018f3:	c1 e6 18             	shl    $0x18,%esi
  8018f6:	89 d0                	mov    %edx,%eax
  8018f8:	c1 e0 10             	shl    $0x10,%eax
  8018fb:	09 f0                	or     %esi,%eax
  8018fd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018ff:	89 d8                	mov    %ebx,%eax
  801901:	09 d0                	or     %edx,%eax
  801903:	c1 e9 02             	shr    $0x2,%ecx
  801906:	fc                   	cld    
  801907:	f3 ab                	rep stos %eax,%es:(%edi)
  801909:	eb 06                	jmp    801911 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80190b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190e:	fc                   	cld    
  80190f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801911:	89 f8                	mov    %edi,%eax
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	57                   	push   %edi
  80191c:	56                   	push   %esi
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 75 0c             	mov    0xc(%ebp),%esi
  801923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801926:	39 c6                	cmp    %eax,%esi
  801928:	73 35                	jae    80195f <memmove+0x47>
  80192a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80192d:	39 d0                	cmp    %edx,%eax
  80192f:	73 2e                	jae    80195f <memmove+0x47>
		s += n;
		d += n;
  801931:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801934:	89 d6                	mov    %edx,%esi
  801936:	09 fe                	or     %edi,%esi
  801938:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80193e:	75 13                	jne    801953 <memmove+0x3b>
  801940:	f6 c1 03             	test   $0x3,%cl
  801943:	75 0e                	jne    801953 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801945:	83 ef 04             	sub    $0x4,%edi
  801948:	8d 72 fc             	lea    -0x4(%edx),%esi
  80194b:	c1 e9 02             	shr    $0x2,%ecx
  80194e:	fd                   	std    
  80194f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801951:	eb 09                	jmp    80195c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801953:	83 ef 01             	sub    $0x1,%edi
  801956:	8d 72 ff             	lea    -0x1(%edx),%esi
  801959:	fd                   	std    
  80195a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80195c:	fc                   	cld    
  80195d:	eb 1d                	jmp    80197c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80195f:	89 f2                	mov    %esi,%edx
  801961:	09 c2                	or     %eax,%edx
  801963:	f6 c2 03             	test   $0x3,%dl
  801966:	75 0f                	jne    801977 <memmove+0x5f>
  801968:	f6 c1 03             	test   $0x3,%cl
  80196b:	75 0a                	jne    801977 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80196d:	c1 e9 02             	shr    $0x2,%ecx
  801970:	89 c7                	mov    %eax,%edi
  801972:	fc                   	cld    
  801973:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801975:	eb 05                	jmp    80197c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801977:	89 c7                	mov    %eax,%edi
  801979:	fc                   	cld    
  80197a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80197c:	5e                   	pop    %esi
  80197d:	5f                   	pop    %edi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801983:	ff 75 10             	pushl  0x10(%ebp)
  801986:	ff 75 0c             	pushl  0xc(%ebp)
  801989:	ff 75 08             	pushl  0x8(%ebp)
  80198c:	e8 87 ff ff ff       	call   801918 <memmove>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199e:	89 c6                	mov    %eax,%esi
  8019a0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019a3:	eb 1a                	jmp    8019bf <memcmp+0x2c>
		if (*s1 != *s2)
  8019a5:	0f b6 08             	movzbl (%eax),%ecx
  8019a8:	0f b6 1a             	movzbl (%edx),%ebx
  8019ab:	38 d9                	cmp    %bl,%cl
  8019ad:	74 0a                	je     8019b9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019af:	0f b6 c1             	movzbl %cl,%eax
  8019b2:	0f b6 db             	movzbl %bl,%ebx
  8019b5:	29 d8                	sub    %ebx,%eax
  8019b7:	eb 0f                	jmp    8019c8 <memcmp+0x35>
		s1++, s2++;
  8019b9:	83 c0 01             	add    $0x1,%eax
  8019bc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019bf:	39 f0                	cmp    %esi,%eax
  8019c1:	75 e2                	jne    8019a5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c8:	5b                   	pop    %ebx
  8019c9:	5e                   	pop    %esi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019d3:	89 c1                	mov    %eax,%ecx
  8019d5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019d8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019dc:	eb 0a                	jmp    8019e8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019de:	0f b6 10             	movzbl (%eax),%edx
  8019e1:	39 da                	cmp    %ebx,%edx
  8019e3:	74 07                	je     8019ec <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e5:	83 c0 01             	add    $0x1,%eax
  8019e8:	39 c8                	cmp    %ecx,%eax
  8019ea:	72 f2                	jb     8019de <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019ec:	5b                   	pop    %ebx
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	57                   	push   %edi
  8019f3:	56                   	push   %esi
  8019f4:	53                   	push   %ebx
  8019f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019fb:	eb 03                	jmp    801a00 <strtol+0x11>
		s++;
  8019fd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a00:	0f b6 01             	movzbl (%ecx),%eax
  801a03:	3c 20                	cmp    $0x20,%al
  801a05:	74 f6                	je     8019fd <strtol+0xe>
  801a07:	3c 09                	cmp    $0x9,%al
  801a09:	74 f2                	je     8019fd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a0b:	3c 2b                	cmp    $0x2b,%al
  801a0d:	75 0a                	jne    801a19 <strtol+0x2a>
		s++;
  801a0f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a12:	bf 00 00 00 00       	mov    $0x0,%edi
  801a17:	eb 11                	jmp    801a2a <strtol+0x3b>
  801a19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a1e:	3c 2d                	cmp    $0x2d,%al
  801a20:	75 08                	jne    801a2a <strtol+0x3b>
		s++, neg = 1;
  801a22:	83 c1 01             	add    $0x1,%ecx
  801a25:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a30:	75 15                	jne    801a47 <strtol+0x58>
  801a32:	80 39 30             	cmpb   $0x30,(%ecx)
  801a35:	75 10                	jne    801a47 <strtol+0x58>
  801a37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a3b:	75 7c                	jne    801ab9 <strtol+0xca>
		s += 2, base = 16;
  801a3d:	83 c1 02             	add    $0x2,%ecx
  801a40:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a45:	eb 16                	jmp    801a5d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	75 12                	jne    801a5d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a4b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a50:	80 39 30             	cmpb   $0x30,(%ecx)
  801a53:	75 08                	jne    801a5d <strtol+0x6e>
		s++, base = 8;
  801a55:	83 c1 01             	add    $0x1,%ecx
  801a58:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a62:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a65:	0f b6 11             	movzbl (%ecx),%edx
  801a68:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a6b:	89 f3                	mov    %esi,%ebx
  801a6d:	80 fb 09             	cmp    $0x9,%bl
  801a70:	77 08                	ja     801a7a <strtol+0x8b>
			dig = *s - '0';
  801a72:	0f be d2             	movsbl %dl,%edx
  801a75:	83 ea 30             	sub    $0x30,%edx
  801a78:	eb 22                	jmp    801a9c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a7a:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a7d:	89 f3                	mov    %esi,%ebx
  801a7f:	80 fb 19             	cmp    $0x19,%bl
  801a82:	77 08                	ja     801a8c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a84:	0f be d2             	movsbl %dl,%edx
  801a87:	83 ea 57             	sub    $0x57,%edx
  801a8a:	eb 10                	jmp    801a9c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a8f:	89 f3                	mov    %esi,%ebx
  801a91:	80 fb 19             	cmp    $0x19,%bl
  801a94:	77 16                	ja     801aac <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a96:	0f be d2             	movsbl %dl,%edx
  801a99:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a9c:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a9f:	7d 0b                	jge    801aac <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801aa1:	83 c1 01             	add    $0x1,%ecx
  801aa4:	0f af 45 10          	imul   0x10(%ebp),%eax
  801aa8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801aaa:	eb b9                	jmp    801a65 <strtol+0x76>

	if (endptr)
  801aac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ab0:	74 0d                	je     801abf <strtol+0xd0>
		*endptr = (char *) s;
  801ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab5:	89 0e                	mov    %ecx,(%esi)
  801ab7:	eb 06                	jmp    801abf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ab9:	85 db                	test   %ebx,%ebx
  801abb:	74 98                	je     801a55 <strtol+0x66>
  801abd:	eb 9e                	jmp    801a5d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	f7 da                	neg    %edx
  801ac3:	85 ff                	test   %edi,%edi
  801ac5:	0f 45 c2             	cmovne %edx,%eax
}
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5f                   	pop    %edi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	57                   	push   %edi
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 04             	sub    $0x4,%esp
  801ad6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801ad9:	57                   	push   %edi
  801ada:	e8 6e fc ff ff       	call   80174d <strlen>
  801adf:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801ae2:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801ae5:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801aef:	eb 46                	jmp    801b37 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801af1:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801af5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801af8:	80 f9 09             	cmp    $0x9,%cl
  801afb:	77 08                	ja     801b05 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801afd:	0f be d2             	movsbl %dl,%edx
  801b00:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b03:	eb 27                	jmp    801b2c <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b05:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b08:	80 f9 05             	cmp    $0x5,%cl
  801b0b:	77 08                	ja     801b15 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b0d:	0f be d2             	movsbl %dl,%edx
  801b10:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b13:	eb 17                	jmp    801b2c <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b15:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b18:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b1b:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b20:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b24:	77 06                	ja     801b2c <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b26:	0f be d2             	movsbl %dl,%edx
  801b29:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b2c:	0f af ce             	imul   %esi,%ecx
  801b2f:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b31:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b34:	83 eb 01             	sub    $0x1,%ebx
  801b37:	83 fb 01             	cmp    $0x1,%ebx
  801b3a:	7f b5                	jg     801af1 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	8b 75 08             	mov    0x8(%ebp),%esi
  801b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b52:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b54:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b59:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	50                   	push   %eax
  801b60:	e8 a1 e7 ff ff       	call   800306 <sys_ipc_recv>
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	79 16                	jns    801b82 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b6c:	85 f6                	test   %esi,%esi
  801b6e:	74 06                	je     801b76 <ipc_recv+0x32>
			*from_env_store = 0;
  801b70:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b76:	85 db                	test   %ebx,%ebx
  801b78:	74 2c                	je     801ba6 <ipc_recv+0x62>
			*perm_store = 0;
  801b7a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b80:	eb 24                	jmp    801ba6 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b82:	85 f6                	test   %esi,%esi
  801b84:	74 0a                	je     801b90 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b86:	a1 08 40 80 00       	mov    0x804008,%eax
  801b8b:	8b 40 74             	mov    0x74(%eax),%eax
  801b8e:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b90:	85 db                	test   %ebx,%ebx
  801b92:	74 0a                	je     801b9e <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801b94:	a1 08 40 80 00       	mov    0x804008,%eax
  801b99:	8b 40 78             	mov    0x78(%eax),%eax
  801b9c:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801b9e:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	57                   	push   %edi
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bbf:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bc1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bc6:	0f 44 d8             	cmove  %eax,%ebx
  801bc9:	eb 1e                	jmp    801be9 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bcb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bce:	74 14                	je     801be4 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bd0:	83 ec 04             	sub    $0x4,%esp
  801bd3:	68 a0 23 80 00       	push   $0x8023a0
  801bd8:	6a 44                	push   $0x44
  801bda:	68 cc 23 80 00       	push   $0x8023cc
  801bdf:	e8 95 f4 ff ff       	call   801079 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801be4:	e8 4e e5 ff ff       	call   800137 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801be9:	ff 75 14             	pushl  0x14(%ebp)
  801bec:	53                   	push   %ebx
  801bed:	56                   	push   %esi
  801bee:	57                   	push   %edi
  801bef:	e8 ef e6 ff ff       	call   8002e3 <sys_ipc_try_send>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 d0                	js     801bcb <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c0e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c11:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c17:	8b 52 50             	mov    0x50(%edx),%edx
  801c1a:	39 ca                	cmp    %ecx,%edx
  801c1c:	75 0d                	jne    801c2b <ipc_find_env+0x28>
			return envs[i].env_id;
  801c1e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c21:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c26:	8b 40 48             	mov    0x48(%eax),%eax
  801c29:	eb 0f                	jmp    801c3a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2b:	83 c0 01             	add    $0x1,%eax
  801c2e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c33:	75 d9                	jne    801c0e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    

00801c3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c42:	89 d0                	mov    %edx,%eax
  801c44:	c1 e8 16             	shr    $0x16,%eax
  801c47:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c53:	f6 c1 01             	test   $0x1,%cl
  801c56:	74 1d                	je     801c75 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c58:	c1 ea 0c             	shr    $0xc,%edx
  801c5b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c62:	f6 c2 01             	test   $0x1,%dl
  801c65:	74 0e                	je     801c75 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c67:	c1 ea 0c             	shr    $0xc,%edx
  801c6a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c71:	ef 
  801c72:	0f b7 c0             	movzwl %ax,%eax
}
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    
  801c77:	66 90                	xchg   %ax,%ax
  801c79:	66 90                	xchg   %ax,%ax
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
