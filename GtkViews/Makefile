LIB_COLL = -collection:gtk_libs=/opt/homebrew/lib


TARGETS = column adwcolumn

ALL :: $(TARGETS)

column : column.odin
	odin build $< -file $(LIB_COLL)

adwcolumn : adwcolumn.odin
	odin build $< -file $(LIB_COLL)


.PHONY: clean

clean:
	rm -f $(TARGETS) $(OBJS)

