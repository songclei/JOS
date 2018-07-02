
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 2a 1f 80 00       	push   $0x801f2a
  800111:	6a 23                	push   $0x23
  800113:	68 47 1f 80 00       	push   $0x801f47
  800118:	e8 69 0f 00 00       	call   801086 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 2a 1f 80 00       	push   $0x801f2a
  800192:	6a 23                	push   $0x23
  800194:	68 47 1f 80 00       	push   $0x801f47
  800199:	e8 e8 0e 00 00       	call   801086 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 2a 1f 80 00       	push   $0x801f2a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 47 1f 80 00       	push   $0x801f47
  8001db:	e8 a6 0e 00 00       	call   801086 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 2a 1f 80 00       	push   $0x801f2a
  800216:	6a 23                	push   $0x23
  800218:	68 47 1f 80 00       	push   $0x801f47
  80021d:	e8 64 0e 00 00       	call   801086 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 2a 1f 80 00       	push   $0x801f2a
  800258:	6a 23                	push   $0x23
  80025a:	68 47 1f 80 00       	push   $0x801f47
  80025f:	e8 22 0e 00 00       	call   801086 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 0a                	push   $0xa
  800295:	68 2a 1f 80 00       	push   $0x801f2a
  80029a:	6a 23                	push   $0x23
  80029c:	68 47 1f 80 00       	push   $0x801f47
  8002a1:	e8 e0 0d 00 00       	call   801086 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 09                	push   $0x9
  8002d7:	68 2a 1f 80 00       	push   $0x801f2a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 47 1f 80 00       	push   $0x801f47
  8002e3:	e8 9e 0d 00 00       	call   801086 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 2a 1f 80 00       	push   $0x801f2a
  800340:	6a 23                	push   $0x23
  800342:	68 47 1f 80 00       	push   $0x801f47
  800347:	e8 3a 0d 00 00       	call   801086 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 08 40 80 00       	mov    0x804008,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 58 1f 80 00       	push   $0x801f58
  80045b:	e8 ff 0c 00 00       	call   80115f <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2) 
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0); 
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close) 
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 08 40 80 00       	mov    0x804008,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 99 1f 80 00       	push   $0x801f99
  800685:	e8 d5 0a 00 00       	call   80115f <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 08 40 80 00       	mov    0x804008,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 b5 1f 80 00       	push   $0x801fb5
  80075a:	e8 00 0a 00 00       	call   80115f <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 78 1f 80 00       	push   $0x801f78
  80080f:	e8 4b 09 00 00       	call   80115f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 2b 02 00 00       	call   800b03 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 f1 12 00 00       	call   801c10 <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 80 12 00 00       	call   801bba <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 0a 12 00 00       	call   801b51 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 c3 0d 00 00       	call   801793 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 08             	sub    $0x8,%esp
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a02:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a07:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a15:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a1b:	53                   	push   %ebx
  800a1c:	ff 75 0c             	pushl  0xc(%ebp)
  800a1f:	68 08 50 80 00       	push   $0x805008
  800a24:	e8 fc 0e 00 00       	call   801925 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a33:	e8 cb fe ff ff       	call   800903 <fsipc>
  800a38:	83 c4 10             	add    $0x10,%esp
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	78 3d                	js     800a7c <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a3f:	39 d8                	cmp    %ebx,%eax
  800a41:	76 19                	jbe    800a5c <devfile_write+0x69>
  800a43:	68 e4 1f 80 00       	push   $0x801fe4
  800a48:	68 eb 1f 80 00       	push   $0x801feb
  800a4d:	68 9f 00 00 00       	push   $0x9f
  800a52:	68 00 20 80 00       	push   $0x802000
  800a57:	e8 2a 06 00 00       	call   801086 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a5c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a61:	76 19                	jbe    800a7c <devfile_write+0x89>
  800a63:	68 18 20 80 00       	push   $0x802018
  800a68:	68 eb 1f 80 00       	push   $0x801feb
  800a6d:	68 a0 00 00 00       	push   $0xa0
  800a72:	68 00 20 80 00       	push   $0x802000
  800a77:	e8 0a 06 00 00       	call   801086 <_panic>

	return r;
}
  800a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a94:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa4:	e8 5a fe ff ff       	call   800903 <fsipc>
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 4b                	js     800afa <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaf:	39 c6                	cmp    %eax,%esi
  800ab1:	73 16                	jae    800ac9 <devfile_read+0x48>
  800ab3:	68 e4 1f 80 00       	push   $0x801fe4
  800ab8:	68 eb 1f 80 00       	push   $0x801feb
  800abd:	6a 7e                	push   $0x7e
  800abf:	68 00 20 80 00       	push   $0x802000
  800ac4:	e8 bd 05 00 00       	call   801086 <_panic>
	assert(r <= PGSIZE);
  800ac9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ace:	7e 16                	jle    800ae6 <devfile_read+0x65>
  800ad0:	68 0b 20 80 00       	push   $0x80200b
  800ad5:	68 eb 1f 80 00       	push   $0x801feb
  800ada:	6a 7f                	push   $0x7f
  800adc:	68 00 20 80 00       	push   $0x802000
  800ae1:	e8 a0 05 00 00       	call   801086 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae6:	83 ec 04             	sub    $0x4,%esp
  800ae9:	50                   	push   %eax
  800aea:	68 00 50 80 00       	push   $0x805000
  800aef:	ff 75 0c             	pushl  0xc(%ebp)
  800af2:	e8 2e 0e 00 00       	call   801925 <memmove>
	return r;
  800af7:	83 c4 10             	add    $0x10,%esp
}
  800afa:	89 d8                	mov    %ebx,%eax
  800afc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	83 ec 20             	sub    $0x20,%esp
  800b0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0d:	53                   	push   %ebx
  800b0e:	e8 47 0c 00 00       	call   80175a <strlen>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1b:	7f 67                	jg     800b84 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	e8 52 f8 ff ff       	call   80037b <fd_alloc>
  800b29:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 57                	js     800b89 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	53                   	push   %ebx
  800b36:	68 00 50 80 00       	push   $0x805000
  800b3b:	e8 53 0c 00 00       	call   801793 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	e8 ae fd ff ff       	call   800903 <fsipc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	79 14                	jns    800b72 <open+0x6f>
		fd_close(fd, 0);
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	6a 00                	push   $0x0
  800b63:	ff 75 f4             	pushl  -0xc(%ebp)
  800b66:	e8 08 f9 ff ff       	call   800473 <fd_close>
		return r;
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	89 da                	mov    %ebx,%edx
  800b70:	eb 17                	jmp    800b89 <open+0x86>
	}

	return fd2num(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 f4             	pushl  -0xc(%ebp)
  800b78:	e8 d7 f7 ff ff       	call   800354 <fd2num>
  800b7d:	89 c2                	mov    %eax,%edx
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	eb 05                	jmp    800b89 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b84:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b89:	89 d0                	mov    %edx,%eax
  800b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba0:	e8 5e fd ff ff       	call   800903 <fsipc>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	ff 75 08             	pushl  0x8(%ebp)
  800bb5:	e8 aa f7 ff ff       	call   800364 <fd2data>
  800bba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbc:	83 c4 08             	add    $0x8,%esp
  800bbf:	68 45 20 80 00       	push   $0x802045
  800bc4:	53                   	push   %ebx
  800bc5:	e8 c9 0b 00 00       	call   801793 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bca:	8b 46 04             	mov    0x4(%esi),%eax
  800bcd:	2b 06                	sub    (%esi),%eax
  800bcf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdc:	00 00 00 
	stat->st_dev = &devpipe;
  800bdf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be6:	30 80 00 
	return 0;
}
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bff:	53                   	push   %ebx
  800c00:	6a 00                	push   $0x0
  800c02:	e8 e1 f5 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c07:	89 1c 24             	mov    %ebx,(%esp)
  800c0a:	e8 55 f7 ff ff       	call   800364 <fd2data>
  800c0f:	83 c4 08             	add    $0x8,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 00                	push   $0x0
  800c15:	e8 ce f5 ff ff       	call   8001e8 <sys_page_unmap>
}
  800c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 1c             	sub    $0x1c,%esp
  800c28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c2d:	a1 08 40 80 00       	mov    0x804008,%eax
  800c32:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3b:	e8 09 10 00 00       	call   801c49 <pageref>
  800c40:	89 c3                	mov    %eax,%ebx
  800c42:	89 3c 24             	mov    %edi,(%esp)
  800c45:	e8 ff 0f 00 00       	call   801c49 <pageref>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	39 c3                	cmp    %eax,%ebx
  800c4f:	0f 94 c1             	sete   %cl
  800c52:	0f b6 c9             	movzbl %cl,%ecx
  800c55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c58:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c5e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c61:	39 ce                	cmp    %ecx,%esi
  800c63:	74 1b                	je     800c80 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c65:	39 c3                	cmp    %eax,%ebx
  800c67:	75 c4                	jne    800c2d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c69:	8b 42 58             	mov    0x58(%edx),%eax
  800c6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6f:	50                   	push   %eax
  800c70:	56                   	push   %esi
  800c71:	68 4c 20 80 00       	push   $0x80204c
  800c76:	e8 e4 04 00 00       	call   80115f <cprintf>
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	eb ad                	jmp    800c2d <_pipeisclosed+0xe>
	}
}
  800c80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 28             	sub    $0x28,%esp
  800c94:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c97:	56                   	push   %esi
  800c98:	e8 c7 f6 ff ff       	call   800364 <fd2data>
  800c9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca7:	eb 4b                	jmp    800cf4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca9:	89 da                	mov    %ebx,%edx
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	e8 6d ff ff ff       	call   800c1f <_pipeisclosed>
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	75 48                	jne    800cfe <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb6:	e8 89 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbb:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbe:	8b 0b                	mov    (%ebx),%ecx
  800cc0:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc3:	39 d0                	cmp    %edx,%eax
  800cc5:	73 e2                	jae    800ca9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	c1 fa 1f             	sar    $0x1f,%edx
  800cd6:	89 d1                	mov    %edx,%ecx
  800cd8:	c1 e9 1b             	shr    $0x1b,%ecx
  800cdb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cde:	83 e2 1f             	and    $0x1f,%edx
  800ce1:	29 ca                	sub    %ecx,%edx
  800ce3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ceb:	83 c0 01             	add    $0x1,%eax
  800cee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf1:	83 c7 01             	add    $0x1,%edi
  800cf4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf7:	75 c2                	jne    800cbb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfc:	eb 05                	jmp    800d03 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 18             	sub    $0x18,%esp
  800d14:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d17:	57                   	push   %edi
  800d18:	e8 47 f6 ff ff       	call   800364 <fd2data>
  800d1d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1f:	83 c4 10             	add    $0x10,%esp
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	eb 3d                	jmp    800d66 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d29:	85 db                	test   %ebx,%ebx
  800d2b:	74 04                	je     800d31 <devpipe_read+0x26>
				return i;
  800d2d:	89 d8                	mov    %ebx,%eax
  800d2f:	eb 44                	jmp    800d75 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d31:	89 f2                	mov    %esi,%edx
  800d33:	89 f8                	mov    %edi,%eax
  800d35:	e8 e5 fe ff ff       	call   800c1f <_pipeisclosed>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	75 32                	jne    800d70 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d3e:	e8 01 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d43:	8b 06                	mov    (%esi),%eax
  800d45:	3b 46 04             	cmp    0x4(%esi),%eax
  800d48:	74 df                	je     800d29 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4a:	99                   	cltd   
  800d4b:	c1 ea 1b             	shr    $0x1b,%edx
  800d4e:	01 d0                	add    %edx,%eax
  800d50:	83 e0 1f             	and    $0x1f,%eax
  800d53:	29 d0                	sub    %edx,%eax
  800d55:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d60:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d63:	83 c3 01             	add    $0x1,%ebx
  800d66:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d69:	75 d8                	jne    800d43 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6e:	eb 05                	jmp    800d75 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d88:	50                   	push   %eax
  800d89:	e8 ed f5 ff ff       	call   80037b <fd_alloc>
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	85 c0                	test   %eax,%eax
  800d95:	0f 88 2c 01 00 00    	js     800ec7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 07 04 00 00       	push   $0x407
  800da3:	ff 75 f4             	pushl  -0xc(%ebp)
  800da6:	6a 00                	push   $0x0
  800da8:	e8 b6 f3 ff ff       	call   800163 <sys_page_alloc>
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	85 c0                	test   %eax,%eax
  800db4:	0f 88 0d 01 00 00    	js     800ec7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc0:	50                   	push   %eax
  800dc1:	e8 b5 f5 ff ff       	call   80037b <fd_alloc>
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	0f 88 e2 00 00 00    	js     800eb5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd3:	83 ec 04             	sub    $0x4,%esp
  800dd6:	68 07 04 00 00       	push   $0x407
  800ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dde:	6a 00                	push   $0x0
  800de0:	e8 7e f3 ff ff       	call   800163 <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 c3 00 00 00    	js     800eb5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f4             	pushl  -0xc(%ebp)
  800df8:	e8 67 f5 ff ff       	call   800364 <fd2data>
  800dfd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dff:	83 c4 0c             	add    $0xc,%esp
  800e02:	68 07 04 00 00       	push   $0x407
  800e07:	50                   	push   %eax
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 54 f3 ff ff       	call   800163 <sys_page_alloc>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	0f 88 89 00 00 00    	js     800ea5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e22:	e8 3d f5 ff ff       	call   800364 <fd2data>
  800e27:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2e:	50                   	push   %eax
  800e2f:	6a 00                	push   $0x0
  800e31:	56                   	push   %esi
  800e32:	6a 00                	push   $0x0
  800e34:	e8 6d f3 ff ff       	call   8001a6 <sys_page_map>
  800e39:	89 c3                	mov    %eax,%ebx
  800e3b:	83 c4 20             	add    $0x20,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	78 55                	js     800e97 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e60:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e65:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e72:	e8 dd f4 ff ff       	call   800354 <fd2num>
  800e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7c:	83 c4 04             	add    $0x4,%esp
  800e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e82:	e8 cd f4 ff ff       	call   800354 <fd2num>
  800e87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	ba 00 00 00 00       	mov    $0x0,%edx
  800e95:	eb 30                	jmp    800ec7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	56                   	push   %esi
  800e9b:	6a 00                	push   $0x0
  800e9d:	e8 46 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800ea2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  800eab:	6a 00                	push   $0x0
  800ead:	e8 36 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800eb2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 26 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec7:	89 d0                	mov    %edx,%eax
  800ec9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed9:	50                   	push   %eax
  800eda:	ff 75 08             	pushl  0x8(%ebp)
  800edd:	e8 e8 f4 ff ff       	call   8003ca <fd_lookup>
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 18                	js     800f01 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	ff 75 f4             	pushl  -0xc(%ebp)
  800eef:	e8 70 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef9:	e8 21 fd ff ff       	call   800c1f <_pipeisclosed>
  800efe:	83 c4 10             	add    $0x10,%esp
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f13:	68 64 20 80 00       	push   $0x802064
  800f18:	ff 75 0c             	pushl  0xc(%ebp)
  800f1b:	e8 73 08 00 00       	call   801793 <strcpy>
	return 0;
}
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f33:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f38:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3e:	eb 2d                	jmp    800f6d <devcons_write+0x46>
		m = n - tot;
  800f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f43:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f45:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f48:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f4d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	53                   	push   %ebx
  800f54:	03 45 0c             	add    0xc(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	57                   	push   %edi
  800f59:	e8 c7 09 00 00       	call   801925 <memmove>
		sys_cputs(buf, m);
  800f5e:	83 c4 08             	add    $0x8,%esp
  800f61:	53                   	push   %ebx
  800f62:	57                   	push   %edi
  800f63:	e8 3f f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f68:	01 de                	add    %ebx,%esi
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	89 f0                	mov    %esi,%eax
  800f6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f72:	72 cc                	jb     800f40 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 08             	sub    $0x8,%esp
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8b:	74 2a                	je     800fb7 <devcons_read+0x3b>
  800f8d:	eb 05                	jmp    800f94 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f8f:	e8 b0 f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f94:	e8 2c f1 ff ff       	call   8000c5 <sys_cgetc>
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	74 f2                	je     800f8f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 16                	js     800fb7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa1:	83 f8 04             	cmp    $0x4,%eax
  800fa4:	74 0c                	je     800fb2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa9:	88 02                	mov    %al,(%edx)
	return 1;
  800fab:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb0:	eb 05                	jmp    800fb7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc5:	6a 01                	push   $0x1
  800fc7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	e8 d7 f0 ff ff       	call   8000a7 <sys_cputs>
}
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <getchar>:

