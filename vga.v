module vga (
	input CLOCK_50,
	output VGA_HS, VGA_VS,
	output [7:0] VGA_R, VGA_G, VGA_B,
	output VGA_CLK,
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	input [3:0] KEY,
	input [9:0] SW
);


wire VGACLK;

assign VGA_CLK = VGACLK;

video video_module(
	.reset(SW[9]),
	.clk(VGACLK),
	.Hsync(VGA_HS),
	.Vsync(VGA_VS),
	.R(VGA_R),
	.G(VGA_G),
	.B(VGA_B),
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),
	.KEYS(KEY),
	.FUNC(SW[3:0])
);

pll vgaclk (
	.ref_clk_clk(CLOCK_50),
	.ref_reset_reset(SW[9]),
	.vga_clk_clk(VGACLK)
);

endmodule
