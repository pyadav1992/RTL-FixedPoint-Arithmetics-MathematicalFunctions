`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University
// Engineer:    Pratik Yadav
// 
// Create Date: 02/21/2016 05:13:16 PM
// Design Name: 
// Module Name: tb_ceil
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

module tb_ceil;

parameter WI = 3;
parameter WF = 4; 

reg [(WI+WF-1):0] A;
wire [(WI+WF-1):0] ceilout;
wire oflag;

real Areal, Ceilreal;
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

ceil #(.WI(WI),
       .WF(WF)) UUT_ceil (.A(A),  
                          .oflag(oflag),
                          .ceilout(ceilout));
                          
initial begin
    A = 7'b000_1000;
    #10; A = 7'b111_1000;
    #10; A = 7'b100_0000;
    #10; A = 7'b110_0001;
    #10; A = 7'b111_1100;
    #10; A = 7'b100_0011;
    #10; A = 7'b001_0000;
    #10; A = 7'b011_1100;
    #10; A = 7'b011_1101;
    #10; A = 7'b010_1101;
    $finish;
end

always @(*) begin
    Areal = fixedToFloat(A,WI,WF);
    Ceilreal = fixedToFloat(ceilout,WI,WF);
end

endmodule
