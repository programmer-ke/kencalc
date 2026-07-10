.PHONY: clean
YFLAGS = -d 	# create y.tab.h
OBJS = kencalc.o init.o math.o symbol.o code.o

kencalc: $(OBJS)
	cc $(OBJS) -lm -o kencalc

kencalc.o code.o init.o symbol.o: kencalc.h

code.o init.o symbol.o: x.tab.h

x.tab.h: y.tab.h
	-cmp -s x.tab.h y.tab.h || cp y.tab.h x.tab.h

pr: kencalc.y kencalc.h code.c init.c math.c symbol.c
	@pr $?
	@touch pr

clean:
	rm -rf $(OBJS) [xy].tab.[ch]
