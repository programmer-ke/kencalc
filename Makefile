YFLAGS = -d 	# create y.tab.h
OBJS = kencalc.o init.o math.o symbol.o

kencalc: $(OBJS)
	cc $(OBJS) -lm -o kencalc

kencalc.o: kencalc.h

init.o symbol.o: kencalc.h y.tab.h

pr:
	@pr kencalc.y kencalc.h init.c math.c symbol.c Makefile

clean:
	rm -rf $(OBJS) y.tab.[ch]
