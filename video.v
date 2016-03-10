module video(
	input reset,
	input clk,
	output reg Hsync, Vsync,
	output reg [7:0] R, G, B,
	input [3:0] KEYS,
	input [3:0] FUNC
);

// Resolution is 1024x768@60Hz

parameter H_RES = 1024;
parameter H_SYNC = 136;
parameter H_BP = 160;
parameter H_FP = 24;

parameter H_LINE = H_SYNC + H_BP + H_RES + H_FP;

parameter V_RES = 768;
parameter V_SYNC = 6;
parameter V_BP = 29;
parameter V_FP = 3;

parameter V_LINE = V_SYNC + V_BP + V_RES + V_FP;

parameter H_CENTER = H_RES / 2;
parameter V_CENTER = V_RES / 2;

parameter PADDLE_HEIGHT = 80, PADDLE_WIDTH = 12;
parameter BALL_SIZE = 10;


// Hpos= 0.. 1688
//Vpos= 0..1066 --> 11 bits;

reg [10:0] Hpos, Vpos; // Current Drawing Position

// Code Variables go here

reg [10:0] player1X, player1Y, player2X, player2Y;
reg [10:0] posX, posY; // Current Drawing Position

//Code Variables end here



always @ (posedge(clk) or posedge(reset)) 
begin

	if (reset == 1)
	begin
		Hpos <= 11'd0;
		Vpos <= 11'd0;
		player1X <= 30;
		player1Y <= V_CENTER;
		player2X <= H_RES - 42;
		player2Y <= V_CENTER;
	end
	else
	begin // not reset

		if (Hpos < H_LINE) Hpos <= Hpos + 1'b1; // Horizontal increment
		else
		begin
			Hpos <= 11'd0; // New Line --> Hpos = 0
				
				
			if (Vpos == V_LINE) Vpos <= 11'd0; // New screen --> Vpos = 0
			else
			begin
				Vpos <= Vpos + 1'b1;  // Vertical increment
			end
		end

			// Generate Hsync, and Vsync VGA signals
		if ((Hpos >= H_FP) && (Hpos < H_FP + H_SYNC)) Hsync <= 1'b0;
		else Hsync <= 1'b1;
		
		if ((Vpos >= V_FP) && (Vpos < V_FP + V_SYNC)) Vsync <= 1'b0;
		else Vsync <= 1'b1;

		// R = G = B = 0 on front, back porsh and sync
		if (((Hpos >= 11'd0) && (Hpos < H_FP + H_SYNC + H_BP)) || ((Vpos >= 11'd0) && (Vpos < V_FP + V_SYNC + V_BP)))
		begin
			R <= 8'hd0;
			G <= 8'hd0;
			B <= 8'hd0;
		end
		
		// Posição atual no ecrã
		posX <= Hpos - (H_FP + H_SYNC + H_BP);
		posY <= Vpos - (V_FP + V_SYNC + V_BP);
		
		if ((posX >= 0) && (posY >= 0))
		begin
		
			// Code goes here
			R <= 8'h00;
			G <= 8'h00;
			B <= 8'h00;
			
			// middle dashed line
			if (posX > H_CENTER - 4 && posX < H_CENTER + 4)
			begin
				R <= 8'hff;
				G <= 8'hff;
				B <= 8'hff;
			end
			
			// left pad (player1)
			if (posX > 0 + 30 && posX < 0 + 42 && posY > player1Y - PADDLE_HEIGHT && posY < PADDLE_HEIGHT)
			begin
				R <= 8'hff;
				G <= 8'hff;
				B <= 8'hff;
			end
			
			// Draw user paddle (left)
			if (draw(player1X, player1Y, Hpos, Vpos, 1'b0))
			begin
				R <= 8'hff;
				G <= 8'hff;
				B <= 8'hff;
			end
			/*else
			begin
				R <= 8'h00;
				G <= 8'h00;
				B <= 8'h00;
			end*/
			
			// Draw Computer paddle (right)
			if (draw(player2X, player2Y, Hpos, Vpos, 1'b0))
			begin
				R <= 8'hff;
				G <= 8'hff;
				B <= 8'hff;
			end
				/*else
				begin // user won -> draw object as red
					R <= 8'hff;
					G <= 8'h00;
					B <= 8'h00;
				end*/
				
			
		
		// Code ends here
		end // ((posX >= 0) && (posY >=0))
		
		
	
		
	end //clk
end //always

always @ (negedge(KEYS[3:0]) or posedge(reset))
begin
	if (reset == 1)
	begin
		//player1Y <= V_CENTER;
		//player2Y <= V_CENTER;
	end
	else
	begin // not reset
		//if (KEYS[0] == 0 && player1Y < V_RES - 45) player1Y <= player1Y + 5;
		//else if(KEYS[1] == 0 && player1Y > 45) player1Y <= player1Y - 5;
	end
end

/*function drawPlayer (input [1:0] dificulty, input [0:0] player);
	
endfunction*/

/*
Test is a pixel should be put on screen. Type = 0: square; Type = 1: Circle
*/
function draw;

input [10:0] objectX, objectY, Hpos, Vpos;
input Type;
integer dX, dY;

dX = Hpos - (H_FP + H_SYNC + H_BP) - objectX;

dY = Vpos - (V_FP + V_SYNC + V_BP) - objectY;

if (Type == 1'b0) // Paddle
	if ((dX > 0) && (dX < PADDLE_WIDTH) &&
		 (dY > 0) && (dY < PADDLE_HEIGHT)) draw = 1'b1;
	else draw = 1'b0;
else // Ball
	if ((dX > 0) && (dY > 0) &&
		 ((BALL_SIZE/2-dX)*(BALL_SIZE/2-dX) + (BALL_SIZE/2-dY)*(BALL_SIZE/2-dY) < (BALL_SIZE/2)*(BALL_SIZE/2))) draw = 1'b1;
	else draw = 1'b0;


endfunction

endmodule
