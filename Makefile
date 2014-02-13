RUSTC ?= rustc
RUSTFLAGS ?= -O --cfg ndebug

# Allow out-of-tree builds by searching dependencies based on the directory of this Makefile
SRCDIR := $(dir $(lastword $(MAKEFILE_LIST)))
VPATH := $(SRCDIR)

LIBFUSE := $(shell $(RUSTC) --crate-file-name $(SRCDIR)src/lib.rs)
EXAMPLES := $(patsubst $(SRCDIR)examples/%.rs,fuse_example_%,$(wildcard $(SRCDIR)examples/*.rs))

all: $(LIBFUSE)

check: libfuse_test
	./libfuse_test

examples: $(EXAMPLES)

clean:
	rm -f $(LIBFUSE) libfuse.d libfuse_test libfuse_test.d $(EXAMPLES)

.PHONY: all check examples clean

$(LIBFUSE): src/lib.rs
	$(RUSTC) $(RUSTFLAGS) --dep-info libfuse.d $<

libfuse_test: src/lib.rs
	$(RUSTC) $(RUSTFLAGS) --dep-info libfuse_test.d --test -o $@ $<

$(EXAMPLES): fuse_example_%: examples/%.rs $(LIBFUSE)
	$(RUSTC) $(RUSTFLAGS) -L . -C prefer-dynamic -o $@ $<

-include libfuse.d
-include libfuse_test.d
