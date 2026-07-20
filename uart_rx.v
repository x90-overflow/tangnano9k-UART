`timescale 1ns/1ps

module uart_rx #( 
    parameter CLK_FREQ = 27_000_000,
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire rst_n,
    input wire rx,
    output reg[7:0] data_in,
    output reg valid
);
    localparam CYCLE_PERBIT = CLK_FREQ/BAUD_RATE;
    localparam HALF_BIT = CYCLE_PERBIT/2;

    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    reg[1:0] state = IDLE;
    reg[15:0] clk_count = 0;
    reg[2:0] bit_index = 0;
    reg[7:0] rx_shift = 0;

    // double flop synchroniser to avoid metastability.
    reg cdc1, cdc2;
    always @(posedge clk) begin
        cdc1 <= rx;
        cdc2 <= cdc1;
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            valid <= 1'b0;
            data_in <= 8'd0;
        end else begin
            valid <= 1'b0;
            case(state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    if(cdc2 == 1'b0) begin
                        state <= START;
                    end
                end
                START: begin
                    if(clk_count == HALF_BIT - 1) begin
                        if(cdc2 == 1'b0) begin
                            clk_count <= 0;
                            state <= DATA;
                        end else begin
                            state <= IDLE; // checking half bit to confirm if its a glitch or data.
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                DATA: begin
                    if(clk_count == CYCLE_PERBIT - 1) begin
                        clk_count <= 0;
                        rx_shift <= {cdc2, rx_shift[7:1]};
                        if(bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                STOP: begin
                    if(clk_count == CYCLE_PERBIT - 1) begin
                        data_in <= rx_shift;
                        valid <= 1'b1;
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule


                        



