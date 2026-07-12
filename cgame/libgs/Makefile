# Build cgame/libgs object tree from network daemon static libraries
# Used by cgame/gs/CMLIB
.DEFAULT_GOAL := all

include ../Rules.make

.PHONY: all clean

all:
	@echo "Extracting network libraries into cgame/libgs/..."
	@mkdir -p io gs db sk log common
	@rm -f io/*.o gs/*.o db/*.o log/*.o sk/*.o common/*.o
	@cd io  && $(ARX) $(PROJROOT)/cnet/io/libgsio.a
	@cd gs  && $(ARX) $(PROJROOT)/cnet/gamed/libgsPro2.a
	@cd db  && $(ARX) $(PROJROOT)/cnet/gdbclient/libdbCli.a
	@cd log && $(ARX) $(PROJROOT)/cnet/logclient/liblogCli.a
	@cp $(PROJROOT)/cnet/common/*_m.o common/
	@if [ -f "$(PROJROOT)/cskill/skill/libskill.a" ]; then \
		cd sk  && $(ARX) $(PROJROOT)/cskill/skill/libskill.a; \
	else \
		echo "  WARNING: cskill/skill/libskill.a not found, sk/ will be empty"; \
	fi
	@echo "cgame/libgs ready."

clean:
	@rm -f io/*.o gs/*.o db/*.o sk/*.o log/*.o common/*.o
