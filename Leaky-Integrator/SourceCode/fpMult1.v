`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Company:        San Diego State University
// Engineer:       
// 
// Create Date:    18:35:07 02/06/2015 
// Design Name: 
// Module Name:    fpMult1 
// Project Name: 
// Target Devices: 
// Tool versions: 
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
///////////////////////////////////////////////////////////////////////////////
`define X_trc (WIO>=2)? (WIO-2+frcL) : frcL

module fpMult1
 # (parameter  WI1 = 4, 		//length of the integer part, operand 1
               WF1 = 3, 		//length of the fraction part, operand 1
               WI2 = 2, 		//length of the integer part, operand 2
               WF2 = 5,		  //length of the fraction part, operand 2
               WIO = 1,		
               WFO = 15     		
         ) 		
	(input RST, 
   input signed [WI1+WF1-1 : 0] in1, 
   input signed [WI2+WF2-1 : 0] in2, 
   output reg signed [WIO+WFO-1 : 0] out);
	
parameter intL = WI1+WI2;				//integer length of correct results
parameter frcL = WF1+WF2;				//fraction length of correct results
		
wire [intL+frcL-1 : 0] tmp;			//The output with correct number of bits

reg [WIO-1 : 0] outI;					//The integer part of the output
reg [WFO-1 : 0] outF;					//The fractional part of the output

assign tmp = in1 * in2;

//--------------------adjusting the bitwidth for the fractional part-----------
always  @* begin
	if (WFO >= frcL)						//append 0s to the lsb bits
			outF = {tmp[frcL-1:0] , {(WFO-frcL){1'b0}}};
	else										//WFO<(WF1+WF2): Truncate bits from the LSB bits
			outF = tmp[frcL-1 : frcL-WFO];
end
//-----------------------------------------------------------------------------

//--------------------adjusting the bitwidth for the integer part--------------
always @* begin
	if (WIO>=intL)								//sign extend the integer part
			outI = {{(WIO-intL){tmp[intL+frcL-1]}}, tmp[intL+frcL-1:frcL]};
	else	begin									//WIO<(WI1+WI2)
		if (WIO==1)
			outI = tmp[intL+frcL-1];
		else
		   outI = {tmp[intL+frcL-1], tmp[`X_trc:frcL]};							
	end
end
//-----------------------------------------------------------------------------

//--------------------registering the output-----------------------------------
always @* //(posedge CLK) //if wanna a registered multiplier decommented
	if (!RST) out <= 0;			//negative reset
	else 	//if (WIO==1)			//Adjust back to Integer part = 1	
		out <= {outI [WIO-1:0], outF [WFO-1:0]};
	

endmodule
