module CheatCode(
	input CLOCK_50,
	input showCheatUI,
	input [119:0] cheatDigits,
	input [7:0] startIndex,
	output reg [12:0] replacementAddress,
	output reg [7:0] replacementData
);

reg [7:0] cheatDigits0, cheatDigits1, cheatDigits2, cheatDigits3, cheatDigits4;

always @(posedge CLOCK_50)
begin
	if (showCheatUI)
		begin	
			if (cheatDigits[startIndex * 8 +: 8] != 8'h02 &&
				cheatDigits[(startIndex + 1) * 8 +: 8] != 8'h02 &&
				cheatDigits[(startIndex + 2) * 8 +: 8] != 8'h02 &&
				cheatDigits[(startIndex + 3) * 8 +: 8] != 8'h02 &&
				cheatDigits[(startIndex + 4) * 8 +: 8] != 8'h02)
				begin
					cheatDigits0 <= (cheatDigits[startIndex * 8 +: 8] >> 1) - 8'd2;
					cheatDigits1 <= (cheatDigits[(startIndex + 1) * 8 +: 8] >> 1) - 8'd2;
					cheatDigits2 <= (cheatDigits[(startIndex + 2) * 8 +: 8] >> 1) - 8'd2;
					cheatDigits3 <= (cheatDigits[(startIndex + 3) * 8 +: 8] >> 1) - 8'd2;
					cheatDigits4 <= (cheatDigits[(startIndex + 4) * 8 +: 8] >> 1) - 8'd2;

					replacementAddress <= { 1'b1, cheatDigits0[3:0], cheatDigits1[3:0], cheatDigits2[3:0]	};			
					replacementData <= { cheatDigits3[3:0], cheatDigits4[3:0] };
				end
			else
				replacementAddress <= 0;
	end
end

endmodule
