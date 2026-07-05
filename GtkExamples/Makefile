PKGCFG = "/opt/homebrew/bin/pkg-config"
GTKBLD = "/opt/homebrew/bin/gtk4-builder-tool"

GTK_CFLAGS = $(shell $(PKGCFG) --cflags gtk4)
GTK_LIBS   = $(shell $(PKGCFG) --libs gtk4)

GTK_COLL = -collection:gtk_libs=/opt/homebrew/lib

TARGETS = hello-adwaita hello-gio hello-gtk hello-glib hello-pango \
          hello-cairo hello-gmodule snake hello-gdk-pixbuf hello-gobject


ALL :: $(TARGETS)

hello-adwaita: hello-adwaita.odin 
	odin build $< -file $(GTK_COLL)

hello-gio: hello-gio.odin 
	odin build $< -file $(GTK_COLL)

hello-gtk: hello-gtk.odin 
	odin build $< -file $(GTK_COLL)

hello-glib: hello-glib.odin 
	odin build $< -file $(GTK_COLL)

hello-pango: hello-pango.odin 
	odin build $< -file $(GTK_COLL)

hello-cairo: hello-cairo.odin 
	odin build $< -file $(GTK_COLL)

hello-gmodule: hello-gmodule.odin 
	odin build $< -file $(GTK_COLL)

snake: snake.odin 
	odin build $< -file $(GTK_COLL)

hello-gdk-pixbuf: hello-gdk-pixbuf.odin 
	odin build $< -file $(GTK_COLL)

hello-gobject: hello-gobject.odin 
	odin build $< -file $(GTK_COLL)


.PHONY: clean test

clean:
	rm -f $(TARGETS) $(OBJS)

