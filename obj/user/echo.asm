
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 c0 1f 80 00       	push   $0x801fc0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 c3 1f 80 00       	push   $0x801fc3
  80008f:	6a 01                	push   $0x1
  800091:	e8 02 0b 00 00       	call   800b98 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 e6 0a 00 00       	call   800b98 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 01 21 80 00       	push   $0x802101
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 c5 0a 00 00       	call   800b98 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 c5 04 00 00       	call   8005b3 <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 7e 08 00 00       	call   8009ad <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 39 04 00 00       	call   800572 <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <charhex_to_dec>:


/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 04             	sub    $0x4,%esp
  8004c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int len = strlen(s);
  8004ca:	57                   	push   %edi
  8004cb:	e8 6e fc ff ff       	call   80013e <strlen>
  8004d0:	83 c4 04             	add    $0x4,%esp
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  8004d3:	8d 58 ff             	lea    -0x1(%eax),%ebx
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
  8004d6:	be 01 00 00 00       	mov    $0x1,%esi
/* lab2 challenge */
int 
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
  8004db:	b8 00 00 00 00       	mov    $0x0,%eax
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  8004e0:	eb 46                	jmp    800528 <charhex_to_dec+0x6a>
		int num = 0;
		if(s[i]>='0' && s[i]<='9')
  8004e2:	0f b6 14 1f          	movzbl (%edi,%ebx,1),%edx
  8004e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004e9:	80 f9 09             	cmp    $0x9,%cl
  8004ec:	77 08                	ja     8004f6 <charhex_to_dec+0x38>
			num = s[i] - '0';
  8004ee:	0f be d2             	movsbl %dl,%edx
  8004f1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004f4:	eb 27                	jmp    80051d <charhex_to_dec+0x5f>
		else if(s[i]>='a' && s[i]<='f')
  8004f6:	8d 4a 9f             	lea    -0x61(%edx),%ecx
  8004f9:	80 f9 05             	cmp    $0x5,%cl
  8004fc:	77 08                	ja     800506 <charhex_to_dec+0x48>
			num = s[i] - 'a' + 10;
  8004fe:	0f be d2             	movsbl %dl,%edx
  800501:	8d 4a a9             	lea    -0x57(%edx),%ecx
  800504:	eb 17                	jmp    80051d <charhex_to_dec+0x5f>
		else if(s[i]>='A' && s[i]<='F')
  800506:	8d 4a bf             	lea    -0x41(%edx),%ecx
  800509:	88 4d f3             	mov    %cl,-0xd(%ebp)
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
		int num = 0;
  80050c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if(s[i]>='0' && s[i]<='9')
			num = s[i] - '0';
		else if(s[i]>='a' && s[i]<='f')
			num = s[i] - 'a' + 10;
		else if(s[i]>='A' && s[i]<='F')
  800511:	80 7d f3 05          	cmpb   $0x5,-0xd(%ebp)
  800515:	77 06                	ja     80051d <charhex_to_dec+0x5f>
			num = s[i] - 'A' + 10;
  800517:	0f be d2             	movsbl %dl,%edx
  80051a:	8d 4a c9             	lea    -0x37(%edx),%ecx

		sum += num * base;
  80051d:	0f af ce             	imul   %esi,%ecx
  800520:	01 c8                	add    %ecx,%eax
		base *= 16;
  800522:	c1 e6 04             	shl    $0x4,%esi
charhex_to_dec(char *s) 
{
	int len = strlen(s);
	int sum = 0;
	int base = 1;
	for(int i = len-1; i >= 2; --i) {
  800525:	83 eb 01             	sub    $0x1,%ebx
  800528:	83 fb 01             	cmp    $0x1,%ebx
  80052b:	7f b5                	jg     8004e2 <charhex_to_dec+0x24>
		sum += num * base;
		base *= 16;
	}

	return sum;
  80052d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800530:	5b                   	pop    %ebx
  800531:	5e                   	pop    %esi
  800532:	5f                   	pop    %edi
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	57                   	push   %edi
  800539:	56                   	push   %esi
  80053a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800543:	8b 55 08             	mov    0x8(%ebp),%edx
  800546:	89 c3                	mov    %eax,%ebx
  800548:	89 c7                	mov    %eax,%edi
  80054a:	89 c6                	mov    %eax,%esi
  80054c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80054e:	5b                   	pop    %ebx
  80054f:	5e                   	pop    %esi
  800550:	5f                   	pop    %edi
  800551:	5d                   	pop    %ebp
  800552:	c3                   	ret    

00800553 <sys_cgetc>:

int
sys_cgetc(void)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
  80055e:	b8 01 00 00 00       	mov    $0x1,%eax
  800563:	89 d1                	mov    %edx,%ecx
  800565:	89 d3                	mov    %edx,%ebx
  800567:	89 d7                	mov    %edx,%edi
  800569:	89 d6                	mov    %edx,%esi
  80056b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80056d:	5b                   	pop    %ebx
  80056e:	5e                   	pop    %esi
  80056f:	5f                   	pop    %edi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	57                   	push   %edi
  800576:	56                   	push   %esi
  800577:	53                   	push   %ebx
  800578:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80057b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800580:	b8 03 00 00 00       	mov    $0x3,%eax
  800585:	8b 55 08             	mov    0x8(%ebp),%edx
  800588:	89 cb                	mov    %ecx,%ebx
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	89 ce                	mov    %ecx,%esi
  80058e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800590:	85 c0                	test   %eax,%eax
  800592:	7e 17                	jle    8005ab <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800594:	83 ec 0c             	sub    $0xc,%esp
  800597:	50                   	push   %eax
  800598:	6a 03                	push   $0x3
  80059a:	68 cf 1f 80 00       	push   $0x801fcf
  80059f:	6a 23                	push   $0x23
  8005a1:	68 ec 1f 80 00       	push   $0x801fec
  8005a6:	e8 69 0f 00 00       	call   801514 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8005ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ae:	5b                   	pop    %ebx
  8005af:	5e                   	pop    %esi
  8005b0:	5f                   	pop    %edi
  8005b1:	5d                   	pop    %ebp
  8005b2:	c3                   	ret    

008005b3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	57                   	push   %edi
  8005b7:	56                   	push   %esi
  8005b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005be:	b8 02 00 00 00       	mov    $0x2,%eax
  8005c3:	89 d1                	mov    %edx,%ecx
  8005c5:	89 d3                	mov    %edx,%ebx
  8005c7:	89 d7                	mov    %edx,%edi
  8005c9:	89 d6                	mov    %edx,%esi
  8005cb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8005cd:	5b                   	pop    %ebx
  8005ce:	5e                   	pop    %esi
  8005cf:	5f                   	pop    %edi
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <sys_yield>:

void
sys_yield(void)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	57                   	push   %edi
  8005d6:	56                   	push   %esi
  8005d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005dd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005e2:	89 d1                	mov    %edx,%ecx
  8005e4:	89 d3                	mov    %edx,%ebx
  8005e6:	89 d7                	mov    %edx,%edi
  8005e8:	89 d6                	mov    %edx,%esi
  8005ea:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005ec:	5b                   	pop    %ebx
  8005ed:	5e                   	pop    %esi
  8005ee:	5f                   	pop    %edi
  8005ef:	5d                   	pop    %ebp
  8005f0:	c3                   	ret    

008005f1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	57                   	push   %edi
  8005f5:	56                   	push   %esi
  8005f6:	53                   	push   %ebx
  8005f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005fa:	be 00 00 00 00       	mov    $0x0,%esi
  8005ff:	b8 04 00 00 00       	mov    $0x4,%eax
  800604:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800607:	8b 55 08             	mov    0x8(%ebp),%edx
  80060a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060d:	89 f7                	mov    %esi,%edi
  80060f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800611:	85 c0                	test   %eax,%eax
  800613:	7e 17                	jle    80062c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800615:	83 ec 0c             	sub    $0xc,%esp
  800618:	50                   	push   %eax
  800619:	6a 04                	push   $0x4
  80061b:	68 cf 1f 80 00       	push   $0x801fcf
  800620:	6a 23                	push   $0x23
  800622:	68 ec 1f 80 00       	push   $0x801fec
  800627:	e8 e8 0e 00 00       	call   801514 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80062c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	57                   	push   %edi
  800638:	56                   	push   %esi
  800639:	53                   	push   %ebx
  80063a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80063d:	b8 05 00 00 00       	mov    $0x5,%eax
  800642:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800645:	8b 55 08             	mov    0x8(%ebp),%edx
  800648:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80064b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80064e:	8b 75 18             	mov    0x18(%ebp),%esi
  800651:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800653:	85 c0                	test   %eax,%eax
  800655:	7e 17                	jle    80066e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800657:	83 ec 0c             	sub    $0xc,%esp
  80065a:	50                   	push   %eax
  80065b:	6a 05                	push   $0x5
  80065d:	68 cf 1f 80 00       	push   $0x801fcf
  800662:	6a 23                	push   $0x23
  800664:	68 ec 1f 80 00       	push   $0x801fec
  800669:	e8 a6 0e 00 00       	call   801514 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80066e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	57                   	push   %edi
  80067a:	56                   	push   %esi
  80067b:	53                   	push   %ebx
  80067c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80067f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800684:	b8 06 00 00 00       	mov    $0x6,%eax
  800689:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80068c:	8b 55 08             	mov    0x8(%ebp),%edx
  80068f:	89 df                	mov    %ebx,%edi
  800691:	89 de                	mov    %ebx,%esi
  800693:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800695:	85 c0                	test   %eax,%eax
  800697:	7e 17                	jle    8006b0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	50                   	push   %eax
  80069d:	6a 06                	push   $0x6
  80069f:	68 cf 1f 80 00       	push   $0x801fcf
  8006a4:	6a 23                	push   $0x23
  8006a6:	68 ec 1f 80 00       	push   $0x801fec
  8006ab:	e8 64 0e 00 00       	call   801514 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8006b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d1:	89 df                	mov    %ebx,%edi
  8006d3:	89 de                	mov    %ebx,%esi
  8006d5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	7e 17                	jle    8006f2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	50                   	push   %eax
  8006df:	6a 08                	push   $0x8
  8006e1:	68 cf 1f 80 00       	push   $0x801fcf
  8006e6:	6a 23                	push   $0x23
  8006e8:	68 ec 1f 80 00       	push   $0x801fec
  8006ed:	e8 22 0e 00 00       	call   801514 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <sys_env_set_trapframe>:
	return syscall(SYS_env_set_exception_handler, 1, envid, (uint32_t)exception_num, 0, 0, 0);
}
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	57                   	push   %edi
  8006fe:	56                   	push   %esi
  8006ff:	53                   	push   %ebx
  800700:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800703:	bb 00 00 00 00       	mov    $0x0,%ebx
  800708:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800710:	8b 55 08             	mov    0x8(%ebp),%edx
  800713:	89 df                	mov    %ebx,%edi
  800715:	89 de                	mov    %ebx,%esi
  800717:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800719:	85 c0                	test   %eax,%eax
  80071b:	7e 17                	jle    800734 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80071d:	83 ec 0c             	sub    $0xc,%esp
  800720:	50                   	push   %eax
  800721:	6a 0a                	push   $0xa
  800723:	68 cf 1f 80 00       	push   $0x801fcf
  800728:	6a 23                	push   $0x23
  80072a:	68 ec 1f 80 00       	push   $0x801fec
  80072f:	e8 e0 0d 00 00       	call   801514 <_panic>
