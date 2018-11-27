module CheatDevice(
	input CLOCK_50,
	input [7:0] CART_DATA,
	input [12:0] CONSOLE_ADDR,
	output reg [7:0] LED,
	output reg [7:0] CONSOLE_DATA,
	output reg [12:0] CART_ADDR
);

reg [12:0] bufferedAddress = 0;
reg [7:0] bufferedData;
reg [7:0] bufferedCheatRomData;

reg [1:0] debounceCount;
reg [12:0] consoleAddress;

reg replaceData = 0;
reg [7:0] replacementData;

wire [12:0] replacementAddress0, replacementAddress1, replacementAddress2;
wire [7:0] replacementData0, replacementData1, replacementData2;

// Initialize all cheat digits to $02, which is the "dash" character (represents no value).
reg [119:0] cheatDigits = 120'h020202020202020202020202020202;
reg [7:0] currentCheatDigit = 0;

// Flag indicating whether we're showing the cheat code entry screen or the game.
reg showCheatUI = 1;

reg readyToStartGame = 0;

wire [7:0] cheatRomData;

always @(posedge CLOCK_50)
begin
	if (showCheatUI)
		begin	
			if (CONSOLE_ADDR != consoleAddress)
				begin
					debounceCount <= 0;
					consoleAddress <= CONSOLE_ADDR;
				end
			else
				begin
					if (debounceCount == 2'b10)
						begin			
							bufferedAddress <= consoleAddress;				

							case (bufferedAddress)
								13'h1150: cheatDigits[currentCheatDigit * 8 +: 8] <= cheatDigits[currentCheatDigit * 8 +: 8] + 8'd2;
								13'h1162: cheatDigits[currentCheatDigit * 8 +: 8] <= cheatDigits[currentCheatDigit * 8 +: 8] - 8'd2;
								13'h1177: currentCheatDigit <= currentCheatDigit - 8'd1;
								13'h1190: currentCheatDigit <= currentCheatDigit + 8'd1;
							endcase
						end

				if (debounceCount != 2'b11)
					debounceCount <= debounceCount + 1'b1;
			end

			if (cheatRomData != bufferedCheatRomData)
				bufferedCheatRomData <= cheatRomData;		

			if (bufferedAddress == 13'h104C)
				readyToStartGame <= 1;
			else
				if (bufferedAddress == 13'h1FFC)
					if (readyToStartGame)
						showCheatUI <= 0;
				else
					readyToStartGame <= 0;
			
			CONSOLE_DATA <= bufferedAddress[12] ? bufferedCheatRomData : 8'bZZZZZZZZ;
		end
	else
		begin
			if (CONSOLE_ADDR != bufferedAddress)
				bufferedAddress <= CONSOLE_ADDR;
		
			CART_ADDR <= bufferedAddress;
				
			if (CART_DATA != bufferedData)
				bufferedData <= CART_DATA;
			
			if (bufferedAddress != 0 &&
				(bufferedAddress == replacementAddress0 ||
				bufferedAddress == replacementAddress1 ||
				bufferedAddress == replacementAddress2))
				begin
					replaceData <= 1;
					
					case (bufferedAddress)
						replacementAddress0: replacementData <= replacementData0;
						replacementAddress1: replacementData <= replacementData1;
						replacementAddress2: replacementData <= replacementData2;
						default: replacementData <= 0;
					endcase					
				end
			else
				replaceData <= 0;
			
			CONSOLE_DATA <= bufferedAddress[12] ? (replaceData ? replacementData : bufferedData) : 8'bZZZZZZZZ;
		end
		
	LED <= replacementData0;//8'b10101010;
end

CheatCode cheatCode0(CLOCK_50, showCheatUI, cheatDigits, 8'd0, replacementAddress0, replacementData0);
CheatCode cheatCode1(CLOCK_50, showCheatUI, cheatDigits, 8'd5, replacementAddress1, replacementData1);
CheatCode cheatCode2(CLOCK_50, showCheatUI, cheatDigits, 8'd10, replacementAddress2, replacementData2);

CheatRom rom(bufferedAddress[11:0], CLOCK_50, cheatRomData);

endmodule
