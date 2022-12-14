`timescale 1ns / 1ps
`define CPS 4
//FIR_tap은 N_TAP_FIR_Filter에서 define해야함.
//////////////////////////////////////////////////////////////////////////////////
module TOP(clk_data, clk_filter, rst, in_data, out_data);
input clk_data, clk_filter, rst; //clk_data가 clk_filter보다 CPS배 빠름
input [15:0] in_data;
output reg [15:0] out_data;

reg [15:0] parallel_input_data [`CPS-1:0];
wire [15:0] parallel_output_data [`CPS-1:0];

reg [5:0] count_for_input;
reg [5:0] count_for_output;

//in_data를 Filter의 입력에 분배
integer i;
always @ (posedge clk_data) 
begin
	if(rst==1)
		for(i=0; i<`CPS; i=i+1)
			parallel_input_data[i] = 0;
	else
		parallel_input_data[count_for_input] <= in_data;
end

//generate FIR_Filter
genvar j;
generate
for(j=0; j<`CPS; j=j+1)
begin : generate_N_TAP_FIR_Filter
N_TAP_FIR_Filter Filter1(clk_filter, rst, parallel_input_data[j], parallel_output_data[j]);
end
endgenerate

always @ (posedge clk_data)
begin
	if(rst==1)
		out_data <= 0;
	else
		begin
			out_data <= parallel_output_data[count_for_output];
		end
end

//counter_for_input
always @ (posedge clk_data)
begin
	if(rst==1)
		count_for_input <= 0;
	else
		begin
			if(count_for_input < (`CPS-1))
				count_for_input <= count_for_input + 1;
			else
				count_for_input <= 0;
		end
end

//counter_for_output
always @ (posedge clk_data)
begin
	if(rst==1)
		count_for_output <= (`CPS-1);
	else
		begin
			if(count_for_output < (`CPS-1))
				count_for_output <= count_for_output + 1;
			else
				count_for_output <= 0;
		end
end

endmodule
