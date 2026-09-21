# 'make V=1' will show command details
V              ?= 0
ifeq ($(V),0)
Q              := @
NULL           := 2>NUL
endif

# Ensure paths are safely quoted to protect against spaces in Windows folders
CC             = "$(TOOCHAIN_PREFIX)sdcc"
AR             = "$(TOOCHAIN_PREFIX)sdar"
PACKIHX        = "$(TOOCHAIN_PREFIX)packihx"
SDRANLIB       = "$(TOOCHAIN_PREFIX)sdranlib"
LD             = "$(PREFIX)ld"
OBJCOPY        = "$(PREFIX)objcopy"

TOP            = .
BDIR           = $(TOP)/$(BUILD_DIR)

# Library folders
LIB_CDIR            := src
LIB_INCLUDE         := include

# WINDOWS FIX: Scrape source files using native Make wildcard syntax instead of Linux find
LIB_CSOURCES   := $(wildcard $(TOP)/$(LIB_CDIR)/*.c)
LIB_RELS       = $(LIB_CSOURCES:$(TOP)/%.c=$(BDIR)/%.rel)
LIB_FWLIB      := fw_stc8.lib
LIB_INCFLAGS   := -I$(TOP)/$(LIB_INCLUDE)

# WINDOWS FIX: Scrape user source files using native Make wildcard syntax
USER_CSOURCES  := $(foreach dir, $(USER_CDIRS), $(wildcard $(TOP)/$(dir)/*.c))
USER_CSOURCES  += $(addprefix $(TOP)/, $(USER_CFILES))
USER_RELS      = $(USER_CSOURCES:$(TOP)/%.c=$(BDIR)/%.rel)
USER_INCFLAGS  := $(addprefix -I$(TOP)/, $(USER_INCLUDES))

# Arch and target specified flags: --model-large
ARCH_FLAGS    := -mmcs51 --model-large
DEBUG_FLAGS   ?= 
OPT           ?= --opt-code-size
CSTD          ?= --std-sdcc99
CC_CFLAGS    += $(ARCH_FLAGS) $(DEBUG_FLAGS) $(OPT) $(CSTD) $(addprefix -D, $(LIB_FLAGS))
LD_CFLAGS    += $(ARCH_FLAGS) $(DEBUG_FLAGS) $(OPT) \
				--iram-size $(MCU_IRAM) --xram-size $(MCU_XRAM) --code-size $(MCU_CODE_SIZE) --out-fmt-ihx

TGT_AFLAGS    += -rcs

.PHONY: all clean flash

all: $(BDIR)/$(PROJECT).hex
	$(Q)if exist $(BDIR)\$(PROJECT).mem type $(subst /,OutsideDir,$(BDIR)\$(PROJECT).mem) 2>NUL || cmd /c "echo Build Complete!"

lib: $(BDIR)/$(LIB_FWLIB)

# WINDOWS FIX: Handled folder creation and output logging using native cmd shells
$(BDIR)/$(LIB_CDIR)/%.rel: $(TOP)/$(LIB_CDIR)/%.c
	@cmd /c "echo   CC $<"
	$(Q)if not exist $(subst /,\\,$(dir $@)) mkdir $(subst /,\\,$(dir $@))
	$(Q)$(CC) $< -c $(CC_CFLAGS) $(LIB_INCFLAGS) -o $@

$(BDIR)/%.rel: $(TOP)/%.c
	@cmd /c "echo   CC $<"
	$(Q)if not exist $(subst /,\\,$(dir $@)) mkdir $(subst /,\\,$(dir $@))
	$(Q)$(CC) $< -c $(CC_CFLAGS) $(USER_INCFLAGS) $(LIB_INCFLAGS) -o $@

# Generate static library
$(BDIR)/$(LIB_FWLIB): $(LIB_RELS)
	@cmd /c "echo   AR $@"
	$(Q)$(AR) $(TGT_AFLAGS) $@ $^
	$(Q)$(SDRANLIB) $@

# WINDOWS FIX: Split compilation and hex packing rules cleanly to follow SDCC output syntax
$(BDIR)/$(PROJECT).ihx: $(USER_RELS) $(BDIR)/$(LIB_FWLIB)
	@cmd /c "echo   LD $@"
	$(Q)$(CC) $(LD_CFLAGS) $^ -o $@

$(BDIR)/$(PROJECT).hex: $(BDIR)/$(PROJECT).ihx
	@cmd /c "echo   PACKIHX $@"
	$(Q)$(PACKIHX) $< > $@

# WINDOWS FIX: Safe recursive file removal using standard Windows cmd scripts
clean:
	$(Q)if exist $(subst /,\\,$(BDIR)) rmdir /s /q $(subst /,\\,$(BDIR))

flash:
	@cmd /c "echo Flash rule skipped. Please flash the output hex using your STC-ISP Windows Utility."
