`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:       San Diego State University
// Engineer:      Uday A Korat
// GitHub:        (https://github.com/ukorat/FixedPoint_Arithmetic)
// Create Date:   15:36:49 03/04/2015 
// Design Name:   
// Module Name:    FixedPoint_Adder 
// Project Name:   Fixed_Point_Library
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

`define WIO1 (WIO >= 2)? (WIO+frc_len-2) : frc_len

`define Max_len ((int_len+frc_len-2)>= (WIO+frc_len-1)) ? (int_len+frc_len-2) : (WIO+frc_len-1)

`define trun_size (WIO < int_len)? ((int_len+frc_len-1)-(WIO+frc_len-1)) : 1

module FixedPoint_Adder #(parameter WI1 = 3,  //INPUT-1 integer length
              WF1 = 4,                        //INPUT-1 fraction length
              WI2 = 4,                        //INPUT-2 integer length
              WF2 = 3,                        //INPUT-2 fraction length
              WIO = (WI1>WI2)? WI1+1:WI2+1,   //OUTPUT integer  length
              WFO = (WF1>WF2)? WF1:WF2)       //OUTPUT fraction length
                 (input signed [WI1+WF1-1:0] in1,
                  input signed [WI2+WF2-1:0] in2,
                  output reg overFlow,
                  output  reg signed [WIO+WFO-1:0] FixedPoint_Add_Out);

parameter int_len = (WI1>WI2)? WI1:WI2; //width for integer part of sum 
parameter frc_len = (WF1>WF2)? WF1:WF2; // width for fraction part of sum

reg [int_len+frc_len-1:0] reg_in1;      //register for INPUT1 = IN1
reg [int_len+frc_len-1:0] reg_in2;      //register for INPUT2 = IN2

reg [int_len+frc_len-1:frc_len] int_in1; //register for Integer part of IN1
reg [int_len+frc_len-1:frc_len] int_in2; // register for Integer part of IN2

reg [frc_len-1:0] frc_in1;               //register for Fraction part of IN1
reg [frc_len-1:0] frc_in2;               //register for Fraction part of IN2

//reg [(`trun_size)-1:0] reg_trun;
//reg [(`trun_size)-1:0] reg_sign;                  

wire [int_len+frc_len:0] tmp; // wired connection of SUM
reg sign_bit;

reg [WIO-1:0] int_out; // Integer register for output SUM
reg [WFO-1:0] frc_out; // Fraction part register for output SUM

//---------------------------------------------------------------------------//
//ADJUSTING NUMBERS TO MAKE EQUAL RADIX POINT PLACE

//--------------------------------------------------------------------------//
//INTEGER adjustment

  always @* begin
    
    if (WI1 < WI2) begin
      int_in1 = {{(WI2-WI1){in1[WI1+WF1-1]}}, in1[WI1+WF1-1:WF1]};
      int_in2 = in2[WI2+WF2-1:WF2];
    end
    else if (WI1 == WI2) begin
        int_in1 = in1[WI1+WF1-1:WF1];
        int_in2 = in2[WI2+WF2-1:WF2];
    end
    else begin
      int_in2 = {{(WI1-WI2){in2[WI2+WF2-1]}}, in2[WI2+WF2-1:WF2]};
      int_in1 = in1[WI1+WF1-1:WF1];
    end
  end
//--------------------------------------------------------------------------//
//FRACTION adjustment

  always @* begin
  
    if (WF1 < WF2) begin
      frc_in1 = { in1[WF1-1:0], {(WF2-WF1){1'b0}}};
      frc_in2 = in2[WF2-1:0];
    end
     else if (WF1 == WF2) begin
         frc_in1 = in1[WF1-1:0];
         frc_in2 = in2[WF2-1:0];
     end
    else begin
      frc_in2 = {in2[WF2-1:0], {(WF1-WF2){1'b0}}};
      frc_in1 = in1[WF1-1:0];
    end
  end

//--------------------------------------------------------------------------//
//new adjusted NUMBERS

  always @* begin
    
    reg_in1 = {int_in1 , frc_in1};
    reg_in2 = {int_in2 , frc_in2};
  
  end
  
//--------------------------------------------------------
// ADDITION of bit adjusted two input
  assign tmp = reg_in1 + reg_in2;
  
//----------------------------------------------------------------------//
//adjust bits for OUTPUT_FRACTION as user define output fraction bitwidth
//padding with zero or truncation from least significant bits

always @* begin
            
    if (WFO > frc_len) begin
      frc_out = {tmp[frc_len-1:0], {(WFO-frc_len){1'b0}}};
    end
    else if (WFO == frc_len) begin
         frc_out = tmp[frc_len-1:0];
    end
    else begin //(WFO<frc_len)
      frc_out = tmp[frc_len-1:frc_len-WFO];
    end
  
  end
  
//--------------------------------------------------------------------//
// signbit of OutPut

  always @* begin
    
    if ((in1[WI1+WF1-1] == in2[WI2+WF2-1])) begin
        sign_bit = tmp[int_len+frc_len];
    end
    else begin
        sign_bit = tmp[int_len+frc_len-1];
    end
  end

//--------------------------------------------------------------------//
//OUTPUT_INTEGER SignBit Padding , Truncation and Overflow conditions
  
  always @* begin 
    
    if (WIO >= int_len) begin
      if ((in1[WI1+WF1-1] == in2[WI2+WF2-1])) begin
      
        int_out = {{(WIO-int_len){sign_bit}} , tmp[int_len+frc_len-1:frc_len] }; 
        
          if (int_out[WIO-1] == in1[WI1+WF1-1]) begin// overflow checking for corner case
            overFlow = 1'b0;
          end
          else begin
            overFlow = 1'b1;
          end
      end
      
      else begin
        int_out = {{(WIO-int_len){sign_bit}} , tmp[int_len+frc_len-1:frc_len] };
        overFlow = 1'b0;
      end
        
    end
    
    else begin // (WIO<int_len)
      
      if (WIO == 1) begin
        int_out = {sign_bit}; //Signbit only for integer part if WIO = 1
      end
      else begin
        int_out = {sign_bit , tmp[`WIO1:frc_len]};
      end
    end
  end

//-----------------------------------------------------------------------//
//overFlow
// comparison of truncated bit and sign bit to check error in output and
// generate overflow
  
  always @* begin
    
    if(WIO < int_len) begin
    
        if ( tmp[`Max_len: WIO+frc_len-1] == ({(`trun_size){tmp[int_len+frc_len-1]}})) begin
            overFlow = 1'b0;
        end
        else begin
            overFlow = 1'b1;
        end
    end
  end
//------------------------------------------------------------------//
// Final Answer with truncation and adjustment

  always @* begin
      FixedPoint_Add_Out <= {int_out,frc_out};
    end
    
endmodule