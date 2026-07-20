`timescale 1ns/1ps

module uart_tx_tb;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg[7:0] data = 8'h55; // U = 01010101
    wire tx;
    wire busy;
    uart_tx #( 
        .CLK_FREQ(1000),
        .BAUD_RATE(100)
    )dut( 
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data(data),
        .tx(tx),
        .busy(busy)
    );

    always #5 clk = ~clk;
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);
        #20 rst = 0;
        #20 start = 1;
        #10 start = 0;
        #2000 $finish;
    end
endmodule