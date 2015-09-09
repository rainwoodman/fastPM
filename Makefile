
CC=mpicc
OPTIMIZE = -O0 -g
CPPFLAGS += -I depends/install/include
LDFLAGS += -L depends/install/lib

CPPFLAGS += -I lua
LDFLAGS += -L lua

SOURCES = fastpm.c pmpfft.c pmghosts.c pmpaint.c pmstore.c pm2lpt.c \
		readparams.c msg.c power.c pmsteps.c pmtimer.c pmio-runpb.c

PFFTLIB = depends/install/lib/libpfft.a
fastpm: $(SOURCES:%.c=.objs/%.o) $(PFFTLIB)
	$(CC) $(OPTIMIZE) -o fastpm $(SOURCES:%.c=.objs/%.o) \
			$(LDFLAGS) -llua -lgsl \
			-lpfft -lfftw3_mpi -lfftw3 \
			-lpfftf -lfftw3f_mpi -lfftw3f \
			-lm 

$(PFFTLIB): depends/install_pfft.sh
	# FIXME: some configure flags may not work. 
	# shall we adopt autotools?
	MPICC=$(CC) sh depends/install_pfft.sh $(PWD)/depends/install
	
-include $(SOURCES:%.c=.deps/%.d)

.objs/%.o : %.c
	@if ! [ -d .objs ]; then mkdir .objs; fi
	$(CC) $(OPTIMIZE) -c $(CPPFLAGS) -o $@ $<

.deps/%.d : %.c
	@if ! [ -d .deps ]; then mkdir .deps; fi
	@if $(CC) -M $(CPPFLAGS) -o - $< > $@.tmp ; then \
		(echo -n .objs/; cat $@.tmp ;) > $@ ; \
	fi;
	@rm $@.tmp

clean:
	rm -rf .objs
	rm -rf .deps
