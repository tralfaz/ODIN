GTK_COLL = -collection:gtk_libs=/opt/homebrew/lib

TARGETS = memmng misc strings timers


ALL :: $(TARGETS)

memmng: memmng.odin 
	odin build $< -file $(GTK_COLL)

misc: misc.odin 
	odin build $< -file $(GTK_COLL)

strings: strings.odin 
	odin build $< -file $(GTK_COLL)

timers: timers.odin 
	odin build $< -file $(GTK_COLL)


.PHONY: clean

clean:
	rm -f $(TARGETS) $(OBJS)

