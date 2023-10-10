module deneme2 #( 
        parameter integer CNT_ONESEC = 1_000_000
)

(
input wire i_clk,       // saat isareti
input wire i_rst_n,     // sifirlama isareti
input wire i_data,      // girdi isareti

output reg o_data       // çikti isareti

 );

 reg [$clog2(CNT_ONESEC) -1: 0] cnt_posedge;

 reg[1:0] state;
 
localparam
    RST     = 2'b00,
    IDLE    = 2'b10,
    CNTR    = 2'b11,
    STOP    = 2'b10;

always @(posedge i_clk)
begin
    if (! i_rst_n) begin
        state <= RST;
        cnt_posedge <=0;
        o_data <=0;
    end // i_rst_n if
    else
    begin
        case(state)
            RST:
            begin
                state <= IDLE;
                cnt_posedge <=0;
                o_data <=0;
            end // RST
            
            IDLE:
            begin
                if (i_data ==1)
                    begin
                        state <= CNTR;
                    end // i_data if
                else
                    begin
                        state <=IDLE;
                    end // i_data else
            end // IDLE
            
            CNTR:
            begin
                if (!i_data)
                begin
                    state <=IDLE;
                end // i_data if
                else if(cnt_posedge == CNT_ONESEC)
                begin
                    state <= STOP;
                    cnt_posedge<=0;
                end // cnt_posedge else if
                else
                begin
                    cnt_posedge <= cnt_posedge +1;
                    state <= CNTR;
                end // i_data else
                
            end // CNTR
            
            STOP:
            begin
             o_data <=1;
             state <=STOP;
            end // STOP 
            
            default:
            begin
            state <=RST;
            end //default
        
        endcase // state case
    
    end // i_rst_n else

end // always
    
endmodule
