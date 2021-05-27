`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:29 04/23/2015 
// Design Name: 
// Module Name:    FixedPoint_Subtractor 
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

module FixedPoint_Subtractor 
#(parameter WI1 = 4,                      //integer length
            WF1 = 4,                      //fraction length
            WI2 = 4,                      //integer length
            WF2 = 4,                      //fraction length
            WIO = (WI1>WI2)? WI1+1:WI2+1, //output integer  length
            WFO = (WF1>WF2)? WF1:WF2      //output fraction length
            )
										(input signed [WI1+WF1-1:0] in1,//minuend
										 input signed [WI2+WF2-1:0] in2,//subtrahend
										 output reg overFlow,
										 output  reg signed [WIO+WFO-1:0] FixedPoint_Sub_Out);

reg [1:0] const = 2'b10;
wire [1:0] overFlow_inter;
reg signed [WI2+WF2-1:0] two_s_complement;
wire signed [WIO+WFO-1:0] subtraction_wire;

always @* begin
    two_s_complement = (~in2) + 1'b1;
end
                        
FixedPoint_Adder #(.WI1(WI1),
                   .WF1(WF1),
                   .WI2(WI2),
                   .WF2(WF2),
                   .WIO(WIO),
                   .WFO(WFO))
                              FP_Adder01 ( .in1(in1),
                                           .in2(two_s_complement),
                                           .overFlow(overFlow_inter[1]),
                                           .FixedPoint_Add_Out(subtraction_wire));
                        
always @* begin
  FixedPoint_Sub_Out = subtraction_wire;
  overFlow = (overFlow_inter[1]);
end

endmodule
