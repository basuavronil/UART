`timescale 1ns / 1ps

module UART_tb;

reg clk;
reg rstn;
reg tx_start;
reg [7:0] data_in;

wire txd;
wire tx_done;

// DUT instantiation

UART DUT (
    .clk(clk),
    .rstn(rstn),
    .tx_start(tx_start),
    .data_in(data_in),
    .txd(txd),
    .tx_done(tx_done)
);

// Clock generation (20 ns period)
always #10 clk = ~clk;


// Task to send a byte
task send_byte(input [7:0] data);
begin
    @(posedge clk);
    data_in  = data;
    tx_start = 1;

    @(posedge clk);
    tx_start = 0;

    // wait for transmission to complete
    wait(tx_done == 1);

    @(posedge clk);
end
endtask


initial begin

    // Initial values
    clk = 0;
    rstn = 0;
    tx_start = 0;
    data_in = 8'h00;

    // Apply reset
    #50;
    rstn = 1;

    // Wait a few cycles
    repeat(5) @(posedge clk);

    // Send bytes
    send_byte(8'hAA);
    send_byte(8'h55);
    send_byte(8'h99);
    send_byte(8'hF0);

    // wait before finish
    #500;
    $finish;

end

endmodule
