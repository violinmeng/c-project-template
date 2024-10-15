CC := clang
SRCDIR := src
BUILDDIR := build
TARGET := bin/run
SRCEXT := c
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
CFLAGS := 
LIB := -L lib
LIBDIR := $(shell find $(LIB) -type d -depth 1)
LIBINC := $(shell find $(LIB) -type d -name include -depth 2)
LIBINC := $(addprefix -I,$(LIBINC))

LIBSOURCESDIR := $(shell find $(LIB) -type d -name src -depth 2)
LIBBUILDDIR := $(subst $(SRCDIR),$(BUILDDIR)/%.o,$(LIBSOURCESDIR))
LIBSOURCES := $(shell find $(LIBSOURCESDIR) -type f -name *.$(SRCEXT))
LIBOBJECTS := $(subst $(SRCDIR),$(BUILDDIR),$(LIBSOURCES:.$(SRCEXT)=.o))

INC := -I include $(LIBINC)
OBJECTS := $(OBJECTS) $(LIBOBJECTS)

EMPTY:=
LIBMAKETARGET :=

$(TARGET): override LIBMAKETARGET :=$(EMPTY)
$(TARGET): $(LIBDIR) $(OBJECTS)
	@echo " Linking... $(OBJECTS)"
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $(OBJECTS) -o $(TARGET) $(LIB) -O3

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@echo " Building...$(LIBBUILDDIR)"
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $< -save-temps=obj -O3

#$(LIBBUILDDIR):
#	@echo " Building Libs... $@"
#	@$(MAKE) -C $(shell echo $@ | cut -d "/" -f 1,2)

$(LIBDIR):
	@echo " Clean Libs... $@"
	@$(MAKE) -C $@ $(LIBMAKETARGET)

clean: override LIBMAKETARGET := clean
clean: $(LIBDIR)
	@echo " Cleaning... $(LIBDIR)"; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGET)"; $(RM) -r $(BUILDDIR) $(TARGET)

# Tests
tester:
	$(CC) $(CFLAGS) test/tester.cpp $(INC) $(LIB) -o bin/tester

# Spikes
ticket:
	$(CC) $(CFLAGS) spikes/ticket.cpp $(INC) $(LIB) -o bin/ticket

.PHONY: clean
.PHONY: $(LIBDIR)