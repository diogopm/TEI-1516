module vga (
	input CLOCK_50,
	output VGA_HS, VGA_VS,
	output [7:0] VGA_R, VGA_G, VGA_B,
	output VGA_CLK,
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
	.KEYS(KEY),
	.FUNC(SW[3:0])
);

pll vgaclk (
	.ref_clk_clk(CLOCK_50),
	.ref_reset_reset(SW[9]),
	.vga_clk_clk(VGACLK)
);

endmodule
