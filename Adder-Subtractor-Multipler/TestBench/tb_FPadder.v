`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:       San Diego State University  
// Engineer:      Pratik Yadav
//
// Create Date:   
// Design Name:   FPadder
// Module Name:   tb_FPadder.v
// Project Name:  FPadder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FPadder
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
////////////////////////////////////////////////////////////////////////////////
module tb_FPadder;
parameter WI1 = 8, WF1 = 32, WI2 = 8, WF2 = 32, WIO = 8, WFO = 32;

  // Inputs
  reg [WI1+WF1-1 : 0] A;
  reg [WI2+WF2-1 : 0] B;

  // Outputs
  wire [WIO+WFO-1 : 0] out;
  wire overflow;
  
  //real number Presentation 
  real in1_real,in2_real,out_real;
  real floatout;
  
  //------------------------Function Definition to convert fixed point to floating point number------------//
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
  
  // Instantiate the Unit Under Test (UUT)
  FPadder #(.WI1(WI1),.WF1(WF1),.WI2(WI2),.WF2(WF2),.WFO(WFO),.WIO(WIO)) uut (
    .A(A), 
    .B(B), 
    .out(out),
    .overflow(overflow)
  );
    
  initial begin
    // Initialize Inputs
    A = 40'b11111111_10000000000000000000000000000000;
    B = 40'b00000000_00000000000000000000000000000000;
    #100;
    A = 40'b00000000_00000000000000000000000000000000;
        B = 40'b11111111_10000000000000000000000000000000;
        #100;
        $finish;  
    // Add stimulus here
  end
  
  always @ A in1_real = fixedToFloat(A,WI1,WF1);
  always @ B in2_real = fixedToFloat(B,WI2,WF2);
  always @ out out_real = fixedToFloat(out,WIO,WFO);
  always @ (in1_real or in2_real) floatout=in1_real + in2_real;
  
endmodule