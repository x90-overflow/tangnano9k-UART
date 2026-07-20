`timescale 1ns/1ps
module uart_loop_tb;
    localparam CLK_FREQ = 100;
    localparam BAUD_RATE = 10;
    localparam CYCLE_PERBIT = CLK_FREQ/BAUD_RATE;

    reg clk = 0;
    reg rst_n = 0;
    reg[7:0] tx_data;
    reg tx_start;
    wire tx_busy;
    wire serial;
    wire [7:0] rx_data;
    wire rx_valid;

    always #5 clk = ~clk;
    localparam BIT_S = CYCLE_PERBIT * 10;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_dut (
        .clk(clk),
        .rst_n(rst_n),
        .data(tx_data),
        .start(tx_start),
        .busy(tx_busy),
        .tx(serial)
    );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_dut( 
        .clk(clk),
        .rst_n(rst_n),
        .data_in(rx_data),
        .valid(rx_valid),
        .rx(serial)
    );

    task send_data(input[7:0] b);
        begin
            @(posedge clk);#1;
            tx_data = b;
            tx_start = 1'b1;
            @(posedge clk);#1;
            tx_start = 1'b0;
            wait (tx_busy == 1'b1); 
            wait (tx_busy == 1'b0);
            #100;
        end
    endtask
    reg[7:0] expected;
    always @(posedge clk) begin
        if(rx_valid) begin
            if(rx_data === expected) begin
                $display("Correct: sent 0x%02h received 0x%02h", expected, rx_data);
            end else begin
                $display("Incorrect: sent 0x%02h received 0x%02h", expected, rx_data);
            end
        end
    end
    initial begin
        $dumpfile("uart_correspondence.vcd");
        $dumpvars(0, uart_loop_tb);

        tx_data = 8'd0; tx_start = 1'b0;
        #20 rst_n = 1'b1; 
        #40;
        expected = 8'h55; send_data(8'h55);
        expected = 8'hA3; send_data(8'hA3);
        #500;
        $finish;
    end
endmodule



