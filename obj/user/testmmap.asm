
obj/user/testmmap.debug:     file format elf32-i386


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
  80002c:	e8 07 00 00 00       	call   800038 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	close(r);
}
#else
void 
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	
}
  800036:	5d                   	pop    %ebp
  800037:	c3                   	ret    

00800038 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800043:	e8 ce 00 00 00       	call   800116 <sys_getenvid>
  800048:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800050:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800055:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005a:	85 db                	test   %ebx,%ebx
  80005c:	7e 07                	jle    800065 <libmain+0x2d>
		binaryname = argv[0];
  80005e:	8b 06                	mov    (%esi),%eax
  800060:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800065:	83 ec 08             	sub    $0x8,%esp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	e8 c4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006f:	e8 0a 00 00 00       	call   80007e <exit>
}
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5e                   	pop    %esi
  80007c:	5d                   	pop    %ebp
  80007d:	c3                   	ret    

0080007e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800084:	e8 87 04 00 00       	call   800510 <close_all>
	sys_env_destroy(0);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	6a 00                	push   $0x0
  80008e:	e8 42 00 00 00       	call   8000d5 <sys_env_destroy>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	c9                   	leave  
  800097:	c3                   	ret    

00800098 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a9:	89 c3                	mov    %eax,%ebx
  8000ab:	89 c7                	mov    %eax,%edi
  8000ad:	89 c6                	mov    %eax,%esi
  8000af:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5f                   	pop    %edi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c6:	89 d1                	mov    %edx,%ecx
  8000c8:	89 d3                	mov    %edx,%ebx
  8000ca:	89 d7                	mov    %edx,%edi
  8000cc:	89 d6                	mov    %edx,%esi
  8000ce:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	89 cb                	mov    %ecx,%ebx
  8000ed:	89 cf                	mov    %ecx,%edi
  8000ef:	89 ce                	mov    %ecx,%esi
  8000f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	7e 17                	jle    80010e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	50                   	push   %eax
  8000fb:	6a 03                	push   $0x3
  8000fd:	68 2a 1f 80 00       	push   $0x801f2a
  800102:	6a 23                	push   $0x23
  800104:	68 47 1f 80 00       	push   $0x801f47
  800109:	e8 69 0f 00 00       	call   801077 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011c:	ba 00 00 00 00       	mov    $0x0,%edx
  800121:	b8 02 00 00 00       	mov    $0x2,%eax
  800126:	89 d1                	mov    %edx,%ecx
  800128:	89 d3                	mov    %edx,%ebx
  80012a:	89 d7                	mov    %edx,%edi
  80012c:	89 d6                	mov    %edx,%esi
  80012e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <sys_yield>:

void
sys_yield(void)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	57                   	push   %edi
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013b:	ba 00 00 00 00       	mov    $0x0,%edx
  800140:	b8 0b 00 00 00       	mov    $0xb,%eax
  800145:	89 d1                	mov    %edx,%ecx
  800147:	89 d3                	mov    %edx,%ebx
  800149:	89 d7                	mov    %edx,%edi
  80014b:	89 d6                	mov    %edx,%esi
  80014d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015d:	be 00 00 00 00       	mov    $0x0,%esi
  800162:	b8 04 00 00 00       	mov    $0x4,%eax
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016a:	8b 55 08             	mov    0x8(%ebp),%edx
  80016d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800170:	89 f7                	mov    %esi,%edi
  800172:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800174:	85 c0                	test   %eax,%eax
  800176:	7e 17                	jle    80018f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	50                   	push   %eax
  80017c:	6a 04                	push   $0x4
  80017e:	68 2a 1f 80 00       	push   $0x801f2a
  800183:	6a 23                	push   $0x23
  800185:	68 47 1f 80 00       	push   $0x801f47
  80018a:	e8 e8 0e 00 00       	call   801077 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800192:	5b                   	pop    %ebx
  800193:	5e                   	pop    %esi
  800194:	5f                   	pop    %edi
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	57                   	push   %edi
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	7e 17                	jle    8001d1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	50                   	push   %eax
  8001be:	6a 05                	push   $0x5
  8001c0:	68 2a 1f 80 00       	push   $0x801f2a
  8001c5:	6a 23                	push   $0x23
  8001c7:	68 47 1f 80 00       	push   $0x801f47
  8001cc:	e8 a6 0e 00 00       	call   801077 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	89 df                	mov    %ebx,%edi
  8001f4:	89 de                	mov    %ebx,%esi
  8001f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 17                	jle    800213 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	50                   	push   %eax
  800200:	6a 06                	push   $0x6
  800202:	68 2a 1f 80 00       	push   $0x801f2a
  800207:	6a 23                	push   $0x23
  800209:	68 47 1f 80 00       	push   $0x801f47
  80020e:	e8 64 0e 00 00       	call   801077 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800216:	5b                   	pop    %ebx
  800217:	5e                   	pop    %esi
  800218:	5f                   	pop    %edi
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	57                   	push   %edi
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800224:	bb 00 00 00 00       	mov    $0x0,%ebx
  800229:	b8 08 00 00 00       	mov    $0x8,%eax
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	8b 55 08             	mov    0x8(%ebp),%edx
  800234:	89 df                	mov    %ebx,%edi
  800236:	89 de                	mov    %ebx,%esi
  800238:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023a:	85 c0                	test   %eax,%eax
  80023c:	7e 17                	jle    800255 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	50                   	push   %eax
  800242:	6a 08                	push   $0x8
  800244:	68 2a 1f 80 00       	push   $0x801f2a
  800249:	6a 23                	push   $0x23
  80024b:	68 47 1f 80 00       	push   $0x801f47
  800250:	e8 22 0e 00 00       	call   801077 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800255:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800258:	5b                   	pop    %ebx
  800259:	5e                   	pop    %esi
  80025a:	5f                   	pop    %edi
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	89 df                	mov    %ebx,%edi
  800278:	89 de                	mov    %ebx,%esi
  80027a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 17                	jle    800297 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	83 ec 0c             	sub    $0xc,%esp
  800283:	50                   	push   %eax
  800284:	6a 0a                	push   $0xa
  800286:	68 2a 1f 80 00       	push   $0x801f2a
  80028b:	6a 23                	push   $0x23
  80028d:	68 47 1f 80 00       	push   $0x801f47
  800292:	e8 e0 0d 00 00       	call   801077 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800297:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 17                	jle    8002d9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	83 ec 0c             	sub    $0xc,%esp
  8002c5:	50                   	push   %eax
  8002c6:	6a 09                	push   $0x9
  8002c8:	68 2a 1f 80 00       	push   $0x801f2a
  8002cd:	6a 23                	push   $0x23
  8002cf:	68 47 1f 80 00       	push   $0x801f47
  8002d4:	e8 9e 0d 00 00       	call   801077 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	be 00 00 00 00       	mov    $0x0,%esi
  8002ec:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	b8 0d 00 00 00       	mov    $0xd,%eax
  800317:	8b 55 08             	mov    0x8(%ebp),%edx
  80031a:	89 cb                	mov    %ecx,%ebx
  80031c:	89 cf                	mov    %ecx,%edi
  80031e:	89 ce                	mov    %ecx,%esi
  800320:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800322:	85 c0                	test   %eax,%eax
  800324:	7e 17                	jle    80033d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	50                   	push   %eax
  80032a:	6a 0d                	push   $0xd
  80032c:	68 2a 1f 80 00       	push   $0x801f2a
  800331:	6a 23                	push   $0x23
  800333:	68 47 1f 80 00       	push   $0x801f47
  800338:	e8 3a 0d 00 00       	call   801077 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800348:	8b 45 08             	mov    0x8(%ebp),%eax
  80034b:	05 00 00 00 30       	add    $0x30000000,%eax
  800350:	c1 e8 0c             	shr    $0xc,%eax
}
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	05 00 00 00 30       	add    $0x30000000,%eax
  800360:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800365:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800372:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800377:	89 c2                	mov    %eax,%edx
  800379:	c1 ea 16             	shr    $0x16,%edx
  80037c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800383:	f6 c2 01             	test   $0x1,%dl
  800386:	74 11                	je     800399 <fd_alloc+0x2d>
  800388:	89 c2                	mov    %eax,%edx
  80038a:	c1 ea 0c             	shr    $0xc,%edx
  80038d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800394:	f6 c2 01             	test   $0x1,%dl
  800397:	75 09                	jne    8003a2 <fd_alloc+0x36>
			*fd_store = fd;
  800399:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	eb 17                	jmp    8003b9 <fd_alloc+0x4d>
  8003a2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ac:	75 c9                	jne    800377 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c1:	83 f8 1f             	cmp    $0x1f,%eax
  8003c4:	77 36                	ja     8003fc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c6:	c1 e0 0c             	shl    $0xc,%eax
  8003c9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ce:	89 c2                	mov    %eax,%edx
  8003d0:	c1 ea 16             	shr    $0x16,%edx
  8003d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003da:	f6 c2 01             	test   $0x1,%dl
  8003dd:	74 24                	je     800403 <fd_lookup+0x48>
  8003df:	89 c2                	mov    %eax,%edx
  8003e1:	c1 ea 0c             	shr    $0xc,%edx
  8003e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003eb:	f6 c2 01             	test   $0x1,%dl
  8003ee:	74 1a                	je     80040a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	eb 13                	jmp    80040f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800401:	eb 0c                	jmp    80040f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800408:	eb 05                	jmp    80040f <fd_lookup+0x54>
  80040a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041a:	ba d4 1f 80 00       	mov    $0x801fd4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80041f:	eb 13                	jmp    800434 <dev_lookup+0x23>
  800421:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800424:	39 08                	cmp    %ecx,(%eax)
  800426:	75 0c                	jne    800434 <dev_lookup+0x23>
			*dev = devtab[i];
  800428:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042d:	b8 00 00 00 00       	mov    $0x0,%eax
  800432:	eb 2e                	jmp    800462 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800434:	8b 02                	mov    (%edx),%eax
  800436:	85 c0                	test   %eax,%eax
  800438:	75 e7                	jne    800421 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043a:	a1 08 40 80 00       	mov    0x804008,%eax
  80043f:	8b 40 48             	mov    0x48(%eax),%eax
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	51                   	push   %ecx
  800446:	50                   	push   %eax
  800447:	68 58 1f 80 00       	push   $0x801f58
  80044c:	e8 ff 0c 00 00       	call   801150 <cprintf>
	*dev = 0;
  800451:	8b 45 0c             	mov    0xc(%ebp),%eax
  800454:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800462:	c9                   	leave  
  800463:	c3                   	ret    

