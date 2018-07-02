
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 2a 1f 80 00       	push   $0x801f2a
  80010c:	6a 23                	push   $0x23
  80010e:	68 47 1f 80 00       	push   $0x801f47
  800113:	e8 69 0f 00 00       	call   801081 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 2a 1f 80 00       	push   $0x801f2a
  80018d:	6a 23                	push   $0x23
  80018f:	68 47 1f 80 00       	push   $0x801f47
  800194:	e8 e8 0e 00 00       	call   801081 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 2a 1f 80 00       	push   $0x801f2a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 47 1f 80 00       	push   $0x801f47
  8001d6:	e8 a6 0e 00 00       	call   801081 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 2a 1f 80 00       	push   $0x801f2a
  800211:	6a 23                	push   $0x23
  800213:	68 47 1f 80 00       	push   $0x801f47
  800218:	e8 64 0e 00 00       	call   801081 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 2a 1f 80 00       	push   $0x801f2a
  800253:	6a 23                	push   $0x23
  800255:	68 47 1f 80 00       	push   $0x801f47
  80025a:	e8 22 0e 00 00       	call   801081 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 0a                	push   $0xa
  800290:	68 2a 1f 80 00       	push   $0x801f2a
  800295:	6a 23                	push   $0x23
  800297:	68 47 1f 80 00       	push   $0x801f47
  80029c:	e8 e0 0d 00 00       	call   801081 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 09                	push   $0x9
  8002d2:	68 2a 1f 80 00       	push   $0x801f2a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 47 1f 80 00       	push   $0x801f47
  8002de:	e8 9e 0d 00 00       	call   801081 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 2a 1f 80 00       	push   $0x801f2a
  80033b:	6a 23                	push   $0x23
  80033d:	68 47 1f 80 00       	push   $0x801f47
  800342:	e8 3a 0d 00 00       	call   801081 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 08 40 80 00       	mov    0x804008,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 58 1f 80 00       	push   $0x801f58
  800456:	e8 ff 0c 00 00       	call   80115a <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2) 
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0); 
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close) 
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 08 40 80 00       	mov    0x804008,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 99 1f 80 00       	push   $0x801f99
  800680:	e8 d5 0a 00 00       	call   80115a <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 08 40 80 00       	mov    0x804008,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 b5 1f 80 00       	push   $0x801fb5
  800755:	e8 00 0a 00 00       	call   80115a <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 78 1f 80 00       	push   $0x801f78
  80080a:	e8 4b 09 00 00       	call   80115a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 2b 02 00 00       	call   800afe <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 f1 12 00 00       	call   801c0b <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 80 12 00 00       	call   801bb5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 0a 12 00 00       	call   801b4c <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 c3 0d 00 00       	call   80178e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	83 ec 08             	sub    $0x8,%esp
  8009f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009fd:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a02:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a10:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a16:	53                   	push   %ebx
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	68 08 50 80 00       	push   $0x805008
  800a1f:	e8 fc 0e 00 00       	call   801920 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a24:	ba 00 00 00 00       	mov    $0x0,%edx
  800a29:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2e:	e8 cb fe ff ff       	call   8008fe <fsipc>
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 3d                	js     800a77 <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a3a:	39 d8                	cmp    %ebx,%eax
  800a3c:	76 19                	jbe    800a57 <devfile_write+0x69>
  800a3e:	68 e4 1f 80 00       	push   $0x801fe4
  800a43:	68 eb 1f 80 00       	push   $0x801feb
  800a48:	68 9f 00 00 00       	push   $0x9f
  800a4d:	68 00 20 80 00       	push   $0x802000
  800a52:	e8 2a 06 00 00       	call   801081 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a57:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a5c:	76 19                	jbe    800a77 <devfile_write+0x89>
  800a5e:	68 18 20 80 00       	push   $0x802018
  800a63:	68 eb 1f 80 00       	push   $0x801feb
  800a68:	68 a0 00 00 00       	push   $0xa0
  800a6d:	68 00 20 80 00       	push   $0x802000
  800a72:	e8 0a 06 00 00       	call   801081 <_panic>

	return r;
}
  800a77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 5a fe ff ff       	call   8008fe <fsipc>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 4b                	js     800af5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaa:	39 c6                	cmp    %eax,%esi
  800aac:	73 16                	jae    800ac4 <devfile_read+0x48>
  800aae:	68 e4 1f 80 00       	push   $0x801fe4
  800ab3:	68 eb 1f 80 00       	push   $0x801feb
  800ab8:	6a 7e                	push   $0x7e
  800aba:	68 00 20 80 00       	push   $0x802000
  800abf:	e8 bd 05 00 00       	call   801081 <_panic>
	assert(r <= PGSIZE);
  800ac4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac9:	7e 16                	jle    800ae1 <devfile_read+0x65>
  800acb:	68 0b 20 80 00       	push   $0x80200b
  800ad0:	68 eb 1f 80 00       	push   $0x801feb
  800ad5:	6a 7f                	push   $0x7f
  800ad7:	68 00 20 80 00       	push   $0x802000
  800adc:	e8 a0 05 00 00       	call   801081 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	50                   	push   %eax
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	e8 2e 0e 00 00       	call   801920 <memmove>
	return r;
  800af2:	83 c4 10             	add    $0x10,%esp
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	83 ec 20             	sub    $0x20,%esp
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b08:	53                   	push   %ebx
  800b09:	e8 47 0c 00 00       	call   801755 <strlen>
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b16:	7f 67                	jg     800b7f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1e:	50                   	push   %eax
  800b1f:	e8 52 f8 ff ff       	call   800376 <fd_alloc>
  800b24:	83 c4 10             	add    $0x10,%esp
		return r;
  800b27:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	78 57                	js     800b84 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	53                   	push   %ebx
  800b31:	68 00 50 80 00       	push   $0x805000
  800b36:	e8 53 0c 00 00       	call   80178e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	e8 ae fd ff ff       	call   8008fe <fsipc>
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	83 c4 10             	add    $0x10,%esp
  800b55:	85 c0                	test   %eax,%eax
  800b57:	79 14                	jns    800b6d <open+0x6f>
		fd_close(fd, 0);
  800b59:	83 ec 08             	sub    $0x8,%esp
  800b5c:	6a 00                	push   $0x0
  800b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b61:	e8 08 f9 ff ff       	call   80046e <fd_close>
		return r;
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	89 da                	mov    %ebx,%edx
  800b6b:	eb 17                	jmp    800b84 <open+0x86>
	}

	return fd2num(fd);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	ff 75 f4             	pushl  -0xc(%ebp)
  800b73:	e8 d7 f7 ff ff       	call   80034f <fd2num>
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	eb 05                	jmp    800b84 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b84:	89 d0                	mov    %edx,%eax
  800b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9b:	e8 5e fd ff ff       	call   8008fe <fsipc>
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	ff 75 08             	pushl  0x8(%ebp)
  800bb0:	e8 aa f7 ff ff       	call   80035f <fd2data>
  800bb5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	68 45 20 80 00       	push   $0x802045
  800bbf:	53                   	push   %ebx
  800bc0:	e8 c9 0b 00 00       	call   80178e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc5:	8b 46 04             	mov    0x4(%esi),%eax
  800bc8:	2b 06                	sub    (%esi),%eax
  800bca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd7:	00 00 00 
	stat->st_dev = &devpipe;
  800bda:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be1:	30 80 00 
	return 0;
}
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bfa:	53                   	push   %ebx
  800bfb:	6a 00                	push   $0x0
  800bfd:	e8 e1 f5 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c02:	89 1c 24             	mov    %ebx,(%esp)
  800c05:	e8 55 f7 ff ff       	call   80035f <fd2data>
  800c0a:	83 c4 08             	add    $0x8,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 00                	push   $0x0
  800c10:	e8 ce f5 ff ff       	call   8001e3 <sys_page_unmap>
}
  800c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 1c             	sub    $0x1c,%esp
  800c23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c26:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c28:	a1 08 40 80 00       	mov    0x804008,%eax
  800c2d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	ff 75 e0             	pushl  -0x20(%ebp)
  800c36:	e8 09 10 00 00       	call   801c44 <pageref>
  800c3b:	89 c3                	mov    %eax,%ebx
  800c3d:	89 3c 24             	mov    %edi,(%esp)
  800c40:	e8 ff 0f 00 00       	call   801c44 <pageref>
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	39 c3                	cmp    %eax,%ebx
  800c4a:	0f 94 c1             	sete   %cl
  800c4d:	0f b6 c9             	movzbl %cl,%ecx
  800c50:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c53:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c5c:	39 ce                	cmp    %ecx,%esi
  800c5e:	74 1b                	je     800c7b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c60:	39 c3                	cmp    %eax,%ebx
  800c62:	75 c4                	jne    800c28 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c64:	8b 42 58             	mov    0x58(%edx),%eax
  800c67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6a:	50                   	push   %eax
  800c6b:	56                   	push   %esi
  800c6c:	68 4c 20 80 00       	push   $0x80204c
  800c71:	e8 e4 04 00 00       	call   80115a <cprintf>
  800c76:	83 c4 10             	add    $0x10,%esp
  800c79:	eb ad                	jmp    800c28 <_pipeisclosed+0xe>
	}
}
  800c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 28             	sub    $0x28,%esp
  800c8f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c92:	56                   	push   %esi
  800c93:	e8 c7 f6 ff ff       	call   80035f <fd2data>
  800c98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca2:	eb 4b                	jmp    800cef <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca4:	89 da                	mov    %ebx,%edx
  800ca6:	89 f0                	mov    %esi,%eax
  800ca8:	e8 6d ff ff ff       	call   800c1a <_pipeisclosed>
  800cad:	85 c0                	test   %eax,%eax
  800caf:	75 48                	jne    800cf9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb1:	e8 89 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb6:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb9:	8b 0b                	mov    (%ebx),%ecx
  800cbb:	8d 51 20             	lea    0x20(%ecx),%edx
  800cbe:	39 d0                	cmp    %edx,%eax
  800cc0:	73 e2                	jae    800ca4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ccc:	89 c2                	mov    %eax,%edx
  800cce:	c1 fa 1f             	sar    $0x1f,%edx
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd9:	83 e2 1f             	and    $0x1f,%edx
  800cdc:	29 ca                	sub    %ecx,%edx
  800cde:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce6:	83 c0 01             	add    $0x1,%eax
  800ce9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cec:	83 c7 01             	add    $0x1,%edi
  800cef:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf2:	75 c2                	jne    800cb6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf7:	eb 05                	jmp    800cfe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 18             	sub    $0x18,%esp
  800d0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d12:	57                   	push   %edi
  800d13:	e8 47 f6 ff ff       	call   80035f <fd2data>
  800d18:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	eb 3d                	jmp    800d61 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d24:	85 db                	test   %ebx,%ebx
  800d26:	74 04                	je     800d2c <devpipe_read+0x26>
				return i;
  800d28:	89 d8                	mov    %ebx,%eax
  800d2a:	eb 44                	jmp    800d70 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d2c:	89 f2                	mov    %esi,%edx
  800d2e:	89 f8                	mov    %edi,%eax
  800d30:	e8 e5 fe ff ff       	call   800c1a <_pipeisclosed>
  800d35:	85 c0                	test   %eax,%eax
  800d37:	75 32                	jne    800d6b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d39:	e8 01 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3e:	8b 06                	mov    (%esi),%eax
  800d40:	3b 46 04             	cmp    0x4(%esi),%eax
  800d43:	74 df                	je     800d24 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d45:	99                   	cltd   
  800d46:	c1 ea 1b             	shr    $0x1b,%edx
  800d49:	01 d0                	add    %edx,%eax
  800d4b:	83 e0 1f             	and    $0x1f,%eax
  800d4e:	29 d0                	sub    %edx,%eax
  800d50:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d5b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5e:	83 c3 01             	add    $0x1,%ebx
  800d61:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d64:	75 d8                	jne    800d3e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d66:	8b 45 10             	mov    0x10(%ebp),%eax
  800d69:	eb 05                	jmp    800d70 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d83:	50                   	push   %eax
  800d84:	e8 ed f5 ff ff       	call   800376 <fd_alloc>
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 2c 01 00 00    	js     800ec2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	68 07 04 00 00       	push   $0x407
  800d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800da1:	6a 00                	push   $0x0
  800da3:	e8 b6 f3 ff ff       	call   80015e <sys_page_alloc>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	85 c0                	test   %eax,%eax
  800daf:	0f 88 0d 01 00 00    	js     800ec2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dbb:	50                   	push   %eax
  800dbc:	e8 b5 f5 ff ff       	call   800376 <fd_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 e2 00 00 00    	js     800eb0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dce:	83 ec 04             	sub    $0x4,%esp
  800dd1:	68 07 04 00 00       	push   $0x407
  800dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 7e f3 ff ff       	call   80015e <sys_page_alloc>
  800de0:	89 c3                	mov    %eax,%ebx
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	85 c0                	test   %eax,%eax
  800de7:	0f 88 c3 00 00 00    	js     800eb0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	ff 75 f4             	pushl  -0xc(%ebp)
  800df3:	e8 67 f5 ff ff       	call   80035f <fd2data>
  800df8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfa:	83 c4 0c             	add    $0xc,%esp
  800dfd:	68 07 04 00 00       	push   $0x407
  800e02:	50                   	push   %eax
  800e03:	6a 00                	push   $0x0
  800e05:	e8 54 f3 ff ff       	call   80015e <sys_page_alloc>
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	0f 88 89 00 00 00    	js     800ea0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1d:	e8 3d f5 ff ff       	call   80035f <fd2data>
  800e22:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e29:	50                   	push   %eax
  800e2a:	6a 00                	push   $0x0
  800e2c:	56                   	push   %esi
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 6d f3 ff ff       	call   8001a1 <sys_page_map>
  800e34:	89 c3                	mov    %eax,%ebx
  800e36:	83 c4 20             	add    $0x20,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	78 55                	js     800e92 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e46:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e52:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e60:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6d:	e8 dd f4 ff ff       	call   80034f <fd2num>
  800e72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e75:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e77:	83 c4 04             	add    $0x4,%esp
  800e7a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7d:	e8 cd f4 ff ff       	call   80034f <fd2num>
  800e82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e85:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	eb 30                	jmp    800ec2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	56                   	push   %esi
  800e96:	6a 00                	push   $0x0
  800e98:	e8 46 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e9d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 36 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800ead:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 26 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec2:	89 d0                	mov    %edx,%eax
  800ec4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	ff 75 08             	pushl  0x8(%ebp)
  800ed8:	e8 e8 f4 ff ff       	call   8003c5 <fd_lookup>
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 18                	js     800efc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eea:	e8 70 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef4:	e8 21 fd ff ff       	call   800c1a <_pipeisclosed>
  800ef9:	83 c4 10             	add    $0x10,%esp
}
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0e:	68 64 20 80 00       	push   $0x802064
  800f13:	ff 75 0c             	pushl  0xc(%ebp)
  800f16:	e8 73 08 00 00       	call   80178e <strcpy>
	return 0;
}
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f33:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f39:	eb 2d                	jmp    800f68 <devcons_write+0x46>
		m = n - tot;
  800f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f40:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f43:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f48:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	53                   	push   %ebx
  800f4f:	03 45 0c             	add    0xc(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	57                   	push   %edi
  800f54:	e8 c7 09 00 00       	call   801920 <memmove>
		sys_cputs(buf, m);
  800f59:	83 c4 08             	add    $0x8,%esp
  800f5c:	53                   	push   %ebx
  800f5d:	57                   	push   %edi
  800f5e:	e8 3f f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f63:	01 de                	add    %ebx,%esi
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	89 f0                	mov    %esi,%eax
  800f6a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6d:	72 cc                	jb     800f3b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f86:	74 2a                	je     800fb2 <devcons_read+0x3b>
  800f88:	eb 05                	jmp    800f8f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f8a:	e8 b0 f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f8f:	e8 2c f1 ff ff       	call   8000c0 <sys_cgetc>
  800f94:	85 c0                	test   %eax,%eax
  800f96:	74 f2                	je     800f8a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 16                	js     800fb2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f9c:	83 f8 04             	cmp    $0x4,%eax
  800f9f:	74 0c                	je     800fad <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa4:	88 02                	mov    %al,(%edx)
	return 1;
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	eb 05                	jmp    800fb2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc0:	6a 01                	push   $0x1
  800fc2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc5:	50                   	push   %eax
  800fc6:	e8 d7 f0 ff ff       	call   8000a2 <sys_cputs>
}
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <getchar>:

