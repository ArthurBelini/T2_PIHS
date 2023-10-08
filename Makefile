AS = as
LD = ld
ASFLAGS = -gstabs -32
LDFLAGS = -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc

TARGET = main

all: $(TARGET)

$(TARGET): main.o
	$(LD) $(LDFLAGS) $^ -o $@

main.o: main.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(TARGET) $(TARGET).o