#else
int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	57                   	push   %edi
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800745:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074a:	b8 09 00 00 00       	mov    $0x9,%eax
  80074f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800752:	8b 55 08             	mov    0x8(%ebp),%edx
  800755:	89 df                	mov    %ebx,%edi
  800757:	89 de                	mov    %ebx,%esi
  800759:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80075b:	85 c0                	test   %eax,%eax
  80075d:	7e 17                	jle    800776 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80075f:	83 ec 0c             	sub    $0xc,%esp
  800762:	50                   	push   %eax
  800763:	6a 09                	push   $0x9
  800765:	68 cf 1f 80 00       	push   $0x801fcf
  80076a:	6a 23                	push   $0x23
  80076c:	68 ec 1f 80 00       	push   $0x801fec
  800771:	e8 9e 0d 00 00       	call   801514 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800776:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5f                   	pop    %edi
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <sys_ipc_try_send>:
#endif

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	57                   	push   %edi
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800784:	be 00 00 00 00       	mov    $0x0,%esi
  800789:	b8 0c 00 00 00       	mov    $0xc,%eax
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	8b 55 08             	mov    0x8(%ebp),%edx
  800794:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800797:	8b 7d 14             	mov    0x14(%ebp),%edi
  80079a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5f                   	pop    %edi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	57                   	push   %edi
  8007a5:	56                   	push   %esi
  8007a6:	53                   	push   %ebx
  8007a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007af:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b7:	89 cb                	mov    %ecx,%ebx
  8007b9:	89 cf                	mov    %ecx,%edi
  8007bb:	89 ce                	mov    %ecx,%esi
  8007bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	7e 17                	jle    8007da <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007c3:	83 ec 0c             	sub    $0xc,%esp
  8007c6:	50                   	push   %eax
  8007c7:	6a 0d                	push   $0xd
  8007c9:	68 cf 1f 80 00       	push   $0x801fcf
  8007ce:	6a 23                	push   $0x23
  8007d0:	68 ec 1f 80 00       	push   $0x801fec
  8007d5:	e8 3a 0d 00 00       	call   801514 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5f                   	pop    %edi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8007ed:	c1 e8 0c             	shr    $0xc,%eax
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	05 00 00 00 30       	add    $0x30000000,%eax
  8007fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800802:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800814:	89 c2                	mov    %eax,%edx
  800816:	c1 ea 16             	shr    $0x16,%edx
  800819:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800820:	f6 c2 01             	test   $0x1,%dl
  800823:	74 11                	je     800836 <fd_alloc+0x2d>
  800825:	89 c2                	mov    %eax,%edx
  800827:	c1 ea 0c             	shr    $0xc,%edx
  80082a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800831:	f6 c2 01             	test   $0x1,%dl
  800834:	75 09                	jne    80083f <fd_alloc+0x36>
			*fd_store = fd;
  800836:	89 01                	mov    %eax,(%ecx)
			return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
  80083d:	eb 17                	jmp    800856 <fd_alloc+0x4d>
  80083f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800844:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800849:	75 c9                	jne    800814 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80084b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800851:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80085e:	83 f8 1f             	cmp    $0x1f,%eax
  800861:	77 36                	ja     800899 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800863:	c1 e0 0c             	shl    $0xc,%eax
  800866:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	c1 ea 16             	shr    $0x16,%edx
  800870:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800877:	f6 c2 01             	test   $0x1,%dl
  80087a:	74 24                	je     8008a0 <fd_lookup+0x48>
  80087c:	89 c2                	mov    %eax,%edx
  80087e:	c1 ea 0c             	shr    $0xc,%edx
  800881:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800888:	f6 c2 01             	test   $0x1,%dl
  80088b:	74 1a                	je     8008a7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 02                	mov    %eax,(%edx)
	return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
  800897:	eb 13                	jmp    8008ac <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089e:	eb 0c                	jmp    8008ac <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a5:	eb 05                	jmp    8008ac <fd_lookup+0x54>
  8008a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	ba 78 20 80 00       	mov    $0x802078,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8008bc:	eb 13                	jmp    8008d1 <dev_lookup+0x23>
  8008be:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8008c1:	39 08                	cmp    %ecx,(%eax)
  8008c3:	75 0c                	jne    8008d1 <dev_lookup+0x23>
			*dev = devtab[i];
  8008c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cf:	eb 2e                	jmp    8008ff <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008d1:	8b 02                	mov    (%edx),%eax
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	75 e7                	jne    8008be <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8008dc:	8b 40 48             	mov    0x48(%eax),%eax
  8008df:	83 ec 04             	sub    $0x4,%esp
  8008e2:	51                   	push   %ecx
  8008e3:	50                   	push   %eax
  8008e4:	68 fc 1f 80 00       	push   $0x801ffc
  8008e9:	e8 ff 0c 00 00       	call   8015ed <cprintf>
	*dev = 0;
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	83 ec 10             	sub    $0x10,%esp
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80090f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800912:	50                   	push   %eax
  800913:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800919:	c1 e8 0c             	shr    $0xc,%eax
  80091c:	50                   	push   %eax
  80091d:	e8 36 ff ff ff       	call   800858 <fd_lookup>
  800922:	83 c4 08             	add    $0x8,%esp
  800925:	85 c0                	test   %eax,%eax
  800927:	78 05                	js     80092e <fd_close+0x2d>
	    || fd != fd2) 
  800929:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80092c:	74 0c                	je     80093a <fd_close+0x39>
		return (must_exist ? r : 0); 
  80092e:	84 db                	test   %bl,%bl
  800930:	ba 00 00 00 00       	mov    $0x0,%edx
  800935:	0f 44 c2             	cmove  %edx,%eax
  800938:	eb 41                	jmp    80097b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800940:	50                   	push   %eax
  800941:	ff 36                	pushl  (%esi)
  800943:	e8 66 ff ff ff       	call   8008ae <dev_lookup>
  800948:	89 c3                	mov    %eax,%ebx
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 1a                	js     80096b <fd_close+0x6a>
		if (dev->dev_close) 
  800951:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800954:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else 
			r = 0;
  800957:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2) 
		return (must_exist ? r : 0); 
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close) 
  80095c:	85 c0                	test   %eax,%eax
  80095e:	74 0b                	je     80096b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800960:	83 ec 0c             	sub    $0xc,%esp
  800963:	56                   	push   %esi
  800964:	ff d0                	call   *%eax
  800966:	89 c3                	mov    %eax,%ebx
  800968:	83 c4 10             	add    $0x10,%esp
		else 
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	56                   	push   %esi
  80096f:	6a 00                	push   $0x0
  800971:	e8 00 fd ff ff       	call   800676 <sys_page_unmap>
	return r;
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	89 d8                	mov    %ebx,%eax
}
  80097b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800988:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80098b:	50                   	push   %eax
  80098c:	ff 75 08             	pushl  0x8(%ebp)
  80098f:	e8 c4 fe ff ff       	call   800858 <fd_lookup>
  800994:	83 c4 08             	add    $0x8,%esp
  800997:	85 c0                	test   %eax,%eax
  800999:	78 10                	js     8009ab <close+0x29>
		return r;
	else 
		return fd_close(fd, 1);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	6a 01                	push   $0x1
  8009a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8009a3:	e8 59 ff ff ff       	call   800901 <fd_close>
  8009a8:	83 c4 10             	add    $0x10,%esp
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <close_all>:

void
close_all(void)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	53                   	push   %ebx
  8009b1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009b9:	83 ec 0c             	sub    $0xc,%esp
  8009bc:	53                   	push   %ebx
  8009bd:	e8 c0 ff ff ff       	call   800982 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009c2:	83 c3 01             	add    $0x1,%ebx
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	83 fb 20             	cmp    $0x20,%ebx
  8009cb:	75 ec                	jne    8009b9 <close_all+0xc>
		close(i);
}
  8009cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	57                   	push   %edi
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	83 ec 2c             	sub    $0x2c,%esp
  8009db:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009e1:	50                   	push   %eax
  8009e2:	ff 75 08             	pushl  0x8(%ebp)
  8009e5:	e8 6e fe ff ff       	call   800858 <fd_lookup>
  8009ea:	83 c4 08             	add    $0x8,%esp
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	0f 88 c1 00 00 00    	js     800ab6 <dup+0xe4>
		return r;
	close(newfdnum);
  8009f5:	83 ec 0c             	sub    $0xc,%esp
  8009f8:	56                   	push   %esi
  8009f9:	e8 84 ff ff ff       	call   800982 <close>

	newfd = INDEX2FD(newfdnum);
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	c1 e3 0c             	shl    $0xc,%ebx
  800a03:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800a09:	83 c4 04             	add    $0x4,%esp
  800a0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a0f:	e8 de fd ff ff       	call   8007f2 <fd2data>
  800a14:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800a16:	89 1c 24             	mov    %ebx,(%esp)
  800a19:	e8 d4 fd ff ff       	call   8007f2 <fd2data>
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	c1 e8 16             	shr    $0x16,%eax
  800a29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a30:	a8 01                	test   $0x1,%al
  800a32:	74 37                	je     800a6b <dup+0x99>
  800a34:	89 f8                	mov    %edi,%eax
  800a36:	c1 e8 0c             	shr    $0xc,%eax
  800a39:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a40:	f6 c2 01             	test   $0x1,%dl
  800a43:	74 26                	je     800a6b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a4c:	83 ec 0c             	sub    $0xc,%esp
  800a4f:	25 07 0e 00 00       	and    $0xe07,%eax
  800a54:	50                   	push   %eax
  800a55:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a58:	6a 00                	push   $0x0
  800a5a:	57                   	push   %edi
  800a5b:	6a 00                	push   $0x0
  800a5d:	e8 d2 fb ff ff       	call   800634 <sys_page_map>
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	83 c4 20             	add    $0x20,%esp
  800a67:	85 c0                	test   %eax,%eax
  800a69:	78 2e                	js     800a99 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a6b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a6e:	89 d0                	mov    %edx,%eax
  800a70:	c1 e8 0c             	shr    $0xc,%eax
  800a73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a7a:	83 ec 0c             	sub    $0xc,%esp
  800a7d:	25 07 0e 00 00       	and    $0xe07,%eax
  800a82:	50                   	push   %eax
  800a83:	53                   	push   %ebx
  800a84:	6a 00                	push   $0x0
  800a86:	52                   	push   %edx
  800a87:	6a 00                	push   $0x0
  800a89:	e8 a6 fb ff ff       	call   800634 <sys_page_map>
  800a8e:	89 c7                	mov    %eax,%edi
  800a90:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a93:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a95:	85 ff                	test   %edi,%edi
  800a97:	79 1d                	jns    800ab6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a99:	83 ec 08             	sub    $0x8,%esp
  800a9c:	53                   	push   %ebx
  800a9d:	6a 00                	push   $0x0
  800a9f:	e8 d2 fb ff ff       	call   800676 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800aa4:	83 c4 08             	add    $0x8,%esp
  800aa7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800aaa:	6a 00                	push   $0x0
  800aac:	e8 c5 fb ff ff       	call   800676 <sys_page_unmap>
	return r;
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	89 f8                	mov    %edi,%eax
}
  800ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 14             	sub    $0x14,%esp
  800ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ac8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800acb:	50                   	push   %eax
  800acc:	53                   	push   %ebx
  800acd:	e8 86 fd ff ff       	call   800858 <fd_lookup>
  800ad2:	83 c4 08             	add    $0x8,%esp
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	78 6d                	js     800b48 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800adb:	83 ec 08             	sub    $0x8,%esp
  800ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae1:	50                   	push   %eax
  800ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae5:	ff 30                	pushl  (%eax)
  800ae7:	e8 c2 fd ff ff       	call   8008ae <dev_lookup>
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 4c                	js     800b3f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af6:	8b 42 08             	mov    0x8(%edx),%eax
  800af9:	83 e0 03             	and    $0x3,%eax
  800afc:	83 f8 01             	cmp    $0x1,%eax
  800aff:	75 21                	jne    800b22 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b01:	a1 08 40 80 00       	mov    0x804008,%eax
  800b06:	8b 40 48             	mov    0x48(%eax),%eax
  800b09:	83 ec 04             	sub    $0x4,%esp
  800b0c:	53                   	push   %ebx
  800b0d:	50                   	push   %eax
  800b0e:	68 3d 20 80 00       	push   $0x80203d
  800b13:	e8 d5 0a 00 00       	call   8015ed <cprintf>
		return -E_INVAL;
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b20:	eb 26                	jmp    800b48 <read+0x8a>
	}
	if (!dev->dev_read)
  800b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b25:	8b 40 08             	mov    0x8(%eax),%eax
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	74 17                	je     800b43 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b2c:	83 ec 04             	sub    $0x4,%esp
  800b2f:	ff 75 10             	pushl  0x10(%ebp)
  800b32:	ff 75 0c             	pushl  0xc(%ebp)
  800b35:	52                   	push   %edx
  800b36:	ff d0                	call   *%eax
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	eb 09                	jmp    800b48 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	eb 05                	jmp    800b48 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b43:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800b48:	89 d0                	mov    %edx,%eax
  800b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b63:	eb 21                	jmp    800b86 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b65:	83 ec 04             	sub    $0x4,%esp
  800b68:	89 f0                	mov    %esi,%eax
  800b6a:	29 d8                	sub    %ebx,%eax
  800b6c:	50                   	push   %eax
  800b6d:	89 d8                	mov    %ebx,%eax
  800b6f:	03 45 0c             	add    0xc(%ebp),%eax
  800b72:	50                   	push   %eax
  800b73:	57                   	push   %edi
  800b74:	e8 45 ff ff ff       	call   800abe <read>
		if (m < 0)
  800b79:	83 c4 10             	add    $0x10,%esp
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	78 10                	js     800b90 <readn+0x41>
			return m;
		if (m == 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	74 0a                	je     800b8e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b84:	01 c3                	add    %eax,%ebx
  800b86:	39 f3                	cmp    %esi,%ebx
  800b88:	72 db                	jb     800b65 <readn+0x16>
  800b8a:	89 d8                	mov    %ebx,%eax
  800b8c:	eb 02                	jmp    800b90 <readn+0x41>
  800b8e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 14             	sub    $0x14,%esp
  800b9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ba5:	50                   	push   %eax
  800ba6:	53                   	push   %ebx
  800ba7:	e8 ac fc ff ff       	call   800858 <fd_lookup>
  800bac:	83 c4 08             	add    $0x8,%esp
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	78 68                	js     800c1d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bbb:	50                   	push   %eax
  800bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbf:	ff 30                	pushl  (%eax)
  800bc1:	e8 e8 fc ff ff       	call   8008ae <dev_lookup>
  800bc6:	83 c4 10             	add    $0x10,%esp
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	78 47                	js     800c14 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bd4:	75 21                	jne    800bf7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800bd6:	a1 08 40 80 00       	mov    0x804008,%eax
  800bdb:	8b 40 48             	mov    0x48(%eax),%eax
  800bde:	83 ec 04             	sub    $0x4,%esp
  800be1:	53                   	push   %ebx
  800be2:	50                   	push   %eax
  800be3:	68 59 20 80 00       	push   $0x802059
  800be8:	e8 00 0a 00 00       	call   8015ed <cprintf>
		return -E_INVAL;
  800bed:	83 c4 10             	add    $0x10,%esp
  800bf0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bf5:	eb 26                	jmp    800c1d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfa:	8b 52 0c             	mov    0xc(%edx),%edx
  800bfd:	85 d2                	test   %edx,%edx
  800bff:	74 17                	je     800c18 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c01:	83 ec 04             	sub    $0x4,%esp
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	50                   	push   %eax
  800c0b:	ff d2                	call   *%edx
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	eb 09                	jmp    800c1d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c14:	89 c2                	mov    %eax,%edx
  800c16:	eb 05                	jmp    800c1d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c18:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800c1d:	89 d0                	mov    %edx,%eax
  800c1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c2a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c2d:	50                   	push   %eax
  800c2e:	ff 75 08             	pushl  0x8(%ebp)
  800c31:	e8 22 fc ff ff       	call   800858 <fd_lookup>
  800c36:	83 c4 08             	add    $0x8,%esp
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	78 0e                	js     800c4b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c43:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	53                   	push   %ebx
  800c51:	83 ec 14             	sub    $0x14,%esp
  800c54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c5a:	50                   	push   %eax
  800c5b:	53                   	push   %ebx
  800c5c:	e8 f7 fb ff ff       	call   800858 <fd_lookup>
  800c61:	83 c4 08             	add    $0x8,%esp
  800c64:	89 c2                	mov    %eax,%edx
  800c66:	85 c0                	test   %eax,%eax
  800c68:	78 65                	js     800ccf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c6a:	83 ec 08             	sub    $0x8,%esp
  800c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c70:	50                   	push   %eax
  800c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c74:	ff 30                	pushl  (%eax)
  800c76:	e8 33 fc ff ff       	call   8008ae <dev_lookup>
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	78 44                	js     800cc6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c85:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c89:	75 21                	jne    800cac <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c8b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c90:	8b 40 48             	mov    0x48(%eax),%eax
  800c93:	83 ec 04             	sub    $0x4,%esp
  800c96:	53                   	push   %ebx
  800c97:	50                   	push   %eax
  800c98:	68 1c 20 80 00       	push   $0x80201c
  800c9d:	e8 4b 09 00 00       	call   8015ed <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800caa:	eb 23                	jmp    800ccf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800cac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800caf:	8b 52 18             	mov    0x18(%edx),%edx
  800cb2:	85 d2                	test   %edx,%edx
  800cb4:	74 14                	je     800cca <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800cb6:	83 ec 08             	sub    $0x8,%esp
  800cb9:	ff 75 0c             	pushl  0xc(%ebp)
  800cbc:	50                   	push   %eax
  800cbd:	ff d2                	call   *%edx
  800cbf:	89 c2                	mov    %eax,%edx
  800cc1:	83 c4 10             	add    $0x10,%esp
  800cc4:	eb 09                	jmp    800ccf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc6:	89 c2                	mov    %eax,%edx
  800cc8:	eb 05                	jmp    800ccf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800cca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800ccf:	89 d0                	mov    %edx,%eax
  800cd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 14             	sub    $0x14,%esp
  800cdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ce0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ce3:	50                   	push   %eax
  800ce4:	ff 75 08             	pushl  0x8(%ebp)
  800ce7:	e8 6c fb ff ff       	call   800858 <fd_lookup>
  800cec:	83 c4 08             	add    $0x8,%esp
  800cef:	89 c2                	mov    %eax,%edx
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	78 58                	js     800d4d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cf5:	83 ec 08             	sub    $0x8,%esp
  800cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cfb:	50                   	push   %eax
  800cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cff:	ff 30                	pushl  (%eax)
  800d01:	e8 a8 fb ff ff       	call   8008ae <dev_lookup>
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 37                	js     800d44 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d10:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d14:	74 32                	je     800d48 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d16:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d19:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d20:	00 00 00 
	stat->st_isdir = 0;
  800d23:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d2a:	00 00 00 
	stat->st_dev = dev;
  800d2d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	53                   	push   %ebx
  800d37:	ff 75 f0             	pushl  -0x10(%ebp)
  800d3a:	ff 50 14             	call   *0x14(%eax)
  800d3d:	89 c2                	mov    %eax,%edx
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	eb 09                	jmp    800d4d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	eb 05                	jmp    800d4d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d48:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d4d:	89 d0                	mov    %edx,%eax
  800d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d59:	83 ec 08             	sub    $0x8,%esp
  800d5c:	6a 00                	push   $0x0
  800d5e:	ff 75 08             	pushl  0x8(%ebp)
  800d61:	e8 2b 02 00 00       	call   800f91 <open>
  800d66:	89 c3                	mov    %eax,%ebx
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	78 1b                	js     800d8a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	50                   	push   %eax
  800d76:	e8 5b ff ff ff       	call   800cd6 <fstat>
  800d7b:	89 c6                	mov    %eax,%esi
	close(fd);
  800d7d:	89 1c 24             	mov    %ebx,(%esp)
  800d80:	e8 fd fb ff ff       	call   800982 <close>
	return r;
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	89 f0                	mov    %esi,%eax
}
  800d8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	89 c6                	mov    %eax,%esi
  800d98:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d9a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800da1:	75 12                	jne    800db5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	6a 01                	push   $0x1
  800da8:	e8 fa 0e 00 00       	call   801ca7 <ipc_find_env>
  800dad:	a3 00 40 80 00       	mov    %eax,0x804000
  800db2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800db5:	6a 07                	push   $0x7
  800db7:	68 00 50 80 00       	push   $0x805000
  800dbc:	56                   	push   %esi
  800dbd:	ff 35 00 40 80 00    	pushl  0x804000
  800dc3:	e8 89 0e 00 00       	call   801c51 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  800dc8:	83 c4 0c             	add    $0xc,%esp
  800dcb:	6a 00                	push   $0x0
  800dcd:	53                   	push   %ebx
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 13 0e 00 00       	call   801be8 <ipc_recv>
}
  800dd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	8b 40 0c             	mov    0xc(%eax),%eax
  800de8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800df5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800dff:	e8 8d ff ff ff       	call   800d91 <fsipc>
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800e12:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e17:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800e21:	e8 6b ff ff ff       	call   800d91 <fsipc>
}
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    