int
getchar(void)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd6:	6a 01                	push   $0x1
  800fd8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 48 f6 ff ff       	call   80062b <read>
	if (r < 0)
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 0f                	js     800ff9 <getchar+0x29>
		return r;
	if (r < 1)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 06                	jle    800ff4 <getchar+0x24>
		return -E_EOF;
	return c;
  800fee:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff2:	eb 05                	jmp    800ff9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 b8 f3 ff ff       	call   8003c5 <fd_lookup>
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 11                	js     801025 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101d:	39 10                	cmp    %edx,(%eax)
  80101f:	0f 94 c0             	sete   %al
  801022:	0f b6 c0             	movzbl %al,%eax
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <opencons>:

int
opencons(void)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80102d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	e8 40 f3 ff ff       	call   800376 <fd_alloc>
  801036:	83 c4 10             	add    $0x10,%esp
		return r;
  801039:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 3e                	js     80107d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	68 07 04 00 00       	push   $0x407
  801047:	ff 75 f4             	pushl  -0xc(%ebp)
  80104a:	6a 00                	push   $0x0
  80104c:	e8 0d f1 ff ff       	call   80015e <sys_page_alloc>
  801051:	83 c4 10             	add    $0x10,%esp
		return r;
  801054:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801056:	85 c0                	test   %eax,%eax
  801058:	78 23                	js     80107d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80105a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801063:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	50                   	push   %eax
  801073:	e8 d7 f2 ff ff       	call   80034f <fd2num>
  801078:	89 c2                	mov    %eax,%edx
  80107a:	83 c4 10             	add    $0x10,%esp
}
  80107d:	89 d0                	mov    %edx,%eax
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801086:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801089:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108f:	e8 8c f0 ff ff       	call   800120 <sys_getenvid>
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	56                   	push   %esi
  80109e:	50                   	push   %eax
  80109f:	68 70 20 80 00       	push   $0x802070
  8010a4:	e8 b1 00 00 00       	call   80115a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a9:	83 c4 18             	add    $0x18,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	ff 75 10             	pushl  0x10(%ebp)
  8010b0:	e8 54 00 00 00       	call   801109 <vcprintf>
	cprintf("\n");
  8010b5:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010bc:	e8 99 00 00 00       	call   80115a <cprintf>
  8010c1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c4:	cc                   	int3   
  8010c5:	eb fd                	jmp    8010c4 <_panic+0x43>

