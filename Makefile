# Shadow Warrior Makefile for GNU Make

# Create Makefile.user yourself to provide your own overrides
# for configurable values
-include Makefile.user

##
##
## CONFIGURABLE OPTIONS
##
##

# Debugging options
RELEASE ?= 1

# DirectX SDK location
DXROOT ?= $(HOME)/sdks/directx/dx7

# Engine source code path
EROOT ?= ../jfbuild.git

# JMACT library source path
MACTROOT ?= ../jfmact.git

# JFAudioLib source path
AUDIOLIBROOT ?= ../jfaudiolib.git

# Engine options
SUPERBUILD ?= 1
POLYMOST ?= 1
USE_OPENGL ?= 1
DYNAMIC_OPENGL ?= 1
NOASM ?= 0
LINKED_GTK ?= 0


##
##
## HERE BE DRAGONS
##
##

# build locations
SRC=source
RSRC=rsrc
OBJ=obj
EINC=$(EROOT)/include
ELIB=$(EROOT)
INC=$(SRC)
o=o

ifneq (0,$(RELEASE))
  # debugging disabled
  debug=-fomit-frame-pointer -O2
else
  # debugging enabled
  debug=-ggdb -O0
endif

include $(AUDIOLIBROOT)/Makefile.shared

CC=gcc
CXX=g++
OURCFLAGS=$(debug) -W -Wall -Wimplicit -Wno-char-subscripts -Wno-unused \
	-fno-pic -funsigned-char -fno-strict-aliasing -DNO_GCC_BUILTINS \
	-I$(INC) -I$(EINC) -I$(MACTROOT) -I$(AUDIOLIBROOT)/include
OURCXXFLAGS=-fno-exceptions -fno-rtti
LIBS=-lm
GAMELIBS=
NASMFLAGS=-s #-g
EXESUFFIX=

JMACTOBJ=$(OBJ)/util_lib.$o \
	$(OBJ)/file_lib.$o \
	$(OBJ)/control.$o \
	$(OBJ)/keyboard.$o \
	$(OBJ)/mouse.$o \
	$(OBJ)/mathutil.$o \
	$(OBJ)/scriplib.$o \
	$(OBJ)/animlib.$o

GAMEOBJS= \
	$(OBJ)/actor.$o \
	$(OBJ)/ai.$o \
	$(OBJ)/anim.$o \
	$(OBJ)/border.$o \
	$(OBJ)/break.$o \
	$(OBJ)/bunny.$o \
	$(OBJ)/cache.$o \
	$(OBJ)/cheats.$o \
	$(OBJ)/colormap.$o \
	$(OBJ)/config.$o \
	$(OBJ)/console.$o \
	$(OBJ)/coolg.$o \
	$(OBJ)/coolie.$o \
	$(OBJ)/copysect.$o \
	$(OBJ)/demo.$o \
	$(OBJ)/draw.$o \
	$(OBJ)/eel.$o \
	$(OBJ)/game.$o \
	$(OBJ)/girlninj.$o \
	$(OBJ)/goro.$o \
	$(OBJ)/hornet.$o \
	$(OBJ)/interp.$o \
	$(OBJ)/interpsh.$o \
	$(OBJ)/inv.$o \
	$(OBJ)/jplayer.$o \
	$(OBJ)/jsector.$o \
	$(OBJ)/jweapon.$o \
	$(OBJ)/lava.$o \
	$(OBJ)/light.$o \
	$(OBJ)/mclip.$o \
	$(OBJ)/mdastr.$o \
	$(OBJ)/menus.$o \
	$(OBJ)/miscactr.$o \
	$(OBJ)/morph.$o \
	$(OBJ)/net.$o \
	$(OBJ)/ninja.$o \
	$(OBJ)/panel.$o \
	$(OBJ)/player.$o \
	$(OBJ)/predict.$o \
	$(OBJ)/quake.$o \
	$(OBJ)/ripper.$o \
	$(OBJ)/ripper2.$o \
	$(OBJ)/rooms.$o \
	$(OBJ)/rotator.$o \
	$(OBJ)/rts.$o \
	$(OBJ)/save.$o \
	$(OBJ)/scrip2.$o \
	$(OBJ)/sector.$o \
	$(OBJ)/serp.$o \
	$(OBJ)/setup.$o \
	$(OBJ)/skel.$o \
	$(OBJ)/skull.$o \
	$(OBJ)/slidor.$o \
	$(OBJ)/sounds.$o \
	$(OBJ)/spike.$o \
	$(OBJ)/sprite.$o \
	$(OBJ)/sumo.$o \
	$(OBJ)/swconfig.$o \
	$(OBJ)/sync.$o \
	$(OBJ)/text.$o \
	$(OBJ)/track.$o \
	$(OBJ)/vator.$o \
	$(OBJ)/vis.$o \
	$(OBJ)/wallmove.$o \
	$(OBJ)/warp.$o \
	$(OBJ)/weapon.$o \
	$(OBJ)/zilla.$o \
	$(OBJ)/zombie.$o \
	$(OBJ)/saveable.$o \
	$(JMACTOBJ)

EDITOROBJS=$(OBJ)/jnstub.$o \
	$(OBJ)/brooms.$o \
	$(OBJ)/bldscript.$o \
	$(OBJ)/jbhlp.$o \
	$(OBJ)/colormap.$o

include $(EROOT)/Makefile.shared

ifeq ($(PLATFORM),LINUX)
	NASMFLAGS+= -f elf
	GAMELIBS+= $(JFAUDIOLIB_LDFLAGS)