int
getchar(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fdb:	6a 01                	push   $0x1
  800fdd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 48 f6 ff ff       	call   800630 <read>
	if (r < 0)
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 0f                	js     800ffe <getchar+0x29>
		return r;
	if (r < 1)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	7e 06                	jle    800ff9 <getchar+0x24>
		return -E_EOF;
	return c;
  800ff3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff7:	eb 05                	jmp    800ffe <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801006:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	ff 75 08             	pushl  0x8(%ebp)
  80100d:	e8 b8 f3 ff ff       	call   8003ca <fd_lookup>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 11                	js     80102a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801022:	39 10                	cmp    %edx,(%eax)
  801024:	0f 94 c0             	sete   %al
  801027:	0f b6 c0             	movzbl %al,%eax
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <opencons>:

int
opencons(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801032:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	e8 40 f3 ff ff       	call   80037b <fd_alloc>
  80103b:	83 c4 10             	add    $0x10,%esp
		return r;
  80103e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801040:	85 c0                	test   %eax,%eax
  801042:	78 3e                	js     801082 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	68 07 04 00 00       	push   $0x407
  80104c:	ff 75 f4             	pushl  -0xc(%ebp)
  80104f:	6a 00                	push   $0x0
  801051:	e8 0d f1 ff ff       	call   800163 <sys_page_alloc>
  801056:	83 c4 10             	add    $0x10,%esp
		return r;
  801059:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 23                	js     801082 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80105f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	50                   	push   %eax
  801078:	e8 d7 f2 ff ff       	call   800354 <fd2num>
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	83 c4 10             	add    $0x10,%esp
}
  801082:	89 d0                	mov    %edx,%eax
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80108e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801094:	e8 8c f0 ff ff       	call   800125 <sys_getenvid>
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	ff 75 08             	pushl  0x8(%ebp)
  8010a2:	56                   	push   %esi
  8010a3:	50                   	push   %eax
  8010a4:	68 70 20 80 00       	push   $0x802070
  8010a9:	e8 b1 00 00 00       	call   80115f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010ae:	83 c4 18             	add    $0x18,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	ff 75 10             	pushl  0x10(%ebp)
  8010b5:	e8 54 00 00 00       	call   80110e <vcprintf>
	cprintf("\n");
  8010ba:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010c1:	e8 99 00 00 00       	call   80115f <cprintf>
  8010c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c9:	cc                   	int3   
  8010ca:	eb fd                	jmp    8010c9 <_panic+0x43>

008010cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d6:	8b 13                	mov    (%ebx),%edx
  8010d8:	8d 42 01             	lea    0x1(%edx),%eax
  8010db:	89 03                	mov    %eax,(%ebx)
  8010dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e9:	75 1a                	jne    801105 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	68 ff 00 00 00       	push   $0xff
  8010f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f6:	50                   	push   %eax
  8010f7:	e8 ab ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801102:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801105:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801109:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110c:	c9                   	leave  
  80110d:	c3                   	ret    

0080110e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111e:	00 00 00 
	b.cnt = 0;
  801121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112b:	ff 75 0c             	pushl  0xc(%ebp)
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801137:	50                   	push   %eax
  801138:	68 cc 10 80 00       	push   $0x8010cc
  80113d:	e8 54 01 00 00       	call   801296 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	e8 50 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801157:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801165:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801168:	50                   	push   %eax
  801169:	ff 75 08             	pushl  0x8(%ebp)
  80116c:	e8 9d ff ff ff       	call   80110e <vcprintf>
	va_end(ap);

	return cnt;
}
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 1c             	sub    $0x1c,%esp
  80117c:	89 c7                	mov    %eax,%edi
  80117e:	89 d6                	mov    %edx,%esi
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	8b 55 0c             	mov    0xc(%ebp),%edx
  801186:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801189:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801194:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801197:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80119a:	39 d3                	cmp    %edx,%ebx
  80119c:	72 05                	jb     8011a3 <printnum+0x30>
  80119e:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a1:	77 45                	ja     8011e8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	ff 75 18             	pushl  0x18(%ebp)
  8011a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ac:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011af:	53                   	push   %ebx
  8011b0:	ff 75 10             	pushl  0x10(%ebp)
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c2:	e8 c9 0a 00 00       	call   801c90 <__udivdi3>
  8011c7:	83 c4 18             	add    $0x18,%esp
  8011ca:	52                   	push   %edx
  8011cb:	50                   	push   %eax
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	89 f8                	mov    %edi,%eax
  8011d0:	e8 9e ff ff ff       	call   801173 <printnum>
  8011d5:	83 c4 20             	add    $0x20,%esp
  8011d8:	eb 18                	jmp    8011f2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	56                   	push   %esi
  8011de:	ff 75 18             	pushl  0x18(%ebp)
  8011e1:	ff d7                	call   *%edi
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 03                	jmp    8011eb <printnum+0x78>
  8011e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011eb:	83 eb 01             	sub    $0x1,%ebx
  8011ee:	85 db                	test   %ebx,%ebx
  8011f0:	7f e8                	jg     8011da <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f2:	83 ec 08             	sub    $0x8,%esp
  8011f5:	56                   	push   %esi
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ff:	ff 75 dc             	pushl  -0x24(%ebp)
  801202:	ff 75 d8             	pushl  -0x28(%ebp)
  801205:	e8 b6 0b 00 00       	call   801dc0 <__umoddi3>
  80120a:	83 c4 14             	add    $0x14,%esp
  80120d:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  801214:	50                   	push   %eax
  801215:	ff d7                	call   *%edi
}
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801225:	83 fa 01             	cmp    $0x1,%edx
  801228:	7e 0e                	jle    801238 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122a:	8b 10                	mov    (%eax),%edx
  80122c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122f:	89 08                	mov    %ecx,(%eax)
  801231:	8b 02                	mov    (%edx),%eax
  801233:	8b 52 04             	mov    0x4(%edx),%edx
  801236:	eb 22                	jmp    80125a <getuint+0x38>
	else if (lflag)
  801238:	85 d2                	test   %edx,%edx
  80123a:	74 10                	je     80124c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123c:	8b 10                	mov    (%eax),%edx
  80123e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801241:	89 08                	mov    %ecx,(%eax)
  801243:	8b 02                	mov    (%edx),%eax
  801245:	ba 00 00 00 00       	mov    $0x0,%edx
  80124a:	eb 0e                	jmp    80125a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124c:	8b 10                	mov    (%eax),%edx
  80124e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801251:	89 08                	mov    %ecx,(%eax)
  801253:	8b 02                	mov    (%edx),%eax
  801255:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801262:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801266:	8b 10                	mov    (%eax),%edx
  801268:	3b 50 04             	cmp    0x4(%eax),%edx
  80126b:	73 0a                	jae    801277 <sprintputch+0x1b>
		*b->buf++ = ch;
  80126d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801270:	89 08                	mov    %ecx,(%eax)
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	88 02                	mov    %al,(%edx)
}
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80127f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801282:	50                   	push   %eax
  801283:	ff 75 10             	pushl  0x10(%ebp)
  801286:	ff 75 0c             	pushl  0xc(%ebp)
  801289:	ff 75 08             	pushl  0x8(%ebp)
  80128c:	e8 05 00 00 00       	call   801296 <vprintfmt>
	va_end(ap);
}
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 2c             	sub    $0x2c,%esp
  80129f:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a8:	eb 12                	jmp    8012bc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	0f 84 38 04 00 00    	je     8016ea <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	ff d6                	call   *%esi
  8012b9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012bc:	83 c7 01             	add    $0x1,%edi
  8012bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c3:	83 f8 25             	cmp    $0x25,%eax
  8012c6:	75 e2                	jne    8012aa <vprintfmt+0x14>
  8012c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e6:	eb 07                	jmp    8012ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012eb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8d 47 01             	lea    0x1(%edi),%eax
  8012f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f5:	0f b6 07             	movzbl (%edi),%eax
  8012f8:	0f b6 c8             	movzbl %al,%ecx
  8012fb:	83 e8 23             	sub    $0x23,%eax
  8012fe:	3c 55                	cmp    $0x55,%al
  801300:	0f 87 c9 03 00 00    	ja     8016cf <vprintfmt+0x439>
  801306:	0f b6 c0             	movzbl %al,%eax
  801309:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801313:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801317:	eb d6                	jmp    8012ef <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  801319:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801320:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801323:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801326:	eb 94                	jmp    8012bc <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  801328:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  80132f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801335:	eb 85                	jmp    8012bc <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801337:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  80133e:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801344:	e9 73 ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  801349:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801350:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801356:	e9 61 ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80135b:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801362:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  801368:	e9 4f ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80136d:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801374:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80137a:	e9 3d ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80137f:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801386:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80138c:	e9 2b ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801391:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  801398:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80139e:	e9 19 ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  8013a3:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  8013aa:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013b0:	e9 07 ff ff ff       	jmp    8012bc <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013b5:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013bc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013c2:	e9 f5 fe ff ff       	jmp    8012bc <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8013cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013d5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013d9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013dc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013df:	83 fa 09             	cmp    $0x9,%edx
  8013e2:	77 3f                	ja     801423 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013e4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013e7:	eb e9                	jmp    8013d2 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ec:	8d 48 04             	lea    0x4(%eax),%ecx
  8013ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013f2:	8b 00                	mov    (%eax),%eax
  8013f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013fa:	eb 2d                	jmp    801429 <vprintfmt+0x193>
  8013fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ff:	85 c0                	test   %eax,%eax
  801401:	b9 00 00 00 00       	mov    $0x0,%ecx
  801406:	0f 49 c8             	cmovns %eax,%ecx
  801409:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80140c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80140f:	e9 db fe ff ff       	jmp    8012ef <vprintfmt+0x59>
  801414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801417:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80141e:	e9 cc fe ff ff       	jmp    8012ef <vprintfmt+0x59>
  801423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801426:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80142d:	0f 89 bc fe ff ff    	jns    8012ef <vprintfmt+0x59>
				width = precision, precision = -1;
  801433:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801439:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801440:	e9 aa fe ff ff       	jmp    8012ef <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801445:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80144b:	e9 9f fe ff ff       	jmp    8012ef <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801450:	8b 45 14             	mov    0x14(%ebp),%eax
  801453:	8d 50 04             	lea    0x4(%eax),%edx
  801456:	89 55 14             	mov    %edx,0x14(%ebp)
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	53                   	push   %ebx
  80145d:	ff 30                	pushl  (%eax)
  80145f:	ff d6                	call   *%esi
			break;
  801461:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801467:	e9 50 fe ff ff       	jmp    8012bc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80146c:	8b 45 14             	mov    0x14(%ebp),%eax
  80146f:	8d 50 04             	lea    0x4(%eax),%edx
  801472:	89 55 14             	mov    %edx,0x14(%ebp)
  801475:	8b 00                	mov    (%eax),%eax
  801477:	99                   	cltd   
  801478:	31 d0                	xor    %edx,%eax
  80147a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80147c:	83 f8 0f             	cmp    $0xf,%eax
  80147f:	7f 0b                	jg     80148c <vprintfmt+0x1f6>
  801481:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  801488:	85 d2                	test   %edx,%edx
  80148a:	75 18                	jne    8014a4 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80148c:	50                   	push   %eax
  80148d:	68 ab 20 80 00       	push   $0x8020ab
  801492:	53                   	push   %ebx
  801493:	56                   	push   %esi
  801494:	e8 e0 fd ff ff       	call   801279 <printfmt>
  801499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80149f:	e9 18 fe ff ff       	jmp    8012bc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8014a4:	52                   	push   %edx
  8014a5:	68 fd 1f 80 00       	push   $0x801ffd
  8014aa:	53                   	push   %ebx
  8014ab:	56                   	push   %esi
  8014ac:	e8 c8 fd ff ff       	call   801279 <printfmt>
  8014b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014b7:	e9 00 fe ff ff       	jmp    8012bc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8d 50 04             	lea    0x4(%eax),%edx
  8014c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014c7:	85 ff                	test   %edi,%edi
  8014c9:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014d5:	0f 8e 94 00 00 00    	jle    80156f <vprintfmt+0x2d9>
  8014db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014df:	0f 84 98 00 00 00    	je     80157d <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	ff 75 d0             	pushl  -0x30(%ebp)
  8014eb:	57                   	push   %edi
  8014ec:	e8 81 02 00 00       	call   801772 <strnlen>
  8014f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014f4:	29 c1                	sub    %eax,%ecx
  8014f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801500:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801503:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801506:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801508:	eb 0f                	jmp    801519 <vprintfmt+0x283>
					putch(padc, putdat);
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	53                   	push   %ebx
  80150e:	ff 75 e0             	pushl  -0x20(%ebp)
  801511:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801513:	83 ef 01             	sub    $0x1,%edi
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 ff                	test   %edi,%edi
  80151b:	7f ed                	jg     80150a <vprintfmt+0x274>
  80151d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801520:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801523:	85 c9                	test   %ecx,%ecx
  801525:	b8 00 00 00 00       	mov    $0x0,%eax
  80152a:	0f 49 c1             	cmovns %ecx,%eax
  80152d:	29 c1                	sub    %eax,%ecx
  80152f:	89 75 08             	mov    %esi,0x8(%ebp)
  801532:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801535:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801538:	89 cb                	mov    %ecx,%ebx
  80153a:	eb 4d                	jmp    801589 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80153c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801540:	74 1b                	je     80155d <vprintfmt+0x2c7>
  801542:	0f be c0             	movsbl %al,%eax
  801545:	83 e8 20             	sub    $0x20,%eax
  801548:	83 f8 5e             	cmp    $0x5e,%eax
  80154b:	76 10                	jbe    80155d <vprintfmt+0x2c7>
					putch('?', putdat);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	ff 75 0c             	pushl  0xc(%ebp)
  801553:	6a 3f                	push   $0x3f
  801555:	ff 55 08             	call   *0x8(%ebp)
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	eb 0d                	jmp    80156a <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	ff 75 0c             	pushl  0xc(%ebp)
  801563:	52                   	push   %edx
  801564:	ff 55 08             	call   *0x8(%ebp)
  801567:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80156a:	83 eb 01             	sub    $0x1,%ebx
  80156d:	eb 1a                	jmp    801589 <vprintfmt+0x2f3>
  80156f:	89 75 08             	mov    %esi,0x8(%ebp)
  801572:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80157b:	eb 0c                	jmp    801589 <vprintfmt+0x2f3>
  80157d:	89 75 08             	mov    %esi,0x8(%ebp)
  801580:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801583:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801586:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801589:	83 c7 01             	add    $0x1,%edi
  80158c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801590:	0f be d0             	movsbl %al,%edx
  801593:	85 d2                	test   %edx,%edx
  801595:	74 23                	je     8015ba <vprintfmt+0x324>
  801597:	85 f6                	test   %esi,%esi
  801599:	78 a1                	js     80153c <vprintfmt+0x2a6>
  80159b:	83 ee 01             	sub    $0x1,%esi
  80159e:	79 9c                	jns    80153c <vprintfmt+0x2a6>
  8015a0:	89 df                	mov    %ebx,%edi
  8015a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015a8:	eb 18                	jmp    8015c2 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	6a 20                	push   $0x20
  8015b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015b2:	83 ef 01             	sub    $0x1,%edi
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	eb 08                	jmp    8015c2 <vprintfmt+0x32c>
  8015ba:	89 df                	mov    %ebx,%edi
  8015bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015c2:	85 ff                	test   %edi,%edi
  8015c4:	7f e4                	jg     8015aa <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c9:	e9 ee fc ff ff       	jmp    8012bc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015ce:	83 fa 01             	cmp    $0x1,%edx
  8015d1:	7e 16                	jle    8015e9 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d6:	8d 50 08             	lea    0x8(%eax),%edx
  8015d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8015dc:	8b 50 04             	mov    0x4(%eax),%edx
  8015df:	8b 00                	mov    (%eax),%eax
  8015e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015e7:	eb 32                	jmp    80161b <vprintfmt+0x385>
	else if (lflag)
  8015e9:	85 d2                	test   %edx,%edx
  8015eb:	74 18                	je     801605 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f0:	8d 50 04             	lea    0x4(%eax),%edx
  8015f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8015f6:	8b 00                	mov    (%eax),%eax
  8015f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015fb:	89 c1                	mov    %eax,%ecx
  8015fd:	c1 f9 1f             	sar    $0x1f,%ecx
  801600:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801603:	eb 16                	jmp    80161b <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  801605:	8b 45 14             	mov    0x14(%ebp),%eax
  801608:	8d 50 04             	lea    0x4(%eax),%edx
  80160b:	89 55 14             	mov    %edx,0x14(%ebp)
  80160e:	8b 00                	mov    (%eax),%eax
  801610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801613:	89 c1                	mov    %eax,%ecx
  801615:	c1 f9 1f             	sar    $0x1f,%ecx
  801618:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80161b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80161e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801621:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801626:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80162a:	79 6f                	jns    80169b <vprintfmt+0x405>
				putch('-', putdat);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	53                   	push   %ebx
  801630:	6a 2d                	push   $0x2d
  801632:	ff d6                	call   *%esi
				num = -(long long) num;
  801634:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801637:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80163a:	f7 d8                	neg    %eax
  80163c:	83 d2 00             	adc    $0x0,%edx
  80163f:	f7 da                	neg    %edx
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 55                	jmp    80169b <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801646:	8d 45 14             	lea    0x14(%ebp),%eax
  801649:	e8 d4 fb ff ff       	call   801222 <getuint>
			base = 10;
  80164e:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801653:	eb 46                	jmp    80169b <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801655:	8d 45 14             	lea    0x14(%ebp),%eax
  801658:	e8 c5 fb ff ff       	call   801222 <getuint>
			base = 8;
  80165d:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801662:	eb 37                	jmp    80169b <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	53                   	push   %ebx
  801668:	6a 30                	push   $0x30
  80166a:	ff d6                	call   *%esi
			putch('x', putdat);
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	53                   	push   %ebx
  801670:	6a 78                	push   $0x78
  801672:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801674:	8b 45 14             	mov    0x14(%ebp),%eax
  801677:	8d 50 04             	lea    0x4(%eax),%edx
  80167a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80167d:	8b 00                	mov    (%eax),%eax
  80167f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801684:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801687:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80168c:	eb 0d                	jmp    80169b <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80168e:	8d 45 14             	lea    0x14(%ebp),%eax
  801691:	e8 8c fb ff ff       	call   801222 <getuint>
			base = 16;
  801696:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8016a2:	51                   	push   %ecx
  8016a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a6:	57                   	push   %edi
  8016a7:	52                   	push   %edx
  8016a8:	50                   	push   %eax
  8016a9:	89 da                	mov    %ebx,%edx
  8016ab:	89 f0                	mov    %esi,%eax
  8016ad:	e8 c1 fa ff ff       	call   801173 <printnum>
			break;
  8016b2:	83 c4 20             	add    $0x20,%esp
  8016b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b8:	e9 ff fb ff ff       	jmp    8012bc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	53                   	push   %ebx
  8016c1:	51                   	push   %ecx
  8016c2:	ff d6                	call   *%esi
			break;
  8016c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016ca:	e9 ed fb ff ff       	jmp    8012bc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	6a 25                	push   $0x25
  8016d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	eb 03                	jmp    8016df <vprintfmt+0x449>
  8016dc:	83 ef 01             	sub    $0x1,%edi
  8016df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016e3:	75 f7                	jne    8016dc <vprintfmt+0x446>
  8016e5:	e9 d2 fb ff ff       	jmp    8012bc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5f                   	pop    %edi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 18             	sub    $0x18,%esp
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801701:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801705:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80170f:	85 c0                	test   %eax,%eax
  801711:	74 26                	je     801739 <vsnprintf+0x47>
  801713:	85 d2                	test   %edx,%edx
  801715:	7e 22                	jle    801739 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801717:	ff 75 14             	pushl  0x14(%ebp)
  80171a:	ff 75 10             	pushl  0x10(%ebp)
  80171d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	68 5c 12 80 00       	push   $0x80125c
  801726:	e8 6b fb ff ff       	call   801296 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80172b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80172e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	eb 05                	jmp    80173e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801746:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801749:	50                   	push   %eax
  80174a:	ff 75 10             	pushl  0x10(%ebp)
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	ff 75 08             	pushl  0x8(%ebp)
  801753:	e8 9a ff ff ff       	call   8016f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801760:	b8 00 00 00 00       	mov    $0x0,%eax
  801765:	eb 03                	jmp    80176a <strlen+0x10>
		n++;
  801767:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80176a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80176e:	75 f7                	jne    801767 <strlen+0xd>
		n++;
	return n;
}
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	eb 03                	jmp    801785 <strnlen+0x13>
		n++;
  801782:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801785:	39 c2                	cmp    %eax,%edx
  801787:	74 08                	je     801791 <strnlen+0x1f>
  801789:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80178d:	75 f3                	jne    801782 <strnlen+0x10>
  80178f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80179d:	89 c2                	mov    %eax,%edx
  80179f:	83 c2 01             	add    $0x1,%edx
  8017a2:	83 c1 01             	add    $0x1,%ecx
  8017a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8017a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017ac:	84 db                	test   %bl,%bl
  8017ae:	75 ef                	jne    80179f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017b0:	5b                   	pop    %ebx
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017ba:	53                   	push   %ebx
  8017bb:	e8 9a ff ff ff       	call   80175a <strlen>
  8017c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017c3:	ff 75 0c             	pushl  0xc(%ebp)
  8017c6:	01 d8                	add    %ebx,%eax
  8017c8:	50                   	push   %eax
  8017c9:	e8 c5 ff ff ff       	call   801793 <strcpy>
	return dst;
}
  8017ce:	89 d8                	mov    %ebx,%eax
  8017d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	8b 75 08             	mov    0x8(%ebp),%esi
  8017dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e0:	89 f3                	mov    %esi,%ebx
  8017e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017e5:	89 f2                	mov    %esi,%edx
  8017e7:	eb 0f                	jmp    8017f8 <strncpy+0x23>
		*dst++ = *src;
  8017e9:	83 c2 01             	add    $0x1,%edx
  8017ec:	0f b6 01             	movzbl (%ecx),%eax
  8017ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017f2:	80 39 01             	cmpb   $0x1,(%ecx)
  8017f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017f8:	39 da                	cmp    %ebx,%edx
  8017fa:	75 ed                	jne    8017e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017fc:	89 f0                	mov    %esi,%eax
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	8b 75 08             	mov    0x8(%ebp),%esi
  80180a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180d:	8b 55 10             	mov    0x10(%ebp),%edx
  801810:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801812:	85 d2                	test   %edx,%edx
  801814:	74 21                	je     801837 <strlcpy+0x35>
  801816:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80181a:	89 f2                	mov    %esi,%edx
  80181c:	eb 09                	jmp    801827 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80181e:	83 c2 01             	add    $0x1,%edx
  801821:	83 c1 01             	add    $0x1,%ecx
  801824:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801827:	39 c2                	cmp    %eax,%edx
  801829:	74 09                	je     801834 <strlcpy+0x32>
  80182b:	0f b6 19             	movzbl (%ecx),%ebx
  80182e:	84 db                	test   %bl,%bl
  801830:	75 ec                	jne    80181e <strlcpy+0x1c>
  801832:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801834:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801837:	29 f0                	sub    %esi,%eax
}
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801843:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801846:	eb 06                	jmp    80184e <strcmp+0x11>
		p++, q++;
  801848:	83 c1 01             	add    $0x1,%ecx
  80184b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80184e:	0f b6 01             	movzbl (%ecx),%eax
  801851:	84 c0                	test   %al,%al
  801853:	74 04                	je     801859 <strcmp+0x1c>
  801855:	3a 02                	cmp    (%edx),%al
  801857:	74 ef                	je     801848 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801859:	0f b6 c0             	movzbl %al,%eax
  80185c:	0f b6 12             	movzbl (%edx),%edx
  80185f:	29 d0                	sub    %edx,%eax
}
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	53                   	push   %ebx
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801872:	eb 06                	jmp    80187a <strncmp+0x17>
		n--, p++, q++;
  801874:	83 c0 01             	add    $0x1,%eax
  801877:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80187a:	39 d8                	cmp    %ebx,%eax
  80187c:	74 15                	je     801893 <strncmp+0x30>
  80187e:	0f b6 08             	movzbl (%eax),%ecx
  801881:	84 c9                	test   %cl,%cl
  801883:	74 04                	je     801889 <strncmp+0x26>
  801885:	3a 0a                	cmp    (%edx),%cl
  801887:	74 eb                	je     801874 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801889:	0f b6 00             	movzbl (%eax),%eax
  80188c:	0f b6 12             	movzbl (%edx),%edx
  80188f:	29 d0                	sub    %edx,%eax
  801891:	eb 05                	jmp    801898 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801898:	5b                   	pop    %ebx
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018a5:	eb 07                	jmp    8018ae <strchr+0x13>
		if (*s == c)
  8018a7:	38 ca                	cmp    %cl,%dl
  8018a9:	74 0f                	je     8018ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8018ab:	83 c0 01             	add    $0x1,%eax
  8018ae:	0f b6 10             	movzbl (%eax),%edx
  8018b1:	84 d2                	test   %dl,%dl
  8018b3:	75 f2                	jne    8018a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018c6:	eb 03                	jmp    8018cb <strfind+0xf>
  8018c8:	83 c0 01             	add    $0x1,%eax
  8018cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018ce:	38 ca                	cmp    %cl,%dl
  8018d0:	74 04                	je     8018d6 <strfind+0x1a>
  8018d2:	84 d2                	test   %dl,%dl
  8018d4:	75 f2                	jne    8018c8 <strfind+0xc>
			break;
	return (char *) s;
}
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	57                   	push   %edi
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
  8018de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018e4:	85 c9                	test   %ecx,%ecx
  8018e6:	74 36                	je     80191e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018ee:	75 28                	jne    801918 <memset+0x40>
  8018f0:	f6 c1 03             	test   $0x3,%cl
  8018f3:	75 23                	jne    801918 <memset+0x40>
		c &= 0xFF;
  8018f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018f9:	89 d3                	mov    %edx,%ebx
  8018fb:	c1 e3 08             	shl    $0x8,%ebx
  8018fe:	89 d6                	mov    %edx,%esi
  801900:	c1 e6 18             	shl    $0x18,%esi
  801903:	89 d0                	mov    %edx,%eax
  801905:	c1 e0 10             	shl    $0x10,%eax
  801908:	09 f0                	or     %esi,%eax
  80190a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	09 d0                	or     %edx,%eax
  801910:	c1 e9 02             	shr    $0x2,%ecx
  801913:	fc                   	cld    
  801914:	f3 ab                	rep stos %eax,%es:(%edi)
  801916:	eb 06                	jmp    80191e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191b:	fc                   	cld    
  80191c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80191e:	89 f8                	mov    %edi,%eax
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5f                   	pop    %edi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	57                   	push   %edi
  801929:	56                   	push   %esi
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801933:	39 c6                	cmp    %eax,%esi
  801935:	73 35                	jae    80196c <memmove+0x47>
  801937:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80193a:	39 d0                	cmp    %edx,%eax
  80193c:	73 2e                	jae    80196c <memmove+0x47>
		s += n;
		d += n;
  80193e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801941:	89 d6                	mov    %edx,%esi
  801943:	09 fe                	or     %edi,%esi
  801945:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80194b:	75 13                	jne    801960 <memmove+0x3b>
  80194d:	f6 c1 03             	test   $0x3,%cl
  801950:	75 0e                	jne    801960 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801952:	83 ef 04             	sub    $0x4,%edi
  801955:	8d 72 fc             	lea    -0x4(%edx),%esi
  801958:	c1 e9 02             	shr    $0x2,%ecx
  80195b:	fd                   	std    
  80195c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80195e:	eb 09                	jmp    801969 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801960:	83 ef 01             	sub    $0x1,%edi
  801963:	8d 72 ff             	lea    -0x1(%edx),%esi
  801966:	fd                   	std    
  801967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801969:	fc                   	cld    
  80196a:	eb 1d                	jmp    801989 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80196c:	89 f2                	mov    %esi,%edx
  80196e:	09 c2                	or     %eax,%edx
  801970:	f6 c2 03             	test   $0x3,%dl
  801973:	75 0f                	jne    801984 <memmove+0x5f>
  801975:	f6 c1 03             	test   $0x3,%cl
  801978:	75 0a                	jne    801984 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80197a:	c1 e9 02             	shr    $0x2,%ecx
  80197d:	89 c7                	mov    %eax,%edi
  80197f:	fc                   	cld    
  801980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801982:	eb 05                	jmp    801989 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801984:	89 c7                	mov    %eax,%edi
  801986:	fc                   	cld    
  801987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801989:	5e                   	pop    %esi
  80198a:	5f                   	pop    %edi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801990:	ff 75 10             	pushl  0x10(%ebp)
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	ff 75 08             	pushl  0x8(%ebp)
  801999:	e8 87 ff ff ff       	call   801925 <memmove>
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ab:	89 c6                	mov    %eax,%esi
  8019ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019b0:	eb 1a                	jmp    8019cc <memcmp+0x2c>
		if (*s1 != *s2)
  8019b2:	0f b6 08             	movzbl (%eax),%ecx
  8019b5:	0f b6 1a             	movzbl (%edx),%ebx
  8019b8:	38 d9                	cmp    %bl,%cl
  8019ba:	74 0a                	je     8019c6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019bc:	0f b6 c1             	movzbl %cl,%eax
  8019bf:	0f b6 db             	movzbl %bl,%ebx
  8019c2:	29 d8                	sub    %ebx,%eax
  8019c4:	eb 0f                	jmp    8019d5 <memcmp+0x35>
		s1++, s2++;
  8019c6:	83 c0 01             	add    $0x1,%eax
  8019c9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019cc:	39 f0                	cmp    %esi,%eax
  8019ce:	75 e2                	jne    8019b2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d5:	5b                   	pop    %ebx
  8019d6:	5e                   	pop    %esi
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	53                   	push   %ebx
  8019dd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019e0:	89 c1                	mov    %eax,%ecx
  8019e2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019e5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e9:	eb 0a                	jmp    8019f5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019eb:	0f b6 10             	movzbl (%eax),%edx
  8019ee:	39 da                	cmp    %ebx,%edx
  8019f0:	74 07                	je     8019f9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019f2:	83 c0 01             	add    $0x1,%eax
  8019f5:	39 c8                	cmp    %ecx,%eax
  8019f7:	72 f2                	jb     8019eb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019f9:	5b                   	pop    %ebx
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	57                   	push   %edi
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a08:	eb 03                	jmp    801a0d <strtol+0x11>
		s++;
  801a0a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a0d:	0f b6 01             	movzbl (%ecx),%eax
  801a10:	3c 20                	cmp    $0x20,%al
  801a12:	74 f6                	je     801a0a <strtol+0xe>
  801a14:	3c 09                	cmp    $0x9,%al
  801a16:	74 f2                	je     801a0a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a18:	3c 2b                	cmp    $0x2b,%al
  801a1a:	75 0a                	jne    801a26 <strtol+0x2a>
		s++;
  801a1c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a24:	eb 11                	jmp    801a37 <strtol+0x3b>
  801a26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a2b:	3c 2d                	cmp    $0x2d,%al
  801a2d:	75 08                	jne    801a37 <strtol+0x3b>
		s++, neg = 1;
  801a2f:	83 c1 01             	add    $0x1,%ecx
  801a32:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a3d:	75 15                	jne    801a54 <strtol+0x58>
  801a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  801a42:	75 10                	jne    801a54 <strtol+0x58>
  801a44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a48:	75 7c                	jne    801ac6 <strtol+0xca>
		s += 2, base = 16;
  801a4a:	83 c1 02             	add    $0x2,%ecx
  801a4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a52:	eb 16                	jmp    801a6a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a54:	85 db                	test   %ebx,%ebx
  801a56:	75 12                	jne    801a6a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a58:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a5d:	80 39 30             	cmpb   $0x30,(%ecx)
  801a60:	75 08                	jne    801a6a <strtol+0x6e>
		s++, base = 8;
  801a62:	83 c1 01             	add    $0x1,%ecx
  801a65:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a72:	0f b6 11             	movzbl (%ecx),%edx
  801a75:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a78:	89 f3                	mov    %esi,%ebx
  801a7a:	80 fb 09             	cmp    $0x9,%bl
  801a7d:	77 08                	ja     801a87 <strtol+0x8b>
			dig = *s - '0';
  801a7f:	0f be d2             	movsbl %dl,%edx
  801a82:	83 ea 30             	sub    $0x30,%edx
  801a85:	eb 22                	jmp    801aa9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a87:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a8a:	89 f3                	mov    %esi,%ebx
  801a8c:	80 fb 19             	cmp    $0x19,%bl
  801a8f:	77 08                	ja     801a99 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a91:	0f be d2             	movsbl %dl,%edx
  801a94:	83 ea 57             	sub    $0x57,%edx
  801a97:	eb 10                	jmp    801aa9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a99:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a9c:	89 f3                	mov    %esi,%ebx
  801a9e:	80 fb 19             	cmp    $0x19,%bl
  801aa1:	77 16                	ja     801ab9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801aa3:	0f be d2             	movsbl %dl,%edx
  801aa6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801aa9:	3b 55 10             	cmp    0x10(%ebp),%edx
  801aac:	7d 0b                	jge    801ab9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801aae:	83 c1 01             	add    $0x1,%ecx
  801ab1:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ab5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ab7:	eb b9                	jmp    801a72 <strtol+0x76>

	if (endptr)
  801ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801abd:	74 0d                	je     801acc <strtol+0xd0>
		*endptr = (char *) s;
  801abf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac2:	89 0e                	mov    %ecx,(%esi)
  801ac4:	eb 06                	jmp    801acc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ac6:	85 db                	test   %ebx,%ebx
  801ac8:	74 98                	je     801a62 <strtol+0x66>
  801aca:	eb 9e                	jmp    801a6a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	f7 da                	neg    %edx
  801ad0:	85 ff                	test   %edi,%edi
  801ad2:	0f 45 c2             	cmovne %edx,%eax
}
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	57                   	push   %edi
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	83 ec 04             	sub    $0x4,%esp
  801ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801ae6:	57                   	push   %edi
  801ae7:	e8 6e fc ff ff       	call   80175a <strlen>
  801aec:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801aef:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801af2:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801afc:	eb 46                	jmp    801b44 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801afe:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801b02:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b05:	80 f9 09             	cmp    $0x9,%cl
  801b08:	77 08                	ja     801b12 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801b0a:	0f be d2             	movsbl %dl,%edx
  801b0d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b10:	eb 27                	jmp    801b39 <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b12:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b15:	80 f9 05             	cmp    $0x5,%cl
  801b18:	77 08                	ja     801b22 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b1a:	0f be d2             	movsbl %dl,%edx
  801b1d:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b20:	eb 17                	jmp    801b39 <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b22:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b25:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b28:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b2d:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b31:	77 06                	ja     801b39 <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b33:	0f be d2             	movsbl %dl,%edx
  801b36:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b39:	0f af ce             	imul   %esi,%ecx
  801b3c:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b3e:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b41:	83 eb 01             	sub    $0x1,%ebx
  801b44:	83 fb 01             	cmp    $0x1,%ebx
  801b47:	7f b5                	jg     801afe <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	8b 75 08             	mov    0x8(%ebp),%esi
  801b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b5f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b61:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b66:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b69:	83 ec 0c             	sub    $0xc,%esp
  801b6c:	50                   	push   %eax
  801b6d:	e8 a1 e7 ff ff       	call   800313 <sys_ipc_recv>
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	85 c0                	test   %eax,%eax
  801b77:	79 16                	jns    801b8f <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b79:	85 f6                	test   %esi,%esi
  801b7b:	74 06                	je     801b83 <ipc_recv+0x32>
			*from_env_store = 0;
  801b7d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b83:	85 db                	test   %ebx,%ebx
  801b85:	74 2c                	je     801bb3 <ipc_recv+0x62>
			*perm_store = 0;
  801b87:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b8d:	eb 24                	jmp    801bb3 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b8f:	85 f6                	test   %esi,%esi
  801b91:	74 0a                	je     801b9d <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b93:	a1 08 40 80 00       	mov    0x804008,%eax
  801b98:	8b 40 74             	mov    0x74(%eax),%eax
  801b9b:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b9d:	85 db                	test   %ebx,%ebx
  801b9f:	74 0a                	je     801bab <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801ba1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba6:	8b 40 78             	mov    0x78(%eax),%eax
  801ba9:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801bab:	a1 08 40 80 00       	mov    0x804008,%eax
  801bb0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	57                   	push   %edi
  801bbe:	56                   	push   %esi
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 0c             	sub    $0xc,%esp
  801bc3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bcc:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bce:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bd3:	0f 44 d8             	cmove  %eax,%ebx
  801bd6:	eb 1e                	jmp    801bf6 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bd8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bdb:	74 14                	je     801bf1 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bdd:	83 ec 04             	sub    $0x4,%esp
  801be0:	68 a0 23 80 00       	push   $0x8023a0
  801be5:	6a 44                	push   $0x44
  801be7:	68 cc 23 80 00       	push   $0x8023cc
  801bec:	e8 95 f4 ff ff       	call   801086 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801bf1:	e8 4e e5 ff ff       	call   800144 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bf6:	ff 75 14             	pushl  0x14(%ebp)
  801bf9:	53                   	push   %ebx
  801bfa:	56                   	push   %esi
  801bfb:	57                   	push   %edi
  801bfc:	e8 ef e6 ff ff       	call   8002f0 <sys_ipc_try_send>
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 d0                	js     801bd8 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5f                   	pop    %edi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c1b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c1e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c24:	8b 52 50             	mov    0x50(%edx),%edx
  801c27:	39 ca                	cmp    %ecx,%edx
  801c29:	75 0d                	jne    801c38 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c2b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c2e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c33:	8b 40 48             	mov    0x48(%eax),%eax
  801c36:	eb 0f                	jmp    801c47 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c38:	83 c0 01             	add    $0x1,%eax
  801c3b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c40:	75 d9                	jne    801c1b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	c1 e8 16             	shr    $0x16,%eax
  801c54:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c5b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c60:	f6 c1 01             	test   $0x1,%cl
  801c63:	74 1d                	je     801c82 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c65:	c1 ea 0c             	shr    $0xc,%edx
  801c68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c6f:	f6 c2 01             	test   $0x1,%dl
  801c72:	74 0e                	je     801c82 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c74:	c1 ea 0c             	shr    $0xc,%edx
  801c77:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c7e:	ef 
  801c7f:	0f b7 c0             	movzwl %ax,%eax
}
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

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
