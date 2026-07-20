PROJECT = uart
TOP = top
DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C
BOARD = tangnano9k
SRC = top.v uart_tx.v uart_rx.v
CST = uart.cst
TB = uart_loop_tb.v
SIM_SRCS = $(TB) uart_tx.v uart_rx.v 

all: $(TOP).fs
$(TOP).json: $(SRC)
	yosys -p "read_verilog $(SRC); synth_gowin -top $(TOP) -json $@"
$(TOP)_pnr.json: $(TOP).json $(CST)
	nextpnr-himbaechel \
		--json $(TOP).json \
		--write $@ \
		--device $(DEVICE) \
		--vopt family=$(FAMILY) \
		--vopt cst=$(CST)
$(TOP).fs: $(TOP)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<
flash: $(TOP).fs
	openFPGALoader -b $(BOARD) -f $<
sim: $(SIM_SRCS)
	iverilog -o sim $(SIM_SRCS)
	vvp sim
clean:
	rm -f $(TOP).json $(TOP)_pnr.json $(TOP).fs
.PHONY: all flash prog clean