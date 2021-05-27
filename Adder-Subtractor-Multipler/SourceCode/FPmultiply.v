`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:06:55 03/13/2015 
// Design Name: 
// Module Name:    FPmultiply 
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
//////////////////////////////////////////////////////////////////////////////////
`define X_trc (WIO>=2)?(WIO-2+fracL):fracL
module FPmultiply
#(parameter  WI1 = 4, 
             WF1 = 5,
             WI2 = 4,
             WF2 = 5,
             WIO = 8,
             WFO = 10)

   (
    input signed[(WI1+WF1-1):0] A,
    input signed[(WI2+WF2-1):0] B,
    output signed[(WIO+WFO-1):0] multiply,
    output overflow
   );

parameter intL = WI1 + WI2;
parameter fracL = WF1 + WF2;

wire [(intL+fracL-1):0] tempmult;

reg  [(WIO-1) : 0] outI;
reg  [(WFO-1) : 0] outF;
reg [((intL-WIO)-1):0] checkbits;
reg [((intL-WIO)-1):0] threshold;
reg overflow_reg;

assign tempmult = A * B;

//------------------------------------------truncation-------------------------------------------------//
//---------------------------------adjusting bitwidth of fractional part-------------------------------//
always @* begin
  if (WFO >= fracL)begin
    outF = {tempmult[fracL-1:0],{(WFO-fracL){1'b0}}};
  end
  else begin
    outF = tempmult[(fracL-1):(fracL-WFO)];
  end
end
//---------------------adjusting bitwidth of Integer part and check if overflow occurs-----------------//
// If overflow occurs indicate by making overflow flag = 1
assign overflow =overflow_reg;
always @* begin
  if (WIO >= intL)begin
    outI = {{(WIO-intL){tempmult[intL+fracL-1]}},tempmult[(intL+fracL-1):fracL]};
    overflow_reg = 1'b0;
    checkbits = 0;
    threshold = 0;  
  end
  else begin
    if (WIO == 1)begin
      outI = tempmult[intL+fracL-1];
      checkbits = tempmult[(intL+fracL-1):(`X_trc)];
      //checkbits are the bits truncated from the integer part of the output
      threshold = {(intL-WIO){tempmult[intL+fracL-1]}};
      //threshold are the number of bits truncated times sign bit of output 
      overflow_reg = 1'b0;
      if (checkbits == threshold)
      overflow_reg = 1'b0;
      else
      overflow_reg = 1'b1;
    end  
    else begin
      outI = {tempmult[intL+fracL-1],tempmult[`X_trc:fracL]};
      checkbits = tempmult[(intL+fracL-1):(`X_trc)+1];
      //checkbits are the bits truncated from the integer part of the output
      threshold = {(intL-WIO){tempmult[intL+fracL-1]}};
      //threshold are the number of bits truncated times sign bit of output 
      overflow_reg = 1'b0;
      
      if (checkbits == threshold)
      overflow_reg = 1'b0;
      else
      overflow_reg = 1'b1;
    end
  end
end

assign multiply ={outI,outF};

endmodule
