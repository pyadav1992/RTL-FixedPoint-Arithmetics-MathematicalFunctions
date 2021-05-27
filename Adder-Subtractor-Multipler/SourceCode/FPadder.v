`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Pratik Yadav
// 
// Create Date:   
// Design Name: 
// Module Name:    FPadder 
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
`define X_trc1 (WIO>=2)?(WIO-2+bigger_Frac):bigger_Frac //starting address to terminate bits 

module FPadder 
#(parameter  WI1 = 8,             // integer part bitwidth for integer 1  
             WF1 = 10,          // fractional part bitwidth for integer 1
             WI2 = 8,             // integer part bitwidth for integer 2
             WF2 = 10,          // fractional part bitwidth for integer 2
             WIO = 9,            // integer part bitwidth for addition output (user input)
             WFO = 10            // integer part bitwidth for addition outout (user input)
            )
   (
    input signed [WI1+WF1-1 : 0] A,             //input A
    input signed [WI2+WF2-1 : 0] B,             //input B
    output overflow,                            // overflow flag        
    output signed  [WIO+WFO-1 : 0] out          // addition output
    );

parameter  bigger_int = ((WI1>=WI2))?WI1:WI2;   // bigger integer part among the two numbers is taken
parameter bigger_Frac = ((WF1>=WF2))?WF1:WF2;   // bigger integer part among the two numbers is taken

wire   [bigger_int+bigger_Frac : 0] tempout;    // output without truncation  

reg sign;  
reg    [(WI1+WF1-1):WF1] A_I;                               // integer part of A
reg    [(WF1-1):0] A_F;                                     // Fractional part of A
reg    [(WI2+WF2-1):WF2] B_I;                               // integer part of B                        
reg    [(WF2-1):0] B_F;                                     // Fractional part of A 
reg    [(bigger_int+bigger_Frac-1):bigger_Frac] tempA_I;  // bitwidth adjusted integer part of A   
reg    [(bigger_Frac-1):0] tempA_F;                       // bitwidth adjusted fractional part of A                       
reg    [(bigger_int+bigger_Frac-1):bigger_Frac] tempB_I;  // bitwidth adjusted integer part of B                               
reg    [(bigger_Frac-1):0] tempB_F;                       // bitwidth adjusted integer part of B 
reg   [bigger_int+bigger_Frac-1 : 0] tempA;               // bitwidth adjusted input A
reg   [bigger_int+bigger_Frac-1 : 0] tempB;               // bitwidth adjusted input B
reg    [WIO-1 : 0] outI;                                  //truncated output integer bits 
reg    [WFO-1 : 0] outF;                                  //truncated output fraction bits
reg    [(bigger_int+bigger_Frac):WIO+bigger_Frac] checkbits;    // truncated bits  of integer part from output
reg  [(bigger_int+bigger_Frac):WIO+bigger_Frac] threshold;      // replicated sign bit extension to find overflow 
reg overflowT;                                                  // overflow due to truncation 

//----------------separating Integer Parts and Fractional parts of numbers----------------------------//  
always @* begin
  A_I = A[(WI1+WF1-1):WF1];
  A_F = A[(WF1-1):0];
  B_I = B[(WI2+WF2-1):WF2];
  B_F = B[(WF2-1):0];
end

//---------------------------Sign extension for integer part-----------------------------------------// 
always @* begin
  if (WI1 > WI2) begin                                  
    tempB_I = {{(WI1-WI2){B_I[WI2+WF2-1]}},B_I};
    tempA_I = A_I;
  end
  else begin
    tempA_I = {{(WI2-WI1){A_I[WI2+WF2-1]}},A_I};
    tempB_I = B_I;
  end
end

//-----------------------------Zero padding for fractional part---------------------------------------//  
always @* begin
  if (WF1 > WF2) begin
    tempB_F = {B_F,{(WF1-WF2){1'b0}}};
    tempA_F = A_F;
  end
  else begin
    tempA_F = {A_F,{(WF2-WF1){1'b0}}};
    tempB_F = B_F;
  end
 end  
 
//--------------------------------------------Addition------------------------------------------------//
 always @* begin
 tempA = {tempA_I,tempA_F};
 tempB = {tempB_I,tempB_F};
 end
assign tempout = tempA + tempB;

always @ * begin
if ((A[WI1+WF1-1] == B[WI2+WF2-1]))
 sign = tempout[bigger_int+bigger_Frac];
else
 sign = 0;
end

//------------------------------------------truncation-------------------------------------------------//
//---------------------------------adjusting bitwidth of fractional part-------------------------------//
always @* begin
  if (WFO >= bigger_Frac)begin
    outF = {tempout[bigger_Frac-1:0],{(WFO-bigger_Frac){1'b0}}};
  end
  else begin
    outF = tempout[(bigger_Frac-1):(bigger_Frac-WFO)];
  end
end
//---------------------adjusting bitwidth of Integer part and check if overflow occurs-----------------//
// If overflow occurs indicate by making overflow flag = 1
assign overflow = (~tempA[bigger_int+bigger_Frac-1] & ~tempB[bigger_int+bigger_Frac-1] & tempout[bigger_int+bigger_Frac] |
                  tempA[bigger_int+bigger_Frac-1] & tempB[bigger_int+bigger_Frac-1] & ~tempout[bigger_int+bigger_Frac] | overflowT);
always @* begin
  if (WIO >= (bigger_int)+1)begin
    outI = {{(WIO-bigger_int){sign}},tempout[(bigger_int+bigger_Frac-1):bigger_Frac]};
    overflowT = 1'b0;
    checkbits = 0;
    threshold = 0;
     
  end
  else begin
    if (WIO == 1)begin
      outI = sign;
      checkbits = tempout[(bigger_int+bigger_Frac-1):bigger_Frac];
      //checkbits are the bits truncated from the integer part of the output
      threshold = {((bigger_int+1)-WIO){tempout[bigger_int+bigger_Frac]}};
      //threshold are the number of bits truncated times sign bit of output 
      overflowT = 1'b0;
      if (checkbits == threshold)
      overflowT = 1'b0;
      else
      overflowT = 1'b1;
    end  
    else begin
      outI = {sign,tempout[`X_trc1:bigger_Frac]};
       checkbits = tempout[(bigger_int+bigger_Frac-1):bigger_Frac];
      //checkbits are the bits truncated from the integer part of the output
      threshold = {((bigger_int+1)-WIO){tempout[bigger_int+bigger_Frac]}};
      //threshold are the number of bits truncated times sign bit of output 
      overflowT = 1'b0;
      if (checkbits == threshold)
      overflowT = 1'b0;
      else
      overflowT = 1'b1;
    end
  end
end

assign out ={outI,outF};

endmodule
