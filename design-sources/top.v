`timescale 1ns / 1ps

module top #(parameter clk_freq=100,baud_rate=2,fifo_depth=4,fifo_width=8)
(output tx_fifo_full,
        rx_fifo_empty,
        frame_error,
        parity_error,
output [fifo_width-1:0] data_out,
input [fifo_width-1:0] data_in,
input clk,
      tx_fifo_write,
      rx_fifo_read_next,
      tx_fifo_reset,
      rx_fifo_reset,
      tx_request,
      rx_request
);

wire data_line,status_line;

tx_with_fifo #(
    .clk_freq(clk_freq),
    .baud_rate(baud_rate),
    .depth(fifo_depth),
    .width(fifo_width)
    ) tx_port1 (
    .tx(data_line),
    .full(tx_fifo_full),
    .cts(status_line),
    .clk(clk),
    .tx_request(tx_request),
    .write(tx_fifo_write),
    .fifo_reset(tx_fifo_reset),
    .fifo_data_in(data_in)
);

rx_with_fifo #(
    .clk_freq(clk_freq),
    .baud_rate(baud_rate),
    .depth(fifo_depth),
    .width(fifo_width)
    ) rx_port1 (
    .fifo_data_out(data_out),
    .rts(status_line),
    .frame_error(frame_error),
    .parity_error(parity_error),
    .empty(rx_fifo_empty),
    .rx(data_line),
    .clk(clk),
    .rx_request(rx_request),
    .fifo_reset(rx_fifo_reset),
    .read_next(rx_fifo_read_next)
);


endmodule
