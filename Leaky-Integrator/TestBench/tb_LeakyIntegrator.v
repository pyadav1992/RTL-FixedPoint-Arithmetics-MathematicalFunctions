`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University  
// Engineer:    Pratik Yadav
// 
// Create Date: 02/24/2016 03:45:57 PM
// Design Name: 
// Module Name: tb_LeakyIntegrator
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


module tb_LeakyIntegrator2;

parameter WI = 8;
parameter WF = 32;

reg [(WI+WF-1):0] InLeaky;
reg Clk;
reg LIdvi;
wire [(WI+WF-1):0] OutSmooth;
wire LIdvo;

parameter Clockperiod = 10;
initial Clk = 0;
always #(Clockperiod/2) Clk = ~Clk;

LeakyIntegrator2           
#(.WI(WI),
  .WF(WF))
          UUTLeakyIntegrator2 (.InLeaky(InLeaky),
                              .Clk(Clk),
                              .LIdvi(LIdvi),
                              .OutSmooth(OutSmooth),
                              .LIdvo(LIdvo)
                              );

real Input;
real Output;
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


parameter data_width = 40;
parameter addr_width = 1008;
reg [(data_width-1):0] rom1 [addr_width-1:0];

initial begin
$readmemb ("TestingLeakyInt.txt",rom1);
end

integer i1;
  
initial begin
    LIdvi = 0;
    InLeaky = 0;

for (i1 = 0; i1<1008; i1 = i1 + 1) begin
    @(posedge Clk);LIdvi = 1; InLeaky = rom1[i1];
end
          
end

always @(posedge Clk) begin
    Input = fixedToFloat(InLeaky,WI,WF);
    Output = fixedToFloat(OutSmooth,WI,WF);
    $display(Output);
end
endmodule