008010c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d1:	8b 13                	mov    (%ebx),%edx
  8010d3:	8d 42 01             	lea    0x1(%edx),%eax
  8010d6:	89 03                	mov    %eax,(%ebx)
  8010d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e4:	75 1a                	jne    801100 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	68 ff 00 00 00       	push   $0xff
  8010ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f1:	50                   	push   %eax
  8010f2:	e8 ab ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801100:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801104:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801112:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801119:	00 00 00 
	b.cnt = 0;
  80111c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801123:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801126:	ff 75 0c             	pushl  0xc(%ebp)
  801129:	ff 75 08             	pushl  0x8(%ebp)
  80112c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	68 c7 10 80 00       	push   $0x8010c7
  801138:	e8 54 01 00 00       	call   801291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801146:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	e8 50 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801152:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801160:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801163:	50                   	push   %eax
  801164:	ff 75 08             	pushl  0x8(%ebp)
  801167:	e8 9d ff ff ff       	call   801109 <vcprintf>
	va_end(ap);

	return cnt;
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	89 c7                	mov    %eax,%edi
  801179:	89 d6                	mov    %edx,%esi
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801181:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801184:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801187:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801192:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801195:	39 d3                	cmp    %edx,%ebx
  801197:	72 05                	jb     80119e <printnum+0x30>
  801199:	39 45 10             	cmp    %eax,0x10(%ebp)
  80119c:	77 45                	ja     8011e3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	ff 75 18             	pushl  0x18(%ebp)
  8011a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011aa:	53                   	push   %ebx
  8011ab:	ff 75 10             	pushl  0x10(%ebp)
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bd:	e8 be 0a 00 00       	call   801c80 <__udivdi3>
  8011c2:	83 c4 18             	add    $0x18,%esp
  8011c5:	52                   	push   %edx
  8011c6:	50                   	push   %eax
  8011c7:	89 f2                	mov    %esi,%edx
  8011c9:	89 f8                	mov    %edi,%eax
  8011cb:	e8 9e ff ff ff       	call   80116e <printnum>
  8011d0:	83 c4 20             	add    $0x20,%esp
  8011d3:	eb 18                	jmp    8011ed <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d5:	83 ec 08             	sub    $0x8,%esp
  8011d8:	56                   	push   %esi
  8011d9:	ff 75 18             	pushl  0x18(%ebp)
  8011dc:	ff d7                	call   *%edi
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	eb 03                	jmp    8011e6 <printnum+0x78>
  8011e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011e6:	83 eb 01             	sub    $0x1,%ebx
  8011e9:	85 db                	test   %ebx,%ebx
  8011eb:	7f e8                	jg     8011d5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ed:	83 ec 08             	sub    $0x8,%esp
  8011f0:	56                   	push   %esi
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011fd:	ff 75 d8             	pushl  -0x28(%ebp)
  801200:	e8 ab 0b 00 00       	call   801db0 <__umoddi3>
  801205:	83 c4 14             	add    $0x14,%esp
  801208:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  80120f:	50                   	push   %eax
  801210:	ff d7                	call   *%edi
}
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801220:	83 fa 01             	cmp    $0x1,%edx
  801223:	7e 0e                	jle    801233 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	8b 52 04             	mov    0x4(%edx),%edx
  801231:	eb 22                	jmp    801255 <getuint+0x38>
	else if (lflag)
  801233:	85 d2                	test   %edx,%edx
  801235:	74 10                	je     801247 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801237:	8b 10                	mov    (%eax),%edx
  801239:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123c:	89 08                	mov    %ecx,(%eax)
  80123e:	8b 02                	mov    (%edx),%eax
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
  801245:	eb 0e                	jmp    801255 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801247:	8b 10                	mov    (%eax),%edx
  801249:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124c:	89 08                	mov    %ecx,(%eax)
  80124e:	8b 02                	mov    (%edx),%eax
  801250:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80125d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801261:	8b 10                	mov    (%eax),%edx
  801263:	3b 50 04             	cmp    0x4(%eax),%edx
  801266:	73 0a                	jae    801272 <sprintputch+0x1b>
		*b->buf++ = ch;
  801268:	8d 4a 01             	lea    0x1(%edx),%ecx
  80126b:	89 08                	mov    %ecx,(%eax)
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	88 02                	mov    %al,(%edx)
}
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80127a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127d:	50                   	push   %eax
  80127e:	ff 75 10             	pushl  0x10(%ebp)
  801281:	ff 75 0c             	pushl  0xc(%ebp)
  801284:	ff 75 08             	pushl  0x8(%ebp)
  801287:	e8 05 00 00 00       	call   801291 <vprintfmt>
	va_end(ap);
}
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	57                   	push   %edi
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 2c             	sub    $0x2c,%esp
  80129a:	8b 75 08             	mov    0x8(%ebp),%esi
  80129d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a3:	eb 12                	jmp    8012b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	0f 84 38 04 00 00    	je     8016e5 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	53                   	push   %ebx
  8012b1:	50                   	push   %eax
  8012b2:	ff d6                	call   *%esi
  8012b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b7:	83 c7 01             	add    $0x1,%edi
  8012ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012be:	83 f8 25             	cmp    $0x25,%eax
  8012c1:	75 e2                	jne    8012a5 <vprintfmt+0x14>
  8012c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e1:	eb 07                	jmp    8012ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8d 47 01             	lea    0x1(%edi),%eax
  8012ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f0:	0f b6 07             	movzbl (%edi),%eax
  8012f3:	0f b6 c8             	movzbl %al,%ecx
  8012f6:	83 e8 23             	sub    $0x23,%eax
  8012f9:	3c 55                	cmp    $0x55,%al
  8012fb:	0f 87 c9 03 00 00    	ja     8016ca <vprintfmt+0x439>
  801301:	0f b6 c0             	movzbl %al,%eax
  801304:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80130e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801312:	eb d6                	jmp    8012ea <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  801314:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80131b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801321:	eb 94                	jmp    8012b7 <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  801323:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  80132a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801330:	eb 85                	jmp    8012b7 <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801332:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  801339:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  80133f:	e9 73 ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  801344:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  80134b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801351:	e9 61 ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  801356:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  80135d:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  801363:	e9 4f ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  801368:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  80136f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  801375:	e9 3d ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80137a:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801381:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  801387:	e9 2b ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80138c:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  801393:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  801399:	e9 19 ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  80139e:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013a5:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013ab:	e9 07 ff ff ff       	jmp    8012b7 <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013b0:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013b7:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013bd:	e9 f5 fe ff ff       	jmp    8012b7 <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013d0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013d4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013d7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013da:	83 fa 09             	cmp    $0x9,%edx
  8013dd:	77 3f                	ja     80141e <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013df:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013e2:	eb e9                	jmp    8013cd <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8013ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013ed:	8b 00                	mov    (%eax),%eax
  8013ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013f5:	eb 2d                	jmp    801424 <vprintfmt+0x193>
  8013f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801401:	0f 49 c8             	cmovns %eax,%ecx
  801404:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80140a:	e9 db fe ff ff       	jmp    8012ea <vprintfmt+0x59>
  80140f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801412:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801419:	e9 cc fe ff ff       	jmp    8012ea <vprintfmt+0x59>
  80141e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801421:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801428:	0f 89 bc fe ff ff    	jns    8012ea <vprintfmt+0x59>
				width = precision, precision = -1;
  80142e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801434:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80143b:	e9 aa fe ff ff       	jmp    8012ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801440:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801446:	e9 9f fe ff ff       	jmp    8012ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80144b:	8b 45 14             	mov    0x14(%ebp),%eax
  80144e:	8d 50 04             	lea    0x4(%eax),%edx
  801451:	89 55 14             	mov    %edx,0x14(%ebp)
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	53                   	push   %ebx
  801458:	ff 30                	pushl  (%eax)
  80145a:	ff d6                	call   *%esi
			break;
  80145c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80145f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801462:	e9 50 fe ff ff       	jmp    8012b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801467:	8b 45 14             	mov    0x14(%ebp),%eax
  80146a:	8d 50 04             	lea    0x4(%eax),%edx
  80146d:	89 55 14             	mov    %edx,0x14(%ebp)
  801470:	8b 00                	mov    (%eax),%eax
  801472:	99                   	cltd   
  801473:	31 d0                	xor    %edx,%eax
  801475:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801477:	83 f8 0f             	cmp    $0xf,%eax
  80147a:	7f 0b                	jg     801487 <vprintfmt+0x1f6>
  80147c:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  801483:	85 d2                	test   %edx,%edx
  801485:	75 18                	jne    80149f <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  801487:	50                   	push   %eax
  801488:	68 ab 20 80 00       	push   $0x8020ab
  80148d:	53                   	push   %ebx
  80148e:	56                   	push   %esi
  80148f:	e8 e0 fd ff ff       	call   801274 <printfmt>
  801494:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80149a:	e9 18 fe ff ff       	jmp    8012b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80149f:	52                   	push   %edx
  8014a0:	68 fd 1f 80 00       	push   $0x801ffd
  8014a5:	53                   	push   %ebx
  8014a6:	56                   	push   %esi
  8014a7:	e8 c8 fd ff ff       	call   801274 <printfmt>
  8014ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014b2:	e9 00 fe ff ff       	jmp    8012b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8d 50 04             	lea    0x4(%eax),%edx
  8014bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014c2:	85 ff                	test   %edi,%edi
  8014c4:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014c9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014d0:	0f 8e 94 00 00 00    	jle    80156a <vprintfmt+0x2d9>
  8014d6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014da:	0f 84 98 00 00 00    	je     801578 <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8014e6:	57                   	push   %edi
  8014e7:	e8 81 02 00 00       	call   80176d <strnlen>
  8014ec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014ef:	29 c1                	sub    %eax,%ecx
  8014f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014f7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8014fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801501:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801503:	eb 0f                	jmp    801514 <vprintfmt+0x283>
					putch(padc, putdat);
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	53                   	push   %ebx
  801509:	ff 75 e0             	pushl  -0x20(%ebp)
  80150c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80150e:	83 ef 01             	sub    $0x1,%edi
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 ff                	test   %edi,%edi
  801516:	7f ed                	jg     801505 <vprintfmt+0x274>
  801518:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80151b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80151e:	85 c9                	test   %ecx,%ecx
  801520:	b8 00 00 00 00       	mov    $0x0,%eax
  801525:	0f 49 c1             	cmovns %ecx,%eax
  801528:	29 c1                	sub    %eax,%ecx
  80152a:	89 75 08             	mov    %esi,0x8(%ebp)
  80152d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801533:	89 cb                	mov    %ecx,%ebx
  801535:	eb 4d                	jmp    801584 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801537:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80153b:	74 1b                	je     801558 <vprintfmt+0x2c7>
  80153d:	0f be c0             	movsbl %al,%eax
  801540:	83 e8 20             	sub    $0x20,%eax
  801543:	83 f8 5e             	cmp    $0x5e,%eax
  801546:	76 10                	jbe    801558 <vprintfmt+0x2c7>
					putch('?', putdat);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	ff 75 0c             	pushl  0xc(%ebp)
  80154e:	6a 3f                	push   $0x3f
  801550:	ff 55 08             	call   *0x8(%ebp)
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	eb 0d                	jmp    801565 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  801558:	83 ec 08             	sub    $0x8,%esp
  80155b:	ff 75 0c             	pushl  0xc(%ebp)
  80155e:	52                   	push   %edx
  80155f:	ff 55 08             	call   *0x8(%ebp)
  801562:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801565:	83 eb 01             	sub    $0x1,%ebx
  801568:	eb 1a                	jmp    801584 <vprintfmt+0x2f3>
  80156a:	89 75 08             	mov    %esi,0x8(%ebp)
  80156d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801573:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801576:	eb 0c                	jmp    801584 <vprintfmt+0x2f3>
  801578:	89 75 08             	mov    %esi,0x8(%ebp)
  80157b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80157e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801581:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801584:	83 c7 01             	add    $0x1,%edi
  801587:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80158b:	0f be d0             	movsbl %al,%edx
  80158e:	85 d2                	test   %edx,%edx
  801590:	74 23                	je     8015b5 <vprintfmt+0x324>
  801592:	85 f6                	test   %esi,%esi
  801594:	78 a1                	js     801537 <vprintfmt+0x2a6>
  801596:	83 ee 01             	sub    $0x1,%esi
  801599:	79 9c                	jns    801537 <vprintfmt+0x2a6>
  80159b:	89 df                	mov    %ebx,%edi
  80159d:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015a3:	eb 18                	jmp    8015bd <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	6a 20                	push   $0x20
  8015ab:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015ad:	83 ef 01             	sub    $0x1,%edi
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 08                	jmp    8015bd <vprintfmt+0x32c>
  8015b5:	89 df                	mov    %ebx,%edi
  8015b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015bd:	85 ff                	test   %edi,%edi
  8015bf:	7f e4                	jg     8015a5 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c4:	e9 ee fc ff ff       	jmp    8012b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015c9:	83 fa 01             	cmp    $0x1,%edx
  8015cc:	7e 16                	jle    8015e4 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d1:	8d 50 08             	lea    0x8(%eax),%edx
  8015d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8015d7:	8b 50 04             	mov    0x4(%eax),%edx
  8015da:	8b 00                	mov    (%eax),%eax
  8015dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015e2:	eb 32                	jmp    801616 <vprintfmt+0x385>
	else if (lflag)
  8015e4:	85 d2                	test   %edx,%edx
  8015e6:	74 18                	je     801600 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015eb:	8d 50 04             	lea    0x4(%eax),%edx
  8015ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8015f1:	8b 00                	mov    (%eax),%eax
  8015f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f6:	89 c1                	mov    %eax,%ecx
  8015f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8015fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015fe:	eb 16                	jmp    801616 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  801600:	8b 45 14             	mov    0x14(%ebp),%eax
  801603:	8d 50 04             	lea    0x4(%eax),%edx
  801606:	89 55 14             	mov    %edx,0x14(%ebp)
  801609:	8b 00                	mov    (%eax),%eax
  80160b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80160e:	89 c1                	mov    %eax,%ecx
  801610:	c1 f9 1f             	sar    $0x1f,%ecx
  801613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801616:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801619:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80161c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801621:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801625:	79 6f                	jns    801696 <vprintfmt+0x405>
				putch('-', putdat);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	53                   	push   %ebx
  80162b:	6a 2d                	push   $0x2d
  80162d:	ff d6                	call   *%esi
				num = -(long long) num;
  80162f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801632:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801635:	f7 d8                	neg    %eax
  801637:	83 d2 00             	adc    $0x0,%edx
  80163a:	f7 da                	neg    %edx
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	eb 55                	jmp    801696 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801641:	8d 45 14             	lea    0x14(%ebp),%eax
  801644:	e8 d4 fb ff ff       	call   80121d <getuint>
			base = 10;
  801649:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  80164e:	eb 46                	jmp    801696 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801650:	8d 45 14             	lea    0x14(%ebp),%eax
  801653:	e8 c5 fb ff ff       	call   80121d <getuint>
			base = 8;
  801658:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  80165d:	eb 37                	jmp    801696 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	53                   	push   %ebx
  801663:	6a 30                	push   $0x30
  801665:	ff d6                	call   *%esi
			putch('x', putdat);
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	53                   	push   %ebx
  80166b:	6a 78                	push   $0x78
  80166d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80166f:	8b 45 14             	mov    0x14(%ebp),%eax
  801672:	8d 50 04             	lea    0x4(%eax),%edx
  801675:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801678:	8b 00                	mov    (%eax),%eax
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80167f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801682:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  801687:	eb 0d                	jmp    801696 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801689:	8d 45 14             	lea    0x14(%ebp),%eax
  80168c:	e8 8c fb ff ff       	call   80121d <getuint>
			base = 16;
  801691:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80169d:	51                   	push   %ecx
  80169e:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a1:	57                   	push   %edi
  8016a2:	52                   	push   %edx
  8016a3:	50                   	push   %eax
  8016a4:	89 da                	mov    %ebx,%edx
  8016a6:	89 f0                	mov    %esi,%eax
  8016a8:	e8 c1 fa ff ff       	call   80116e <printnum>
			break;
  8016ad:	83 c4 20             	add    $0x20,%esp
  8016b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b3:	e9 ff fb ff ff       	jmp    8012b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	53                   	push   %ebx
  8016bc:	51                   	push   %ecx
  8016bd:	ff d6                	call   *%esi
			break;
  8016bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016c5:	e9 ed fb ff ff       	jmp    8012b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	6a 25                	push   $0x25
  8016d0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	eb 03                	jmp    8016da <vprintfmt+0x449>
  8016d7:	83 ef 01             	sub    $0x1,%edi
  8016da:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016de:	75 f7                	jne    8016d7 <vprintfmt+0x446>
  8016e0:	e9 d2 fb ff ff       	jmp    8012b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5f                   	pop    %edi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	83 ec 18             	sub    $0x18,%esp
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801700:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80170a:	85 c0                	test   %eax,%eax
  80170c:	74 26                	je     801734 <vsnprintf+0x47>
  80170e:	85 d2                	test   %edx,%edx
  801710:	7e 22                	jle    801734 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801712:	ff 75 14             	pushl  0x14(%ebp)
  801715:	ff 75 10             	pushl  0x10(%ebp)
  801718:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	68 57 12 80 00       	push   $0x801257
  801721:	e8 6b fb ff ff       	call   801291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801726:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801729:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80172c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	eb 05                	jmp    801739 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801734:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801741:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801744:	50                   	push   %eax
  801745:	ff 75 10             	pushl  0x10(%ebp)
  801748:	ff 75 0c             	pushl  0xc(%ebp)
  80174b:	ff 75 08             	pushl  0x8(%ebp)
  80174e:	e8 9a ff ff ff       	call   8016ed <vsnprintf>
	va_end(ap);

	return rc;
}
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80175b:	b8 00 00 00 00       	mov    $0x0,%eax
  801760:	eb 03                	jmp    801765 <strlen+0x10>
		n++;
  801762:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801765:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801769:	75 f7                	jne    801762 <strlen+0xd>
		n++;
	return n;
}
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801773:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	eb 03                	jmp    801780 <strnlen+0x13>
		n++;
  80177d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801780:	39 c2                	cmp    %eax,%edx
  801782:	74 08                	je     80178c <strnlen+0x1f>
  801784:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801788:	75 f3                	jne    80177d <strnlen+0x10>
  80178a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	53                   	push   %ebx
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801798:	89 c2                	mov    %eax,%edx
  80179a:	83 c2 01             	add    $0x1,%edx
  80179d:	83 c1 01             	add    $0x1,%ecx
  8017a0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017a7:	84 db                	test   %bl,%bl
  8017a9:	75 ef                	jne    80179a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017ab:	5b                   	pop    %ebx
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017b5:	53                   	push   %ebx
  8017b6:	e8 9a ff ff ff       	call   801755 <strlen>
  8017bb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017be:	ff 75 0c             	pushl  0xc(%ebp)
  8017c1:	01 d8                	add    %ebx,%eax
  8017c3:	50                   	push   %eax
  8017c4:	e8 c5 ff ff ff       	call   80178e <strcpy>
	return dst;
}
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017db:	89 f3                	mov    %esi,%ebx
  8017dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017e0:	89 f2                	mov    %esi,%edx
  8017e2:	eb 0f                	jmp    8017f3 <strncpy+0x23>
		*dst++ = *src;
  8017e4:	83 c2 01             	add    $0x1,%edx
  8017e7:	0f b6 01             	movzbl (%ecx),%eax
  8017ea:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017ed:	80 39 01             	cmpb   $0x1,(%ecx)
  8017f0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017f3:	39 da                	cmp    %ebx,%edx
  8017f5:	75 ed                	jne    8017e4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017f7:	89 f0                	mov    %esi,%eax
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	8b 75 08             	mov    0x8(%ebp),%esi
  801805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801808:	8b 55 10             	mov    0x10(%ebp),%edx
  80180b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80180d:	85 d2                	test   %edx,%edx
  80180f:	74 21                	je     801832 <strlcpy+0x35>
  801811:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801815:	89 f2                	mov    %esi,%edx
  801817:	eb 09                	jmp    801822 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801819:	83 c2 01             	add    $0x1,%edx
  80181c:	83 c1 01             	add    $0x1,%ecx
  80181f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801822:	39 c2                	cmp    %eax,%edx
  801824:	74 09                	je     80182f <strlcpy+0x32>
  801826:	0f b6 19             	movzbl (%ecx),%ebx
  801829:	84 db                	test   %bl,%bl
  80182b:	75 ec                	jne    801819 <strlcpy+0x1c>
  80182d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80182f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801832:	29 f0                	sub    %esi,%eax
}
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801841:	eb 06                	jmp    801849 <strcmp+0x11>
		p++, q++;
  801843:	83 c1 01             	add    $0x1,%ecx
  801846:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801849:	0f b6 01             	movzbl (%ecx),%eax
  80184c:	84 c0                	test   %al,%al
  80184e:	74 04                	je     801854 <strcmp+0x1c>
  801850:	3a 02                	cmp    (%edx),%al
  801852:	74 ef                	je     801843 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801854:	0f b6 c0             	movzbl %al,%eax
  801857:	0f b6 12             	movzbl (%edx),%edx
  80185a:	29 d0                	sub    %edx,%eax
}
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 55 0c             	mov    0xc(%ebp),%edx
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80186d:	eb 06                	jmp    801875 <strncmp+0x17>
		n--, p++, q++;
  80186f:	83 c0 01             	add    $0x1,%eax
  801872:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801875:	39 d8                	cmp    %ebx,%eax
  801877:	74 15                	je     80188e <strncmp+0x30>
  801879:	0f b6 08             	movzbl (%eax),%ecx
  80187c:	84 c9                	test   %cl,%cl
  80187e:	74 04                	je     801884 <strncmp+0x26>
  801880:	3a 0a                	cmp    (%edx),%cl
  801882:	74 eb                	je     80186f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801884:	0f b6 00             	movzbl (%eax),%eax
  801887:	0f b6 12             	movzbl (%edx),%edx
  80188a:	29 d0                	sub    %edx,%eax
  80188c:	eb 05                	jmp    801893 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801893:	5b                   	pop    %ebx
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018a0:	eb 07                	jmp    8018a9 <strchr+0x13>
		if (*s == c)
  8018a2:	38 ca                	cmp    %cl,%dl
  8018a4:	74 0f                	je     8018b5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018a6:	83 c0 01             	add    $0x1,%eax
  8018a9:	0f b6 10             	movzbl (%eax),%edx
  8018ac:	84 d2                	test   %dl,%dl
  8018ae:	75 f2                	jne    8018a2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018c1:	eb 03                	jmp    8018c6 <strfind+0xf>
  8018c3:	83 c0 01             	add    $0x1,%eax
  8018c6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018c9:	38 ca                	cmp    %cl,%dl
  8018cb:	74 04                	je     8018d1 <strfind+0x1a>
  8018cd:	84 d2                	test   %dl,%dl
  8018cf:	75 f2                	jne    8018c3 <strfind+0xc>
			break;
	return (char *) s;
}
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	57                   	push   %edi
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018df:	85 c9                	test   %ecx,%ecx
  8018e1:	74 36                	je     801919 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018e3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018e9:	75 28                	jne    801913 <memset+0x40>
  8018eb:	f6 c1 03             	test   $0x3,%cl
  8018ee:	75 23                	jne    801913 <memset+0x40>
		c &= 0xFF;
  8018f0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018f4:	89 d3                	mov    %edx,%ebx
  8018f6:	c1 e3 08             	shl    $0x8,%ebx
  8018f9:	89 d6                	mov    %edx,%esi
  8018fb:	c1 e6 18             	shl    $0x18,%esi
  8018fe:	89 d0                	mov    %edx,%eax
  801900:	c1 e0 10             	shl    $0x10,%eax
  801903:	09 f0                	or     %esi,%eax
  801905:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801907:	89 d8                	mov    %ebx,%eax
  801909:	09 d0                	or     %edx,%eax
  80190b:	c1 e9 02             	shr    $0x2,%ecx
  80190e:	fc                   	cld    
  80190f:	f3 ab                	rep stos %eax,%es:(%edi)
  801911:	eb 06                	jmp    801919 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801913:	8b 45 0c             	mov    0xc(%ebp),%eax
  801916:	fc                   	cld    
  801917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801919:	89 f8                	mov    %edi,%eax
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5f                   	pop    %edi
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	57                   	push   %edi
  801924:	56                   	push   %esi
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80192b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80192e:	39 c6                	cmp    %eax,%esi
  801930:	73 35                	jae    801967 <memmove+0x47>
  801932:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801935:	39 d0                	cmp    %edx,%eax
  801937:	73 2e                	jae    801967 <memmove+0x47>
		s += n;
		d += n;
  801939:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80193c:	89 d6                	mov    %edx,%esi
  80193e:	09 fe                	or     %edi,%esi
  801940:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801946:	75 13                	jne    80195b <memmove+0x3b>
  801948:	f6 c1 03             	test   $0x3,%cl
  80194b:	75 0e                	jne    80195b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80194d:	83 ef 04             	sub    $0x4,%edi
  801950:	8d 72 fc             	lea    -0x4(%edx),%esi
  801953:	c1 e9 02             	shr    $0x2,%ecx
  801956:	fd                   	std    
  801957:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801959:	eb 09                	jmp    801964 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80195b:	83 ef 01             	sub    $0x1,%edi
  80195e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801961:	fd                   	std    
  801962:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801964:	fc                   	cld    
  801965:	eb 1d                	jmp    801984 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801967:	89 f2                	mov    %esi,%edx
  801969:	09 c2                	or     %eax,%edx
  80196b:	f6 c2 03             	test   $0x3,%dl
  80196e:	75 0f                	jne    80197f <memmove+0x5f>
  801970:	f6 c1 03             	test   $0x3,%cl
  801973:	75 0a                	jne    80197f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801975:	c1 e9 02             	shr    $0x2,%ecx
  801978:	89 c7                	mov    %eax,%edi
  80197a:	fc                   	cld    
  80197b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80197d:	eb 05                	jmp    801984 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80197f:	89 c7                	mov    %eax,%edi
  801981:	fc                   	cld    
  801982:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801984:	5e                   	pop    %esi
  801985:	5f                   	pop    %edi
  801986:	5d                   	pop    %ebp
  801987:	c3                   	ret    

