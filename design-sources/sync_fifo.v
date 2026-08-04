`timescale 1ns / 1ps
`define w_address w_ptr[ptr_width-1:0]
`define r_address r_ptr[ptr_width-1:0]

module sync_fifo #(
parameter depth=4, width=4,
localparam ptr_width=$clog2(depth)
)
(output [width-1:0] data_out,
output full,empty,
input [width-1:0] data_in,
input write,read_next,clk,reset
);

reg [ptr_width:0] w_ptr,r_ptr;

reg [width-1:0] memory [depth-1:0];
assign data_out= memory[`r_address];


always @(posedge clk) begin
    if(~reset) begin
        w_ptr<=0;
        r_ptr<=0;
    end
    
    else begin
        if(write & ~full & reset) begin
            memory[`w_address]<=data_in;
            w_ptr<=w_ptr+1;
        end
        
        if(read_next & ~empty & reset) begin
            r_ptr<=r_ptr+1;
        end
    end
end

assign full= ( w_ptr == {~r_ptr[ptr_width],r_ptr[ptr_width-1:0]} );
assign empty= (w_ptr==r_ptr);

endmodule
