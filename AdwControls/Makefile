GTK_COLL = -collection:gtk_libs=/opt/homebrew/lib

TARGETS = buttons dropdown linkbtn spinbtn toggles \
          chkradio entries scale switch


ALL :: $(TARGETS)

buttons: buttons.odin 
	odin build $< -file $(GTK_COLL)

dropdown: dropdown.odin 
	odin build $< -file $(GTK_COLL)

linkbtn: linkbtn.odin 
	odin build $< -file $(GTK_COLL)

spinbtn: spinbtn.odin 
	odin build $< -file $(GTK_COLL)

toggles: toggles.odin 
	odin build $< -file $(GTK_COLL)

chkradio: chkradio.odin 
	odin build $< -file $(GTK_COLL)

entries: entries.odin 
	odin build $< -file $(GTK_COLL)

scale: scale.odin 
	odin build $< -file $(GTK_COLL)

switch: switch.odin 
	odin build $< -file $(GTK_COLL)


.PHONY: clean test

clean:
	rm -f $(TARGETS) $(OBJS)

