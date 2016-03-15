module video(
	input reset,
	input clk,
	output reg Hsync, Vsync,
	output reg [7:0] R, G, B,
	output reg [6:0] HEX0, HEX1, HEX2, HEX3,
	output [6:0] HEX4, HEX5,
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

// Begin constants
parameter H_CENTER = H_RES / 2;
parameter V_CENTER = V_RES / 2;

parameter PADDLE_HEIGHT = 83, PADDLE_WIDTH = 12;
parameter BALL_SIZE = 10;
// End constants

assign HEX5 = dec2bin(userPoints);
assign HEX4 = dec2bin(computerPoints);

// Hpos= 0.. 1688
//Vpos= 0..1066 --> 11 bits;

reg [10:0] Hpos, Vpos; // Current Drawing Position

// Code Variables go here
reg h_direction, v_direction;
reg [1:0] hSpeed;
reg [2:0] vSpeed;
reg [6:0] userPoints, computerPoints;
reg [10:0] player1X, player1Y, player2X, player2Y, ballX, ballY;
reg [2:0] playerHit, computerHit;
reg [10:0] posX, posY; // Current Drawing Position
//Code Variables end here

always @ (posedge(clk) or posedge(reset)) 
begin

	if (reset == 1)
	begin
		Hpos <= 11'd0;
		Vpos <= 11'd0;
		player1X <= 30;
		player1Y <= V_CENTER - PADDLE_HEIGHT / 2;
		player2X <= H_RES - 42;
		player2Y <= V_CENTER - PADDLE_HEIGHT / 2;
		ballX <= H_CENTER;
		ballY <= V_CENTER;
		h_direction <= 1'b0;
		v_direction <= 1'b1;
		hSpeed <= 2'd1;
		vSpeed <= 4'd4;
		HEX0 <= ~7'b0111111;
		HEX1 <= ~7'b0111111;
		HEX2 <= ~7'b0111111;
		HEX3 <= ~7'b0111111;
		//HEX4 <= ~7'b0111111;
		//HEX5 <= ~7'b0111111;
		playerHit <= 11'd0;
		computerHit <= 11'd0;
		userPoints <= 4'd0;
		computerPoints <= 4'd0;
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
			
			// Dashed line in the middle
			if (dash(posX, posY))
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
			
			// Draw computer paddle (right)
			if (draw(player2X, player2Y, Hpos, Vpos, 1'b0))
			begin
				R <= 8'hff;
				G <= 8'hff;
				B <= 8'hff;
			end
			
			// Draw ball
			if (draw(ballX, ballY, Hpos, Vpos, 1'b1))
			begin
				R <= 8'hff;
				G <= 8'hff;
				B <= 8'hff;
			end
				
			if (Hpos < H_LINE) Hpos <= Hpos + 1'b1; // Horizontal increment
			else
			begin
				Hpos <= 11'd0; // New Line --> Hpos = 0	
				if (Vpos == V_LINE) Vpos <= 11'd0; // New screen --> Vpos = 0
				else
				begin
					Vpos <= Vpos + 1'b1;  // Vertical increment	
					// Proceed for movement. Test on 4 times per line (2 of them for computer; user may use 4 to increase speed)
					if ((Vpos == V_LINE-1) || (Vpos == 3*V_LINE/4) || (Vpos == V_LINE/2) || (Vpos == V_LINE/4))
					begin 
						
							// User paddle moviment
							if (KEYS[0] == 0)
							begin
								if (player1Y + PADDLE_HEIGHT < V_RES) player1Y <= player1Y + 1'b1;
							end
							else if (KEYS[1] == 0)
								if (player1Y > 11'd0) player1Y <= player1Y - 1'b1;
							
							// Computer paddle movement
							if (ballY > player2Y + PADDLE_HEIGHT / 2 && player2Y + PADDLE_HEIGHT < V_RES) player2Y <= player2Y + 1;
							else if (ballY < player2Y && player2Y > 0) player2Y <= player2Y - 1;
							
							playerHit = hit(player1X, player1Y, ballX, ballY);
							computerHit = hit(player2X - PADDLE_WIDTH, player2Y, ballX, ballY);
							
							// Ball horizontal direction
							if (playerHit > 0 || computerHit > 0)
							begin
								HEX1 = dec2bin(playerHit); // debug
								HEX0 = dec2bin(computerHit); // debug
							
								h_direction = ~h_direction;
								vSpeed = playerHit + computerHit;
							end
							
							// Ball vertical direction
							if (ballY + BALL_SIZE / 2 >= V_RES || ballY - BALL_SIZE / 2 <= 0)
								if (v_direction == 1'b0) v_direction = 1'b1;
								else v_direction = 1'b0;
							
							// Ball movement Y
							if ((ballY + BALL_SIZE/2) + 100 <= V_RES + 100 && (ballY - BALL_SIZE/2) + 100 >= 0 + 100)
								ballY = ballY + vSpeed - 4;
							else
							begin
								case (vSpeed)
									1: vSpeed = 7;
									2: vSpeed = 6;
									3: vSpeed = 5;
									4: vSpeed = 4;
									5: vSpeed = 3;
									6: vSpeed = 2;
									7: vSpeed = 1;
									default: vSpeed = 4;
								endcase
								ballY = ballY + vSpeed - 4;
							end
							
							// Ball movement X
							if (ballX < H_RES && ballX > 0)
								if (h_direction == 1'b0) ballX <= ballX - 1;
								else ballX <= ballX + 1;
							else
							begin
								if (h_direction == 1'b1) userPoints = userPoints + 1;
								else computerPoints = computerPoints + 1;
								ballX = H_CENTER;
								ballY = V_CENTER;
								h_direction = ~h_direction;
							end
							
					end // Vpos == 
				end
			end
		// Code ends here
		end // ((posX >= 0) && (posY >=0))
	end //clk
end //always

/*
Test if pixel of middle line should be put on screen
*/
function dash;

input [10:0] posX, posY;

if (posX >= H_CENTER - 1 && posX <= H_CENTER + 1 && posY % 20 < 10) dash = 1'b1;
else dash = 1'b0;

endfunction

/*
Test is a pixel should be put on screen. Type = 0: Paddle; Type = 1: Ball
*/
function draw;

input [10:0] objectX, objectY, Hpos, Vpos;
input type;

integer dX, dY;

dX = Hpos - (H_FP + H_SYNC + H_BP) - objectX;
dY = Vpos - (V_FP + V_SYNC + V_BP) - objectY;

if (type == 1'b0) // Paddle
	if ((dX > 0) && (dX < PADDLE_WIDTH) &&
		 (dY > 0) && (dY < PADDLE_HEIGHT)) draw = 1'b1;
	else draw = 1'b0;
else // Ball
	if ((dX > 0) && (dY > 0) &&
		 ((BALL_SIZE/2-dX)*(BALL_SIZE/2-dX) + (BALL_SIZE/2-dY)*(BALL_SIZE/2-dY) < (BALL_SIZE/2)*(BALL_SIZE/2))) draw = 1'b1;
	else draw = 1'b0;


endfunction

/*
Test if ball hit paddle
*/
function integer hit;

input [10:0] paddleX, paddleY, ballX, ballY;

integer result = 0;

if (ballX == paddleX + PADDLE_WIDTH)
begin
	if (ballY - BALL_SIZE/2 <= paddleY + PADDLE_HEIGHT && ballY + BALL_SIZE/2 >= paddleY)
	begin
		result = paddleY + PADDLE_HEIGHT;
		result = result - ballY;
		result = PADDLE_HEIGHT - result;
		result = result / 12;
		result = result + 1;
		hit = result;
	end
end
else hit = 3'd0;

endfunction

function integer calculateSpeed;

input [2:0] speed;

case (speed)
	1: calculateSpeed = 7;
	2: calculateSpeed = 6;
	3: calculateSpeed = 5;
	4: calculateSpeed = 4;
	5: calculateSpeed = 3;
	6: calculateSpeed = 2;
	7: calculateSpeed = 1;
	default: calculateSpeed = 4;
endcase

endfunction

/*
Convert decimal digit to binary digit 
*/
function [6:0] dec2bin (input [3:0] in);

	case (in)
		0: dec2bin = ~7'b0111111;
		1: dec2bin = ~7'b0000110;
		2: dec2bin = ~7'b1011011;
		3: dec2bin = ~7'b1001111;
		4: dec2bin = ~7'b1100110;
		5: dec2bin = ~7'b1101101;
		6: dec2bin = ~7'b1111101;
		7: dec2bin = ~7'b0000111;
		8: dec2bin = ~7'b1111111;
		9: dec2bin = ~7'b1101111;
		default: dec2bin = ~7'b0000000;
	endcase
	
endfunction

endmodule
