// 4 Bitlik bir multiplaxer
module mux4#( 
    parameter bitNo = 4,
    parameter selNo = $clog2(bitNo)
    )(
    input wire[bitNo-1:0] d, // input pins
    input wire[selNo-1:0] sel, // select pins
    input wire ene, // enable pin
    output reg y // output pin
    );
    
    always@(sel,ene,d)
    if (ene)
        begin 
            case(sel)
                2'b00: y = d[0];
                2'b01: y = d[1];
                2'b10: y = d[2];
                2'b11: y = d[3];
            endcase
        end

endmodule
