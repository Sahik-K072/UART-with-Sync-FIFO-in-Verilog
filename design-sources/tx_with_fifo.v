`timescale 1ns / 1ps

module tx_with_fifo #(parameter clk_freq=100,baud_rate=2,depth=4,width=8)
(output tx,full,
input cts,clk,tx_request,write,fifo_reset,
input [width-1:0] fifo_data_in
);

wire empty;
wire [width-1:0] fifo_data_out;
wire tx_done;
reg read_next=0;

always @(posedge clk) begin
    if(read_next) read_next<=0;
    else if(tx_done) read_next<=1;
end

uart_tx #(clk_freq,baud_rate) tx1(
    .tx(tx),
    .tx_done(tx_done),
    .cts(cts),
    .clk(clk),
    .tx_request(tx_request),
    .empty(empty),
    .data(fifo_data_out)
);

sync_fifo #(depth,width) tx_fifo(
    .data_out(fifo_data_out),
    .full(full),
    .empty(empty),
    .data_in(fifo_data_in),
    .write(write),
    .read_next(read_next),
    .clk(clk),
    .reset(fifo_reset)
);

endmodule
