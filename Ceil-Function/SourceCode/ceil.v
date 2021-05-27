`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State  University
// Engineer:    Pratik Yadav
// 
// Create Date: 02/21/2016 03:43:26 PM
// Design Name: 
// Module Name: ceil
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

module ceil
 #(parameter WI = 8,
             WF = 32)   
(
input signed [(WI+WF-1):0] A,
output reg signed [(WI+WF-1):0] ceilout,
output reg oflag
);
    
reg signed [(WI-1): 0] Int;
reg [(WF-1): 0] Frac;
reg signed [(WI-1): 0] one;
reg signed [(WI-1): 0] mod;
reg [(WI-1): 0] com;

// Separate out integer and fractional 
// Part of the input  
always @(*) begin
  Int = A[(WI+WF-1): WF];
  Frac = A[(WF-1): 0];
  one = {{(WI-1){1'b0}},{1'b1}};
  com = {1,{(WI-1){1'b0}}};
end

// Check for fractional part 
// overflow and round to ceil 
always @(*) begin     
if (Frac > 0) begin  
  mod = Int + one;
  if (mod == com)begin
     oflag = 1'b1;
  end
  else begin
     oflag = 1'b0;
  end 
  end  
  else begin
     mod = Int;
     oflag = 1'b0;
  end
end

always @(*) begin
 ceilout = {mod,{(WF){1'b0}}}; 
end
    
endmodule
