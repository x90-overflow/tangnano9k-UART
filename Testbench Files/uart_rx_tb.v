`timescale 1ns/1ps
module uart_rx_tb;
    localparam CLK_FREQ = 100;
    localparam BAUD_RATE = 10;
    localparam CYCLE_PERBIT = CLK_FREQ/BAUD_RATE; 

    reg clk = 0;
    reg rst_n = 0;
    reg rx = 1'b1;
    wire[7:0] data_in;
    wire valid;

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .data_in(data_in),
        .valid(valid)
    );

    always #5 clk = ~clk;

    localparam BIT_S = CYCLE_PERBIT * 10;

    task send_byte(input[7:0] b);
        integer i;
        begin
            rx = 1'b0; #(BIT_S);
            for(i = 0; i < 8; i = i + 1) begin
                rx = b[i]; #(BIT_S);
            end
            rx = 1'b1; #(BIT_S);
        end
    endtask
    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);
        #20 rst_n = 1'b1;
        #40;
        send_byte(8'h55); // U
        #(BIT_S);
        send_byte(8'hA3);
        #(BIT_S * 5);
        $finish;
    end
    always @(posedge clk) begin
        if(valid) begin
            $display("RX: 0x%02h at time %0t", data_in, $time);
        end
    end
endmodule


