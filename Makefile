CC    ?= gcc
RM    ?= rm -rf
STRIP ?= strip

EPDKVER ?= $(shell git describe --dirty)

CFLAGS += -std=c99 -pedantic -Wall -O2 -DEPDKVER=\"$(EPDKVER)\" $(ECFLAGS)

all: easypdkprog

UNAME_S := $(shell uname -s)

ifeq ($(OSTYPE),msys)
    UNAME_S := Windows
endif

ifeq ($(OS),Windows_NT)
    EXE_EXTENSION := .exe
endif

ifneq ($(UNAME_S),Linux)
    ARGPSA    = lib/argp-standalone-1.3
    ARGPSALIB = $(ARGPSA)/libargp.a
    CFLAGS  += -I$(ARGPSA)
endif

DEP=  $(wildcard *.h)
SRC=  serialcom.c fpdkutil.c fpdkcom.c fpdkicdata.c fpdkihex8.c fpdkiccalib.c fpdkicserial.c fpdkicscramble.c fpdkpdkformat.c
OBJ=  $(subst .c,.o,$(SRC))

easypdkprog: $(ARGPSALIB) $(DEP) $(OBJ) easypdkprog.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o easypdkprog easypdkprog.c $(OBJ) $(LIBS) $(ARGPSALIB)
	$(STRIP) easypdkprog$(EXE_EXTENSION)

easypdkdac: $(DEP) $(OBJ) easypdkdac.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o easypdkdac easypdkdac.c $(OBJ) $(LIBS)

$(ARGPSALIB):
	cd $(ARGPSA) && sh configure CFLAGS='-w -Os $(ECFLAGS)' $(EHOST)
	$(MAKE) -C $(ARGPSA)

clean:
	$(RM) $(OBJ)
	$(RM) easypdkprog$(EXE_EXTENSION)
	$(RM) easypdkdac$(EXE_EXTENSION)

distclean: clean
ifneq ($(UNAME_S),Linux)
	-$(MAKE) distclean -C $(ARGPSA)
endif