00800e28 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	8b 40 0c             	mov    0xc(%eax),%eax
  800e38:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 05 00 00 00       	mov    $0x5,%eax
  800e47:	e8 45 ff ff ff       	call   800d91 <fsipc>
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 2c                	js     800e7c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	68 00 50 80 00       	push   $0x805000
  800e58:	53                   	push   %ebx
  800e59:	e8 19 f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e5e:	a1 80 50 80 00       	mov    0x805080,%eax
  800e63:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e69:	a1 84 50 80 00       	mov    0x805084,%eax
  800e6e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	53                   	push   %ebx
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e90:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800e95:	0f 46 d8             	cmovbe %eax,%ebx

	if(n > PGSIZE - (sizeof(int) + sizeof(size_t)))
		n = PGSIZE - (sizeof(int) + sizeof(size_t)); 


	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800e9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  800ea3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800ea9:	53                   	push   %ebx
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	68 08 50 80 00       	push   $0x805008
  800eb2:	e8 52 f4 ff ff       	call   800309 <memmove>

	if((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800eb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebc:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec1:	e8 cb fe ff ff       	call   800d91 <fsipc>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 3d                	js     800f0a <devfile_write+0x89>
		return r;

	assert(r <= n);
  800ecd:	39 d8                	cmp    %ebx,%eax
  800ecf:	76 19                	jbe    800eea <devfile_write+0x69>
  800ed1:	68 88 20 80 00       	push   $0x802088
  800ed6:	68 8f 20 80 00       	push   $0x80208f
  800edb:	68 9f 00 00 00       	push   $0x9f
  800ee0:	68 a4 20 80 00       	push   $0x8020a4
  800ee5:	e8 2a 06 00 00       	call   801514 <_panic>
	assert(r <= PGSIZE - (sizeof(int) + sizeof(size_t)));
  800eea:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800eef:	76 19                	jbe    800f0a <devfile_write+0x89>
  800ef1:	68 bc 20 80 00       	push   $0x8020bc
  800ef6:	68 8f 20 80 00       	push   $0x80208f
  800efb:	68 a0 00 00 00       	push   $0xa0
  800f00:	68 a4 20 80 00       	push   $0x8020a4
  800f05:	e8 0a 06 00 00       	call   801514 <_panic>

	return r;
}
  800f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	8b 40 0c             	mov    0xc(%eax),%eax
  800f1d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800f22:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f28:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f32:	e8 5a fe ff ff       	call   800d91 <fsipc>
  800f37:	89 c3                	mov    %eax,%ebx
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 4b                	js     800f88 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800f3d:	39 c6                	cmp    %eax,%esi
  800f3f:	73 16                	jae    800f57 <devfile_read+0x48>
  800f41:	68 88 20 80 00       	push   $0x802088
  800f46:	68 8f 20 80 00       	push   $0x80208f
  800f4b:	6a 7e                	push   $0x7e
  800f4d:	68 a4 20 80 00       	push   $0x8020a4
  800f52:	e8 bd 05 00 00       	call   801514 <_panic>
	assert(r <= PGSIZE);
  800f57:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f5c:	7e 16                	jle    800f74 <devfile_read+0x65>
  800f5e:	68 af 20 80 00       	push   $0x8020af
  800f63:	68 8f 20 80 00       	push   $0x80208f
  800f68:	6a 7f                	push   $0x7f
  800f6a:	68 a4 20 80 00       	push   $0x8020a4
  800f6f:	e8 a0 05 00 00       	call   801514 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	50                   	push   %eax
  800f78:	68 00 50 80 00       	push   $0x805000
  800f7d:	ff 75 0c             	pushl  0xc(%ebp)
  800f80:	e8 84 f3 ff ff       	call   800309 <memmove>
	return r;
  800f85:	83 c4 10             	add    $0x10,%esp
}
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	53                   	push   %ebx
  800f95:	83 ec 20             	sub    $0x20,%esp
  800f98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f9b:	53                   	push   %ebx
  800f9c:	e8 9d f1 ff ff       	call   80013e <strlen>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fa9:	7f 67                	jg     801012 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb1:	50                   	push   %eax
  800fb2:	e8 52 f8 ff ff       	call   800809 <fd_alloc>
  800fb7:	83 c4 10             	add    $0x10,%esp
		return r;
  800fba:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 57                	js     801017 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	53                   	push   %ebx
  800fc4:	68 00 50 80 00       	push   $0x805000
  800fc9:	e8 a9 f1 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800fce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800fd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fde:	e8 ae fd ff ff       	call   800d91 <fsipc>
  800fe3:	89 c3                	mov    %eax,%ebx
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	79 14                	jns    801000 <open+0x6f>
		fd_close(fd, 0);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	6a 00                	push   $0x0
  800ff1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff4:	e8 08 f9 ff ff       	call   800901 <fd_close>
		return r;
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	89 da                	mov    %ebx,%edx
  800ffe:	eb 17                	jmp    801017 <open+0x86>
	}

	return fd2num(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	ff 75 f4             	pushl  -0xc(%ebp)
  801006:	e8 d7 f7 ff ff       	call   8007e2 <fd2num>
  80100b:	89 c2                	mov    %eax,%edx
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	eb 05                	jmp    801017 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801012:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801017:	89 d0                	mov    %edx,%eax
  801019:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801024:	ba 00 00 00 00       	mov    $0x0,%edx
  801029:	b8 08 00 00 00       	mov    $0x8,%eax
  80102e:	e8 5e fd ff ff       	call   800d91 <fsipc>
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	ff 75 08             	pushl  0x8(%ebp)
  801043:	e8 aa f7 ff ff       	call   8007f2 <fd2data>
  801048:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80104a:	83 c4 08             	add    $0x8,%esp
  80104d:	68 e9 20 80 00       	push   $0x8020e9
  801052:	53                   	push   %ebx
  801053:	e8 1f f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801058:	8b 46 04             	mov    0x4(%esi),%eax
  80105b:	2b 06                	sub    (%esi),%eax
  80105d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801063:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80106a:	00 00 00 
	stat->st_dev = &devpipe;
  80106d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801074:	30 80 00 
	return 0;
}
  801077:	b8 00 00 00 00       	mov    $0x0,%eax
  80107c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	53                   	push   %ebx
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80108d:	53                   	push   %ebx
  80108e:	6a 00                	push   $0x0
  801090:	e8 e1 f5 ff ff       	call   800676 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801095:	89 1c 24             	mov    %ebx,(%esp)
  801098:	e8 55 f7 ff ff       	call   8007f2 <fd2data>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	50                   	push   %eax
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 ce f5 ff ff       	call   800676 <sys_page_unmap>
}
  8010a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ab:	c9                   	leave  
  8010ac:	c3                   	ret    

