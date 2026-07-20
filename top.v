module top(
    input wire clk, 
    input wire rst_n_btn,
    input wire uart_rx,
    output wire uart_tx,
    output wire[5:0] led_n
);
    wire rst_n = rst_n_btn;
    localparam CLK_FREQ = 27_000_000;
    localparam BAUD_RATE = 115200;

    wire[7:0] rx_data;
    wire rx_valid;
    wire tx_busy;
    reg[7:0] tx_data;
    reg tx_start;

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )rx_1(
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rx),
        .data_in(rx_data),
        .valid(rx_valid)
    );

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )tx_1(
        .clk(clk),
        .rst_n(rst_n),
        .start(tx_start),
        .data(tx_data),
        .tx(uart_tx),
        .busy(tx_busy)
    );
    always @(posedge clk) begin
        if(!rst_n) begin
            tx_start <= 1'b0;
            tx_data <= 8'd0;
        end else begin
            tx_start <= 1'b0;
            if(rx_valid && !tx_busy) begin
                tx_data <= rx_data;
                tx_start <= 1'b1;
            end
        end
    end
    reg led_rx = 0, led_start = 0;
    always @(posedge clk) begin
        if(rx_valid) led_rx <= ~led_rx;
        if(tx_start) led_start <= ~led_start;
    end
    assign led_n = ~{2'b00, tx_busy, 1'b1, led_start, led_rx};
endmodule