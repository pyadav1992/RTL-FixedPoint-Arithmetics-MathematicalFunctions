`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        San Diego State University
// Engineer:       Pratik Yadav
// 
// Create Date:  
// Design Name: 
// Module Name:    FPsubtractor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies:   FPadder
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
module FPsubtractor 
#(parameter WI1 = 4,                            //1 integer length
            WF1 = 4,                            //1 fraction length
            WI2 = 4,                            //2 integer length
            WF2 = 4,                            //2 fraction length
            WIO = (WI1>WI2)? WI1+1:WI2+1,       //O integer  length
            WFO = (WF1>WF2)? WF1:WF2            //O fraction length
            )
  ( 
    input signed [WI1+WF1-1:0] A,   
    input signed [WI2+WF2-1:0] B,   
    output reg overflow,
    output  reg signed [WIO+WFO-1:0] FPsubout
  );

reg [1:0] const = 2'b10;
wire [1:0] overflow_inter;
reg signed [WI2+WF2-1:0] twos_complement;
wire signed [WIO+WFO-1:0] subtraction_wire;

  always @* begin
      twos_complement = (~B) + 1'b1;
  end
                          
(* DONT_TOUCH = "yes" *)  FPadder #(.WI1(WI1),
                                  .WF1(WF1),
                                  .WI2(WI2),
                                  .WF2(WF2),
                                  .WIO(WIO),
                                  .WFO(WFO))
                                              FPadder01  ( .A(A),
                                                           .B(twos_complement),
                                                           .overflow(overflow_inter[1]),
                                                           .out(subtraction_wire));
                          
  always @* begin
    FPsubout = subtraction_wire;
    overflow = (overflow_inter[1]);
  end

endmodule