00800464 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 10             	sub    $0x10,%esp
  80046c:	8b 75 08             	mov    0x8(%ebp),%esi
  80046f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800475:	50                   	push   %eax
  800476:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047c:	c1 e8 0c             	shr    $0xc,%eax
  80047f:	50                   	push   %eax
  800480:	e8 36 ff ff ff       	call   8003bb <fd_lookup>
  800485:	83 c4 08             	add    $0x8,%esp
  800488:	85 c0                	test   %eax,%eax
  80048a:	78 05                	js     800491 <fd_close+0x2d>
	    || fd != fd2) 
  80048c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80048f:	74 0c                	je     80049d <fd_close+0x39>
		return (must_exist ? r : 0); 
  800491:	84 db                	test   %bl,%bl
  800493:	ba 00 00 00 00       	mov    $0x0,%edx
  800498:	0f 44 c2             	cmove  %edx,%eax
  80049b:	eb 41                	jmp    8004de <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a3:	50                   	push   %eax
  8004a4:	ff 36                	pushl  (%esi)
  8004a6:	e8 66 ff ff ff       	call   800411 <dev_lookup>
  8004ab:	89 c3                	mov    %eax,%ebx
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	78 1a                	js     8004ce <fd_close+0x6a>
		if (dev->dev_close) 
  8004b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  8004ba:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	74 0b                	je     8004ce <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c3:	83 ec 0c             	sub    $0xc,%esp
  8004c6:	56                   	push   %esi
  8004c7:	ff d0                	call   *%eax
  8004c9:	89 c3                	mov    %eax,%ebx
  8004cb:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	56                   	push   %esi
  8004d2:	6a 00                	push   $0x0
  8004d4:	e8 00 fd ff ff       	call   8001d9 <sys_page_unmap>
	return r;
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	89 d8                	mov    %ebx,%eax
}
  8004de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e1:	5b                   	pop    %ebx
  8004e2:	5e                   	pop    %esi
  8004e3:	5d                   	pop    %ebp
  8004e4:	c3                   	ret    

008004e5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	ff 75 08             	pushl  0x8(%ebp)
  8004f2:	e8 c4 fe ff ff       	call   8003bb <fd_lookup>
  8004f7:	83 c4 08             	add    $0x8,%esp
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	78 10                	js     80050e <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	6a 01                	push   $0x1
  800503:	ff 75 f4             	pushl  -0xc(%ebp)
  800506:	e8 59 ff ff ff       	call   800464 <fd_close>
  80050b:	83 c4 10             	add    $0x10,%esp
}
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <close_all>:

void
close_all(void)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	53                   	push   %ebx
  800514:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800517:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	53                   	push   %ebx
  800520:	e8 c0 ff ff ff       	call   8004e5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800525:	83 c3 01             	add    $0x1,%ebx
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	83 fb 20             	cmp    $0x20,%ebx
  80052e:	75 ec                	jne    80051c <close_all+0xc>
		close(i);
}
  800530:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800533:	c9                   	leave  
  800534:	c3                   	ret    

00800535 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	57                   	push   %edi
  800539:	56                   	push   %esi
  80053a:	53                   	push   %ebx
  80053b:	83 ec 2c             	sub    $0x2c,%esp
  80053e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800541:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	ff 75 08             	pushl  0x8(%ebp)
  800548:	e8 6e fe ff ff       	call   8003bb <fd_lookup>
  80054d:	83 c4 08             	add    $0x8,%esp
  800550:	85 c0                	test   %eax,%eax
  800552:	0f 88 c1 00 00 00    	js     800619 <dup+0xe4>
		return r;
	close(newfdnum);
  800558:	83 ec 0c             	sub    $0xc,%esp
  80055b:	56                   	push   %esi
  80055c:	e8 84 ff ff ff       	call   8004e5 <close>

	newfd = INDEX2FD(newfdnum);
  800561:	89 f3                	mov    %esi,%ebx
  800563:	c1 e3 0c             	shl    $0xc,%ebx
  800566:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056c:	83 c4 04             	add    $0x4,%esp
  80056f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800572:	e8 de fd ff ff       	call   800355 <fd2data>
  800577:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800579:	89 1c 24             	mov    %ebx,(%esp)
  80057c:	e8 d4 fd ff ff       	call   800355 <fd2data>
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800587:	89 f8                	mov    %edi,%eax
  800589:	c1 e8 16             	shr    $0x16,%eax
  80058c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800593:	a8 01                	test   $0x1,%al
  800595:	74 37                	je     8005ce <dup+0x99>
  800597:	89 f8                	mov    %edi,%eax
  800599:	c1 e8 0c             	shr    $0xc,%eax
  80059c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a3:	f6 c2 01             	test   $0x1,%dl
  8005a6:	74 26                	je     8005ce <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005af:	83 ec 0c             	sub    $0xc,%esp
  8005b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b7:	50                   	push   %eax
  8005b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bb:	6a 00                	push   $0x0
  8005bd:	57                   	push   %edi
  8005be:	6a 00                	push   $0x0
  8005c0:	e8 d2 fb ff ff       	call   800197 <sys_page_map>
  8005c5:	89 c7                	mov    %eax,%edi
  8005c7:	83 c4 20             	add    $0x20,%esp
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	78 2e                	js     8005fc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d1:	89 d0                	mov    %edx,%eax
  8005d3:	c1 e8 0c             	shr    $0xc,%eax
  8005d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e5:	50                   	push   %eax
  8005e6:	53                   	push   %ebx
  8005e7:	6a 00                	push   $0x0
  8005e9:	52                   	push   %edx
  8005ea:	6a 00                	push   $0x0
  8005ec:	e8 a6 fb ff ff       	call   800197 <sys_page_map>
  8005f1:	89 c7                	mov    %eax,%edi
  8005f3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f8:	85 ff                	test   %edi,%edi
  8005fa:	79 1d                	jns    800619 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 00                	push   $0x0
  800602:	e8 d2 fb ff ff       	call   8001d9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060d:	6a 00                	push   $0x0
  80060f:	e8 c5 fb ff ff       	call   8001d9 <sys_page_unmap>
	return r;
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	89 f8                	mov    %edi,%eax
}
  800619:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061c:	5b                   	pop    %ebx
  80061d:	5e                   	pop    %esi
  80061e:	5f                   	pop    %edi
  80061f:	5d                   	pop    %ebp
  800620:	c3                   	ret    

