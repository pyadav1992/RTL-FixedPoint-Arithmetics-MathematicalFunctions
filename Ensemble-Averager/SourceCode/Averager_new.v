`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     San Diego State University
// Engineer:    Pratik Yadav
// 
// Create Date: 03/30/2016 06:15:20 PM
// Design Name: 
// Module Name: Averager
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

module Averager_new
#(parameter WI = 12,
            WF = 12,
            WIO = 12,
            WFO = 12,
            winS = 1024)    
                        (
                        input signed[(WI+WF-1):0] in,       // input ensemble
                        input Clk,                          // Clock
                        input Rst,                          // Reset
                        output reg signed [(WIO+WFO-1):0] Out, // Averaged output
                        //input handshaking
                        input Valid_in,
                        output reg Ready_in,
                        //output handshaking
                        output reg Valid_out,
                        input Ready_out);

// Memories for accumulating and storing output
(* RAM_style = "block" *) reg signed [(WI+WF-1):0] Accumulate [0:(winS-1)];
(* RAM_style = "block" *) reg signed [(WI+WF-1):0] tempAlpha [0:(winS-1)];

// counter registers
reg [9:0] m;
reg [9:0] i1;
reg [9:0] i1_mem;
reg [9:0] i2;
reg [9:0] i2_mem;
reg [9:0] i3;
reg flag1;
reg flag2;
reg [2:0] State;
localparam S0 = 0;
localparam S1 = 1;
localparam S2 = 2;
localparam S3 = 3;
localparam S4 = 4;

//====================Averager============================================//
localparam M = 16;
localparam Alpha = 16'b00_11100110011001;  //Alpha = (1-(1/M))       
reg signed [(WI+WF-1):0] regMult1;
wire signed [(WI+WF-1):0] wireMult1;

(* DONT_TOUCH = "yes" *)  
fpMult   #( .WI1(WI), //length of the integer part, operand 1
            .WF1(WF), //length of the fraction part, operand 1
            .WI2(2), //length of the integer part, operand 2
            .WF2(14), //length of the fraction part, operand 2
            .WIO(WI),        
            .WFO(WF)) 
                    UUT_exp_Averaging_Mult1       
                                            (//.RST(Rst),
                                             .in1(regMult1),
                                             .in2(Alpha),
                                             .out(wireMult1));        

reg signed [(WI+WF-1):0] regAdd1;
reg signed [(WI+WF-1):0] regAdd2;
wire signed [(WI+WF-1):0] WireAdder;
FixedPoint_Adder #(.WI1(WI), //INPUT-1 integer length
                   .WF1(WF), //INPUT-1 fraction length
                   .WI2(WI), //INPUT-2 integer length
                   .WF2(WF), //INPUT-2 fraction length
                   .WIO(WI), //OUTPUT integer  length
                   .WFO(WF)) //OUTPUT fraction length
                           UUT_exp_Averaging_Adder
                                             (.in1(regAdd1),
                                              .in2(regAdd2),
                                              .overFlow(),
                                              .Rst(Rst),
                                              .FixedPoint_Add_Out(WireAdder)); 
                                              
always @(posedge Clk) begin
    if(!Rst) begin
        State <= S0;
        m  <= 0; 
        i1 <= 0;
        i2 <= 0;
        i3 <= 0;
        flag1 <= 1'b0;
        flag2 <= 1'b0;
        Ready_in <= 1'b0;
        Valid_out <= 1'b0;
    end
    else begin
        case(State)            
            S0: begin
                  State <= S1;
                  i1 <= 0;
                  i1_mem <= 0;
                  i2 <= 0;
                  i2_mem <= 0;
                  i3 <= 0;  
                  flag1 <= 1'b0;
                  flag2 <= 1'b0;
                  Ready_in <= 1'b0;
                  Valid_out <= 1'b0;
                end
            
            S1: begin  
                   flag1 <= 1'b1;     
                   if(i1 < (winS-1)) begin
                      i1 <= i1 + 1;
                      State <= S1;
                   end
                  if(flag1)begin
                    if(i1_mem < (winS-1)) begin
                       i1_mem <= i1_mem + 1;
                       State <= S1; 
                    end
                    else begin
                       flag1 <= 1'b0; 
                       // i2 <= 0;
                       State <= S2;
                       Ready_in <= 1'b1;  
                    end
                  end
                end
                
            S2: begin
                if (Valid_in) begin
                    flag2 <= 1'b1;
                    if(i2 < (winS-1)) begin
                         i2 <= i2 +1;
                         State <= S2;
                    end
                end
                if(flag2)begin
                  if(i2_mem < (winS-1)) begin
                      i2_mem <= i2_mem + 1;
                      State <= S2;  
                  end
                  else begin
                     flag2 <= 1'b0;
                     State <= S3; 
                     Ready_in <= 1'b0;
                     m <= m + 1;
                     i3 <= 0;
                  end
                end
                end
            
            S3: begin
                    if (m < (M)) begin
                        State <= S0;
                    end
                    else begin
                        State <= S4;
                        m <= 0;
                        i3 <= 0;
                    end
                end
           
           S4: begin
                 Valid_out <= 1'b1;
                 if (Ready_out == 1'b1) begin
                    if (i3 < (winS-1)) begin
                        i3 <= i3 + 1;
                        State <= S4;
                    end   
                    else begin
                        State <= S0;
                    end
                 end
                 else begin
                    State <= S4;
                 end
               end  
               
          default: begin
                   end                     
        endcase  
    end
end

always @(posedge Clk) begin
    if(!Rst) begin
        regAdd1 <= 0;
        regAdd2 <= 0;
        regMult1 <= 0;
        Out <= 0;
        $readmemb("C:/Users/YadavP15/Desktop/Verilog/SpectrumSensing_Polyphase/SpectrumSensing_Polyphase/SpectrumSensing_Polyphase.srcs/sources_1/new/Polyphase/zeroing.txt",Accumulate);
        $readmemb("C:/Users/YadavP15/Desktop/Verilog/SpectrumSensing_Polyphase/SpectrumSensing_Polyphase/SpectrumSensing_Polyphase.srcs/sources_1/new/Polyphase/zeroing.txt",tempAlpha);
        // regMult2 <= 0;
    end
    else begin
        case(State)
            S0: begin
                end
            
            S1: begin
                 regMult1 <= Accumulate[i1];
                 if(flag1)begin
                    tempAlpha[i1_mem] <= wireMult1;
                 end
                end
            
            S2: begin
                if (Valid_in) begin
                  regAdd1  <= in;
                  regAdd2  <= tempAlpha[i2];
                end
                if (flag2) begin  
                  Accumulate[i2_mem]  <= WireAdder;
                end
                end
                
            S3: begin 
                end
           
            S4: begin
                Out <= Accumulate[i3];
                end  
                   
          default: begin
                   end                     
        
        endcase  
    end
end
                            
endmodule