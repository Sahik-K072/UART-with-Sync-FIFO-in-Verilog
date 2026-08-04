`timescale 1ns / 1ps

module uart_rx #(parameter clk_freq=100, baud_rate=2)
(output reg rts=1'b0,frame_error=1'b0,parity_error=1'b0,rx_done,
output reg [7:0] data,
input rx,clk,full,rx_request
);

always @(*) begin
    if(~full & rx_request) rts=0;
    else rts=1;
end

//baud rate generator
localparam oversampling_rate=16;
reg baud_tick=1'b0, sampling_instant=1'b0;
integer clk_count=0, baud_tick_count=0, divisor=clk_freq/(baud_rate*oversampling_rate);

always @(posedge clk)
begin
    if(clk_count<divisor-1) begin
        baud_tick<=1'b0;
        clk_count<=clk_count+1;
    end
    else begin
        baud_tick<=1'b1;
        clk_count<=0;
    end
end

//sampling instant generator
always @(posedge baud_tick)
begin
    if(baud_tick_count==7) begin
        sampling_instant<=1'b1;
        baud_tick_count<=baud_tick_count+1;
    end
    else if(baud_tick_count==15) baud_tick_count<=0;
    else begin
        sampling_instant<=1'b0;
        baud_tick_count<=baud_tick_count+1;
    end
end

//states
localparam IDLE=3'd0,
           START=3'd1,
           READ_DATA=3'd2,
           PARITY=3'd3,
           STOP=3'd4;

reg [2:0] state=3'd0, next_state=3'd0;

//state transition
always @(posedge clk) begin
    state<=next_state;
    if(next_state==STOP) rx_done<=1;
    else if(rx_done) rx_done<=0;
end

//state action
reg [2:0] count=3'b0;
reg data_bits_received=1'b0;
always @(posedge sampling_instant)
begin
    case(state)
        READ_DATA: begin
                       data<={rx,data[7:1]};
                       count<=count+1;
                       if(count==7) data_bits_received<=1;
                   end
        PARITY: begin
                    if(rx!=^data) parity_error<=1;
                    else parity_error<=0;
                end
        STOP: begin
                  data_bits_received<=0;
                  if(rx==0) frame_error<=1;
                  else frame_error<=0;
              end
        default: begin
                   data_bits_received<=0;
                   frame_error<=0;
                   parity_error<=0;
                 end
    endcase
end

//state assignment
always @(rx or sampling_instant or data_bits_received)
begin
    case(state)
        IDLE: if(rx==0) next_state=START;
              else next_state=IDLE;
        START: if(sampling_instant) begin
                   if(rx==0) next_state=READ_DATA;
                   else next_state=IDLE;
               end
               else next_state=START;
        READ_DATA: if(data_bits_received) next_state=PARITY;
                   else next_state=READ_DATA;
        PARITY: if(sampling_instant) next_state=STOP;
                else next_state=PARITY;
        STOP: if(sampling_instant) next_state=IDLE;
              else next_state=STOP;
        default: next_state=IDLE;
    endcase
end

endmodule