00800621 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800621:	55                   	push   %ebp
  800622:	89 e5                	mov    %esp,%ebp
  800624:	53                   	push   %ebx
  800625:	83 ec 14             	sub    $0x14,%esp
  800628:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	53                   	push   %ebx
  800630:	e8 86 fd ff ff       	call   8003bb <fd_lookup>
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	89 c2                	mov    %eax,%edx
  80063a:	85 c0                	test   %eax,%eax
  80063c:	78 6d                	js     8006ab <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800648:	ff 30                	pushl  (%eax)
  80064a:	e8 c2 fd ff ff       	call   800411 <dev_lookup>
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 4c                	js     8006a2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800656:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800659:	8b 42 08             	mov    0x8(%edx),%eax
  80065c:	83 e0 03             	and    $0x3,%eax
  80065f:	83 f8 01             	cmp    $0x1,%eax
  800662:	75 21                	jne    800685 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800664:	a1 08 40 80 00       	mov    0x804008,%eax
  800669:	8b 40 48             	mov    0x48(%eax),%eax
  80066c:	83 ec 04             	sub    $0x4,%esp
  80066f:	53                   	push   %ebx
  800670:	50                   	push   %eax
  800671:	68 99 1f 80 00       	push   $0x801f99
  800676:	e8 d5 0a 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800683:	eb 26                	jmp    8006ab <read+0x8a>
	}
	if (!dev->dev_read)
  800685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800688:	8b 40 08             	mov    0x8(%eax),%eax
  80068b:	85 c0                	test   %eax,%eax
  80068d:	74 17                	je     8006a6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80068f:	83 ec 04             	sub    $0x4,%esp
  800692:	ff 75 10             	pushl  0x10(%ebp)
  800695:	ff 75 0c             	pushl  0xc(%ebp)
  800698:	52                   	push   %edx
  800699:	ff d0                	call   *%eax
  80069b:	89 c2                	mov    %eax,%edx
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 09                	jmp    8006ab <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a2:	89 c2                	mov    %eax,%edx
  8006a4:	eb 05                	jmp    8006ab <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ab:	89 d0                	mov    %edx,%eax
  8006ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	57                   	push   %edi
  8006b6:	56                   	push   %esi
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 0c             	sub    $0xc,%esp
  8006bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006be:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c6:	eb 21                	jmp    8006e9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c8:	83 ec 04             	sub    $0x4,%esp
  8006cb:	89 f0                	mov    %esi,%eax
  8006cd:	29 d8                	sub    %ebx,%eax
  8006cf:	50                   	push   %eax
  8006d0:	89 d8                	mov    %ebx,%eax
  8006d2:	03 45 0c             	add    0xc(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	57                   	push   %edi
  8006d7:	e8 45 ff ff ff       	call   800621 <read>
		if (m < 0)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	78 10                	js     8006f3 <readn+0x41>
			return m;
		if (m == 0)
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	74 0a                	je     8006f1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e7:	01 c3                	add    %eax,%ebx
  8006e9:	39 f3                	cmp    %esi,%ebx
  8006eb:	72 db                	jb     8006c8 <readn+0x16>
  8006ed:	89 d8                	mov    %ebx,%eax
  8006ef:	eb 02                	jmp    8006f3 <readn+0x41>
  8006f1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	53                   	push   %ebx
  8006ff:	83 ec 14             	sub    $0x14,%esp
  800702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800705:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	53                   	push   %ebx
  80070a:	e8 ac fc ff ff       	call   8003bb <fd_lookup>
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	89 c2                	mov    %eax,%edx
  800714:	85 c0                	test   %eax,%eax
  800716:	78 68                	js     800780 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800722:	ff 30                	pushl  (%eax)
  800724:	e8 e8 fc ff ff       	call   800411 <dev_lookup>
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	85 c0                	test   %eax,%eax
  80072e:	78 47                	js     800777 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800733:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800737:	75 21                	jne    80075a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800739:	a1 08 40 80 00       	mov    0x804008,%eax
  80073e:	8b 40 48             	mov    0x48(%eax),%eax
  800741:	83 ec 04             	sub    $0x4,%esp
  800744:	53                   	push   %ebx
  800745:	50                   	push   %eax
  800746:	68 b5 1f 80 00       	push   $0x801fb5
  80074b:	e8 00 0a 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800758:	eb 26                	jmp    800780 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075d:	8b 52 0c             	mov    0xc(%edx),%edx
  800760:	85 d2                	test   %edx,%edx
  800762:	74 17                	je     80077b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800764:	83 ec 04             	sub    $0x4,%esp
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	ff 75 0c             	pushl  0xc(%ebp)
  80076d:	50                   	push   %eax
  80076e:	ff d2                	call   *%edx
  800770:	89 c2                	mov    %eax,%edx
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	eb 09                	jmp    800780 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800777:	89 c2                	mov    %eax,%edx
  800779:	eb 05                	jmp    800780 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800780:	89 d0                	mov    %edx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <seek>:

int
seek(int fdnum, off_t offset)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	ff 75 08             	pushl  0x8(%ebp)
  800794:	e8 22 fc ff ff       	call   8003bb <fd_lookup>
  800799:	83 c4 08             	add    $0x8,%esp
  80079c:	85 c0                	test   %eax,%eax
  80079e:	78 0e                	js     8007ae <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 14             	sub    $0x14,%esp
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	53                   	push   %ebx
  8007bf:	e8 f7 fb ff ff       	call   8003bb <fd_lookup>
  8007c4:	83 c4 08             	add    $0x8,%esp
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 65                	js     800832 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d7:	ff 30                	pushl  (%eax)
  8007d9:	e8 33 fc ff ff       	call   800411 <dev_lookup>
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	78 44                	js     800829 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ec:	75 21                	jne    80080f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007ee:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f3:	8b 40 48             	mov    0x48(%eax),%eax
  8007f6:	83 ec 04             	sub    $0x4,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	50                   	push   %eax
  8007fb:	68 78 1f 80 00       	push   $0x801f78
  800800:	e8 4b 09 00 00       	call   801150 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080d:	eb 23                	jmp    800832 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80080f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800812:	8b 52 18             	mov    0x18(%edx),%edx
  800815:	85 d2                	test   %edx,%edx
  800817:	74 14                	je     80082d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	ff 75 0c             	pushl  0xc(%ebp)
  80081f:	50                   	push   %eax
  800820:	ff d2                	call   *%edx
  800822:	89 c2                	mov    %eax,%edx
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	eb 09                	jmp    800832 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800829:	89 c2                	mov    %eax,%edx
  80082b:	eb 05                	jmp    800832 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800832:	89 d0                	mov    %edx,%eax
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	83 ec 14             	sub    $0x14,%esp
  800840:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800843:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800846:	50                   	push   %eax
  800847:	ff 75 08             	pushl  0x8(%ebp)
  80084a:	e8 6c fb ff ff       	call   8003bb <fd_lookup>
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	89 c2                	mov    %eax,%edx
  800854:	85 c0                	test   %eax,%eax
  800856:	78 58                	js     8008b0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800862:	ff 30                	pushl  (%eax)
  800864:	e8 a8 fb ff ff       	call   800411 <dev_lookup>
  800869:	83 c4 10             	add    $0x10,%esp
  80086c:	85 c0                	test   %eax,%eax
  80086e:	78 37                	js     8008a7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800873:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800877:	74 32                	je     8008ab <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800879:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800883:	00 00 00 
	stat->st_isdir = 0;
  800886:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088d:	00 00 00 
	stat->st_dev = dev;
  800890:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800896:	83 ec 08             	sub    $0x8,%esp
  800899:	53                   	push   %ebx
  80089a:	ff 75 f0             	pushl  -0x10(%ebp)
  80089d:	ff 50 14             	call   *0x14(%eax)
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	eb 09                	jmp    8008b0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	eb 05                	jmp    8008b0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b0:	89 d0                	mov    %edx,%eax
  8008b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bc:	83 ec 08             	sub    $0x8,%esp
  8008bf:	6a 00                	push   $0x0
  8008c1:	ff 75 08             	pushl  0x8(%ebp)
  8008c4:	e8 2b 02 00 00       	call   800af4 <open>
  8008c9:	89 c3                	mov    %eax,%ebx
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 1b                	js     8008ed <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	50                   	push   %eax
  8008d9:	e8 5b ff ff ff       	call   800839 <fstat>
  8008de:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e0:	89 1c 24             	mov    %ebx,(%esp)
  8008e3:	e8 fd fb ff ff       	call   8004e5 <close>
	return r;
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	89 f0                	mov    %esi,%eax
}
  8008ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	89 c6                	mov    %eax,%esi
  8008fb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800904:	75 12                	jne    800918 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800906:	83 ec 0c             	sub    $0xc,%esp
  800909:	6a 01                	push   $0x1
  80090b:	e8 f1 12 00 00       	call   801c01 <ipc_find_env>
  800910:	a3 00 40 80 00       	mov    %eax,0x804000
  800915:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800918:	6a 07                	push   $0x7
  80091a:	68 00 50 80 00       	push   $0x805000
  80091f:	56                   	push   %esi
  800920:	ff 35 00 40 80 00    	pushl  0x804000
  800926:	e8 80 12 00 00       	call   801bab <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80092b:	83 c4 0c             	add    $0xc,%esp
  80092e:	6a 00                	push   $0x0
  800930:	53                   	push   %ebx
  800931:	6a 00                	push   $0x0
  800933:	e8 0a 12 00 00       	call   801b42 <ipc_recv>
}
  800938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 40 0c             	mov    0xc(%eax),%eax
  80094b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800950:	8b 45 0c             	mov    0xc(%ebp),%eax
  800953:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	b8 02 00 00 00       	mov    $0x2,%eax
  800962:	e8 8d ff ff ff       	call   8008f4 <fsipc>
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 40 0c             	mov    0xc(%eax),%eax
  800975:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097a:	ba 00 00 00 00       	mov    $0x0,%edx
  80097f:	b8 06 00 00 00       	mov    $0x6,%eax
  800984:	e8 6b ff ff ff       	call   8008f4 <fsipc>
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	83 ec 04             	sub    $0x4,%esp
  800992:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 40 0c             	mov    0xc(%eax),%eax
  80099b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009aa:	e8 45 ff ff ff       	call   8008f4 <fsipc>
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	78 2c                	js     8009df <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b3:	83 ec 08             	sub    $0x8,%esp
  8009b6:	68 00 50 80 00       	push   $0x805000
  8009bb:	53                   	push   %ebx
  8009bc:	e8 c3 0d 00 00       	call   801784 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009cc:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d7:	83 c4 10             	add    $0x10,%esp
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ee:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f3:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8009f8:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 40 0c             	mov    0xc(%eax),%eax
  800a01:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800a06:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0c:	53                   	push   %ebx
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	68 08 50 80 00       	push   $0x805008
  800a15:	e8 fc 0e 00 00       	call   801916 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a24:	e8 cb fe ff ff       	call   8008f4 <fsipc>
  800a29:	83 c4 10             	add    $0x10,%esp
  800a2c:	85 c0                	test   %eax,%eax
  800a2e:	78 3d                	js     800a6d <devfile_write+0x89>
		return r;

	assert(r <= n);
  800a30:	39 d8                	cmp    %ebx,%eax
  800a32:	76 19                	jbe    800a4d <devfile_write+0x69>
  800a34:	68 e4 1f 80 00       	push   $0x801fe4
  800a39:	68 eb 1f 80 00       	push   $0x801feb
  800a3e:	68 9f 00 00 00       	push   $0x9f
  800a43:	68 00 20 80 00       	push   $0x802000
  800a48:	e8 2a 06 00 00       	call   801077 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800a4d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a52:	76 19                	jbe    800a6d <devfile_write+0x89>
  800a54:	68 18 20 80 00       	push   $0x802018
  800a59:	68 eb 1f 80 00       	push   $0x801feb
  800a5e:	68 a0 00 00 00       	push   $0xa0
  800a63:	68 00 20 80 00       	push   $0x802000
  800a68:	e8 0a 06 00 00       	call   801077 <_panic>

	return r;
}
  800a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a80:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a85:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a90:	b8 03 00 00 00       	mov    $0x3,%eax
  800a95:	e8 5a fe ff ff       	call   8008f4 <fsipc>
  800a9a:	89 c3                	mov    %eax,%ebx
  800a9c:	85 c0                	test   %eax,%eax
  800a9e:	78 4b                	js     800aeb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa0:	39 c6                	cmp    %eax,%esi
  800aa2:	73 16                	jae    800aba <devfile_read+0x48>
  800aa4:	68 e4 1f 80 00       	push   $0x801fe4
  800aa9:	68 eb 1f 80 00       	push   $0x801feb
  800aae:	6a 7e                	push   $0x7e
  800ab0:	68 00 20 80 00       	push   $0x802000
  800ab5:	e8 bd 05 00 00       	call   801077 <_panic>
	assert(r <= PGSIZE);
  800aba:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800abf:	7e 16                	jle    800ad7 <devfile_read+0x65>
  800ac1:	68 0b 20 80 00       	push   $0x80200b
  800ac6:	68 eb 1f 80 00       	push   $0x801feb
  800acb:	6a 7f                	push   $0x7f
  800acd:	68 00 20 80 00       	push   $0x802000
  800ad2:	e8 a0 05 00 00       	call   801077 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad7:	83 ec 04             	sub    $0x4,%esp
  800ada:	50                   	push   %eax
  800adb:	68 00 50 80 00       	push   $0x805000
  800ae0:	ff 75 0c             	pushl  0xc(%ebp)
  800ae3:	e8 2e 0e 00 00       	call   801916 <memmove>
	return r;
  800ae8:	83 c4 10             	add    $0x10,%esp
}
  800aeb:	89 d8                	mov    %ebx,%eax
  800aed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	53                   	push   %ebx
  800af8:	83 ec 20             	sub    $0x20,%esp
  800afb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800afe:	53                   	push   %ebx
  800aff:	e8 47 0c 00 00       	call   80174b <strlen>
  800b04:	83 c4 10             	add    $0x10,%esp
  800b07:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0c:	7f 67                	jg     800b75 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b14:	50                   	push   %eax
  800b15:	e8 52 f8 ff ff       	call   80036c <fd_alloc>
  800b1a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	78 57                	js     800b7a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	68 00 50 80 00       	push   $0x805000
  800b2c:	e8 53 0c 00 00       	call   801784 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b34:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b41:	e8 ae fd ff ff       	call   8008f4 <fsipc>
  800b46:	89 c3                	mov    %eax,%ebx
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	79 14                	jns    800b63 <open+0x6f>
		fd_close(fd, 0);
  800b4f:	83 ec 08             	sub    $0x8,%esp
  800b52:	6a 00                	push   $0x0
  800b54:	ff 75 f4             	pushl  -0xc(%ebp)
  800b57:	e8 08 f9 ff ff       	call   800464 <fd_close>
		return r;
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	89 da                	mov    %ebx,%edx
  800b61:	eb 17                	jmp    800b7a <open+0x86>
	}

	return fd2num(fd);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	ff 75 f4             	pushl  -0xc(%ebp)
  800b69:	e8 d7 f7 ff ff       	call   800345 <fd2num>
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	83 c4 10             	add    $0x10,%esp
  800b73:	eb 05                	jmp    800b7a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b75:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7a:	89 d0                	mov    %edx,%eax
  800b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b91:	e8 5e fd ff ff       	call   8008f4 <fsipc>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	ff 75 08             	pushl  0x8(%ebp)
  800ba6:	e8 aa f7 ff ff       	call   800355 <fd2data>
  800bab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bad:	83 c4 08             	add    $0x8,%esp
  800bb0:	68 45 20 80 00       	push   $0x802045
  800bb5:	53                   	push   %ebx
  800bb6:	e8 c9 0b 00 00       	call   801784 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbb:	8b 46 04             	mov    0x4(%esi),%eax
  800bbe:	2b 06                	sub    (%esi),%eax
  800bc0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bcd:	00 00 00 
	stat->st_dev = &devpipe;
  800bd0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd7:	30 80 00 
	return 0;
}
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf0:	53                   	push   %ebx
  800bf1:	6a 00                	push   $0x0
  800bf3:	e8 e1 f5 ff ff       	call   8001d9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf8:	89 1c 24             	mov    %ebx,(%esp)
  800bfb:	e8 55 f7 ff ff       	call   800355 <fd2data>
  800c00:	83 c4 08             	add    $0x8,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 00                	push   $0x0
  800c06:	e8 ce f5 ff ff       	call   8001d9 <sys_page_unmap>
}
  800c0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 1c             	sub    $0x1c,%esp
  800c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c1e:	a1 08 40 80 00       	mov    0x804008,%eax
  800c23:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2c:	e8 09 10 00 00       	call   801c3a <pageref>
  800c31:	89 c3                	mov    %eax,%ebx
  800c33:	89 3c 24             	mov    %edi,(%esp)
  800c36:	e8 ff 0f 00 00       	call   801c3a <pageref>
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	39 c3                	cmp    %eax,%ebx
  800c40:	0f 94 c1             	sete   %cl
  800c43:	0f b6 c9             	movzbl %cl,%ecx
  800c46:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c49:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800c4f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c52:	39 ce                	cmp    %ecx,%esi
  800c54:	74 1b                	je     800c71 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c56:	39 c3                	cmp    %eax,%ebx
  800c58:	75 c4                	jne    800c1e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5a:	8b 42 58             	mov    0x58(%edx),%eax
  800c5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c60:	50                   	push   %eax
  800c61:	56                   	push   %esi
  800c62:	68 4c 20 80 00       	push   $0x80204c
  800c67:	e8 e4 04 00 00       	call   801150 <cprintf>
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	eb ad                	jmp    800c1e <_pipeisclosed+0xe>
	}
}
  800c71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 28             	sub    $0x28,%esp
  800c85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c88:	56                   	push   %esi
  800c89:	e8 c7 f6 ff ff       	call   800355 <fd2data>
  800c8e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c90:	83 c4 10             	add    $0x10,%esp
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
  800c98:	eb 4b                	jmp    800ce5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9a:	89 da                	mov    %ebx,%edx
  800c9c:	89 f0                	mov    %esi,%eax
  800c9e:	e8 6d ff ff ff       	call   800c10 <_pipeisclosed>
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	75 48                	jne    800cef <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca7:	e8 89 f4 ff ff       	call   800135 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cac:	8b 43 04             	mov    0x4(%ebx),%eax
  800caf:	8b 0b                	mov    (%ebx),%ecx
  800cb1:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb4:	39 d0                	cmp    %edx,%eax
  800cb6:	73 e2                	jae    800c9a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cbf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc2:	89 c2                	mov    %eax,%edx
  800cc4:	c1 fa 1f             	sar    $0x1f,%edx
  800cc7:	89 d1                	mov    %edx,%ecx
  800cc9:	c1 e9 1b             	shr    $0x1b,%ecx
  800ccc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ccf:	83 e2 1f             	and    $0x1f,%edx
  800cd2:	29 ca                	sub    %ecx,%edx
  800cd4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cdc:	83 c0 01             	add    $0x1,%eax
  800cdf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce2:	83 c7 01             	add    $0x1,%edi
  800ce5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce8:	75 c2                	jne    800cac <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ced:	eb 05                	jmp    800cf4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 18             	sub    $0x18,%esp
  800d05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d08:	57                   	push   %edi
  800d09:	e8 47 f6 ff ff       	call   800355 <fd2data>
  800d0e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	eb 3d                	jmp    800d57 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1a:	85 db                	test   %ebx,%ebx
  800d1c:	74 04                	je     800d22 <devpipe_read+0x26>
				return i;
  800d1e:	89 d8                	mov    %ebx,%eax
  800d20:	eb 44                	jmp    800d66 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	89 f8                	mov    %edi,%eax
  800d26:	e8 e5 fe ff ff       	call   800c10 <_pipeisclosed>
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	75 32                	jne    800d61 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d2f:	e8 01 f4 ff ff       	call   800135 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d34:	8b 06                	mov    (%esi),%eax
  800d36:	3b 46 04             	cmp    0x4(%esi),%eax
  800d39:	74 df                	je     800d1a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3b:	99                   	cltd   
  800d3c:	c1 ea 1b             	shr    $0x1b,%edx
  800d3f:	01 d0                	add    %edx,%eax
  800d41:	83 e0 1f             	and    $0x1f,%eax
  800d44:	29 d0                	sub    %edx,%eax
  800d46:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d51:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d54:	83 c3 01             	add    $0x1,%ebx
  800d57:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5a:	75 d8                	jne    800d34 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5f:	eb 05                	jmp    800d66 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d79:	50                   	push   %eax
  800d7a:	e8 ed f5 ff ff       	call   80036c <fd_alloc>
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	85 c0                	test   %eax,%eax
  800d86:	0f 88 2c 01 00 00    	js     800eb8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8c:	83 ec 04             	sub    $0x4,%esp
  800d8f:	68 07 04 00 00       	push   $0x407
  800d94:	ff 75 f4             	pushl  -0xc(%ebp)
  800d97:	6a 00                	push   $0x0
  800d99:	e8 b6 f3 ff ff       	call   800154 <sys_page_alloc>
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	85 c0                	test   %eax,%eax
  800da5:	0f 88 0d 01 00 00    	js     800eb8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db1:	50                   	push   %eax
  800db2:	e8 b5 f5 ff ff       	call   80036c <fd_alloc>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	0f 88 e2 00 00 00    	js     800ea6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	68 07 04 00 00       	push   $0x407
  800dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 7e f3 ff ff       	call   800154 <sys_page_alloc>
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	0f 88 c3 00 00 00    	js     800ea6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	ff 75 f4             	pushl  -0xc(%ebp)
  800de9:	e8 67 f5 ff ff       	call   800355 <fd2data>
  800dee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df0:	83 c4 0c             	add    $0xc,%esp
  800df3:	68 07 04 00 00       	push   $0x407
  800df8:	50                   	push   %eax
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 54 f3 ff ff       	call   800154 <sys_page_alloc>
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	0f 88 89 00 00 00    	js     800e96 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	ff 75 f0             	pushl  -0x10(%ebp)
  800e13:	e8 3d f5 ff ff       	call   800355 <fd2data>
  800e18:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e1f:	50                   	push   %eax
  800e20:	6a 00                	push   $0x0
  800e22:	56                   	push   %esi
  800e23:	6a 00                	push   $0x0
  800e25:	e8 6d f3 ff ff       	call   800197 <sys_page_map>
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	83 c4 20             	add    $0x20,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	78 55                	js     800e88 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e51:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e56:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	ff 75 f4             	pushl  -0xc(%ebp)
  800e63:	e8 dd f4 ff ff       	call   800345 <fd2num>
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6d:	83 c4 04             	add    $0x4,%esp
  800e70:	ff 75 f0             	pushl  -0x10(%ebp)
  800e73:	e8 cd f4 ff ff       	call   800345 <fd2num>
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	ba 00 00 00 00       	mov    $0x0,%edx
  800e86:	eb 30                	jmp    800eb8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	56                   	push   %esi
  800e8c:	6a 00                	push   $0x0
  800e8e:	e8 46 f3 ff ff       	call   8001d9 <sys_page_unmap>
  800e93:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 36 f3 ff ff       	call   8001d9 <sys_page_unmap>
  800ea3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eac:	6a 00                	push   $0x0
  800eae:	e8 26 f3 ff ff       	call   8001d9 <sys_page_unmap>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb8:	89 d0                	mov    %edx,%eax
  800eba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eca:	50                   	push   %eax
  800ecb:	ff 75 08             	pushl  0x8(%ebp)
  800ece:	e8 e8 f4 ff ff       	call   8003bb <fd_lookup>
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 18                	js     800ef2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee0:	e8 70 f4 ff ff       	call   800355 <fd2data>
	return _pipeisclosed(fd, p);
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eea:	e8 21 fd ff ff       	call   800c10 <_pipeisclosed>
  800eef:	83 c4 10             	add    $0x10,%esp
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f04:	68 64 20 80 00       	push   $0x802064
  800f09:	ff 75 0c             	pushl  0xc(%ebp)
  800f0c:	e8 73 08 00 00       	call   801784 <strcpy>
	return 0;
}
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
  800f1e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f24:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f29:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2f:	eb 2d                	jmp    800f5e <devcons_write+0x46>
		m = n - tot;
  800f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f34:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f36:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f39:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f3e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	53                   	push   %ebx
  800f45:	03 45 0c             	add    0xc(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	57                   	push   %edi
  800f4a:	e8 c7 09 00 00       	call   801916 <memmove>
		sys_cputs(buf, m);
  800f4f:	83 c4 08             	add    $0x8,%esp
  800f52:	53                   	push   %ebx
  800f53:	57                   	push   %edi
  800f54:	e8 3f f1 ff ff       	call   800098 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f59:	01 de                	add    %ebx,%esi
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f63:	72 cc                	jb     800f31 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7c:	74 2a                	je     800fa8 <devcons_read+0x3b>
  800f7e:	eb 05                	jmp    800f85 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f80:	e8 b0 f1 ff ff       	call   800135 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f85:	e8 2c f1 ff ff       	call   8000b6 <sys_cgetc>
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	74 f2                	je     800f80 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 16                	js     800fa8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f92:	83 f8 04             	cmp    $0x4,%eax
  800f95:	74 0c                	je     800fa3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9a:	88 02                	mov    %al,(%edx)
	return 1;
  800f9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa1:	eb 05                	jmp    800fa8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb6:	6a 01                	push   $0x1
  800fb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	e8 d7 f0 ff ff       	call   800098 <sys_cputs>
}
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <getchar>:

