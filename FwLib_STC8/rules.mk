# 'make V=1' will show command details
V              ?= 0
ifeq ($(V),0)
Q              := @
NULL           := 2>/dev/null
endif

# If running on Windows, force GNU Make to use the Windows Command Prompt (cmd.exe)
SHELL          := cmd.exe

CC             = $(TOOCHAIN_PREFIX)sdcc
AR             = $(TOOCHAIN_PREFIX)sdar
PACKIHX        = $(TOOCHAIN_PREFIX)packihx
SDRANLIB       = $(TOOCHAIN_PREFIX)sdranlib
LD             = $(PREFIX)ld
OBJCOPY        = $(PREFIX)objcopy
TOP            = .
BDIR           = $(TOP)/$(BUILD_DIR)

# Library folders
LIB_CDIR            := src
LIB_INCLUDE         := include

# WINDOWS CHANGE: Replaced native Linux 'find' command with native Windows 'dir /b /s' syntax 
# and switched unix path forward slashes (/) to backslashes (\) for Windows shell operations
LIB_CSOURCES   := $(subst /,\,$(shell dir /b /s "$(TOP)\$(LIB_CDIR)\*.c"))
LIB_RELS       = $(LIB_CSOURCES:$(TOP)/%.c=$(BDIR)/%.rel)
LIB_FWLIB      := fw_stc8.lib
LIB_INCFLAGS   := -I$(TOP)/$(LIB_INCLUDE)

# WINDOWS CHANGE: Rewrote loop to dynamically look up C files in Windows command prompt 
# across your defined user subdirectories.
USER_CSOURCES  := $(foreach dir, $(USER_CDIRS), $(subst /,\,$(shell dir /b "$(TOP)\$(dir)\*.c" 2>nul)))
USER_CSOURCES  += $(addprefix $(TOP)/, $(USER_CFILES))
USER_RELS      = $(USER_CSOURCES:$(TOP)/%.c=$(BDIR)/%.rel)
USER_INCFLAGS  := $(addprefix -I$(TOP)/, $(USER_INCLUDES))

# Arch and target specified flags: --model-large
ARCH_FLAGS    := -mmcs51 --model-large
DEBUG_FLAGS   ?= 
# c flags
OPT           ?= --opt-code-size
CSTD          ?= --std-sdcc99
CC_CFLAGS    += $(ARCH_FLAGS) $(DEBUG_FLAGS) $(OPT) $(CSTD) $(addprefix -D, $(LIB_FLAGS))
LD_CFLAGS    += $(ARCH_FLAGS) $(DEBUG_FLAGS) $(OPT) \
				--iram-size $(MCU_IRAM) --xram-size $(MCU_XRAM) --code-size $(MCU_CODE_SIZE) --out-fmt-ihx

TGT_AFLAGS    += -rcs

.PHONY: all clean flash

all: $(BDIR)/$(PROJECT).hex
	@type $(subst /,\,$(BDIR)/$(PROJECT).mem)

lib: $(BDIR)/$(LIB_FWLIB)

$(BDIR)/$(LIB_CDIR)/%.rel: $(TOP)/$(LIB_CDIR)/%.c
	@echo   CC $<
	$(Q)if not exist "$(subst /,\,$(dir $@))" mkdir "$(subst /,\,$(dir $@))"
	$(Q)$(CC) $< -c $(CC_CFLAGS) $(LIB_INCFLAGS) -o $@

$(BDIR)/%.rel: $(TOP)/%.c
	@echo   CC $<
	$(Q)if not exist "$(subst /,\,$(dir $@))" mkdir "$(subst /,\,$(dir $@))"
	$(Q)$(CC) $< -c $(CC_CFLAGS) $(USER_INCFLAGS) $(LIB_INCFLAGS) -o $@

# Generate static library
$(BDIR)/$(LIB_FWLIB): $(LIB_RELS)
	@echo   AR $@
	$(Q)$(AR) $(TGT_AFLAGS) $@ $^
	$(Q)$(SDRANLIB) $@

$(BDIR)/$(PROJECT).hex: $(USER_RELS) $(BDIR)/$(LIB_FWLIB)
	@echo   CC $@
	$(Q)$(CC) $(LD_CFLAGS) $^ $(BDIR)/$(LIB_FWLIB) -o $@

# WINDOWS CHANGE: Replaced Unix 'rm -rf' with Windows native directory removal tools
clean:
	$(Q)if exist "$(subst /,\,$(BDIR))" rmdir /s /q "$(subst /,\,$(BDIR))"

# WINDOWS CHANGE: Replaced linux stc8prog executable with native STC-ISP executable syntax 
# (assuming stc-isp.exe command line or python-based stcgal is on your Windows PATH)
flash:
	stcgal -p COM3 -b 115200 $(BDIR)/$(PROJECT).hex
