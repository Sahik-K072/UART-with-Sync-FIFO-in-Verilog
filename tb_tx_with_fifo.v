`timescale 1ns / 1ps

module tb_tx_with_fifo;

localparam real clk_freq=100;
localparam baud_rate=2,depth=4,width=8;

wire tx,full;
reg cts,clk,tx_request,write,fifo_reset;
reg [width-1:0] fifo_data_in;

tx_with_fifo #(
    .clk_freq(clk_freq),
    .baud_rate(baud_rate),
    .depth(depth),
    .width(width)
    ) dut(
    .tx(tx),
    .full(full),
    .cts(cts),
    .clk(clk),
    .tx_request(tx_request),
    .write(write),
    .fifo_reset(fifo_reset),
    .fifo_data_in(fifo_data_in)
);

localparam real clk_delay=(1/clk_freq*2);
initial begin
    clk=1'b0;
    forever #clk_delay clk=~clk;
end

reg [width-1:0] fifo_data [depth-1:0];
integer i,w_address=0;
initial begin
    fifo_reset=0;
    cts=0;
    for(i=0;i<depth;i=i+1) fifo_data[i]= $urandom;
    #1 fifo_reset=1;
    
    write2fifo(fifo_data[w_address]); w_address=w_address+1;
    #1 write2fifo(fifo_data[w_address]); w_address=w_address+1;
    #1 write2fifo(fifo_data[w_address]); w_address=w_address+1;
    #1 write2fifo(fifo_data[w_address]); w_address=w_address+1;
    #1 write2fifo(fifo_data[w_address]); w_address=w_address+1;
    
    tx_request=1;
    wait(dut.empty) #2 $finish;
end

task write2fifo;
    input [width-1:0] data;
    begin
        fifo_data_in=data;
        write=1;
        #(clk_delay*2) write=0;
    end
endtask
endmodule
