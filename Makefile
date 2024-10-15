CC := clang
SRCDIR := src
BUILDDIR := build
INCDIR := include
TARGET := bin/run
SRCEXT := c
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
CFLAGS := 
LIB := -L lib
LIBDIR := $(shell find $(LIB) -type d -depth 1)
LIBINCDIR := $(shell find $(LIB) -type d -name include -depth 2)
LIBINCDIRSTAR := $(addsuffix /*, $(LIBINCDIR))
LIBINC := $(addprefix -I,$(LIBINCDIR))

LIBSRCDIR := $(shell find $(LIB) -type d -name src -depth 2)
LIBSRCDIRSTAR := $(addsuffix /*, $(LIBSRCDIR))
LIBBUILDDIR := $(subst $(SRCDIR),$(BUILDDIR)/%.o,$(LIBSRCDIR))
LIBSOURCES := $(shell find $(LIBSRCDIR) -type f -name *.$(SRCEXT))
LIBOBJECTS := $(subst $(SRCDIR),$(BUILDDIR),$(LIBSOURCES:.$(SRCEXT)=.o))

INC := -I include $(LIBINC)
OBJECTS := $(OBJECTS) $(LIBOBJECTS)

EMPTY:=
LIBMAKETARGET := $(EMPTY)

LINTER := clang-tidy
FORMATTER := clang-format

$(TARGET): override LIBMAKETARGET := $(EMPTY)
$(TARGET): $(LIBDIR) $(OBJECTS)
	@echo " Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $(OBJECTS) -o $(TARGET) $(LIB) -O3

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@echo " Building..."
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

# Run linter on source directories
lint: gencompilejson
	@echo " $(LINTER) --config-file=.clang-tidy $(SRCDIR)/* $(INCDIR)/* $(LIBINCDIRSTAR) $(LIBSRCDIRSTAR) -- $(CFLAGS) $(INC)";
	@$(LINTER) --config-file=.clang-tidy $(SRCDIR)/* $(INCDIR)/* $(LIBINCDIRSTAR) $(LIBSRCDIRSTAR) -- $(CFLAGS) $(INC)

gencompilejson:
	@compiledb -o build/compile_commands.json make
# Run formatter on source directories
format:
	@echo "$(FORMATTER) -style=file -i $(SRCDIR)/* $(INCDIR)/* $(LIBINCDIRSTAR) $(LIBSRCDIRSTAR)"
	@$(FORMATTER) -style=file -i $(SRCDIR)/* $(INCDIR)/* $(LIBINCDIRSTAR) $(LIBSRCDIRSTAR)

#format:
#	find . -iname '*.h' -o -iname '*.c' | xargs clang-format -i

#tidy:
#	find . -iname '*.h' -o -iname '*.c' | xargs clang-tidy

.PHONY: clean
.PHONY: $(LIBDIR)