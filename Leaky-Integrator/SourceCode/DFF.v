`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        San Diego State University
// Engineer:       Pratik Yadav
// 
// Create Date:    11:35:58 03/16/2015 
// Design Name: 
// Module Name:    DFF 
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
module DFF 
#(parameter BW = 9)
  (
    input signed [BW-1:0]d,
    input CLK,RESET,
    output reg signed [BW-1:0] q
  );
       
always @(posedge CLK ) begin
  if (!RESET)
    q <= 0;
  else
    q <= d;
end
  
endmodule
