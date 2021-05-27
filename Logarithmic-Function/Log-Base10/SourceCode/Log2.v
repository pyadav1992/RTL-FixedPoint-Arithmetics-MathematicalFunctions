`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University
// Engineer:    Pratik Yadav
// 
// Create Date: 03/01/2016 06:43:10 PM
// Design Name: 
// Module Name: Log2
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

module Log2
    #(parameter xWF = 23,           //integer part for input and output
                xWI = 2,            //fraction part for input and output
                cWF = 26,           //integer part for coefficients
                cWI = 2,            //fractional part for coefficients
                aWF = 28,           //integer part for accumulator
                aWI = 2,            // fractional part for accumulator
                SignedDatapath = 1, // the memory coefficients has negetive values
                noSegBits = 12)     
    (
    input signed [(xWI+xWF-1):0] Number,    //Input
    input Rst,
    output reg signed [(xWI+xWF-1):0] Base2 // Output Log base 2
    );
    
    parameter xWL = xWI + xWF;          // total bitwidth for Input
    parameter cWL = cWI + cWF;          // total bitwidth for Coefficient
    parameter aWL = aWI + aWF;          // total bitwidth for accumulator  
    parameter delta = (2-1) / (2**noSegBits);

//----------------------------------
// Finding the segment
// taking the upper noSegBits bits for addressing
parameter a = xWL-2-SignedDatapath;   //removing -1
parameter b = xWL-noSegBits-SignedDatapath-1;   //removing -1  
reg [(xWL-2-SignedDatapath)-(xWL-noSegBits-SignedDatapath-1):0] bitStream;
integer ind_fp;
    
always @(*) begin
  bitStream = Number[a:b];
  ind_fp = bitStream;
end

//----------------------------------
// Removing the common part and taking the internal index
// Taking the lower bits for calculation
parameter jj = xWF - noSegBits - 1;
parameter xoWL = xWL - noSegBits;
parameter xoWF = xWF - noSegBits; 
parameter xoWI = xoWL - xoWF;
reg signed [(xoWI+xoWF-1):0] xoFP;

always @(*) begin
  xoFP = Number[jj:0];
end

//----------------------------------
// Non-linear approximation
// Fixed-point operations

parameter addr_width = 4096;
reg [(cWL-1):0] ramCoefFP_Log2x_row0 [addr_width-1:0]; // Memory for Log2 table
reg [(cWL-1):0] ramCoefFP_Log2x_row1 [addr_width-1:0]; // Memory for Log2 table

initial begin
    $readmemb("Row0.txt",ramCoefFP_Log2x_row0);
    $readmemb("Row1.txt",ramCoefFP_Log2x_row1);
end

reg signed [(aWL-1):0] accFP;
reg signed [(cWL-1):0] tempRow0;
reg signed [(cWL-1):0] tempRow1;    
reg signed [(aWL-1):0] Row0;
reg signed [(aWL-1):0] Row1;

wire signed [(aWL-1):0] Mul1;
wire signed [(aWL-1):0] Mul2;
wire signed [(aWL-1):0] Add1;
wire signed [(aWL-1):0] Add2;
    
    //integer j = p;

fpMult1 #(.WI1(xoWI),   //length of the integer part, operand 1
      .WF1(xoWF),   //length of the fraction part, operand 1
      .WI2(aWI),   //length of the integer part, operand 2
      .WF2(aWF),    //length of the fraction part, operand 2
      .WIO(aWI),    
      .WFO(aWF))    
                 Multiplier1
                             (.RST(Rst),
                              .in1(xoFP),
                              .in2(accFP),
                              .out(Mul1));

FixedPoint_Adder #(.WI1(aWI), //INPUT-1 integer length
           .WF1(aWF), //INPUT-1 fraction length
           .WI2(aWI), //INPUT-2 integer length
           .WF2(aWF), //INPUT-2 fraction length
           .WIO(aWI), //OUTPUT integer  length
           .WFO(aWF)) //OUTPUT fraction length
                 Adder1
                        (.in1(Mul1),
                         .in2(Row1),
                         .overFlow(),
                         .FixedPoint_Add_Out(Add1));
                         
fpMult1 #(.WI1(xoWI),   //length of the integer part, operand 1
          .WF1(xoWF),   //length of the fraction part, operand 1
          .WI2(aWI),   //length of the integer part, operand 2
          .WF2(aWF),      //length of the fraction part, operand 2
          .WIO(aWI),        
          .WFO(aWF))         
                Multiplier2
                            (.RST(Rst),
                             .in1(xoFP),
                             .in2(Add1),
                             .out(Mul2));

FixedPoint_Adder #(.WI1(aWI), //INPUT-1 integer length
                   .WF1(aWF), //INPUT-1 fraction length
                   .WI2(aWI), //INPUT-2 integer length
                   .WF2(aWF), //INPUT-2 fraction length
                   .WIO(xWI), //OUTPUT integer  length
                   .WFO(xWF)) //OUTPUT fraction length
                              Adder2
                                     (.in1(Mul2),
                                      .in2(Row0),
                                      .overFlow(),
                                      .FixedPoint_Add_Out(Add2));                        
                         
                    
always @(*) begin
    if(!Rst)begin
        accFP = 0;
    end
    else begin
        tempRow1 = ramCoefFP_Log2x_row1[ind_fp]; // removed +1
        tempRow0 = ramCoefFP_Log2x_row0[ind_fp]; // removed +1
        Row1 = {tempRow1,{(aWL-cWL){1'b0}}};
        Row0 = {tempRow0,{(aWL-cWL){1'b0}}}; // removed +1        
        Base2 = Add2;
    end      
end
   
endmodule