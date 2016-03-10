module sync(
	input reset,
	input clk,
	output reg Hsync, Vsync,
	output reg [7:0] R, G, B,
	input [3:0] KEYS,
	input [2:0] FUNC
);