00801988 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80198b:	ff 75 10             	pushl  0x10(%ebp)
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	ff 75 08             	pushl  0x8(%ebp)
  801994:	e8 87 ff ff ff       	call   801920 <memmove>
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a6:	89 c6                	mov    %eax,%esi
  8019a8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019ab:	eb 1a                	jmp    8019c7 <memcmp+0x2c>
		if (*s1 != *s2)
  8019ad:	0f b6 08             	movzbl (%eax),%ecx
  8019b0:	0f b6 1a             	movzbl (%edx),%ebx
  8019b3:	38 d9                	cmp    %bl,%cl
  8019b5:	74 0a                	je     8019c1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019b7:	0f b6 c1             	movzbl %cl,%eax
  8019ba:	0f b6 db             	movzbl %bl,%ebx
  8019bd:	29 d8                	sub    %ebx,%eax
  8019bf:	eb 0f                	jmp    8019d0 <memcmp+0x35>
		s1++, s2++;
  8019c1:	83 c0 01             	add    $0x1,%eax
  8019c4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019c7:	39 f0                	cmp    %esi,%eax
  8019c9:	75 e2                	jne    8019ad <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	53                   	push   %ebx
  8019d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019db:	89 c1                	mov    %eax,%ecx
  8019dd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019e0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e4:	eb 0a                	jmp    8019f0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019e6:	0f b6 10             	movzbl (%eax),%edx
  8019e9:	39 da                	cmp    %ebx,%edx
  8019eb:	74 07                	je     8019f4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019ed:	83 c0 01             	add    $0x1,%eax
  8019f0:	39 c8                	cmp    %ecx,%eax
  8019f2:	72 f2                	jb     8019e6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019f4:	5b                   	pop    %ebx
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	57                   	push   %edi
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a03:	eb 03                	jmp    801a08 <strtol+0x11>
		s++;
  801a05:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a08:	0f b6 01             	movzbl (%ecx),%eax
  801a0b:	3c 20                	cmp    $0x20,%al
  801a0d:	74 f6                	je     801a05 <strtol+0xe>
  801a0f:	3c 09                	cmp    $0x9,%al
  801a11:	74 f2                	je     801a05 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a13:	3c 2b                	cmp    $0x2b,%al
  801a15:	75 0a                	jne    801a21 <strtol+0x2a>
		s++;
  801a17:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a1a:	bf 00 00 00 00       	mov    $0x0,%edi
  801a1f:	eb 11                	jmp    801a32 <strtol+0x3b>
  801a21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a26:	3c 2d                	cmp    $0x2d,%al
  801a28:	75 08                	jne    801a32 <strtol+0x3b>
		s++, neg = 1;
  801a2a:	83 c1 01             	add    $0x1,%ecx
  801a2d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a38:	75 15                	jne    801a4f <strtol+0x58>
  801a3a:	80 39 30             	cmpb   $0x30,(%ecx)
  801a3d:	75 10                	jne    801a4f <strtol+0x58>
  801a3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a43:	75 7c                	jne    801ac1 <strtol+0xca>
		s += 2, base = 16;
  801a45:	83 c1 02             	add    $0x2,%ecx
  801a48:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a4d:	eb 16                	jmp    801a65 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a4f:	85 db                	test   %ebx,%ebx
  801a51:	75 12                	jne    801a65 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a53:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a58:	80 39 30             	cmpb   $0x30,(%ecx)
  801a5b:	75 08                	jne    801a65 <strtol+0x6e>
		s++, base = 8;
  801a5d:	83 c1 01             	add    $0x1,%ecx
  801a60:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a6d:	0f b6 11             	movzbl (%ecx),%edx
  801a70:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a73:	89 f3                	mov    %esi,%ebx
  801a75:	80 fb 09             	cmp    $0x9,%bl
  801a78:	77 08                	ja     801a82 <strtol+0x8b>
			dig = *s - '0';
  801a7a:	0f be d2             	movsbl %dl,%edx
  801a7d:	83 ea 30             	sub    $0x30,%edx
  801a80:	eb 22                	jmp    801aa4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a82:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a85:	89 f3                	mov    %esi,%ebx
  801a87:	80 fb 19             	cmp    $0x19,%bl
  801a8a:	77 08                	ja     801a94 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a8c:	0f be d2             	movsbl %dl,%edx
  801a8f:	83 ea 57             	sub    $0x57,%edx
  801a92:	eb 10                	jmp    801aa4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a94:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a97:	89 f3                	mov    %esi,%ebx
  801a99:	80 fb 19             	cmp    $0x19,%bl
  801a9c:	77 16                	ja     801ab4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a9e:	0f be d2             	movsbl %dl,%edx
  801aa1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801aa4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801aa7:	7d 0b                	jge    801ab4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801aa9:	83 c1 01             	add    $0x1,%ecx
  801aac:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ab0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ab2:	eb b9                	jmp    801a6d <strtol+0x76>

	if (endptr)
  801ab4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ab8:	74 0d                	je     801ac7 <strtol+0xd0>
		*endptr = (char *) s;
  801aba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abd:	89 0e                	mov    %ecx,(%esi)
  801abf:	eb 06                	jmp    801ac7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ac1:	85 db                	test   %ebx,%ebx
  801ac3:	74 98                	je     801a5d <strtol+0x66>
  801ac5:	eb 9e                	jmp    801a65 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ac7:	89 c2                	mov    %eax,%edx
  801ac9:	f7 da                	neg    %edx
  801acb:	85 ff                	test   %edi,%edi
  801acd:	0f 45 c2             	cmovne %edx,%eax
}
  801ad0:	5b                   	pop    %ebx
  801ad1:	5e                   	pop    %esi
  801ad2:	5f                   	pop    %edi
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	57                   	push   %edi
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801ae1:	57                   	push   %edi
  801ae2:	e8 6e fc ff ff       	call   801755 <strlen>
  801ae7:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801aea:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801aed:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801af7:	eb 46                	jmp    801b3f <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801af9:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801afd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b00:	80 f9 09             	cmp    $0x9,%cl
  801b03:	77 08                	ja     801b0d <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b05:	0f be d2             	movsbl %dl,%edx
  801b08:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b0b:	eb 27                	jmp    801b34 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b0d:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b10:	80 f9 05             	cmp    $0x5,%cl
  801b13:	77 08                	ja     801b1d <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b15:	0f be d2             	movsbl %dl,%edx
  801b18:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b1b:	eb 17                	jmp    801b34 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b1d:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b20:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b23:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b28:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b2c:	77 06                	ja     801b34 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b2e:	0f be d2             	movsbl %dl,%edx
  801b31:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b34:	0f af ce             	imul   %esi,%ecx
  801b37:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b39:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b3c:	83 eb 01             	sub    $0x1,%ebx
  801b3f:	83 fb 01             	cmp    $0x1,%ebx
  801b42:	7f b5                	jg     801af9 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	8b 75 08             	mov    0x8(%ebp),%esi
  801b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b5a:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b5c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b61:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	50                   	push   %eax
  801b68:	e8 a1 e7 ff ff       	call   80030e <sys_ipc_recv>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	79 16                	jns    801b8a <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b74:	85 f6                	test   %esi,%esi
  801b76:	74 06                	je     801b7e <ipc_recv+0x32>
			*from_env_store = 0;
  801b78:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b7e:	85 db                	test   %ebx,%ebx
  801b80:	74 2c                	je     801bae <ipc_recv+0x62>
			*perm_store = 0;
  801b82:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b88:	eb 24                	jmp    801bae <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b8a:	85 f6                	test   %esi,%esi
  801b8c:	74 0a                	je     801b98 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b8e:	a1 08 40 80 00       	mov    0x804008,%eax
  801b93:	8b 40 74             	mov    0x74(%eax),%eax
  801b96:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b98:	85 db                	test   %ebx,%ebx
  801b9a:	74 0a                	je     801ba6 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801b9c:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba1:	8b 40 78             	mov    0x78(%eax),%eax
  801ba4:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801ba6:	a1 08 40 80 00       	mov    0x804008,%eax
  801bab:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	57                   	push   %edi
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 0c             	sub    $0xc,%esp
  801bbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bc7:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bc9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bce:	0f 44 d8             	cmove  %eax,%ebx
  801bd1:	eb 1e                	jmp    801bf1 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bd3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bd6:	74 14                	je     801bec <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	68 a0 23 80 00       	push   $0x8023a0
  801be0:	6a 44                	push   $0x44
  801be2:	68 cc 23 80 00       	push   $0x8023cc
  801be7:	e8 95 f4 ff ff       	call   801081 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801bec:	e8 4e e5 ff ff       	call   80013f <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bf1:	ff 75 14             	pushl  0x14(%ebp)
  801bf4:	53                   	push   %ebx
  801bf5:	56                   	push   %esi
  801bf6:	57                   	push   %edi
  801bf7:	e8 ef e6 ff ff       	call   8002eb <sys_ipc_try_send>
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 d0                	js     801bd3 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5f                   	pop    %edi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c16:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1f:	8b 52 50             	mov    0x50(%edx),%edx
  801c22:	39 ca                	cmp    %ecx,%edx
  801c24:	75 0d                	jne    801c33 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c26:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c29:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c2e:	8b 40 48             	mov    0x48(%eax),%eax
  801c31:	eb 0f                	jmp    801c42 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c33:	83 c0 01             	add    $0x1,%eax
  801c36:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c3b:	75 d9                	jne    801c16 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4a:	89 d0                	mov    %edx,%eax
  801c4c:	c1 e8 16             	shr    $0x16,%eax
  801c4f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c56:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c5b:	f6 c1 01             	test   $0x1,%cl
  801c5e:	74 1d                	je     801c7d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c60:	c1 ea 0c             	shr    $0xc,%edx
  801c63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c6a:	f6 c2 01             	test   $0x1,%dl
  801c6d:	74 0e                	je     801c7d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c6f:	c1 ea 0c             	shr    $0xc,%edx
  801c72:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c79:	ef 
  801c7a:	0f b7 c0             	movzwl %ax,%eax
}
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    
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