008010ad <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	57                   	push   %edi
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 1c             	sub    $0x1c,%esp
  8010b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010b9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8010c9:	e8 12 0c 00 00       	call   801ce0 <pageref>
  8010ce:	89 c3                	mov    %eax,%ebx
  8010d0:	89 3c 24             	mov    %edi,(%esp)
  8010d3:	e8 08 0c 00 00       	call   801ce0 <pageref>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	39 c3                	cmp    %eax,%ebx
  8010dd:	0f 94 c1             	sete   %cl
  8010e0:	0f b6 c9             	movzbl %cl,%ecx
  8010e3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010e6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ec:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ef:	39 ce                	cmp    %ecx,%esi
  8010f1:	74 1b                	je     80110e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010f3:	39 c3                	cmp    %eax,%ebx
  8010f5:	75 c4                	jne    8010bb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010f7:	8b 42 58             	mov    0x58(%edx),%eax
  8010fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fd:	50                   	push   %eax
  8010fe:	56                   	push   %esi
  8010ff:	68 f0 20 80 00       	push   $0x8020f0
  801104:	e8 e4 04 00 00       	call   8015ed <cprintf>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	eb ad                	jmp    8010bb <_pipeisclosed+0xe>
	}
}
  80110e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 28             	sub    $0x28,%esp
  801122:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801125:	56                   	push   %esi
  801126:	e8 c7 f6 ff ff       	call   8007f2 <fd2data>
  80112b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	bf 00 00 00 00       	mov    $0x0,%edi
  801135:	eb 4b                	jmp    801182 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801137:	89 da                	mov    %ebx,%edx
  801139:	89 f0                	mov    %esi,%eax
  80113b:	e8 6d ff ff ff       	call   8010ad <_pipeisclosed>
  801140:	85 c0                	test   %eax,%eax
  801142:	75 48                	jne    80118c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801144:	e8 89 f4 ff ff       	call   8005d2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801149:	8b 43 04             	mov    0x4(%ebx),%eax
  80114c:	8b 0b                	mov    (%ebx),%ecx
  80114e:	8d 51 20             	lea    0x20(%ecx),%edx
  801151:	39 d0                	cmp    %edx,%eax
  801153:	73 e2                	jae    801137 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801155:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801158:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80115c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80115f:	89 c2                	mov    %eax,%edx
  801161:	c1 fa 1f             	sar    $0x1f,%edx
  801164:	89 d1                	mov    %edx,%ecx
  801166:	c1 e9 1b             	shr    $0x1b,%ecx
  801169:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80116c:	83 e2 1f             	and    $0x1f,%edx
  80116f:	29 ca                	sub    %ecx,%edx
  801171:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801175:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801179:	83 c0 01             	add    $0x1,%eax
  80117c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117f:	83 c7 01             	add    $0x1,%edi
  801182:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801185:	75 c2                	jne    801149 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801187:	8b 45 10             	mov    0x10(%ebp),%eax
  80118a:	eb 05                	jmp    801191 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 18             	sub    $0x18,%esp
  8011a2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011a5:	57                   	push   %edi
  8011a6:	e8 47 f6 ff ff       	call   8007f2 <fd2data>
  8011ab:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b5:	eb 3d                	jmp    8011f4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011b7:	85 db                	test   %ebx,%ebx
  8011b9:	74 04                	je     8011bf <devpipe_read+0x26>
				return i;
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	eb 44                	jmp    801203 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011bf:	89 f2                	mov    %esi,%edx
  8011c1:	89 f8                	mov    %edi,%eax
  8011c3:	e8 e5 fe ff ff       	call   8010ad <_pipeisclosed>
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	75 32                	jne    8011fe <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011cc:	e8 01 f4 ff ff       	call   8005d2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011d1:	8b 06                	mov    (%esi),%eax
  8011d3:	3b 46 04             	cmp    0x4(%esi),%eax
  8011d6:	74 df                	je     8011b7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011d8:	99                   	cltd   
  8011d9:	c1 ea 1b             	shr    $0x1b,%edx
  8011dc:	01 d0                	add    %edx,%eax
  8011de:	83 e0 1f             	and    $0x1f,%eax
  8011e1:	29 d0                	sub    %edx,%eax
  8011e3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011eb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011ee:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011f1:	83 c3 01             	add    $0x1,%ebx
  8011f4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011f7:	75 d8                	jne    8011d1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011fc:	eb 05                	jmp    801203 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	e8 ed f5 ff ff       	call   800809 <fd_alloc>
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	89 c2                	mov    %eax,%edx
  801221:	85 c0                	test   %eax,%eax
  801223:	0f 88 2c 01 00 00    	js     801355 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	68 07 04 00 00       	push   $0x407
  801231:	ff 75 f4             	pushl  -0xc(%ebp)
  801234:	6a 00                	push   $0x0
  801236:	e8 b6 f3 ff ff       	call   8005f1 <sys_page_alloc>
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	89 c2                	mov    %eax,%edx
  801240:	85 c0                	test   %eax,%eax
  801242:	0f 88 0d 01 00 00    	js     801355 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	e8 b5 f5 ff ff       	call   800809 <fd_alloc>
  801254:	89 c3                	mov    %eax,%ebx
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	0f 88 e2 00 00 00    	js     801343 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	68 07 04 00 00       	push   $0x407
  801269:	ff 75 f0             	pushl  -0x10(%ebp)
  80126c:	6a 00                	push   $0x0
  80126e:	e8 7e f3 ff ff       	call   8005f1 <sys_page_alloc>
  801273:	89 c3                	mov    %eax,%ebx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	0f 88 c3 00 00 00    	js     801343 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801280:	83 ec 0c             	sub    $0xc,%esp
  801283:	ff 75 f4             	pushl  -0xc(%ebp)
  801286:	e8 67 f5 ff ff       	call   8007f2 <fd2data>
  80128b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128d:	83 c4 0c             	add    $0xc,%esp
  801290:	68 07 04 00 00       	push   $0x407
  801295:	50                   	push   %eax
  801296:	6a 00                	push   $0x0
  801298:	e8 54 f3 ff ff       	call   8005f1 <sys_page_alloc>
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	0f 88 89 00 00 00    	js     801333 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b0:	e8 3d f5 ff ff       	call   8007f2 <fd2data>
  8012b5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012bc:	50                   	push   %eax
  8012bd:	6a 00                	push   $0x0
  8012bf:	56                   	push   %esi
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 6d f3 ff ff       	call   800634 <sys_page_map>
  8012c7:	89 c3                	mov    %eax,%ebx
  8012c9:	83 c4 20             	add    $0x20,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 55                	js     801325 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012d0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8012d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012de:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012e5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801300:	e8 dd f4 ff ff       	call   8007e2 <fd2num>
  801305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801308:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80130a:	83 c4 04             	add    $0x4,%esp
  80130d:	ff 75 f0             	pushl  -0x10(%ebp)
  801310:	e8 cd f4 ff ff       	call   8007e2 <fd2num>
  801315:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801318:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	ba 00 00 00 00       	mov    $0x0,%edx
  801323:	eb 30                	jmp    801355 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	56                   	push   %esi
  801329:	6a 00                	push   $0x0
  80132b:	e8 46 f3 ff ff       	call   800676 <sys_page_unmap>
  801330:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	ff 75 f0             	pushl  -0x10(%ebp)
  801339:	6a 00                	push   $0x0
  80133b:	e8 36 f3 ff ff       	call   800676 <sys_page_unmap>
  801340:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	ff 75 f4             	pushl  -0xc(%ebp)
  801349:	6a 00                	push   $0x0
  80134b:	e8 26 f3 ff ff       	call   800676 <sys_page_unmap>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801355:	89 d0                	mov    %edx,%eax
  801357:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135a:	5b                   	pop    %ebx
  80135b:	5e                   	pop    %esi
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 e8 f4 ff ff       	call   800858 <fd_lookup>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 18                	js     80138f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801377:	83 ec 0c             	sub    $0xc,%esp
  80137a:	ff 75 f4             	pushl  -0xc(%ebp)
  80137d:	e8 70 f4 ff ff       	call   8007f2 <fd2data>
	return _pipeisclosed(fd, p);
  801382:	89 c2                	mov    %eax,%edx
  801384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801387:	e8 21 fd ff ff       	call   8010ad <_pipeisclosed>
  80138c:	83 c4 10             	add    $0x10,%esp
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801394:	b8 00 00 00 00       	mov    $0x0,%eax
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013a1:	68 08 21 80 00       	push   $0x802108
  8013a6:	ff 75 0c             	pushl  0xc(%ebp)
  8013a9:	e8 c9 ed ff ff       	call   800177 <strcpy>
	return 0;
}
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	57                   	push   %edi
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cc:	eb 2d                	jmp    8013fb <devcons_write+0x46>
		m = n - tot;
  8013ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013d3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013d6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013db:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013de:	83 ec 04             	sub    $0x4,%esp
  8013e1:	53                   	push   %ebx
  8013e2:	03 45 0c             	add    0xc(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	57                   	push   %edi
  8013e7:	e8 1d ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	53                   	push   %ebx
  8013f0:	57                   	push   %edi
  8013f1:	e8 3f f1 ff ff       	call   800535 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013f6:	01 de                	add    %ebx,%esi
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	89 f0                	mov    %esi,%eax
  8013fd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801400:	72 cc                	jb     8013ce <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801402:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801415:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801419:	74 2a                	je     801445 <devcons_read+0x3b>
  80141b:	eb 05                	jmp    801422 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80141d:	e8 b0 f1 ff ff       	call   8005d2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801422:	e8 2c f1 ff ff       	call   800553 <sys_cgetc>
  801427:	85 c0                	test   %eax,%eax
  801429:	74 f2                	je     80141d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 16                	js     801445 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80142f:	83 f8 04             	cmp    $0x4,%eax
  801432:	74 0c                	je     801440 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801434:	8b 55 0c             	mov    0xc(%ebp),%edx
  801437:	88 02                	mov    %al,(%edx)
	return 1;
  801439:	b8 01 00 00 00       	mov    $0x1,%eax
  80143e:	eb 05                	jmp    801445 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80144d:	8b 45 08             	mov    0x8(%ebp),%eax
  801450:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801453:	6a 01                	push   $0x1
  801455:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	e8 d7 f0 ff ff       	call   800535 <sys_cputs>
}
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <getchar>:

