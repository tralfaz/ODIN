PKGCFG = "/opt/homebrew/bin/pkg-config"

GTK_CFLAGS = $(shell $(PKGCFG) --cflags gtk4)
GTK_LIBS   = $(shell $(PKGCFG) --libs gtk4)


TARGETS = fontdlg


%.o : %.c
	gcc -o $@ -c $(GTK_CFLAGS) $^

ALL :: $(TARGETS)

fontdlg: fontdlg.odin
	odin build $< -file -out:$@


.PHONY: clean

clean:
	rm $(TARGETS)

