########################################################################
####################### Makefile Template ##############################
########################################################################

# Compiler settings - Can be customized.
CC = gcc
FLEX = flex
BISON = bison
# Add project include directory so headers under src/include are found
CXXFLAGS = -std=c11 -Wall -I$(SRCDIR)/include
LDFLAGS = 

# Makefile settings - Can be customized.
APPNAME = calculator
SRCDIR = src
OBJDIR = obj

############## Do not change anything from here downwards! #############
SRC = $(wildcard $(SRCDIR)/*$(EXT))
OBJ = $(SRC:$(SRCDIR)/%$(EXT)=$(OBJDIR)/%.o)

# UNIX-based OS variables & settings
RM = rm
DELOBJ = $(OBJ)
# Windows OS variables & settings
DEL = del
EXE = .exe

########################################################################
####################### Targets beginning here #########################
########################################################################

all: $(APPNAME)

# Builds the app
$(APPNAME):
	@echo "Compiling..."
	$(BISON) -d -o calcset.tab.c ${SRCDIR}/calcset.y
	$(FLEX) -o lex.yy.c ${SRCDIR}/calcset.l
	$(CC) calcset.tab.c lex.yy.c $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

# Creates the dependecy rules
%.d: $(SRCDIR)/%$(EXT)
	@$(CPP) $(CFLAGS) $< -MM -MT $(@:%.d=$(OBJDIR)/%.o) >$@

# Includes all .h files
-include $(DEP)

# Building rule for .o files and its .c/.cpp in combination with all .h
$(OBJDIR)/%.o: $(SRCDIR)/%$(EXT)
	$(CC) $(CXXFLAGS) -o $@ -c $<

#################### Cleaning rules for Windows OS #####################
# Cleans complete project
.PHONY: clean re
fclean:
	$(DEL) $(WDELOBJ) $(APPNAME)$(EXE)
	del /f /q calcset.tab.c calcset.tab.h lex.yy.c 2>nul || true

re:
	$(MAKE) clean
	$(MAKE) all