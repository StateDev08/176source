# Build cskill/skill into static and shared libraries
.DEFAULT_GOAL := all

include ../../cgame/Rules.make

INC += -I$(PROJROOT)/cnet/common

SRC = skill.cpp playerwrapper.cpp skillfilter.cpp skillwrapper.cpp
OBJ = $(SRC:.cpp=.o)

.PHONY: all clean

all: libskill.a

libskill.a: $(OBJ)
	$(AR) $@ $(OBJ)

%.o: %.cpp
	$(CPP) -fPIC -c $(INC) $< -o $@

clean:
	rm -f $(OBJ) libskill.a
