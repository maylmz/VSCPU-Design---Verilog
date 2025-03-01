`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:16:31 05/31/2024 
// Design Name: 
// Module Name:    TinyMIPS 
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
//
//////////////////////////////////////////////////////////////////////////////////
// Code your design here
module TinyMIPS(
    input clk, 
    input rst, 
    input [15:0] data_fromRAM, 
    output reg wrEn, 
    output reg [7:0] addr_toRAM, 
    output reg [15:0] data_toRAM
);
    reg [2:0] st, stN;
    reg [7:0] PC, PCN;
    reg [15:0] IW, IWN;
    reg [15:0] T1, T1N, T2, T2N;

    reg [15:0] RF [7:0];  // Register File
  
  	
  	

    always @(posedge clk) begin
			if (rst) begin
			st <= 3'd0;
			PC <= 8'd0;
			IW <= 16'd0;
			T1 <= 16'd0;
			T2 <= 16'd0;
			end else begin
			st <= stN;
			PC <= PCN;
			IW <= IWN;
			T1 <= T1N;
			T2 <= T2N;
			end
    end

    always @* begin
            wrEn = 1'b0;
            PCN = PC;
            IWN = IW;
            stN = 3'd0;
            addr_toRAM = 8'hX;
            data_toRAM = 16'hX;
            T1N = T1;
            T2N = T1;

        case (st)
                3'd0: begin // S0: Fetch State
                    addr_toRAM = PC;
                    stN = 3'd1;
                end
                3'd1: begin // S1 State
                    IWN = data_fromRAM;
                    case (data_fromRAM[15:12])
                        4'b0000: begin // ADD
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0001: begin // ADDi
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0010: begin // MUL
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0011: begin // SRL
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0100: begin // LD
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0101: begin // ST
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0110: begin // CP
                            T1N = RF[data_fromRAM[8:6]];
                            stN = 3'd2;
                        end
                        4'b0111: begin // CPi
                            RF[data_fromRAM[11:9]] = {7'd0, data_fromRAM[8:0]};
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b1000: begin // BEQ
                            T1N = RF[data_fromRAM[11:9]];
                            stN = 3'd2;
                        end
                        4'b1001: begin // BLT
                            T1N = RF[data_fromRAM[11:9]];
                            stN = 3'd2;
                        end
                        4'b1010: begin // BGT
                            T1N = RF[data_fromRAM[11:9]];
                            stN = 3'd2;
                        end
                    endcase
                end
                3'd2: begin // S2 State
                    case (IW[15:12])
                        4'b0000: begin // ADD
                            T1N = T1;
                            T2N = RF[IW[5:3]];
                            stN = 3'd3;
                        end
                        4'b0001: begin // ADDi
                            RF[IW[11:9]] = T1 + {{2{IW[5]}}, IW[5:0]};
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b0010: begin // MUL
                            T1N = T1;
                            T2N = RF[IW[5:3]];
                            stN = 3'd3;
                        end
                        4'b0011: begin // SRL
                            T1N = T1;
                            T2N = RF[IW[5:3]];
                            stN = 3'd3;
                        end
                        4'b0100: begin // LD
                            addr_toRAM = T1 + {{2{IW[5]}}, IW[5:0]};
                            stN = 3'd3;
                        end
                        4'b0101: begin // ST
                            addr_toRAM = T1 + {{2{IW[5]}}, IW[5:0]};
                            data_toRAM = RF[IW[11:9]];
                            wrEn = 1'b1;
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b0110: begin // CP
                            RF[IW[11:9]] = T1;
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b1000: begin // BEQ
                            T2N = RF[IW[8:6]];
                            T1N = T1;
                            stN = 3'd3;
                        end
                        4'b1001: begin // BLT
                            T2N = RF[IW[8:6]];
                            T1N = T1;
                            stN = 3'd3;
                        end
                        4'b1010: begin // BGT
                            T2N = RF[IW[8:6]];
                            T1N = T1;
                            stN = 3'd3;
                        end
                    endcase
                end
                3'd3: begin // S3 State
                    case (IW[15:12])
                        4'b0000: begin // ADD
                            RF[IW[11:9]] = T1 + T2;
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b0010: begin // MUL
                            RF[IW[11:9]] = T1 * T2;
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b0101: begin //ST
                          T2N = T2;
                          T1N = T1;
                          wrEn = 1'b1;
                          addr_toRAM = T2;
                          data_toRAM = RF[IW[11:9]];       
                          PCN = PC + 8'd1;
                          stN = 3'd0;
                        end  
                      	4'b0011: begin // SRL
                            RF[IW[11:9]] = (T2 < 32) ? (T1 >> T2) : (T1 << (T2 - 32));
                            PCN = PC + 8'd1;
                            stN = 3'd0;
                        end
                        4'b0100: begin // LD
                          	T1N = T1;
                            T2N = T2;
                          	addr_toRAM = T2;
                            RF[IW[11:9]] = data_fromRAM;
                            PCN = PC + 8'd1;
                        end
                        4'b1000: begin // BEQ
                            PCN = (T1 == T2) ? (PC + {{2{IW[5]}}, IW[5:0]}) : (PC + 8'd1);
                            stN = 3'd0;
                        end
                        4'b1001: begin // BLT
                            PCN = (T1 < T2) ? (PC + {{2{IW[5]}}, IW[5:0]}) : (PC + 8'd1);
                            stN = 3'd0;
                        end
                        4'b1010: begin // BGT
                            PCN = (T1 > T2) ? (PC + {{2{IW[5]}}, IW[5:0]}) : (PC + 8'd1);
                            stN = 3'd0;
                        end
                          
                        default: begin
                          stN = 3'd0;
                        end
                    endcase
                end
            endcase
        end
    
endmodule

module blram(clk, rst, we, addr, din, dout);
    
    input clk;
    input rst;
    input we;
  	input [7:0] addr;
    input [15:0] din;
    output reg [15:0] dout;
    
  	parameter SIZE = 8, DEPTH = 2**SIZE;

    reg [15:0] mem [DEPTH-1:0];

    always @(posedge clk) begin
        dout <= mem[addr];
        if (we)
            mem[addr] <= din;
    end
endmodule
