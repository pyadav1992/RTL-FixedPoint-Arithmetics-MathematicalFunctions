`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University
// Engineer:    Pratik Yadav
// 
// Create Date: 02/25/2016 02:17:35 PM
// Design Name: 
// Module Name: LeakyIntegrator2
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

module LeakyIntegrator2
    #(parameter WI = 12,
                WF = 12)
    (
    input signed [(WI+WF-1):0] InLeaky,
    input Clk,
    input LIdvi,
    output reg LIdvo,
    output reg signed [(WI+WF-1):0] OutSmooth
    );

parameter alpha = 40'b0000000011100110011001100110011001100111;    // 0.9
parameter alphaCap = 40'b0000000000011001100110011001100110011001;  // 0.1
wire signed [(WI+WF-1):0] tempAlpha;
wire signed [(WI+WF-1):0] delayIn;
wire signed [(WI+WF-1):0] delayOut;
wire signed [(WI+WF-1):0] WireSmooth;
   

FixedPoint_Adder #(.WI1(WI), //1 integer length
.WF1(WF),                    //1 fraction length
.WI2(WI),                    //2 integer length
.WF2(WF),                    //2 fraction length
.WIO(WI),                    //O integer  length
.WFO(WF))                    //O fraction length
      AccumAdder
                  (.in1(InLeaky),
                   .in2(tempAlpha),
                   .overFlow(),
                   .FixedPoint_Add_Out(delayIn));
                      
DFF #(.BW(WI+WF))
              Delay (.d(delayIn),                   
                     .CLK(Clk),
                     .RESET(LIdvi),
                     .q(delayOut));
                                            
fpMult1    # (.WI1(WI),     //length of the integer part, operand 1
              .WF1(WF),         //length of the fraction part, operand 1
              .WI2(WI),         //length of the integer part, operand 2
              .WF2(WF),        //length of the fraction part, operand 2
              .WIO(WI),        
              .WFO(WF)       
              )         
                      LIalphaMult1    (.RST(LIdvi),
                                       .in1(alpha),
                                       .in2(delayOut),
                                       .out(tempAlpha));  
                 
fpMult1    # (.WI1(WI),     //length of the integer part, operand 1
              .WF1(WF),         //length of the fraction part, operand 1
              .WI2(WI),         //length of the integer part, operand 2
              .WF2(WF),        //length of the fraction part, operand 2
              .WIO(WI),        
              .WFO(WF)       
              )         
                      LIalphaMult2    ( .RST(LIdvi),
                                        .in1(delayIn),
                                        .in2(alphaCap),
                                        .out(WireSmooth)); 
      
                                                                             
always @(*) begin
    if(!LIdvi) begin
       OutSmooth <= 0; 
    end
    else begin
       OutSmooth <= WireSmooth;
       LIdvo <= 1;
    end
end

endmodule
