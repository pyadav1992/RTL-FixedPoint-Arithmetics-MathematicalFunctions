`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University
// Engineer:    Pratik Yadav
// 
// Create Date: 03/05/2016 04:03:43 PM
// Design Name: 
// Module Name: tb_Log10
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  
// If not, see <https://www.gnu.org/licenses/>
//////////////////////////////////////////////////////////////////////////////////

module tb_Log10;

parameter WI = 8;     // integer part for input
parameter WF = 32;    // fractional part for input
parameter WIO = 8;
parameter WFO = 32;

reg [(WI+WF-1):0] NumIn;  // Input
reg  Rst;                         // Log Reset     
wire [(WIO+WFO-1):0] Base10;  // Output Log10
wire Negflow;                     // Overflow when input 

real In, Log10;
function real fixedToFloat;
	       input [63:0] in;
				 input integer WI;
				 input integer WF;
				 integer idx;
				 real retVal;
				 begin
				 retVal = 0;
				 for (idx = 0; idx<WI+WF-1;idx = idx+1)begin
						if(in[idx] == 1'b1)begin
						  retVal = retVal + (2.0**(idx-WF));
						end
				 end
				 fixedToFloat = retVal -(in[WI+WF-1]*(2.0**(WI-1)));
				 end
endfunction

Log10 #(.WI(WI),     // integer part for input
        .WF(WF),    // fractional part for input
        .WIO(WIO),   // integer part for output
        .WFO(WFO))   // fractional part for output
              UUTLog10      
                    (.NumIn(NumIn),  // Input
                     .Rst(Rst),                         // Log Reset     
                     .Base10(Base10),  // Output Log10
                     .Negflow(Negflow)                     // Overflow when input 
                     );

//initial begin
//    $readmemb("Row0.txt",tb_Log10.UUTLog10.log2Norm.ramCoefFP_Log2x_row0);
//    $readmemb("Row1.txt",tb_Log10.UUTLog10.log2Norm.ramCoefFP_Log2x_row1);
//end

//8.40
initial begin
Rst = 0;
NumIn = 0;
#100; Rst = 1; NumIn =  40'b00000000_00000000000001101000110110111000;  
#100; Rst = 1; NumIn =  40'b00010000_11111010111000010100011110101110; 
#100; Rst = 1; NumIn =  40'b00001000_00010001111000110000000000010100;
#100; Rst = 1; NumIn =  40'b00000000_00000001010001111010111000010100;
#100; Rst = 1; NumIn =  40'b01011010_00000001111010111000010100011110;
#100; Rst = 1; NumIn =  40'b00000010_00000000000000000000000000000000;
end

//2.10
//initial begin
//Rst = 0;
//NumIn = 0;
//#100; Rst = 1; NumIn =  12'b01_1000000000;  
//#100; Rst = 1; NumIn =  12'b00_1000000000; 
//#100; Rst = 1; NumIn =  12'b01_0000001011;
//#100; Rst = 1; NumIn =  12'b00_0001100001;
//#100; Rst = 1; NumIn =  12'b01_0001100001;
//end

always@(*)begin
    In = fixedToFloat(NumIn,WI,WF);
    Log10 = fixedToFloat(Base10,WIO,WFO);
end
    
endmodule
