`timescale 1ns / 1ps

module rx_with_fifo #(parameter clk_freq=100,baud_rate=2,depth=4,width=8)
(output [width-1:0] fifo_data_out,
output rts,frame_error,parity_error,empty,
input rx,clk,rx_request,fifo_reset,read_next
);

wire full;
wire [width-1:0] fifo_data_in;
wire rx_done;
reg write=1'b0;

always @(posedge clk) begin
    if(write) write<=0;
    else if(rx_done) write<=1;
end

uart_rx #(clk_freq,baud_rate) rx1(
    .rts(rts),
    .frame_error(frame_error),
    .parity_error(parity_error),
    .rx_done(rx_done),
    .data(fifo_data_in),
    .rx(rx),
    .clk(clk),
    .full(full),
    .rx_request(rx_request)
);

sync_fifo #(depth,width) rx_fifo(
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
