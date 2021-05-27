`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University
// Engineer:    Pratik Yadav  
// 
// Create Date: 03/02/2016 06:12:36 PM
// Design Name: 
// Module Name: tb_Log2
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

module tb_Log2;

parameter xWF = 23;         //integer part for input and output
parameter xWI = 2;          //fraction part for input and output
parameter cWF = 26;        //integer part for coefficients
parameter cWI = 2;         //fractional part for coefficients
parameter aWF = 28;        //integer part for accumulator
parameter aWI = 2;         // fractional part for accumulator
parameter SignedDatapath = 1; // the memory coefficients has negetive values
//parameter p = 1;              // Polynomial order
parameter noSegBits = 12;   
    
reg [xWF+xWI-1:0] Number;
reg Rst;
wire [xWF+xWI-1:0] Base2;

Log2 #( .xWF(xWF),          //integer part for input and output
        .xWI(xWI),          //fraction part for input and output
        .cWF(cWF),          //integer part for coefficients
        .cWI(cWI),          //fractional part for coefficients
        .aWF(aWF),          //integer part for accumulator
        .aWI(aWI),          // fractional part for accumulator
        .SignedDatapath(SignedDatapath), // the memory coefficients has negetive values
        .noSegBits(noSegBits))     
                            Log2Test                            
                                        (.Number(Number),    //Input
                                         .Rst(Rst),
                                         .Base2(Base2)); // Output Log base 2
                                           
	real in_Number;
    real Out_Log2;
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
                                           
//initial begin
//    $readmemb("Row0.txt",tb_Log2.Log2Test.ramCoefFP_Log2x_row0);
//    $readmemb("Row1.txt",tb_Log2.Log2Test.ramCoefFP_Log2x_row1);
//end

initial begin
Number = 0;
Rst = 0;
#100;Rst = 1; Number = 25'b01_10101000111101011100001;
#100;
$finish; 
end

always @(*)begin
    in_Number = fixedToFloat(Number,xWI,xWF);
    Out_Log2 = fixedToFloat(Base2,xWI,xWF);
end
    
endmodule