int
getchar(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fcc:	6a 01                	push   $0x1
  800fce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 48 f6 ff ff       	call   800621 <read>
	if (r < 0)
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 0f                	js     800fef <getchar+0x29>
		return r;
	if (r < 1)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	7e 06                	jle    800fea <getchar+0x24>
		return -E_EOF;
	return c;
  800fe4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe8:	eb 05                	jmp    800fef <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 b8 f3 ff ff       	call   8003bb <fd_lookup>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 11                	js     80101b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801013:	39 10                	cmp    %edx,(%eax)
  801015:	0f 94 c0             	sete   %al
  801018:	0f b6 c0             	movzbl %al,%eax
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <opencons>:

int
opencons(void)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801023:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801026:	50                   	push   %eax
  801027:	e8 40 f3 ff ff       	call   80036c <fd_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
		return r;
  80102f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	78 3e                	js     801073 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	68 07 04 00 00       	push   $0x407
  80103d:	ff 75 f4             	pushl  -0xc(%ebp)
  801040:	6a 00                	push   $0x0
  801042:	e8 0d f1 ff ff       	call   800154 <sys_page_alloc>
  801047:	83 c4 10             	add    $0x10,%esp
		return r;
  80104a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 23                	js     801073 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801050:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	50                   	push   %eax
  801069:	e8 d7 f2 ff ff       	call   800345 <fd2num>
  80106e:	89 c2                	mov    %eax,%edx
  801070:	83 c4 10             	add    $0x10,%esp
}
  801073:	89 d0                	mov    %edx,%eax
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80107f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801085:	e8 8c f0 ff ff       	call   800116 <sys_getenvid>
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	ff 75 0c             	pushl  0xc(%ebp)
  801090:	ff 75 08             	pushl  0x8(%ebp)
  801093:	56                   	push   %esi
  801094:	50                   	push   %eax
  801095:	68 70 20 80 00       	push   $0x802070
  80109a:	e8 b1 00 00 00       	call   801150 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80109f:	83 c4 18             	add    $0x18,%esp
  8010a2:	53                   	push   %ebx
  8010a3:	ff 75 10             	pushl  0x10(%ebp)
  8010a6:	e8 54 00 00 00       	call   8010ff <vcprintf>
	cprintf("\n");
  8010ab:	c7 04 24 5d 20 80 00 	movl   $0x80205d,(%esp)
  8010b2:	e8 99 00 00 00       	call   801150 <cprintf>
  8010b7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ba:	cc                   	int3   
  8010bb:	eb fd                	jmp    8010ba <_panic+0x43>

