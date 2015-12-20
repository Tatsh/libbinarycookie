LIBNAME := libbinarycookies
LIBVERSION = 0.0.1
LIBVERSION_SHORT = 0
LIBEXTENSION := so
CFLAGS := -std=c11 -pedantic -Wall
CC := gcc
DESTDIR := ./out

OBJECTS = bincookie.o

all: $(LIBNAME).$(LIBEXTENSION)

dylib: $(OBJECTS)
	$(CC) -dynamiclib $(CFLAGS) -current_version $(LIBVERSION) -compatibility_version $(LIBVERSION) -fvisibility=hidden -o $(LIBNAME).A.dylib $(OBJECTS)

install: $(LIBNAME).$(LIBEXTENSION)
	mkdir -p $(DESTDIR)
	cp $(LIBNAME).$(LIBEXTENSION) $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT) $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION) $(DESTDIR)/lib
	cp bincookie.h $(DESTDIR)/include/binarycookies.h

$(LIBNAME).$(LIBEXTENSION): $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT)
	rm -f $(LIBNAME).$(LIBEXTENSION)
	ln -s $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT) $(LIBNAME).$(LIBEXTENSION)

$(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT): $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION)
	rm -f $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT)
	ln -s $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION) $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT)

$(LIBNAME).$(LIBEXTENSION).$(LIBVERSION): $(OBJECTS)
	$(CC) -shared -Wl,-soname,$(LIBNAME).$(LIBEXTENSION).$(LIBVERSION_SHORT) -o $(LIBNAME).$(LIBEXTENSION).$(LIBVERSION) $(OBJECTS)

$(OBJECTS):%.o:%.c
	$(CC) $(CFLAGS) -fvisibility=hidden -fPIC -c $< -o $@

dylib-examples: readbincook-dylib

examples: convert2netscape

convert2netscape: $(LIBNAME).$(LIBEXTENSION)
	$(CC) -I. $(CFLAGS) -L. -o convert2netscape examples/convert2netscape.c -lbinarycookies

convert2netscape-dylib: dylib
	$(CC) -I. $(CFLAGS) -L. -o convert2netscape examples/convert2netscape.c $(LIBNAME).A.dylib

clean:
	rm -f $(OBJECTS) $(LIBNAME).$(LIBEXTENSION)* $(LIBNAME).*.dylib readbincook $(DESTDIR)/$(LIBNAME).$(LIBEXTENSION)* $(DESTDIR)/$(LIBNAME).*.dylib