int
getchar(void)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801469:	6a 01                	push   $0x1
  80146b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	6a 00                	push   $0x0
  801471:	e8 48 f6 ff ff       	call   800abe <read>
	if (r < 0)
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 0f                	js     80148c <getchar+0x29>
		return r;
	if (r < 1)
  80147d:	85 c0                	test   %eax,%eax
  80147f:	7e 06                	jle    801487 <getchar+0x24>
		return -E_EOF;
	return c;
  801481:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801485:	eb 05                	jmp    80148c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801487:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	ff 75 08             	pushl  0x8(%ebp)
  80149b:	e8 b8 f3 ff ff       	call   800858 <fd_lookup>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 11                	js     8014b8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014aa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014b0:	39 10                	cmp    %edx,(%eax)
  8014b2:	0f 94 c0             	sete   %al
  8014b5:	0f b6 c0             	movzbl %al,%eax
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <opencons>:

int
opencons(void)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	e8 40 f3 ff ff       	call   800809 <fd_alloc>
  8014c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 3e                	js     801510 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	68 07 04 00 00       	push   $0x407
  8014da:	ff 75 f4             	pushl  -0xc(%ebp)
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 0d f1 ff ff       	call   8005f1 <sys_page_alloc>
  8014e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 23                	js     801510 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014ed:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	50                   	push   %eax
  801506:	e8 d7 f2 ff ff       	call   8007e2 <fd2num>
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	83 c4 10             	add    $0x10,%esp
}
  801510:	89 d0                	mov    %edx,%eax
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	56                   	push   %esi
  801518:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801519:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80151c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801522:	e8 8c f0 ff ff       	call   8005b3 <sys_getenvid>
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	56                   	push   %esi
  801531:	50                   	push   %eax
  801532:	68 14 21 80 00       	push   $0x802114
  801537:	e8 b1 00 00 00       	call   8015ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80153c:	83 c4 18             	add    $0x18,%esp
  80153f:	53                   	push   %ebx
  801540:	ff 75 10             	pushl  0x10(%ebp)
  801543:	e8 54 00 00 00       	call   80159c <vcprintf>
	cprintf("\n");
  801548:	c7 04 24 01 21 80 00 	movl   $0x802101,(%esp)
  80154f:	e8 99 00 00 00       	call   8015ed <cprintf>
  801554:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801557:	cc                   	int3   
  801558:	eb fd                	jmp    801557 <_panic+0x43>

0080155a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	53                   	push   %ebx
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801564:	8b 13                	mov    (%ebx),%edx
  801566:	8d 42 01             	lea    0x1(%edx),%eax
  801569:	89 03                	mov    %eax,(%ebx)
  80156b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801572:	3d ff 00 00 00       	cmp    $0xff,%eax
  801577:	75 1a                	jne    801593 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	68 ff 00 00 00       	push   $0xff
  801581:	8d 43 08             	lea    0x8(%ebx),%eax
  801584:	50                   	push   %eax
  801585:	e8 ab ef ff ff       	call   800535 <sys_cputs>
		b->idx = 0;
  80158a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801590:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801593:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801597:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015ac:	00 00 00 
	b.cnt = 0;
  8015af:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	ff 75 08             	pushl  0x8(%ebp)
  8015bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	68 5a 15 80 00       	push   $0x80155a
  8015cb:	e8 54 01 00 00       	call   801724 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	e8 50 ef ff ff       	call   800535 <sys_cputs>

	return b.cnt;
}
  8015e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015f6:	50                   	push   %eax
  8015f7:	ff 75 08             	pushl  0x8(%ebp)
  8015fa:	e8 9d ff ff ff       	call   80159c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	57                   	push   %edi
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
  801607:	83 ec 1c             	sub    $0x1c,%esp
  80160a:	89 c7                	mov    %eax,%edi
  80160c:	89 d6                	mov    %edx,%esi
  80160e:	8b 45 08             	mov    0x8(%ebp),%eax
  801611:	8b 55 0c             	mov    0xc(%ebp),%edx
  801614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801617:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80161a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80161d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801622:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801625:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801628:	39 d3                	cmp    %edx,%ebx
  80162a:	72 05                	jb     801631 <printnum+0x30>
  80162c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80162f:	77 45                	ja     801676 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	ff 75 18             	pushl  0x18(%ebp)
  801637:	8b 45 14             	mov    0x14(%ebp),%eax
  80163a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80163d:	53                   	push   %ebx
  80163e:	ff 75 10             	pushl  0x10(%ebp)
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	ff 75 e4             	pushl  -0x1c(%ebp)
  801647:	ff 75 e0             	pushl  -0x20(%ebp)
  80164a:	ff 75 dc             	pushl  -0x24(%ebp)
  80164d:	ff 75 d8             	pushl  -0x28(%ebp)
  801650:	e8 cb 06 00 00       	call   801d20 <__udivdi3>
  801655:	83 c4 18             	add    $0x18,%esp
  801658:	52                   	push   %edx
  801659:	50                   	push   %eax
  80165a:	89 f2                	mov    %esi,%edx
  80165c:	89 f8                	mov    %edi,%eax
  80165e:	e8 9e ff ff ff       	call   801601 <printnum>
  801663:	83 c4 20             	add    $0x20,%esp
  801666:	eb 18                	jmp    801680 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	56                   	push   %esi
  80166c:	ff 75 18             	pushl  0x18(%ebp)
  80166f:	ff d7                	call   *%edi
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb 03                	jmp    801679 <printnum+0x78>
  801676:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801679:	83 eb 01             	sub    $0x1,%ebx
  80167c:	85 db                	test   %ebx,%ebx
  80167e:	7f e8                	jg     801668 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	56                   	push   %esi
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168a:	ff 75 e0             	pushl  -0x20(%ebp)
  80168d:	ff 75 dc             	pushl  -0x24(%ebp)
  801690:	ff 75 d8             	pushl  -0x28(%ebp)
  801693:	e8 b8 07 00 00       	call   801e50 <__umoddi3>
  801698:	83 c4 14             	add    $0x14,%esp
  80169b:	0f be 80 37 21 80 00 	movsbl 0x802137(%eax),%eax
  8016a2:	50                   	push   %eax
  8016a3:	ff d7                	call   *%edi
}
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016b3:	83 fa 01             	cmp    $0x1,%edx
  8016b6:	7e 0e                	jle    8016c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016b8:	8b 10                	mov    (%eax),%edx
  8016ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016bd:	89 08                	mov    %ecx,(%eax)
  8016bf:	8b 02                	mov    (%edx),%eax
  8016c1:	8b 52 04             	mov    0x4(%edx),%edx
  8016c4:	eb 22                	jmp    8016e8 <getuint+0x38>
	else if (lflag)
  8016c6:	85 d2                	test   %edx,%edx
  8016c8:	74 10                	je     8016da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016ca:	8b 10                	mov    (%eax),%edx
  8016cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016cf:	89 08                	mov    %ecx,(%eax)
  8016d1:	8b 02                	mov    (%edx),%eax
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d8:	eb 0e                	jmp    8016e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016da:	8b 10                	mov    (%eax),%edx
  8016dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016df:	89 08                	mov    %ecx,(%eax)
  8016e1:	8b 02                	mov    (%edx),%eax
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    

