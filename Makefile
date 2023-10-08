AS = as
LD = ld
ASFLAGS = -gstabs -32
LDFLAGS = -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc

TARGET = main

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(LD) $(LDFLAGS) $^ -o $@

$(TARGET).o: $(TARGET).s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(TARGET).o $(TARGET)
