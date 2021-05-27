`timescale 1ns / 1ns
///////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University  
// Engineer:    Pratik Yadav
// 
// Create Date: 03/04/2016 05:51:16 PM
// Design Name: 
// Module Name: Log10
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
///////////////////////////////////////////////////////////////////////////////
 
module Log10
#(parameter WI = 10,     // integer part for input
            WF = 40,    // fractional part for input
            WIO = 12,    // integer part for output
            WFO = 12)   // fractional part for output
(
input [(WI+WF-1):0] NumIn,  // Input
input Rst,                         // Log Reset     
output reg [(WIO+WFO-1):0] Base10,  // Output Log10
output reg Negflow                     // Overflow when input 
);
         
//========================================Normalize===========================//
//    The number of bits aFP needed to be shifted relative to the fixed to
//    become normalized is returned in the shift, with left shifts positive
//    and right shifts negative.
//    Required format for Log2 is xWI = 2, xWF = 23;

reg [WI+WF-1:0] in;
always @(*) begin
  if (NumIn[WI+WF-1]==1'b0) begin
    Negflow = 1'b0;
    in = NumIn;
  end else begin 
    Negflow = 1'b1;
  end
end
  
// -- priority encoder: to shift the input into WIL=1;
integer e;
integer signed shift;

reg sym;
integer counter_e; //The counter for finding the first 1
always @(*) begin
  for (counter_e=WI+WF-1; counter_e >= 0; counter_e = counter_e-1)
    if (in[WI+WF-counter_e-1]) e = counter_e-1;
end
  
//--------------------------------shift for Normalization--------------------//
reg [WI+WF-1:0] in_s; 
always @(*)begin  
  in_s = in << e;
  if (WI >= (e)) begin
    sym = 1'b0;  // denotes normalization need to shift the "node" to left, 
                 // which means shift the register to right
    shift = (e+2) - WI;
  end else if ((e)> WI) begin
    sym = 1'b1;  // denotes normalization need to shift the "node" to right, 
                 // which means shift the register to left
    shift = (e+2)-WI;
  end  
end 
    
//------------------Instantiation for Normalized Log2------------------------//
parameter xWF = 23;        //integer part for input and output to Log2
parameter xWI = 2;         //fraction part for input and output to Log2
parameter cWF = 26;        //integer part for coefficients in Log2 
parameter cWI = 2;         //fractional part for coefficients in Log2
parameter aWF = 28;        //integer part for accumulator in Log2
parameter aWI = 2;         // fractional part for accumulator in Log2
parameter SignedDatapath = 1; // the memory coefficients has negetive values in Log2
parameter noSegBits = 12;  //Addressing data bits    

reg [xWI+xWF-1:0] inLog2;
wire [xWI+xWF-1:0] tempBase2;
parameter WL = WI + WF;
parameter xWL = xWI + xWF;
  
always @(*) begin  
   if (WL > xWL) begin  
       inLog2 = in_s[WI+WF-1:(WI+WF-1)-(xWI+xWF-1)];
   end
   else if(WL == xWL) begin  
          inLog2 = in_s;
     end
     else begin
          inLog2 = {in_s, {(xWL - WL){1'b0}}};
     end
end
      
Log2 #( .xWF(xWF),         //integer part for input and output
        .xWI(xWI),          //fraction part for input and output
        .cWF(cWF),        //integer part for coefficients
        .cWI(cWI),         //fractional part for coefficients
        .aWF(aWF),        //integer part for accumulator
        .aWI(aWI),         // fractional part for accumulator
        .SignedDatapath(SignedDatapath), // the memory coefficients has negetive values
        .noSegBits(noSegBits))     
                                log2Norm    
                                            (.Number(inLog2),    //Input
                                             .Rst(Rst),
                                             .Base2(tempBase2)); // Output Log base 2
    
//------------------------------------Denormalization------------------------// 
// Adding the shift to normalized log2 integer part will give denormalize log2 value      

integer signed negShift;

always @(*) begin
    negShift = -shift;
end

parameter dWI = 8;
reg signed [(dWI-1):0] tempS1;
reg signed [(dWI-1):0] tempS2;
reg signed [(dWI+WF-1):0] DenormFactor1;
reg signed [(dWI+WF-1):0] DenormFactor2;
reg signed [(xWI+xWF-1):0] tempLog2;

 
always @(*) begin
    tempS1 = negShift;
    DenormFactor1 = {tempS1,{(WF){1'b0}}};
    tempS2 = shift;
    DenormFactor2 = {tempS2,{(WF){1'b0}}};
    tempLog2 = tempBase2;
end

reg signed [(xWI+xWF-1):0] regA1;
reg signed [(dWI+WF-1):0] regB1;
wire signed [(WIO+WFO-1):0] tempDenormLog2_1;                                          

reg signed [(xWI+xWF-1):0] regA2;
reg signed [(dWI+WF-1):0] regB2;
wire signed [(WIO+WFO-1):0] tempDenormLog2_2;                                          

reg signed [(WIO+WFO-1):0] DenormLog2;
    
FixedPoint_Adder #(.WI1(xWI), //INPUT-1 integer length
                   .WF1(xWF), //INPUT-1 fraction length
                   .WI2(dWI), //INPUT-2 integer length
                   .WF2(WF), //INPUT-2 fraction length
                   .WIO(WIO), //OUTPUT integer  length
                   .WFO(WFO)) //OUTPUT fraction length
                              DenormAdder
                                            (.in1(regA1),
                                             .in2(regB1),
                                             .overFlow(),
                                             .FixedPoint_Add_Out(tempDenormLog2_1));

FixedPoint_Subtractor #(.WI1(xWI), //INPUT-1 integer length
            .WF1(xWF), //INPUT-1 fraction length
            .WI2(dWI), //INPUT-2 integer length
            .WF2(WF), //INPUT-2 fraction length
            .WIO(WIO), //OUTPUT integer  length
            .WFO(WFO)) //OUTPUT fraction length
                DenormSubstractor   
                              (.in1(regA2),//minuend
                               .in2(regB2),//subtrahend
                               .overFlow(),
                               .FixedPoint_Sub_Out(tempDenormLog2_2));

always @(*) begin
 if (shift < 0)begin
    regA1 = tempLog2;
    regB1 = DenormFactor1;
    DenormLog2 = tempDenormLog2_1;
    end
    else if (shift == 0) begin
    regA1 = tempLog2;
    regB1 = DenormFactor1;
    DenormLog2 = tempDenormLog2_1;           
    end
    else begin
    regA2 = tempLog2;
    regB2 = DenormFactor2;
    DenormLog2 = tempDenormLog2_2;
    end 
   end

//------------------------------------Convert to Base 10-----------------//
parameter base10factor = 25'b00_01001101000100000100110;
wire signed [(WIO+WFO-1):0] tempBase10; 
    
fpMult1 #(.WI1(xWI),   //length of the integer part, operand 1
      .WF1(xWF),   //length of the fraction part, operand 1
      .WI2(WIO),   //length of the integer part, operand 2
      .WF2(WFO),    //length of the fraction part, operand 2
      .WIO(WIO),    
      .WFO(WFO))    
                 Multiplier1
                             (.RST(Rst),
                              .in1(base10factor),
                              .in2(DenormLog2),
                              .out(tempBase10));
    
always @(*) begin
  if (!Rst) begin
      Base10 = 0; 
  end
  else begin
      Base10 = tempBase10;
  end
end 
    
endmodule