008016ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016f4:	8b 10                	mov    (%eax),%edx
  8016f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8016f9:	73 0a                	jae    801705 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016fe:	89 08                	mov    %ecx,(%eax)
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	88 02                	mov    %al,(%edx)
}
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80170d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801710:	50                   	push   %eax
  801711:	ff 75 10             	pushl  0x10(%ebp)
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	ff 75 08             	pushl  0x8(%ebp)
  80171a:	e8 05 00 00 00       	call   801724 <vprintfmt>
	va_end(ap);
}
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	57                   	push   %edi
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	83 ec 2c             	sub    $0x2c,%esp
  80172d:	8b 75 08             	mov    0x8(%ebp),%esi
  801730:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801733:	8b 7d 10             	mov    0x10(%ebp),%edi
  801736:	eb 12                	jmp    80174a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801738:	85 c0                	test   %eax,%eax
  80173a:	0f 84 38 04 00 00    	je     801b78 <vprintfmt+0x454>
				return;
			putch(ch, putdat);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	53                   	push   %ebx
  801744:	50                   	push   %eax
  801745:	ff d6                	call   *%esi
  801747:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80174a:	83 c7 01             	add    $0x1,%edi
  80174d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801751:	83 f8 25             	cmp    $0x25,%eax
  801754:	75 e2                	jne    801738 <vprintfmt+0x14>
  801756:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80175a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801761:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801768:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	eb 07                	jmp    80177d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 9;
			break;

		// flag to pad on the right
		case '-':
			padc = '-';
  801779:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177d:	8d 47 01             	lea    0x1(%edi),%eax
  801780:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801783:	0f b6 07             	movzbl (%edi),%eax
  801786:	0f b6 c8             	movzbl %al,%ecx
  801789:	83 e8 23             	sub    $0x23,%eax
  80178c:	3c 55                	cmp    $0x55,%al
  80178e:	0f 87 c9 03 00 00    	ja     801b5d <vprintfmt+0x439>
  801794:	0f b6 c0             	movzbl %al,%eax
  801797:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
  80179e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017a5:	eb d6                	jmp    80177d <vprintfmt+0x59>
		switch (ch = *(unsigned char *) fmt++) {

		/* my code here */
		// black
		case 'B':  
			color = 0;
  8017a7:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8017ae:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		/* my code here */
		// black
		case 'B':  
			color = 0;
			break;
  8017b4:	eb 94                	jmp    80174a <vprintfmt+0x26>
		// blue
		case 'b':
			color = 1;
  8017b6:	c7 05 04 40 80 00 01 	movl   $0x1,0x804004
  8017bd:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 0;
			break;
		// blue
		case 'b':
			color = 1;
			break;
  8017c3:	eb 85                	jmp    80174a <vprintfmt+0x26>
		// green
		case 'G':
			color = 2;
  8017c5:	c7 05 04 40 80 00 02 	movl   $0x2,0x804004
  8017cc:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 1;
			break;
		// green
		case 'G':
			color = 2;
			break;
  8017d2:	e9 73 ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// cyan
		case 'C':
			color = 3;
  8017d7:	c7 05 04 40 80 00 03 	movl   $0x3,0x804004
  8017de:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 2;
			break;
		// cyan
		case 'C':
			color = 3;
			break;
  8017e4:	e9 61 ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// red
		case 'R':
			color = 4;
  8017e9:	c7 05 04 40 80 00 04 	movl   $0x4,0x804004
  8017f0:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 3;
			break;
		// red
		case 'R':
			color = 4;
			break;
  8017f6:	e9 4f ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// purple
		case 'P':
			color = 5;
  8017fb:	c7 05 04 40 80 00 05 	movl   $0x5,0x804004
  801802:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801805:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 4;
			break;
		// purple
		case 'P':
			color = 5;
			break;
  801808:	e9 3d ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// orange
		case 'O':
			color = 6;
  80180d:	c7 05 04 40 80 00 06 	movl   $0x6,0x804004
  801814:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 5;
			break;
		// orange
		case 'O':
			color = 6;
			break;
  80181a:	e9 2b ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// white
		case 'W':
			color = 7;
  80181f:	c7 05 04 40 80 00 07 	movl   $0x7,0x804004
  801826:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 6;
			break;
		// white
		case 'W':
			color = 7;
			break;
  80182c:	e9 19 ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// grey
		case 'g':
			color = 8;
  801831:	c7 05 04 40 80 00 08 	movl   $0x8,0x804004
  801838:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 7;
			break;
		// grey
		case 'g':
			color = 8;
			break;
  80183e:	e9 07 ff ff ff       	jmp    80174a <vprintfmt+0x26>
		// violet
		case 'V':
			color = 9;
  801843:	c7 05 04 40 80 00 09 	movl   $0x9,0x804004
  80184a:	00 00 00 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			color = 8;
			break;
		// violet
		case 'V':
			color = 9;
			break;
  801850:	e9 f5 fe ff ff       	jmp    80174a <vprintfmt+0x26>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801860:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801863:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801867:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80186a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80186d:	83 fa 09             	cmp    $0x9,%edx
  801870:	77 3f                	ja     8018b1 <vprintfmt+0x18d>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801872:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801875:	eb e9                	jmp    801860 <vprintfmt+0x13c>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801877:	8b 45 14             	mov    0x14(%ebp),%eax
  80187a:	8d 48 04             	lea    0x4(%eax),%ecx
  80187d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801880:	8b 00                	mov    (%eax),%eax
  801882:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801888:	eb 2d                	jmp    8018b7 <vprintfmt+0x193>
  80188a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80188d:	85 c0                	test   %eax,%eax
  80188f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801894:	0f 49 c8             	cmovns %eax,%ecx
  801897:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80189d:	e9 db fe ff ff       	jmp    80177d <vprintfmt+0x59>
  8018a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018ac:	e9 cc fe ff ff       	jmp    80177d <vprintfmt+0x59>
  8018b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018b4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018bb:	0f 89 bc fe ff ff    	jns    80177d <vprintfmt+0x59>
				width = precision, precision = -1;
  8018c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018ce:	e9 aa fe ff ff       	jmp    80177d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018d3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018d9:	e9 9f fe ff ff       	jmp    80177d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018de:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e1:	8d 50 04             	lea    0x4(%eax),%edx
  8018e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	ff 30                	pushl  (%eax)
  8018ed:	ff d6                	call   *%esi
			break;
  8018ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018f5:	e9 50 fe ff ff       	jmp    80174a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fd:	8d 50 04             	lea    0x4(%eax),%edx
  801900:	89 55 14             	mov    %edx,0x14(%ebp)
  801903:	8b 00                	mov    (%eax),%eax
  801905:	99                   	cltd   
  801906:	31 d0                	xor    %edx,%eax
  801908:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80190a:	83 f8 0f             	cmp    $0xf,%eax
  80190d:	7f 0b                	jg     80191a <vprintfmt+0x1f6>
  80190f:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  801916:	85 d2                	test   %edx,%edx
  801918:	75 18                	jne    801932 <vprintfmt+0x20e>
				printfmt(putch, putdat, "error %d", err);
  80191a:	50                   	push   %eax
  80191b:	68 4f 21 80 00       	push   $0x80214f
  801920:	53                   	push   %ebx
  801921:	56                   	push   %esi
  801922:	e8 e0 fd ff ff       	call   801707 <printfmt>
  801927:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80192d:	e9 18 fe ff ff       	jmp    80174a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801932:	52                   	push   %edx
  801933:	68 a1 20 80 00       	push   $0x8020a1
  801938:	53                   	push   %ebx
  801939:	56                   	push   %esi
  80193a:	e8 c8 fd ff ff       	call   801707 <printfmt>
  80193f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801942:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801945:	e9 00 fe ff ff       	jmp    80174a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80194a:	8b 45 14             	mov    0x14(%ebp),%eax
  80194d:	8d 50 04             	lea    0x4(%eax),%edx
  801950:	89 55 14             	mov    %edx,0x14(%ebp)
  801953:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801955:	85 ff                	test   %edi,%edi
  801957:	b8 48 21 80 00       	mov    $0x802148,%eax
  80195c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80195f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801963:	0f 8e 94 00 00 00    	jle    8019fd <vprintfmt+0x2d9>
  801969:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80196d:	0f 84 98 00 00 00    	je     801a0b <vprintfmt+0x2e7>
				for (width -= strnlen(p, precision); width > 0; width--)
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	ff 75 d0             	pushl  -0x30(%ebp)
  801979:	57                   	push   %edi
  80197a:	e8 d7 e7 ff ff       	call   800156 <strnlen>
  80197f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801982:	29 c1                	sub    %eax,%ecx
  801984:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801987:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80198a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80198e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801991:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801994:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801996:	eb 0f                	jmp    8019a7 <vprintfmt+0x283>
					putch(padc, putdat);
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	53                   	push   %ebx
  80199c:	ff 75 e0             	pushl  -0x20(%ebp)
  80199f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a1:	83 ef 01             	sub    $0x1,%edi
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 ff                	test   %edi,%edi
  8019a9:	7f ed                	jg     801998 <vprintfmt+0x274>
  8019ab:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019ae:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019b1:	85 c9                	test   %ecx,%ecx
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b8:	0f 49 c1             	cmovns %ecx,%eax
  8019bb:	29 c1                	sub    %eax,%ecx
  8019bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c6:	89 cb                	mov    %ecx,%ebx
  8019c8:	eb 4d                	jmp    801a17 <vprintfmt+0x2f3>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019ce:	74 1b                	je     8019eb <vprintfmt+0x2c7>
  8019d0:	0f be c0             	movsbl %al,%eax
  8019d3:	83 e8 20             	sub    $0x20,%eax
  8019d6:	83 f8 5e             	cmp    $0x5e,%eax
  8019d9:	76 10                	jbe    8019eb <vprintfmt+0x2c7>
					putch('?', putdat);
  8019db:	83 ec 08             	sub    $0x8,%esp
  8019de:	ff 75 0c             	pushl  0xc(%ebp)
  8019e1:	6a 3f                	push   $0x3f
  8019e3:	ff 55 08             	call   *0x8(%ebp)
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	eb 0d                	jmp    8019f8 <vprintfmt+0x2d4>
				else
					putch(ch, putdat);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	52                   	push   %edx
  8019f2:	ff 55 08             	call   *0x8(%ebp)
  8019f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019f8:	83 eb 01             	sub    $0x1,%ebx
  8019fb:	eb 1a                	jmp    801a17 <vprintfmt+0x2f3>
  8019fd:	89 75 08             	mov    %esi,0x8(%ebp)
  801a00:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a03:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a06:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a09:	eb 0c                	jmp    801a17 <vprintfmt+0x2f3>
  801a0b:	89 75 08             	mov    %esi,0x8(%ebp)
  801a0e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a11:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a14:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a17:	83 c7 01             	add    $0x1,%edi
  801a1a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a1e:	0f be d0             	movsbl %al,%edx
  801a21:	85 d2                	test   %edx,%edx
  801a23:	74 23                	je     801a48 <vprintfmt+0x324>
  801a25:	85 f6                	test   %esi,%esi
  801a27:	78 a1                	js     8019ca <vprintfmt+0x2a6>
  801a29:	83 ee 01             	sub    $0x1,%esi
  801a2c:	79 9c                	jns    8019ca <vprintfmt+0x2a6>
  801a2e:	89 df                	mov    %ebx,%edi
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi
  801a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a36:	eb 18                	jmp    801a50 <vprintfmt+0x32c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	6a 20                	push   $0x20
  801a3e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a40:	83 ef 01             	sub    $0x1,%edi
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	eb 08                	jmp    801a50 <vprintfmt+0x32c>
  801a48:	89 df                	mov    %ebx,%edi
  801a4a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a50:	85 ff                	test   %edi,%edi
  801a52:	7f e4                	jg     801a38 <vprintfmt+0x314>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a57:	e9 ee fc ff ff       	jmp    80174a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a5c:	83 fa 01             	cmp    $0x1,%edx
  801a5f:	7e 16                	jle    801a77 <vprintfmt+0x353>
		return va_arg(*ap, long long);
  801a61:	8b 45 14             	mov    0x14(%ebp),%eax
  801a64:	8d 50 08             	lea    0x8(%eax),%edx
  801a67:	89 55 14             	mov    %edx,0x14(%ebp)
  801a6a:	8b 50 04             	mov    0x4(%eax),%edx
  801a6d:	8b 00                	mov    (%eax),%eax
  801a6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a72:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a75:	eb 32                	jmp    801aa9 <vprintfmt+0x385>
	else if (lflag)
  801a77:	85 d2                	test   %edx,%edx
  801a79:	74 18                	je     801a93 <vprintfmt+0x36f>
		return va_arg(*ap, long);
  801a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7e:	8d 50 04             	lea    0x4(%eax),%edx
  801a81:	89 55 14             	mov    %edx,0x14(%ebp)
  801a84:	8b 00                	mov    (%eax),%eax
  801a86:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a89:	89 c1                	mov    %eax,%ecx
  801a8b:	c1 f9 1f             	sar    $0x1f,%ecx
  801a8e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a91:	eb 16                	jmp    801aa9 <vprintfmt+0x385>
	else
		return va_arg(*ap, int);
  801a93:	8b 45 14             	mov    0x14(%ebp),%eax
  801a96:	8d 50 04             	lea    0x4(%eax),%edx
  801a99:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9c:	8b 00                	mov    (%eax),%eax
  801a9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aa1:	89 c1                	mov    %eax,%ecx
  801aa3:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aa9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aac:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aaf:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ab4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ab8:	79 6f                	jns    801b29 <vprintfmt+0x405>
				putch('-', putdat);
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	53                   	push   %ebx
  801abe:	6a 2d                	push   $0x2d
  801ac0:	ff d6                	call   *%esi
				num = -(long long) num;
  801ac2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ac5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ac8:	f7 d8                	neg    %eax
  801aca:	83 d2 00             	adc    $0x0,%edx
  801acd:	f7 da                	neg    %edx
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	eb 55                	jmp    801b29 <vprintfmt+0x405>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ad4:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad7:	e8 d4 fb ff ff       	call   8016b0 <getuint>
			base = 10;
  801adc:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801ae1:	eb 46                	jmp    801b29 <vprintfmt+0x405>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ae3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae6:	e8 c5 fb ff ff       	call   8016b0 <getuint>
			base = 8;
  801aeb:	bf 08 00 00 00       	mov    $0x8,%edi
			goto number;
  801af0:	eb 37                	jmp    801b29 <vprintfmt+0x405>

		// pointer
		case 'p':
			putch('0', putdat);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	53                   	push   %ebx
  801af6:	6a 30                	push   $0x30
  801af8:	ff d6                	call   *%esi
			putch('x', putdat);
  801afa:	83 c4 08             	add    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	6a 78                	push   $0x78
  801b00:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b02:	8b 45 14             	mov    0x14(%ebp),%eax
  801b05:	8d 50 04             	lea    0x4(%eax),%edx
  801b08:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b0b:	8b 00                	mov    (%eax),%eax
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b12:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b15:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  801b1a:	eb 0d                	jmp    801b29 <vprintfmt+0x405>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b1c:	8d 45 14             	lea    0x14(%ebp),%eax
  801b1f:	e8 8c fb ff ff       	call   8016b0 <getuint>
			base = 16;
  801b24:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801b30:	51                   	push   %ecx
  801b31:	ff 75 e0             	pushl  -0x20(%ebp)
  801b34:	57                   	push   %edi
  801b35:	52                   	push   %edx
  801b36:	50                   	push   %eax
  801b37:	89 da                	mov    %ebx,%edx
  801b39:	89 f0                	mov    %esi,%eax
  801b3b:	e8 c1 fa ff ff       	call   801601 <printnum>
			break;
  801b40:	83 c4 20             	add    $0x20,%esp
  801b43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b46:	e9 ff fb ff ff       	jmp    80174a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b4b:	83 ec 08             	sub    $0x8,%esp
  801b4e:	53                   	push   %ebx
  801b4f:	51                   	push   %ecx
  801b50:	ff d6                	call   *%esi
			break;
  801b52:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b58:	e9 ed fb ff ff       	jmp    80174a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	53                   	push   %ebx
  801b61:	6a 25                	push   $0x25
  801b63:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	eb 03                	jmp    801b6d <vprintfmt+0x449>
  801b6a:	83 ef 01             	sub    $0x1,%edi
  801b6d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b71:	75 f7                	jne    801b6a <vprintfmt+0x446>
  801b73:	e9 d2 fb ff ff       	jmp    80174a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 18             	sub    $0x18,%esp
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b8f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b93:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	74 26                	je     801bc7 <vsnprintf+0x47>
  801ba1:	85 d2                	test   %edx,%edx
  801ba3:	7e 22                	jle    801bc7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ba5:	ff 75 14             	pushl  0x14(%ebp)
  801ba8:	ff 75 10             	pushl  0x10(%ebp)
  801bab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	68 ea 16 80 00       	push   $0x8016ea
  801bb4:	e8 6b fb ff ff       	call   801724 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bbc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	eb 05                	jmp    801bcc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bd4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bd7:	50                   	push   %eax
  801bd8:	ff 75 10             	pushl  0x10(%ebp)
  801bdb:	ff 75 0c             	pushl  0xc(%ebp)
  801bde:	ff 75 08             	pushl  0x8(%ebp)
  801be1:	e8 9a ff ff ff       	call   801b80 <vsnprintf>
	va_end(ap);

	return rc;
}
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// send pg=UTOP if it is zero
	if(pg == NULL)  
  801bf6:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801bf8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bfd:	0f 44 c2             	cmove  %edx,%eax

	// the call fails
	int32_t e;
	if((e = sys_ipc_recv(pg)) < 0) {
  801c00:	83 ec 0c             	sub    $0xc,%esp
  801c03:	50                   	push   %eax
  801c04:	e8 98 eb ff ff       	call   8007a1 <sys_ipc_recv>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	79 16                	jns    801c26 <ipc_recv+0x3e>
		if(from_env_store != NULL)
  801c10:	85 f6                	test   %esi,%esi
  801c12:	74 06                	je     801c1a <ipc_recv+0x32>
			*from_env_store = 0;
  801c14:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c1a:	85 db                	test   %ebx,%ebx
  801c1c:	74 2c                	je     801c4a <ipc_recv+0x62>
			*perm_store = 0;
  801c1e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c24:	eb 24                	jmp    801c4a <ipc_recv+0x62>

		return e;
	}

	if(from_env_store != NULL)
  801c26:	85 f6                	test   %esi,%esi
  801c28:	74 0a                	je     801c34 <ipc_recv+0x4c>
		*from_env_store = thisenv->env_ipc_from;
  801c2a:	a1 08 40 80 00       	mov    0x804008,%eax
  801c2f:	8b 40 74             	mov    0x74(%eax),%eax
  801c32:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c34:	85 db                	test   %ebx,%ebx
  801c36:	74 0a                	je     801c42 <ipc_recv+0x5a>
		*perm_store = thisenv->env_ipc_perm;
  801c38:	a1 08 40 80 00       	mov    0x804008,%eax
  801c3d:	8b 40 78             	mov    0x78(%eax),%eax
  801c40:	89 03                	mov    %eax,(%ebx)

	return thisenv->env_ipc_value;
  801c42:	a1 08 40 80 00       	mov    0x804008,%eax
  801c47:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	57                   	push   %edi
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801c63:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801c65:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801c6a:	0f 44 d8             	cmove  %eax,%ebx
  801c6d:	eb 1e                	jmp    801c8d <ipc_send+0x3c>

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		// panic on any error other than -E_IPC_NOT_RECV
		if(e != -E_IPC_NOT_RECV)
  801c6f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c72:	74 14                	je     801c88 <ipc_send+0x37>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");
  801c74:	83 ec 04             	sub    $0x4,%esp
  801c77:	68 40 24 80 00       	push   $0x802440
  801c7c:	6a 44                	push   $0x44
  801c7e:	68 6c 24 80 00       	push   $0x80246c
  801c83:	e8 8c f8 ff ff       	call   801514 <_panic>

		// yield the CPU to let other environment run
		sys_yield();
  801c88:	e8 45 e9 ff ff       	call   8005d2 <sys_yield>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)UTOP;

	int32_t e;
	while((e = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801c8d:	ff 75 14             	pushl  0x14(%ebp)
  801c90:	53                   	push   %ebx
  801c91:	56                   	push   %esi
  801c92:	57                   	push   %edi
  801c93:	e8 e6 ea ff ff       	call   80077e <sys_ipc_try_send>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 d0                	js     801c6f <ipc_send+0x1e>
			panic("ipc_send: error other than -E_IPC_NOT_RECV");

		// yield the CPU to let other environment run
		sys_yield();
	}
}
  801c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cb5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cbb:	8b 52 50             	mov    0x50(%edx),%edx
  801cbe:	39 ca                	cmp    %ecx,%edx
  801cc0:	75 0d                	jne    801ccf <ipc_find_env+0x28>
			return envs[i].env_id;
  801cc2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cc5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cca:	8b 40 48             	mov    0x48(%eax),%eax
  801ccd:	eb 0f                	jmp    801cde <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ccf:	83 c0 01             	add    $0x1,%eax
  801cd2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd7:	75 d9                	jne    801cb2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	c1 e8 16             	shr    $0x16,%eax
  801ceb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cf7:	f6 c1 01             	test   $0x1,%cl
  801cfa:	74 1d                	je     801d19 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cfc:	c1 ea 0c             	shr    $0xc,%edx
  801cff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d06:	f6 c2 01             	test   $0x1,%dl
  801d09:	74 0e                	je     801d19 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d0b:	c1 ea 0c             	shr    $0xc,%edx
  801d0e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d15:	ef 
  801d16:	0f b7 c0             	movzwl %ax,%eax
}
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    
  801d1b:	66 90                	xchg   %ax,%ax
  801d1d:	66 90                	xchg   %ax,%ax
  801d1f:	90                   	nop

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
