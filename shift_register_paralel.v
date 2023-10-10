// 8 bit pshift register
module sh_8_bit_hdl( 
    input clk,
    input [7:0] data,
    input rst,
    output reg [15:0] data_out
    );
    
    always @(posedge clk or posedge rst)
        begin
            if (rst) 
                begin
                    data_out <= 16'b0000000010101010; // Initial value: 0000000010101010
                end 
            else 
                begin
                    data_out [7:0] <= data[7:0];
                    data_out <= data_out << 8; // Shift left by 8 bits
                end
        end
endmodule
