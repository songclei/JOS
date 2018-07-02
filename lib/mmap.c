#ifdef CHALLENGE5
#include <inc/lib.h>
#include <inc/string.h>


void *find_va_region(void *start, size_t length);

//
// page fault handler for mmap region
// ps: this page fault handler needs to be compatible with page fault,
// 	   so we need to copy the handler in fork.c
//
static void
mmap_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// first we need to check the page dirctory entry
	// if there is a page mmapped then the pde should have PTE_MMAP
	pde_t pde = uvpd[PDX(addr)]; 
	if(!(pde & PTE_P) && !(pde & PTE_MMAP))
		panic("page fault");

	pte_t pte = uvpt[PGNUM(addr)];
	// if the pte do not have PTE_P, there are two possibilities:
	// 1. it is a page mmaped, then we should read from disk
	// 2. the va does not map to any area, simply panic
	if(!(pte & PTE_P)) {
		if(pte & PTE_MMAP) {
			// block number is stored in page table entry
			int blockno = pte >> PGSHIFT;

			// if it is not a shared page, then we should allocate
			// a new page and read to this new physical area
			if(!(pte & PTE_SHARE)) {
				if((r = sys_page_alloc(0, addr, (pte&PTE_SYSCALL)|PTE_P)) < 0)
					panic("mmap_pgfault: %e", r);
			}

			devfile_load(pte&PTE_SHARE, (void *)((int)addr&(~0xFFF)), blockno, pte&PTE_SYSCALL);
		}
		else {
			panic("page fault");
		}
	}
	// the rest part is in order to be compatible with copy-on-write
	else if(!(err & FEC_WR) || !(pte & PTE_COW))
		panic("page fault");
	else {
		if((r = sys_page_alloc(0, (void *)PFTEMP, (pte&PTE_SYSCALL)&(~PTE_COW))) < 0)
			panic("mmap_pgfault: %e", r);

		memcpy((void *)PFTEMP, (void *)(ROUNDDOWN(addr, PGSIZE)), PGSIZE);

		if((r = sys_page_map(0, (void *)PFTEMP, 0, (void *)
			(ROUNDDOWN(addr, PGSIZE)), (pte&PTE_SYSCALL)&(~PTE_COW))) < 0)
			panic("mmap_pgfault: %e", r);

		if((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
			panic("mmap_pgfault: %e", r);
	}
}



//
// map a file region into current environment's virtual space.
// the file's content does not really in the memory untill the environment
// access to it(and load the page from disk to the memory using the page 
// fault handler). Return the start address
// 
// parameters:
//	 start -- indicate user's preferrence. The real start address does not 
//		   necessarily be the address given by the caller
//   length -- the size of the mapped region. It may not be page-aligned, so
//			we should to round it up to PGSIZE
//	 prot -- PROT_READ: the page can be read
//			 PROT_WRITE: the page can be write
// 	 flags -- MAP_SHARED: modify to this region should reflect in the disk
//						and can be seen by other environment
//			  MAP_PRIVATE: modify to the page cannot be seen in the disk or
//						by other environment
//		* flags should contain one and only one of above
//	 fdnum -- file descriptor number
//	 offset -- offset from the start of the file
//
// 
// if a page is mmaped, then the page table entry should look like:
// 
//	31 					  11 		  0
//	-----------------------------------
//	| block number in disk |  flags	  |
//  -----------------------------------
//	
// flags should include : PTE_MMAP | PTE_U [| PTE_W | PTE_SHARE]
//

void *
mmap(void *start, size_t length, int prot, int flags, int fdnum, int offset)
{
	int r;
	int perm = 0;
	struct Fd *fd;

	set_pgfault_handler(mmap_pgfault);

	// use the fdnum to find *struct Fd*
	if((r = fd_lookup(fdnum, &fd)) < 0)
		return NULL;

	// addr is the real start
	void *addr;
	addr = find_va_region(start, length);
	if(addr >= (void *)UTOP)
		panic("mmap: cannot find virtual region");

	// round to pgsize
	offset = ROUNDUP(offset, PGSIZE);
	length = ROUNDUP(length, PGSIZE);

	if(prot & PROT_READ)
		perm |= PTE_U;
	if(prot & PROT_WRITE)
		perm |= PTE_U | PTE_W;

	// flags can either be shared or private
	if(flags & MAP_SHARED) {
		if(flags & MAP_PRIVATE)
			panic("mmap: flags should be PTE_SHARE or PTE_PRIVATE");
		perm |= PTE_SHARE;
	}
	else if(!(flags & MAP_PRIVATE))
		panic("mmap: flags should be PTE_SHARE or PTE_PRIVATE");

	// mark it as a mmap page
	perm |= PTE_MMAP;

	if((r = devfile_mmap(addr, length, fd->fd_file.id, perm, offset)) < 0)
		return NULL;

	// return the start address of the mmapped region
	return addr;
}



// 
// find a region of successive virtual address which have not
// been mapped, *start* is a preferrence but not a must  
//
void *
find_va_region(void *start, size_t length) 
{
	start = ROUNDDOWN(start, PGSIZE);
	length = ROUNDUP(length, PGSIZE);

	size_t cnt_len = 0;
	void *addr = start;

	// try addr *start*
	while(cnt_len < length) {
		pde_t pde = uvpd[PDX(addr)];
		// the entire pages in the page table are empty
		// and it is not a mmapped page
		if(!(pde & PTE_P) && !(pde & PTE_MMAP)) {
			cnt_len += PGSIZE * NPTENTRIES;
			addr += PGSIZE * NPTENTRIES;
		}
		else {
			pte_t pte = uvpt[PGNUM(addr)];

			// if the page has been mapped, then it is no longer successive
			if(pte & PTE_P || pte & PTE_MMAP) 
				break;
			// this page is empty, try the next
			else {
				cnt_len += PGSIZE;
				addr += PGSIZE;
			}
		}
	}

	// if we find enough empty space 
	if(cnt_len >= length)
		return start;

	// if addr *start* is not suitable, search the virtual space 
	for(start = 0; start < (void *)UTOP; start += PGSIZE) {
		cnt_len = 0;
		addr = start;

		while(cnt_len < length) {
			pde_t pde = uvpt[PDX(addr)];

			if(!(pde & PTE_P) && !(pde & PTE_MMAP)) {
				cnt_len += PGSIZE * NPTENTRIES;
				addr += PGSIZE * NPTENTRIES;
			}
			else {
				pte_t pte = uvpt[PGNUM(addr)];

				if(pte & PTE_P || pte & PTE_MMAP) 
					break;
				else {
					cnt_len += PGSIZE;
					addr += PGSIZE;
				}
			}
		}

		if(cnt_len >= length)
			return start;

		start = addr;
	}

	// if we cannot find a suitable address, we return a 
	// invalid addr to notify 
	return (void *)UTOP;
}
#endif