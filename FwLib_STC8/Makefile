####### MCU #######

## STC8G1K17A
MCU                 ?= STC8G1K17
MCU_IRAM            ?= 256
MCU_XRAM            ?= 1024
MCU_CODE_SIZE       ?= 17408 


##### Project #####

PROJECT             ?= app
# The path for generated files
BUILD_DIR           = build

TOOCHAIN_PREFIX     ?= C:/Program Files/SDCC/bin/

# C source folders
USER_CDIRS          := user
# C source single files
USER_CFILES         :=
USER_INCLUDES       := user


## STC8G1K17 33.1776MHz Configuration (Perfect 115200 Baud / Max Speed)
LIB_FLAGS           := __CONF_FOSC=33177600UL \
                       __CONF_MCU_MODEL=MCU_MODEL_STC8G1K17 \
                       __CONF_CLKDIV=0x00 \
                       __CONF_IRCBAND=0x01 \
                       __CONF_VRTRIM=0x00 \
                       __CONF_IRTRIM=0x00 \
                       __CONF_LIRTRIM=0x00

# ## STC8G1K17 27.6480MHz Configuration (Perfect 115200 Baud)
# LIB_FLAGS           := __CONF_FOSC=27648000UL \
#                        __CONF_MCU_MODEL=MCU_MODEL_STC8G1K17 \
#                        __CONF_CLKDIV=0x00 \
#                        __CONF_IRCBAND=0x01 \
#                        __CONF_VRTRIM=0x00 \
#                        __CONF_IRTRIM=0x00 \
#                        __CONF_LIRTRIM=0x00

# ## STC8G1K17 22.1184MHz Configuration (Perfect 115200 Baud / Safe Speed)
# LIB_FLAGS           := __CONF_FOSC=22118400UL \
#                        __CONF_MCU_MODEL=MCU_MODEL_STC8G1K17 \
#                        __CONF_CLKDIV=0x00 \
#                        __CONF_IRCBAND=0x00 \
#                        __CONF_VRTRIM=0x00 \
#                        __CONF_IRTRIM=0x00 \
#                        __CONF_LIRTRIM=0x00

# ## STC8G1K17 18.4320MHz Configuration (Perfect 115200 Baud)
# LIB_FLAGS           := __CONF_FOSC=18432000UL \
#                        __CONF_MCU_MODEL=MCU_MODEL_STC8G1K17 \
#                        __CONF_CLKDIV=0x00 \
#                        __CONF_IRCBAND=0x00 \
#                        __CONF_VRTRIM=0x00 \
#                        __CONF_IRTRIM=0x00 \
#                        __CONF_LIRTRIM=0x00

# ## STC8G1K17 11.0592MHz Configuration (Perfect 115200 Baud / Legacy Standard)
# LIB_FLAGS           := __CONF_FOSC=11059200UL \
#                        __CONF_MCU_MODEL=MCU_MODEL_STC8G1K17 \
#                        __CONF_CLKDIV=0x00 \
#                        __CONF_IRCBAND=0x00 \
#                        __CONF_VRTRIM=0x00 \
#                        __CONF_IRTRIM=0x00 \
#                        __CONF_LIRTRIM=0x00

# ## STC8G1K17 5.5296MHz Configuration (Perfect 115200 Baud / Battery Saving)
# LIB_FLAGS           := __CONF_FOSC=5529600UL \
#                        __CONF_MCU_MODEL=MCU_MODEL_STC8G1K17 \
#                        __CONF_CLKDIV=0x00 \
#                        __CONF_IRCBAND=0x00 \
#                        __CONF_VRTRIM=0x00 \
#                        __CONF_IRTRIM=0x00 \
#                        __CONF_LIRTRIM=0x00


include ./rules.mk