008010bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c7:	8b 13                	mov    (%ebx),%edx
  8010c9:	8d 42 01             	lea    0x1(%edx),%eax
  8010cc:	89 03                	mov    %eax,(%ebx)
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010da:	75 1a                	jne    8010f6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	68 ff 00 00 00       	push   $0xff
  8010e4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e7:	50                   	push   %eax
  8010e8:	e8 ab ef ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  8010ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80110f:	00 00 00 
	b.cnt = 0;
  801112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111c:	ff 75 0c             	pushl  0xc(%ebp)
  80111f:	ff 75 08             	pushl  0x8(%ebp)
  801122:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801128:	50                   	push   %eax
  801129:	68 bd 10 80 00       	push   $0x8010bd
  80112e:	e8 54 01 00 00       	call   801287 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801133:	83 c4 08             	add    $0x8,%esp
  801136:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	e8 50 ef ff ff       	call   800098 <sys_cputs>

	return b.cnt;
}
  801148:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801156:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801159:	50                   	push   %eax
  80115a:	ff 75 08             	pushl  0x8(%ebp)
  80115d:	e8 9d ff ff ff       	call   8010ff <vcprintf>
	va_end(ap);

	return cnt;
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 1c             	sub    $0x1c,%esp
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	89 d6                	mov    %edx,%esi
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801188:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118b:	39 d3                	cmp    %edx,%ebx
  80118d:	72 05                	jb     801194 <printnum+0x30>
  80118f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801192:	77 45                	ja     8011d9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	ff 75 18             	pushl  0x18(%ebp)
  80119a:	8b 45 14             	mov    0x14(%ebp),%eax
  80119d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a0:	53                   	push   %ebx
  8011a1:	ff 75 10             	pushl  0x10(%ebp)
  8011a4:	83 ec 08             	sub    $0x8,%esp
  8011a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b3:	e8 c8 0a 00 00       	call   801c80 <__udivdi3>
  8011b8:	83 c4 18             	add    $0x18,%esp
  8011bb:	52                   	push   %edx
  8011bc:	50                   	push   %eax
  8011bd:	89 f2                	mov    %esi,%edx
  8011bf:	89 f8                	mov    %edi,%eax
  8011c1:	e8 9e ff ff ff       	call   801164 <printnum>
  8011c6:	83 c4 20             	add    $0x20,%esp
  8011c9:	eb 18                	jmp    8011e3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cb:	83 ec 08             	sub    $0x8,%esp
  8011ce:	56                   	push   %esi
  8011cf:	ff 75 18             	pushl  0x18(%ebp)
  8011d2:	ff d7                	call   *%edi
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	eb 03                	jmp    8011dc <printnum+0x78>
  8011d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011dc:	83 eb 01             	sub    $0x1,%ebx
  8011df:	85 db                	test   %ebx,%ebx
  8011e1:	7f e8                	jg     8011cb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	56                   	push   %esi
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f6:	e8 b5 0b 00 00       	call   801db0 <__umoddi3>
  8011fb:	83 c4 14             	add    $0x14,%esp
  8011fe:	0f be 80 93 20 80 00 	movsbl 0x802093(%eax),%eax
  801205:	50                   	push   %eax
  801206:	ff d7                	call   *%edi
}
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120e:	5b                   	pop    %ebx
  80120f:	5e                   	pop    %esi
  801210:	5f                   	pop    %edi
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801216:	83 fa 01             	cmp    $0x1,%edx
  801219:	7e 0e                	jle    801229 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121b:	8b 10                	mov    (%eax),%edx
  80121d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801220:	89 08                	mov    %ecx,(%eax)
  801222:	8b 02                	mov    (%edx),%eax
  801224:	8b 52 04             	mov    0x4(%edx),%edx
  801227:	eb 22                	jmp    80124b <getuint+0x38>
	else if (lflag)
  801229:	85 d2                	test   %edx,%edx
  80122b:	74 10                	je     80123d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80122d:	8b 10                	mov    (%eax),%edx
  80122f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801232:	89 08                	mov    %ecx,(%eax)
  801234:	8b 02                	mov    (%edx),%eax
  801236:	ba 00 00 00 00       	mov    $0x0,%edx
  80123b:	eb 0e                	jmp    80124b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80123d:	8b 10                	mov    (%eax),%edx
  80123f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801242:	89 08                	mov    %ecx,(%eax)
  801244:	8b 02                	mov    (%edx),%eax
  801246:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801253:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801257:	8b 10                	mov    (%eax),%edx
  801259:	3b 50 04             	cmp    0x4(%eax),%edx
  80125c:	73 0a                	jae    801268 <sprintputch+0x1b>
		*b->buf++ = ch;
  80125e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801261:	89 08                	mov    %ecx,(%eax)
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	88 02                	mov    %al,(%edx)
}
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801270:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801273:	50                   	push   %eax
  801274:	ff 75 10             	pushl  0x10(%ebp)
  801277:	ff 75 0c             	pushl  0xc(%ebp)
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 05 00 00 00       	call   801287 <vprintfmt>
	va_end(ap);
}
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 2c             	sub    $0x2c,%esp
  801290:	8b 75 08             	mov    0x8(%ebp),%esi
  801293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801296:	8b 7d 10             	mov    0x10(%ebp),%edi
  801299:	eb 12                	jmp    8012ad <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129b:	85 c0                	test   %eax,%eax
  80129d:	0f 84 38 04 00 00    	je     8016db <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	53                   	push   %ebx
  8012a7:	50                   	push   %eax
  8012a8:	ff d6                	call   *%esi
  8012aa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012ad:	83 c7 01             	add    $0x1,%edi
  8012b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b4:	83 f8 25             	cmp    $0x25,%eax
  8012b7:	75 e2                	jne    80129b <vprintfmt+0x14>
  8012b9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012bd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d7:	eb 07                	jmp    8012e0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  8012dc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e0:	8d 47 01             	lea    0x1(%edi),%eax
  8012e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e6:	0f b6 07             	movzbl (%edi),%eax
  8012e9:	0f b6 c8             	movzbl %al,%ecx
  8012ec:	83 e8 23             	sub    $0x23,%eax
  8012ef:	3c 55                	cmp    $0x55,%al
  8012f1:	0f 87 c9 03 00 00    	ja     8016c0 <vprintfmt+0x439>
  8012f7:	0f b6 c0             	movzbl %al,%eax
  8012fa:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  801301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801304:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801308:	eb d6                	jmp    8012e0 <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  80130a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  801311:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  801317:	eb 94                	jmp    8012ad <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  801319:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  801320:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  801326:	eb 85                	jmp    8012ad <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  801328:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  80132f:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  801335:	e9 73 ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  80133a:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  801341:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  801347:	e9 61 ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  80134c:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  801353:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  801359:	e9 4f ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  80135e:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801365:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  80136b:	e9 3d ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  801370:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801377:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80137d:	e9 2b ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  801382:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  801389:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80138f:	e9 19 ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  801394:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  80139b:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  8013a1:	e9 07 ff ff ff       	jmp    8012ad <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  8013a6:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  8013ad:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  8013b3:	e9 f5 fe ff ff       	jmp    8012ad <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8013c3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8013c6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8013ca:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8013cd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8013d0:	83 fa 09             	cmp    $0x9,%edx
  8013d3:	77 3f                	ja     801414 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8013d5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8013d8:	eb e9                	jmp    8013c3 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8013da:	8b 45 14             	mov    0x14(%ebp),%eax
  8013dd:	8d 48 04             	lea    0x4(%eax),%ecx
  8013e0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8013e3:	8b 00                	mov    (%eax),%eax
  8013e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8013eb:	eb 2d                	jmp    80141a <vprintfmt+0x193>
  8013ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f7:	0f 49 c8             	cmovns %eax,%ecx
  8013fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801400:	e9 db fe ff ff       	jmp    8012e0 <vprintfmt+0x59>
  801405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801408:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80140f:	e9 cc fe ff ff       	jmp    8012e0 <vprintfmt+0x59>
  801414:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801417:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80141a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141e:	0f 89 bc fe ff ff    	jns    8012e0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801424:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801427:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801431:	e9 aa fe ff ff       	jmp    8012e0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801436:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80143c:	e9 9f fe ff ff       	jmp    8012e0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801441:	8b 45 14             	mov    0x14(%ebp),%eax
  801444:	8d 50 04             	lea    0x4(%eax),%edx
  801447:	89 55 14             	mov    %edx,0x14(%ebp)
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	53                   	push   %ebx
  80144e:	ff 30                	pushl  (%eax)
  801450:	ff d6                	call   *%esi
			break;
  801452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801458:	e9 50 fe ff ff       	jmp    8012ad <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80145d:	8b 45 14             	mov    0x14(%ebp),%eax
  801460:	8d 50 04             	lea    0x4(%eax),%edx
  801463:	89 55 14             	mov    %edx,0x14(%ebp)
  801466:	8b 00                	mov    (%eax),%eax
  801468:	99                   	cltd   
  801469:	31 d0                	xor    %edx,%eax
  80146b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80146d:	83 f8 0f             	cmp    $0xf,%eax
  801470:	7f 0b                	jg     80147d <vprintfmt+0x1f6>
  801472:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  801479:	85 d2                	test   %edx,%edx
  80147b:	75 18                	jne    801495 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80147d:	50                   	push   %eax
  80147e:	68 ab 20 80 00       	push   $0x8020ab
  801483:	53                   	push   %ebx
  801484:	56                   	push   %esi
  801485:	e8 e0 fd ff ff       	call   80126a <printfmt>
  80148a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80148d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801490:	e9 18 fe ff ff       	jmp    8012ad <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801495:	52                   	push   %edx
  801496:	68 fd 1f 80 00       	push   $0x801ffd
  80149b:	53                   	push   %ebx
  80149c:	56                   	push   %esi
  80149d:	e8 c8 fd ff ff       	call   80126a <printfmt>
  8014a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a8:	e9 00 fe ff ff       	jmp    8012ad <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b0:	8d 50 04             	lea    0x4(%eax),%edx
  8014b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8014b8:	85 ff                	test   %edi,%edi
  8014ba:	b8 a4 20 80 00       	mov    $0x8020a4,%eax
  8014bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8014c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8014c6:	0f 8e 94 00 00 00    	jle    801560 <vprintfmt+0x2d9>
  8014cc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8014d0:	0f 84 98 00 00 00    	je     80156e <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8014dc:	57                   	push   %edi
  8014dd:	e8 81 02 00 00       	call   801763 <strnlen>
  8014e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014e5:	29 c1                	sub    %eax,%ecx
  8014e7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014ea:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8014ed:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8014f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8014f4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8014f7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8014f9:	eb 0f                	jmp    80150a <vprintfmt+0x283>
					putch(padc, putdat);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801502:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801504:	83 ef 01             	sub    $0x1,%edi
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 ff                	test   %edi,%edi
  80150c:	7f ed                	jg     8014fb <vprintfmt+0x274>
  80150e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801511:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801514:	85 c9                	test   %ecx,%ecx
  801516:	b8 00 00 00 00       	mov    $0x0,%eax
  80151b:	0f 49 c1             	cmovns %ecx,%eax
  80151e:	29 c1                	sub    %eax,%ecx
  801520:	89 75 08             	mov    %esi,0x8(%ebp)
  801523:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801526:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801529:	89 cb                	mov    %ecx,%ebx
  80152b:	eb 4d                	jmp    80157a <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80152d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801531:	74 1b                	je     80154e <vprintfmt+0x2c7>
  801533:	0f be c0             	movsbl %al,%eax
  801536:	83 e8 20             	sub    $0x20,%eax
  801539:	83 f8 5e             	cmp    $0x5e,%eax
  80153c:	76 10                	jbe    80154e <vprintfmt+0x2c7>
					putch('?', putdat);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	ff 75 0c             	pushl  0xc(%ebp)
  801544:	6a 3f                	push   $0x3f
  801546:	ff 55 08             	call   *0x8(%ebp)
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	eb 0d                	jmp    80155b <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	ff 75 0c             	pushl  0xc(%ebp)
  801554:	52                   	push   %edx
  801555:	ff 55 08             	call   *0x8(%ebp)
  801558:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80155b:	83 eb 01             	sub    $0x1,%ebx
  80155e:	eb 1a                	jmp    80157a <vprintfmt+0x2f3>
  801560:	89 75 08             	mov    %esi,0x8(%ebp)
  801563:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801566:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801569:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80156c:	eb 0c                	jmp    80157a <vprintfmt+0x2f3>
  80156e:	89 75 08             	mov    %esi,0x8(%ebp)
  801571:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801574:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801577:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80157a:	83 c7 01             	add    $0x1,%edi
  80157d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801581:	0f be d0             	movsbl %al,%edx
  801584:	85 d2                	test   %edx,%edx
  801586:	74 23                	je     8015ab <vprintfmt+0x324>
  801588:	85 f6                	test   %esi,%esi
  80158a:	78 a1                	js     80152d <vprintfmt+0x2a6>
  80158c:	83 ee 01             	sub    $0x1,%esi
  80158f:	79 9c                	jns    80152d <vprintfmt+0x2a6>
  801591:	89 df                	mov    %ebx,%edi
  801593:	8b 75 08             	mov    0x8(%ebp),%esi
  801596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801599:	eb 18                	jmp    8015b3 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	53                   	push   %ebx
  80159f:	6a 20                	push   $0x20
  8015a1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015a3:	83 ef 01             	sub    $0x1,%edi
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	eb 08                	jmp    8015b3 <vprintfmt+0x32c>
  8015ab:	89 df                	mov    %ebx,%edi
  8015ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b3:	85 ff                	test   %edi,%edi
  8015b5:	7f e4                	jg     80159b <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ba:	e9 ee fc ff ff       	jmp    8012ad <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015bf:	83 fa 01             	cmp    $0x1,%edx
  8015c2:	7e 16                	jle    8015da <vprintfmt+0x353>
		return va_arg(*ap, long long);
  8015c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c7:	8d 50 08             	lea    0x8(%eax),%edx
  8015ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8015cd:	8b 50 04             	mov    0x4(%eax),%edx
  8015d0:	8b 00                	mov    (%eax),%eax
  8015d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8015d8:	eb 32                	jmp    80160c <vprintfmt+0x385>
	else if (lflag)
  8015da:	85 d2                	test   %edx,%edx
  8015dc:	74 18                	je     8015f6 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  8015de:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e1:	8d 50 04             	lea    0x4(%eax),%edx
  8015e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8015e7:	8b 00                	mov    (%eax),%eax
  8015e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ec:	89 c1                	mov    %eax,%ecx
  8015ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8015f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015f4:	eb 16                	jmp    80160c <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  8015f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f9:	8d 50 04             	lea    0x4(%eax),%edx
  8015fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8015ff:	8b 00                	mov    (%eax),%eax
  801601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801604:	89 c1                	mov    %eax,%ecx
  801606:	c1 f9 1f             	sar    $0x1f,%ecx
  801609:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80160c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80160f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801612:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801617:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80161b:	79 6f                	jns    80168c <vprintfmt+0x405>
				putch('-', putdat);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	53                   	push   %ebx
  801621:	6a 2d                	push   $0x2d
  801623:	ff d6                	call   *%esi
				num = -(long long) num;
  801625:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801628:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80162b:	f7 d8                	neg    %eax
  80162d:	83 d2 00             	adc    $0x0,%edx
  801630:	f7 da                	neg    %edx
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	eb 55                	jmp    80168c <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801637:	8d 45 14             	lea    0x14(%ebp),%eax
  80163a:	e8 d4 fb ff ff       	call   801213 <getuint>
			base = 10;
  80163f:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801644:	eb 46                	jmp    80168c <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801646:	8d 45 14             	lea    0x14(%ebp),%eax
  801649:	e8 c5 fb ff ff       	call   801213 <getuint>
			base = 8;
  80164e:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801653:	eb 37                	jmp    80168c <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	53                   	push   %ebx
  801659:	6a 30                	push   $0x30
  80165b:	ff d6                	call   *%esi
			putch('x', putdat);
  80165d:	83 c4 08             	add    $0x8,%esp
  801660:	53                   	push   %ebx
  801661:	6a 78                	push   $0x78
  801663:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801665:	8b 45 14             	mov    0x14(%ebp),%eax
  801668:	8d 50 04             	lea    0x4(%eax),%edx
  80166b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80166e:	8b 00                	mov    (%eax),%eax
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801675:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801678:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  80167d:	eb 0d                	jmp    80168c <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80167f:	8d 45 14             	lea    0x14(%ebp),%eax
  801682:	e8 8c fb ff ff       	call   801213 <getuint>
			base = 16;
  801687:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801693:	51                   	push   %ecx
  801694:	ff 75 e0             	pushl  -0x20(%ebp)
  801697:	57                   	push   %edi
  801698:	52                   	push   %edx
  801699:	50                   	push   %eax
  80169a:	89 da                	mov    %ebx,%edx
  80169c:	89 f0                	mov    %esi,%eax
  80169e:	e8 c1 fa ff ff       	call   801164 <printnum>
			break;
  8016a3:	83 c4 20             	add    $0x20,%esp
  8016a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016a9:	e9 ff fb ff ff       	jmp    8012ad <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	51                   	push   %ecx
  8016b3:	ff d6                	call   *%esi
			break;
  8016b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8016bb:	e9 ed fb ff ff       	jmp    8012ad <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	53                   	push   %ebx
  8016c4:	6a 25                	push   $0x25
  8016c6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	eb 03                	jmp    8016d0 <vprintfmt+0x449>
  8016cd:	83 ef 01             	sub    $0x1,%edi
  8016d0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8016d4:	75 f7                	jne    8016cd <vprintfmt+0x446>
  8016d6:	e9 d2 fb ff ff       	jmp    8012ad <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5f                   	pop    %edi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 18             	sub    $0x18,%esp
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801700:	85 c0                	test   %eax,%eax
  801702:	74 26                	je     80172a <vsnprintf+0x47>
  801704:	85 d2                	test   %edx,%edx
  801706:	7e 22                	jle    80172a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801708:	ff 75 14             	pushl  0x14(%ebp)
  80170b:	ff 75 10             	pushl  0x10(%ebp)
  80170e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	68 4d 12 80 00       	push   $0x80124d
  801717:	e8 6b fb ff ff       	call   801287 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80171c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80171f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	eb 05                	jmp    80172f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80172a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801737:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80173a:	50                   	push   %eax
  80173b:	ff 75 10             	pushl  0x10(%ebp)
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	ff 75 08             	pushl  0x8(%ebp)
  801744:	e8 9a ff ff ff       	call   8016e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801751:	b8 00 00 00 00       	mov    $0x0,%eax
  801756:	eb 03                	jmp    80175b <strlen+0x10>
		n++;
  801758:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80175b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80175f:	75 f7                	jne    801758 <strlen+0xd>
		n++;
	return n;
}
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801769:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	eb 03                	jmp    801776 <strnlen+0x13>
		n++;
  801773:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801776:	39 c2                	cmp    %eax,%edx
  801778:	74 08                	je     801782 <strnlen+0x1f>
  80177a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80177e:	75 f3                	jne    801773 <strnlen+0x10>
  801780:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80178e:	89 c2                	mov    %eax,%edx
  801790:	83 c2 01             	add    $0x1,%edx
  801793:	83 c1 01             	add    $0x1,%ecx
  801796:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80179a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80179d:	84 db                	test   %bl,%bl
  80179f:	75 ef                	jne    801790 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8017a1:	5b                   	pop    %ebx
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017ab:	53                   	push   %ebx
  8017ac:	e8 9a ff ff ff       	call   80174b <strlen>
  8017b1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8017b4:	ff 75 0c             	pushl  0xc(%ebp)
  8017b7:	01 d8                	add    %ebx,%eax
  8017b9:	50                   	push   %eax
  8017ba:	e8 c5 ff ff ff       	call   801784 <strcpy>
	return dst;
}
  8017bf:	89 d8                	mov    %ebx,%eax
  8017c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d1:	89 f3                	mov    %esi,%ebx
  8017d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017d6:	89 f2                	mov    %esi,%edx
  8017d8:	eb 0f                	jmp    8017e9 <strncpy+0x23>
		*dst++ = *src;
  8017da:	83 c2 01             	add    $0x1,%edx
  8017dd:	0f b6 01             	movzbl (%ecx),%eax
  8017e0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017e3:	80 39 01             	cmpb   $0x1,(%ecx)
  8017e6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017e9:	39 da                	cmp    %ebx,%edx
  8017eb:	75 ed                	jne    8017da <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017ed:	89 f0                	mov    %esi,%eax
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fe:	8b 55 10             	mov    0x10(%ebp),%edx
  801801:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801803:	85 d2                	test   %edx,%edx
  801805:	74 21                	je     801828 <strlcpy+0x35>
  801807:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80180b:	89 f2                	mov    %esi,%edx
  80180d:	eb 09                	jmp    801818 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80180f:	83 c2 01             	add    $0x1,%edx
  801812:	83 c1 01             	add    $0x1,%ecx
  801815:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801818:	39 c2                	cmp    %eax,%edx
  80181a:	74 09                	je     801825 <strlcpy+0x32>
  80181c:	0f b6 19             	movzbl (%ecx),%ebx
  80181f:	84 db                	test   %bl,%bl
  801821:	75 ec                	jne    80180f <strlcpy+0x1c>
  801823:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801825:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801828:	29 f0                	sub    %esi,%eax
}
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801834:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801837:	eb 06                	jmp    80183f <strcmp+0x11>
		p++, q++;
  801839:	83 c1 01             	add    $0x1,%ecx
  80183c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80183f:	0f b6 01             	movzbl (%ecx),%eax
  801842:	84 c0                	test   %al,%al
  801844:	74 04                	je     80184a <strcmp+0x1c>
  801846:	3a 02                	cmp    (%edx),%al
  801848:	74 ef                	je     801839 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80184a:	0f b6 c0             	movzbl %al,%eax
  80184d:	0f b6 12             	movzbl (%edx),%edx
  801850:	29 d0                	sub    %edx,%eax
}
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	53                   	push   %ebx
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801863:	eb 06                	jmp    80186b <strncmp+0x17>
		n--, p++, q++;
  801865:	83 c0 01             	add    $0x1,%eax
  801868:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80186b:	39 d8                	cmp    %ebx,%eax
  80186d:	74 15                	je     801884 <strncmp+0x30>
  80186f:	0f b6 08             	movzbl (%eax),%ecx
  801872:	84 c9                	test   %cl,%cl
  801874:	74 04                	je     80187a <strncmp+0x26>
  801876:	3a 0a                	cmp    (%edx),%cl
  801878:	74 eb                	je     801865 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80187a:	0f b6 00             	movzbl (%eax),%eax
  80187d:	0f b6 12             	movzbl (%edx),%edx
  801880:	29 d0                	sub    %edx,%eax
  801882:	eb 05                	jmp    801889 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801889:	5b                   	pop    %ebx
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801896:	eb 07                	jmp    80189f <strchr+0x13>
		if (*s == c)
  801898:	38 ca                	cmp    %cl,%dl
  80189a:	74 0f                	je     8018ab <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80189c:	83 c0 01             	add    $0x1,%eax
  80189f:	0f b6 10             	movzbl (%eax),%edx
  8018a2:	84 d2                	test   %dl,%dl
  8018a4:	75 f2                	jne    801898 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8018a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018b7:	eb 03                	jmp    8018bc <strfind+0xf>
  8018b9:	83 c0 01             	add    $0x1,%eax
  8018bc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018bf:	38 ca                	cmp    %cl,%dl
  8018c1:	74 04                	je     8018c7 <strfind+0x1a>
  8018c3:	84 d2                	test   %dl,%dl
  8018c5:	75 f2                	jne    8018b9 <strfind+0xc>
			break;
	return (char *) s;
}
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	57                   	push   %edi
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
  8018cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8018d5:	85 c9                	test   %ecx,%ecx
  8018d7:	74 36                	je     80190f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018df:	75 28                	jne    801909 <memset+0x40>
  8018e1:	f6 c1 03             	test   $0x3,%cl
  8018e4:	75 23                	jne    801909 <memset+0x40>
		c &= 0xFF;
  8018e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018ea:	89 d3                	mov    %edx,%ebx
  8018ec:	c1 e3 08             	shl    $0x8,%ebx
  8018ef:	89 d6                	mov    %edx,%esi
  8018f1:	c1 e6 18             	shl    $0x18,%esi
  8018f4:	89 d0                	mov    %edx,%eax
  8018f6:	c1 e0 10             	shl    $0x10,%eax
  8018f9:	09 f0                	or     %esi,%eax
  8018fb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018fd:	89 d8                	mov    %ebx,%eax
  8018ff:	09 d0                	or     %edx,%eax
  801901:	c1 e9 02             	shr    $0x2,%ecx
  801904:	fc                   	cld    
  801905:	f3 ab                	rep stos %eax,%es:(%edi)
  801907:	eb 06                	jmp    80190f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801909:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190c:	fc                   	cld    
  80190d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80190f:	89 f8                	mov    %edi,%eax
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5f                   	pop    %edi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801924:	39 c6                	cmp    %eax,%esi
  801926:	73 35                	jae    80195d <memmove+0x47>
  801928:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80192b:	39 d0                	cmp    %edx,%eax
  80192d:	73 2e                	jae    80195d <memmove+0x47>
		s += n;
		d += n;
  80192f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801932:	89 d6                	mov    %edx,%esi
  801934:	09 fe                	or     %edi,%esi
  801936:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80193c:	75 13                	jne    801951 <memmove+0x3b>
  80193e:	f6 c1 03             	test   $0x3,%cl
  801941:	75 0e                	jne    801951 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801943:	83 ef 04             	sub    $0x4,%edi
  801946:	8d 72 fc             	lea    -0x4(%edx),%esi
  801949:	c1 e9 02             	shr    $0x2,%ecx
  80194c:	fd                   	std    
  80194d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80194f:	eb 09                	jmp    80195a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801951:	83 ef 01             	sub    $0x1,%edi
  801954:	8d 72 ff             	lea    -0x1(%edx),%esi
  801957:	fd                   	std    
  801958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80195a:	fc                   	cld    
  80195b:	eb 1d                	jmp    80197a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80195d:	89 f2                	mov    %esi,%edx
  80195f:	09 c2                	or     %eax,%edx
  801961:	f6 c2 03             	test   $0x3,%dl
  801964:	75 0f                	jne    801975 <memmove+0x5f>
  801966:	f6 c1 03             	test   $0x3,%cl
  801969:	75 0a                	jne    801975 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80196b:	c1 e9 02             	shr    $0x2,%ecx
  80196e:	89 c7                	mov    %eax,%edi
  801970:	fc                   	cld    
  801971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801973:	eb 05                	jmp    80197a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801975:	89 c7                	mov    %eax,%edi
  801977:	fc                   	cld    
  801978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80197a:	5e                   	pop    %esi
  80197b:	5f                   	pop    %edi
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801981:	ff 75 10             	pushl  0x10(%ebp)
  801984:	ff 75 0c             	pushl  0xc(%ebp)
  801987:	ff 75 08             	pushl  0x8(%ebp)
  80198a:	e8 87 ff ff ff       	call   801916 <memmove>
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199c:	89 c6                	mov    %eax,%esi
  80199e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019a1:	eb 1a                	jmp    8019bd <memcmp+0x2c>
		if (*s1 != *s2)
  8019a3:	0f b6 08             	movzbl (%eax),%ecx
  8019a6:	0f b6 1a             	movzbl (%edx),%ebx
  8019a9:	38 d9                	cmp    %bl,%cl
  8019ab:	74 0a                	je     8019b7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8019ad:	0f b6 c1             	movzbl %cl,%eax
  8019b0:	0f b6 db             	movzbl %bl,%ebx
  8019b3:	29 d8                	sub    %ebx,%eax
  8019b5:	eb 0f                	jmp    8019c6 <memcmp+0x35>
		s1++, s2++;
  8019b7:	83 c0 01             	add    $0x1,%eax
  8019ba:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019bd:	39 f0                	cmp    %esi,%eax
  8019bf:	75 e2                	jne    8019a3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8019c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	53                   	push   %ebx
  8019ce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8019d1:	89 c1                	mov    %eax,%ecx
  8019d3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8019d6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019da:	eb 0a                	jmp    8019e6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019dc:	0f b6 10             	movzbl (%eax),%edx
  8019df:	39 da                	cmp    %ebx,%edx
  8019e1:	74 07                	je     8019ea <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019e3:	83 c0 01             	add    $0x1,%eax
  8019e6:	39 c8                	cmp    %ecx,%eax
  8019e8:	72 f2                	jb     8019dc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019ea:	5b                   	pop    %ebx
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	57                   	push   %edi
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019f9:	eb 03                	jmp    8019fe <strtol+0x11>
		s++;
  8019fb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019fe:	0f b6 01             	movzbl (%ecx),%eax
  801a01:	3c 20                	cmp    $0x20,%al
  801a03:	74 f6                	je     8019fb <strtol+0xe>
  801a05:	3c 09                	cmp    $0x9,%al
  801a07:	74 f2                	je     8019fb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a09:	3c 2b                	cmp    $0x2b,%al
  801a0b:	75 0a                	jne    801a17 <strtol+0x2a>
		s++;
  801a0d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a10:	bf 00 00 00 00       	mov    $0x0,%edi
  801a15:	eb 11                	jmp    801a28 <strtol+0x3b>
  801a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a1c:	3c 2d                	cmp    $0x2d,%al
  801a1e:	75 08                	jne    801a28 <strtol+0x3b>
		s++, neg = 1;
  801a20:	83 c1 01             	add    $0x1,%ecx
  801a23:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a28:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a2e:	75 15                	jne    801a45 <strtol+0x58>
  801a30:	80 39 30             	cmpb   $0x30,(%ecx)
  801a33:	75 10                	jne    801a45 <strtol+0x58>
  801a35:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a39:	75 7c                	jne    801ab7 <strtol+0xca>
		s += 2, base = 16;
  801a3b:	83 c1 02             	add    $0x2,%ecx
  801a3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a43:	eb 16                	jmp    801a5b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a45:	85 db                	test   %ebx,%ebx
  801a47:	75 12                	jne    801a5b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a49:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4e:	80 39 30             	cmpb   $0x30,(%ecx)
  801a51:	75 08                	jne    801a5b <strtol+0x6e>
		s++, base = 8;
  801a53:	83 c1 01             	add    $0x1,%ecx
  801a56:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a60:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a63:	0f b6 11             	movzbl (%ecx),%edx
  801a66:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a69:	89 f3                	mov    %esi,%ebx
  801a6b:	80 fb 09             	cmp    $0x9,%bl
  801a6e:	77 08                	ja     801a78 <strtol+0x8b>
			dig = *s - '0';
  801a70:	0f be d2             	movsbl %dl,%edx
  801a73:	83 ea 30             	sub    $0x30,%edx
  801a76:	eb 22                	jmp    801a9a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a78:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a7b:	89 f3                	mov    %esi,%ebx
  801a7d:	80 fb 19             	cmp    $0x19,%bl
  801a80:	77 08                	ja     801a8a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a82:	0f be d2             	movsbl %dl,%edx
  801a85:	83 ea 57             	sub    $0x57,%edx
  801a88:	eb 10                	jmp    801a9a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a8a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a8d:	89 f3                	mov    %esi,%ebx
  801a8f:	80 fb 19             	cmp    $0x19,%bl
  801a92:	77 16                	ja     801aaa <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a94:	0f be d2             	movsbl %dl,%edx
  801a97:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a9a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a9d:	7d 0b                	jge    801aaa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a9f:	83 c1 01             	add    $0x1,%ecx
  801aa2:	0f af 45 10          	imul   0x10(%ebp),%eax
  801aa6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801aa8:	eb b9                	jmp    801a63 <strtol+0x76>

	if (endptr)
  801aaa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801aae:	74 0d                	je     801abd <strtol+0xd0>
		*endptr = (char *) s;
  801ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab3:	89 0e                	mov    %ecx,(%esi)
  801ab5:	eb 06                	jmp    801abd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ab7:	85 db                	test   %ebx,%ebx
  801ab9:	74 98                	je     801a53 <strtol+0x66>
  801abb:	eb 9e                	jmp    801a5b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801abd:	89 c2                	mov    %eax,%edx
  801abf:	f7 da                	neg    %edx
  801ac1:	85 ff                	test   %edi,%edi
  801ac3:	0f 45 c2             	cmovne %edx,%eax
}
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	57                   	push   %edi
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 04             	sub    $0x4,%esp
  801ad4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  801ad7:	57                   	push   %edi
  801ad8:	e8 6e fc ff ff       	call   80174b <strlen>
  801add:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801ae0:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  801ae3:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801aed:	eb 46                	jmp    801b35 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  801aef:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  801af3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801af6:	80 f9 09             	cmp    $0x9,%cl
  801af9:	77 08                	ja     801b03 <charhex_to_dec+0x38>
			num = s[i] - '0';
  801afb:	0f be d2             	movsbl %dl,%edx
  801afe:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b01:	eb 27                	jmp    801b2a <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  801b03:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  801b06:	80 f9 05             	cmp    $0x5,%cl
  801b09:	77 08                	ja     801b13 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  801b0b:	0f be d2             	movsbl %dl,%edx
  801b0e:	8d 4a a9             	lea    -0x57(%edx),%ecx
  801b11:	eb 17                	jmp    801b2a <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  801b13:	8d 4a bf             	lea    -0x41(%edx),%ecx
  801b16:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  801b19:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  801b1e:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  801b22:	77 06                	ja     801b2a <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  801b24:	0f be d2             	movsbl %dl,%edx
  801b27:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  801b2a:	0f af ce             	imul   %esi,%ecx
  801b2d:	01 c8                	add    %ecx,%eax
		base *= 16;
  801b2f:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  801b32:	83 eb 01             	sub    $0x1,%ebx
  801b35:	83 fb 01             	cmp    $0x1,%ebx
  801b38:	7f b5                	jg     801aef <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  801b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5f                   	pop    %edi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	8b 75 08             	mov    0x8(%ebp),%esi
  801b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801b50:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801b52:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b57:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	50                   	push   %eax
  801b5e:	e8 a1 e7 ff ff       	call   800304 <sys_ipc_recv>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	79 16                	jns    801b80 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801b6a:	85 f6                	test   %esi,%esi
  801b6c:	74 06                	je     801b74 <ipc_recv+0x32>
			*from_env_store = 0;
  801b6e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b74:	85 db                	test   %ebx,%ebx
  801b76:	74 2c                	je     801ba4 <ipc_recv+0x62>
			*perm_store = 0;
  801b78:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b7e:	eb 24                	jmp    801ba4 <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801b80:	85 f6                	test   %esi,%esi
  801b82:	74 0a                	je     801b8e <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801b84:	a1 08 40 80 00       	mov    0x804008,%eax
  801b89:	8b 40 74             	mov    0x74(%eax),%eax
  801b8c:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b8e:	85 db                	test   %ebx,%ebx
  801b90:	74 0a                	je     801b9c <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801b92:	a1 08 40 80 00       	mov    0x804008,%eax
  801b97:	8b 40 78             	mov    0x78(%eax),%eax
  801b9a:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801b9c:	a1 08 40 80 00       	mov    0x804008,%eax
  801ba1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801bbd:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801bbf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bc4:	0f 44 d8             	cmove  %eax,%ebx
  801bc7:	eb 1e                	jmp    801be7 <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801bc9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bcc:	74 14                	je     801be2 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	68 a0 23 80 00       	push   $0x8023a0
  801bd6:	6a 44                	push   $0x44
  801bd8:	68 cc 23 80 00       	push   $0x8023cc
  801bdd:	e8 95 f4 ff ff       	call   801077 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801be2:	e8 4e e5 ff ff       	call   800135 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801be7:	ff 75 14             	pushl  0x14(%ebp)
  801bea:	53                   	push   %ebx
  801beb:	56                   	push   %esi
  801bec:	57                   	push   %edi
  801bed:	e8 ef e6 ff ff       	call   8002e1 <sys_ipc_try_send>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	78 d0                	js     801bc9 <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5f                   	pop    %edi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c0c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c0f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c15:	8b 52 50             	mov    0x50(%edx),%edx
  801c18:	39 ca                	cmp    %ecx,%edx
  801c1a:	75 0d                	jne    801c29 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c1c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c1f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c24:	8b 40 48             	mov    0x48(%eax),%eax
  801c27:	eb 0f                	jmp    801c38 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c29:	83 c0 01             	add    $0x1,%eax
  801c2c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c31:	75 d9                	jne    801c0c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c40:	89 d0                	mov    %edx,%eax
  801c42:	c1 e8 16             	shr    $0x16,%eax
  801c45:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c51:	f6 c1 01             	test   $0x1,%cl
  801c54:	74 1d                	je     801c73 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c56:	c1 ea 0c             	shr    $0xc,%edx
  801c59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c60:	f6 c2 01             	test   $0x1,%dl
  801c63:	74 0e                	je     801c73 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c65:	c1 ea 0c             	shr    $0xc,%edx
  801c68:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c6f:	ef 
  801c70:	0f b7 c0             	movzwl %ax,%eax
}
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	66 90                	xchg   %ax,%ax
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
