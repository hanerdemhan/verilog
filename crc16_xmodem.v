module crc16_xmodem(
input clk,
input wire [7:0] crc_in [0:X],
output reg [15:0] crc
);

always @(posedge clk) begin
    integer y;
    reg [15:0] crc_reg;
    
    crc_reg = 16'h0000;
    
    for (y = 0; y < (X+1); y = y + 1) begin
        crc_reg = crc_reg ^ (crc_in[y] << 8);
        
        for (integer j = 0; j < 8; j = j + 1) begin
            if (crc_reg[15] == 1'b1) begin
                crc_reg = crc_reg << 1 ^ 16'h1021;
            end else begin
                crc_reg = crc_reg << 1;
            end
        end
    end

    crc = crc_reg;
end
endmodule
