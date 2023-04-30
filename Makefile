CXX = g++
CXXFLAGS = -g -Og $(shell pkg-config --cflags liblo alsa) -Wall -Wpointer-arith
LDFLAGS = $(shell pkg-config --libs liblo alsa)
SOURCES = $(wildcard src/core/*.cpp) src/seq192.cpp
BIN = seq192
BIN_JT = seq192-jt
BIN_NOUI = seq192-noui
BIN_NOUI_JT = seq192-noui-jt

PREFIX = /usr/local


USE_GTK=1
ifeq ($(USE_GTK), 1)
	CXXFLAGS += $(shell pkg-config --cflags gtkmm-3.0) -DGTKMM_DISABLE_DEPRECATED -D USE_GTK
	LDFLAGS += $(shell pkg-config --libs gtkmm-3.0)
	SOURCES += $(wildcard src/gui/*.cpp)
endif

USE_JACK=1
ifeq ($(USE_JACK), 1)
	CXXFLAGS += $(shell pkg-config --cflags jack) -D USE_JACK
	LDFLAGS += $(shell pkg-config --libs jack)
endif

OBJ = $(SOURCES:.cpp=.o)
DEPENDS := $(SOURCES:.cpp=.d)

.PHONY: all clean #install install_all uninstall

all: src/$(BIN)

bold := $(shell tput bold)
sgr0 := $(shell tput sgr0)

src/$(BIN): $(OBJ)
	@printf '\n$(bold)Linking$(sgr0)\n'
	$(CXX) -o $@ $^ $(LDFLAGS)
	@printf '\n'

%.o: %.cpp Makefile
	@printf '\n$(bold)Compilation from $< to $@ $(sgr0)\n'
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

-include $(DEPENDS)

manual:
	ronn man/MANUAL.md --manual='User manual' --roff
	mv man/MANUAL.1 man/seq192.1

manual-html:
	ronn man/MANUAL.md --manual='User manual' --html

clean:
	@rm -f $(OBJ) $(DEPENDS) src/$(BIN)

install: src/$(BIN)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/pixmaps
	mkdir -p $(DESTDIR)$(PREFIX)/share/applications
	mkdir -p $(DESTDIR)$(PREFIX)/share/man/man1
	cp $< $(DESTDIR)$(PREFIX)/bin/$(BIN)
	cp src/xpm/seq192_32.xpm $(DESTDIR)$(PREFIX)/share/pixmaps/seq192.xpm
	cp desktop/seq192.desktop $(DESTDIR)$(PREFIX)/share/applications/seq192.desktop
	cp man/seq192.1 $(DESTDIR)$(PREFIX)/share/man/man1/seq192.1

install_nsm: src/$(BIN)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/pixmaps
	mkdir -p $(DESTDIR)$(PREFIX)/share/applications
	mkdir -p $(DESTDIR)$(PREFIX)/share/man/man1
	cp $< $(DESTDIR)$(PREFIX)/bin/$(BIN)
	cp src/xpm/seq192_32.xpm $(DESTDIR)$(PREFIX)/share/pixmaps/seq192.xpm
	cp desktop/seq192.desktop $(DESTDIR)$(PREFIX)/share/applications/seq192.desktop
	cp desktop/seq192-jt.desktop $(DESTDIR)$(PREFIX)/share/applications/seq192-jt.desktop
	#cp desktop/seq192-noui-jt.desktop $(DESTDIR)$(PREFIX)/share/applications/seq192-noui-jt.desktop
	#cp desktop/seq192-noui.desktop $(DESTDIR)$(PREFIX)/share/applications/seq192-noui.desktop
	cp man/seq192.1 $(DESTDIR)$(PREFIX)/share/man/man1/seq192.1
	ln -sf $(DESTDIR)$(PREFIX)/bin/$(BIN) $(DESTDIR)$(PREFIX)/bin/$(BIN_JT) 
	#ln -sf $(DESTDIR)$(PREFIX)/bin/$(BIN) $(DESTDIR)$(PREFIX)/bin/$(BIN_NOUI_JT) 
	#ln -sf $(DESTDIR)$(PREFIX)/bin/$(BIN) $(DESTDIR)$(PREFIX)/bin/$(BIN_NOUI) 

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN)
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN_JT)
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN_NOUI_JT)
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN_NOUI)
	rm -f $(DESTDIR)$(PREFIX)/share/pixmaps/seq192.xpm
	rm -f $(DESTDIR)$(PREFIX)/share/applications/seq192.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/seq192-jt.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/seq192-noui-jt.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/seq192-noui.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/seq192.1
