#include <inc/lib.h>
#ifdef CHALLENGE5
void
umain(int argc, char **argv)
{
	struct Fd *fd;
	char *pmmap;
	int r;

	if((r = open("/newmotd", O_RDONLY)) < 0)
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
		panic("open did not fill struct Fd correctly\n");
	
	pmmap = (char *)mmap(0,	PGSIZE, PROT_WRITE, MAP_SHARED, fd2num(fd), 0);



	pmmap[0] = '1';
	cprintf("%c\n", pmmap[10]);

	close(r);
}
#else
void 
umain(int argc, char **argv)
{
	
}
#endif