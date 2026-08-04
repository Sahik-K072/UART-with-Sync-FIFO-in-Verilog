`timescale 1ns / 1ps

module tb_top;

localparam real clk_freq=100;
localparam baud_rate=2,
           fifo_depth=4,
           fifo_width=8;

wire tx_fifo_full,
     rx_fifo_empty,
     frame_error,
     parity_error;
wire [fifo_width-1:0] data_out;
reg [fifo_width-1:0] data_in;
reg clk,
    tx_fifo_write,
    rx_fifo_read_next,
    tx_fifo_reset,
    rx_fifo_reset,
    tx_request,
    rx_request;

top top1(
    .tx_fifo_full(tx_fifo_full),
    .rx_fifo_empty(rx_fifo_empty),
    .frame_error(frame_error),
    .parity_error(parity_error),
    .data_out(data_out),
    .data_in(data_in),
    .clk(clk),
    .tx_fifo_write(tx_fifo_write),
    .rx_fifo_read_next(rx_fifo_read_next),
    .tx_fifo_reset(tx_fifo_reset),
    .rx_fifo_reset(rx_fifo_reset),
    .tx_request(tx_request),
    .rx_request(rx_request)
);

localparam real clk_delay=1/(clk_freq*2);
initial begin
    clk=0;
    forever #clk_delay clk=~clk;
end

reg [fifo_width-1:0] tx_data [fifo_depth-1:0];
integer i,j=0;
initial begin
    tx_fifo_reset=0;
    rx_fifo_reset=0;
    tx_fifo_write=0;
    rx_fifo_read_next=0;
    for(i=0;i<fifo_depth;i=i+1) begin
        tx_data[i]=$urandom;
    end
    
    #1 tx_fifo_reset=1;
       rx_fifo_reset=1;
    
    i=0;
    repeat(fifo_depth*2) begin
        @(posedge clk);
        data_in=tx_data[i];
        if(tx_fifo_write==0) tx_fifo_write=1;
        else if (tx_fifo_write==1) begin
            tx_fifo_write=0;
            i=i+1;
        end
    end
    
    #1 tx_request=1;
       rx_request=1;
    
    #1;
    
    wait(top1.status_line==1);
    repeat(fifo_depth) begin
        if(data_out==tx_data[j]) $display("PASS");
        else $display("FAIL  Expected:%h, Actual=%h",tx_data[j],data_out);
        j=j+1;
        rx_fifo_read_next<=1;
        #(clk_delay*2) rx_fifo_read_next<=0;
        #clk_delay;
    end
    
    #2 $finish;
end

endmodule
