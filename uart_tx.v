`timescale 1ns / 1ps

module uart_tx #(parameter clk_freq=100, baud_rate=2)
(output reg tx,tx_done,
input cts,clk,tx_request,empty,
input [7:0] data
);

reg baud_tick=1'b0;
integer clk_count=0, divisor=clk_freq/baud_rate;

//baud tick generator
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

//states
localparam IDLE=3'd0,
           START=3'd1,
           DATA=3'd2,
           PARITY=3'd3,
           STOP=3'd4;

reg [2:0] state=IDLE, next_state=IDLE;

reg parity;
always @(*) parity=^data; //even parity

//state transition
always @(posedge clk) begin
    state<=next_state;
    if(next_state==STOP) tx_done<=1;
    else if(tx_done) tx_done<=0;
end
//state action
reg [2:0] count=0;
reg data_bits_sent=1'b0;
always @(posedge baud_tick) begin
    case(state)
        IDLE: begin
                  tx<=1'b1;
              end
        START: tx<=1'b0;
        DATA: begin
                  tx<=data[count];
                  count<=count+1;
                  if(count==7) data_bits_sent<=1'b1;
                  else data_bits_sent<=1'b0;
              end
        PARITY: tx<=parity;
        STOP: begin
                  tx<=1'b1;
                  data_bits_sent<=0;
              end
        default: begin
                    tx<=1'b1;
                    data_bits_sent<=1'b0;
                end
    endcase
end

//state assignment
always @(*)
begin
    case(state)
        IDLE: if(~empty & tx_request & cts==0) next_state=START;
              else next_state=IDLE;
        START: if(baud_tick) next_state=DATA;
               else next_state=START;
        DATA: if(data_bits_sent) next_state=PARITY;
              else next_state=DATA;
        PARITY: if(baud_tick) next_state=STOP;
                else next_state=PARITY;
        STOP: if(baud_tick) next_state=IDLE;
              else next_state=STOP;
        default: next_state=IDLE;
    endcase
end

endmodule
