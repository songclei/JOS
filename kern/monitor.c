// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>

/* lab2 challenge */
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "", mon_backtrace},
	{ "showmappings", "Display page table information", mon_showmappings},
	{ "changeperm", "Change the permission bit", mon_changeperm},
	{ "dumpmem", "Display content of given memory range", mon_dumpmem}
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t ebp = read_ebp();
	while(ebp != 0)
	{
		cprintf("  ebp %08x", ebp);
		uint32_t addr = ebp + 4;
		uint32_t eip = *(int *)addr;
		cprintf("  eip %08x", eip);
		cprintf("  args");
		for(int i = 0; i < 5; ++i)
		{
			addr = addr + 4;
			cprintf(" %08x", *(int *)addr);
		}
		cprintf("\n");
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
		char funcname[100];
		int l = 0;
		for(; info.eip_fn_name[l] != ':'; ++l)
			funcname[l] = info.eip_fn_name[l];
		funcname[l] = '\0';
		cprintf("         %s:%d: %s+%d\n", info.eip_file, info.eip_line, funcname, eip-info.eip_fn_addr);
		ebp = *(int *)ebp;
	}
	return 0;
}


/* lab2 challenge */
int 
mon_showmappings(int argc, char **argv, struct Trapframe *tf) 
{
	extern pde_t *kern_pgdir;

	uintptr_t begin_addr = ROUNDDOWN(charhex_to_dec(argv[1]), PGSIZE);
	uintptr_t end_addr = ROUNDDOWN(charhex_to_dec(argv[2]), PGSIZE);


	for(uintptr_t addr = begin_addr; addr <= end_addr; addr += PGSIZE) {
		pte_t *page_table_entry = pgdir_walk(kern_pgdir, (void *)addr, 0);

		if(page_table_entry == NULL) 
			cprintf("va: 0x%08x    not been mapped\n", addr);
		else if(!(*page_table_entry & PTE_P))
			cprintf("va: 0x%08x    not been mapped\n", addr);
		else {
			cprintf("va: 0x%08x    pa: 0x%08x    perm: ", addr, *page_table_entry & 0xFFFFF000);	
			if((*page_table_entry & PTE_U) && !(*page_table_entry & PTE_W))
				cprintf("kernel R, usr R\n");
			else if((*page_table_entry & PTE_U) && (*page_table_entry & PTE_W))
				cprintf("kernel RW, usr RW\n");
			else if(!(*page_table_entry & PTE_U) && !(*page_table_entry & PTE_W))
				cprintf("kernel R, user none\n");
			else 
				cprintf("kernel RW, usr none\n");
		}
	}

	return 0;
}


int
mon_changeperm(int argc, char **argv, struct Trapframe *tf)
{
	extern pde_t *kern_pgdir;

	int perm = 0;
	switch(argv[3][4]) {
		case 'P':
			if(argv[3][5] == '\0') {
				cprintf("cannot change PTE_P permission bit\n");
				return 0;
			}
			else if(argv[3][5] == 'W')
				perm = PTE_PWT;
			else if(argv[3][5] == 'C')
				perm = PTE_PCD;
			else if(argv[3][5] == 'S')
				perm = PTE_PS;
			break;
		case 'W':
			perm = PTE_W;
			break;
		case 'U':
			perm = PTE_U;
			break;
		case 'A':
			perm = PTE_A;
			break;
		case 'D':
			perm = PTE_D;
			break;
		case 'G':
			perm = PTE_G;
			break;
		default:
			return 0;
	}

	uintptr_t addr = charhex_to_dec(argv[2]);
	pte_t *page_table_entry = pgdir_walk(kern_pgdir, (void *)addr, 0);

	if(page_table_entry == NULL)
		return 0;
	else {
		if(strcmp(argv[1], "set") == 0)
			*page_table_entry = *page_table_entry | perm;
		else if(strcmp(argv[1], "clean") == 0)
			*page_table_entry = *page_table_entry & (~perm);
	}
	
	return 0;
}

int 
mon_dumpmem(int argc, char **argv, struct Trapframe *tf)
{
	extern pde_t *kern_pgdir;

	if(strcmp(argv[1], "v") == 0) {
		uintptr_t begin_addr = charhex_to_dec(argv[2]);
		uintptr_t end_addr = charhex_to_dec(argv[3]);

		for(size_t page = ROUNDDOWN(begin_addr, PGSIZE); page <= ROUNDDOWN(end_addr, PGSIZE); ++page) {
			pte_t *page_table_entry = pgdir_walk(kern_pgdir, (void *)page, 0);

			if(page_table_entry == NULL || !(*page_table_entry & PTE_P)) {
				cprintf("virtual page 0x%x has not been mapped", page);
				continue;
			}

			uintptr_t begin_page = page > begin_addr ? page : begin_addr;
			uintptr_t end_page = page + PGSIZE - 1 < end_addr ? page + PGSIZE - 1 : end_addr ;
			for(uintptr_t addr = begin_page; addr <= end_page; addr += 8) {
				cprintf("0x%08x: ", addr);
				for(uintptr_t i = addr; i < addr + 8; ++i) {
					cprintf("%02x ", *(uint8_t *)i);
					if(i == end_page)
						break;
				}
				cprintf("\n");
			}
		}
	}
	else if(strcmp(argv[1], "p") == 0) {
		physaddr_t begin_addr = charhex_to_dec(argv[2]);
		physaddr_t end_addr = charhex_to_dec(argv[3]);

		for(uintptr_t addr = begin_addr + KERNBASE; addr <= end_addr + KERNBASE; addr += 8) {
			cprintf("0x%08x: ", addr - KERNBASE);
			for(uintptr_t i = addr; i < addr + 8; ++i) {
				cprintf("%02x ", *(uint8_t *)i);
				if(i == end_addr + KERNBASE)
					break;
			}
			cprintf("\n");
		}
	}

	return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;

	/* lab3 challenge */
	if(strcmp(argv[0], "step") == 0 || strcmp(argv[0], "s") == 0)
		return -1;
	
	else if(strcmp(argv[0], "run") == 0 || strcmp(argv[0], "r") == 0) {
		tf->tf_eflags &= (~0x100);
		return -1;
	}
	/* lab3 challenge */		

	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{

	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL) {
		/* lab3 challenge */
		tf->tf_eflags |= 0x100;
		/* lab3 challenge */
		print_trapframe(tf);
	}

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0) 
				break;
	}
}
