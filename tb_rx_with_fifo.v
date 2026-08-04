`timescale 1ns / 1ps

module tb_rx_with_fifo;

localparam real clk_freq=100;
localparam baud_rate=2,depth=4,width=8;

wire [width-1:0] fifo_data_out;
wire rts,frame_error,parity_error,empty;
reg rx,clk,rx_request,fifo_reset,read_next; 

rx_with_fifo #(
    .clk_freq(clk_freq),
    .baud_rate(baud_rate),
    .depth(depth),
    .width(width)
    ) dut(
    .fifo_data_out(fifo_data_out),
    .rts(rts),
    .frame_error(frame_error),
    .parity_error(parity_error),
    .empty(empty),
    .rx(rx),
    .clk(clk),
    .rx_request(rx_request),
    .fifo_reset(fifo_reset),
    .read_next(read_next)
);

localparam real clk_delay= (1/clk_freq*2);
initial begin
    clk=1'b0;
    forever #clk_delay clk=~clk;
end

//baud tick generator
reg baud_tick=1'b0;
integer clk_count=0, divisor=clk_freq/baud_rate;

always @(posedge clk)
begin
    if(clk_count<divisor-1)
    begin
        baud_tick<=0;
        clk_count=clk_count+1;
    end
    else begin
        baud_tick<=~baud_tick;
        clk_count=0;
    end
end

reg [width+2:0] tx_data [depth+1:0];
integer i,w_address=0,r_address=0;
initial begin
    fifo_reset=0;
    rx_request=1;
    for(i=0;i<depth+2;i=i+1) begin
        tx_data[i][width:1]= $urandom;
        tx_data[i][0]=0;
        tx_data[i][width+2]=1;
        // parity:
        tx_data[i][width+1]= ^tx_data[i][width:1];
    end
    #1 fifo_reset=1;
    
    senddata(tx_data[w_address]); w_address=w_address+1;
    #1 senddata(tx_data[w_address]); w_address=w_address+1;
    #1 senddata(tx_data[w_address]); w_address=w_address+1;
    #1 senddata(tx_data[w_address]); w_address=w_address+1;
    #1 senddata(tx_data[w_address]); w_address=w_address+1;
    
    #1 read; r_address=r_address+1;
    #1 read; r_address=r_address+1;
    #1 read; r_address=r_address+1;
    #1 read; r_address=r_address+1;
    wait(dut.full) #2 $finish;
end

integer j;
task senddata;
    input [width+2:0] data;
    begin
        j=0;
        repeat(width+3) begin
            @(posedge baud_tick);
            rx=data[j];
            j=j+1;
        end
    end
endtask

task read;
    begin
        if(fifo_data_out==tx_data[r_address][width:1]) $display("Pass");
        else $display("Fail. Expected=%b, Actual=%b",tx_data[r_address][width:1],fifo_data_out);
        read_next=1;
        #(clk_delay*2) read_next=0;
    end
endtask

endmodule
