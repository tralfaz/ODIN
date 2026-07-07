LIB_COLL = -collection:gtk_libs=/opt/homebrew/lib


TARGETS = graph1

ALL :: $(TARGETS)

graph1 : graph1.odin
	odin build $< -file $(LIB_COLL)


.PHONY: clean

clean:
	rm -f $(TARGETS) $(OBJS)