endif
ifeq ($(PLATFORM),WINDOWS)
	OURCFLAGS+= -DUNDERSCORES -I$(DXROOT)/include
	NASMFLAGS+= -DUNDERSCORES -f win32
	GAMEOBJS+= $(OBJ)/gameres.$o $(OBJ)/startdlg.$o $(OBJ)/startwin.game.$o
	EDITOROBJS+= $(OBJ)/buildres.$o
	GAMELIBS+= -ldsound \
	       $(AUDIOLIBROOT)/third-party/mingw32/lib/libvorbisfile.a \
	       $(AUDIOLIBROOT)/third-party/mingw32/lib/libvorbis.a \
	       $(AUDIOLIBROOT)/third-party/mingw32/lib/libogg.a
endif

ifeq ($(RENDERTYPE),SDL)
	OURCFLAGS+= $(subst -Dmain=SDL_main,,$(shell sdl-config --cflags))

	ifeq (1,$(HAVE_GTK2))
		OURCFLAGS+= -DHAVE_GTK2 $(shell pkg-config --cflags gtk+-2.0)
		GAMEOBJS+= $(OBJ)/game_banner.$o $(OBJ)/startdlg.$o $(OBJ)/startgtk.game.$o
		EDITOROBJS+= $(OBJ)/editor_banner.$o
	endif

	GAMEOBJS+= $(OBJ)/game_icon.$o
	EDITOROBJS+= $(OBJ)/build_icon.$o
endif

OURCFLAGS+= $(BUILDCFLAGS)

.PHONY: clean all engine $(ELIB)/$(ENGINELIB) $(ELIB)/$(EDITORLIB) $(AUDIOLIBROOT)/$(JFAUDIOLIB)

# TARGETS

# Invoking Make from the terminal in OSX just chains the build on to xcode
ifeq ($(PLATFORM),DARWIN)
ifeq ($(RELEASE),0)
style=Debug
else
style=Release
endif
.PHONY: alldarwin
alldarwin:
	cd osx && xcodebuild -target All -buildstyle $(style)
endif

all: sw$(EXESUFFIX) build$(EXESUFFIX)

sw$(EXESUFFIX): $(GAMEOBJS) $(ELIB)/$(ENGINELIB) $(AUDIOLIBROOT)/$(JFAUDIOLIB)
	$(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -o $@ $^ $(LIBS) $(GAMELIBS) -Wl,-Map=$@.map
	
build$(EXESUFFIX): $(EDITOROBJS) $(ELIB)/$(EDITORLIB) $(ELIB)/$(ENGINELIB)
	$(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -o $@ $^ $(LIBS) -Wl,-Map=$@.map

include Makefile.deps

.PHONY: enginelib editorlib
enginelib editorlib:
	$(MAKE) -C $(EROOT) \
		SUPERBUILD=$(SUPERBUILD) POLYMOST=$(POLYMOST) \
		USE_OPENGL=$(USE_OPENGL) DYNAMIC_OPENGL=$(DYNAMIC_OPENGL) \
		NOASM=$(NOASM) RELEASE=$(RELEASE) $@

$(ELIB)/$(ENGINELIB): enginelib
$(ELIB)/$(EDITORLIB): editorlib
$(AUDIOLIBROOT)/$(JAUDIOLIB):
	$(MAKE) -C $(AUDIOLIBROOT) RELEASE=$(RELEASE)

# RULES
$(OBJ)/%.$o: $(SRC)/%.nasm
	nasm $(NASMFLAGS) $< -o $@

$(OBJ)/%.$o: $(SRC)/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1
$(OBJ)/%.$o: $(SRC)/%.cpp
	$(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1
$(OBJ)/%.$o: $(SRC)/jmact/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1

$(OBJ)/%.$o: $(SRC)/misc/%.rc
	windres -i $< -o $@ --include-dir=$(EINC) --include-dir=$(SRC)

$(OBJ)/%.$o: $(SRC)/util/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1

$(OBJ)/%.$o: $(RSRC)/%.c
	$(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@ 2>&1

$(OBJ)/game_banner.$o: $(RSRC)/game_banner.c
$(OBJ)/editor_banner.$o: $(RSRC)/editor_banner.c
$(RSRC)/game_banner.c: $(RSRC)/game.bmp
	echo "#include <gdk-pixbuf/gdk-pixdata.h>" > $@
	gdk-pixbuf-csource --extern --struct --raw --name=startbanner_pixdata $^ | sed 's/load_inc//' >> $@
$(RSRC)/editor_banner.c: $(RSRC)/build.bmp
	echo "#include <gdk-pixbuf/gdk-pixdata.h>" > $@
	gdk-pixbuf-csource --extern --struct --raw --name=startbanner_pixdata $^ | sed 's/load_inc//' >> $@

# PHONIES	
clean:
ifeq ($(PLATFORM),DARWIN)
	cd osx && xcodebuild -target All clean
else
	-rm -f $(OBJ)/*
	$(MAKE) -C $(EROOT) clean
	$(MAKE) -C $(AUDIOLIBROOT) clean
endif
	
veryclean: clean
ifeq ($(PLATFORM),DARWIN)
else
	-rm -f sw$(EXESUFFIX) build$(EXESUFFIX) core*
	$(MAKE) -C $(EROOT) veryclean
endif

ifeq ($(PLATFORM),WINDOWS)
.PHONY: datainst
datainst:
	cd datainst && $(MAKE) GAME=SW
endif
