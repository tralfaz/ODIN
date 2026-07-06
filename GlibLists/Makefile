GTK_COLL = -collection:gtk_libs=/opt/homebrew/lib

TARGETS = dlist slist


ALL :: $(TARGETS)

dlist: dlist.odin 
	odin build $< -file $(GTK_COLL)

slist: slist.odin 
	odin build $< -file $(GTK_COLL)


.PHONY: clean

clean:
	rm -f $(TARGETS) $(OBJS)

