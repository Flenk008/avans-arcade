CC := gcc
LD := gcc

LFLAGS += -lSDL2

ifeq ($(HOST),Msys)
SHARED_FLAGS += -I/mingw64/include
endif

DESKTOP_SRCS += ppusim/sim.c \
								ppusim/mem.c \
								ppusim/pixel.c \
								ppusim/work.c

