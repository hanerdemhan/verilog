//LMT01

module sicaklik_sensor(clk, i_sicaklik, reset_count, sicaklik_o);
input i_sicaklik; // Data input 
input  clk; // clock input 
input  reset_count;
output reg [7:0] sicaklik_o; //= 24'h000000;

reg [23:0] counter_sicaklik; //= 24'h000000;
reg Q1;  //=1'b0;
reg D_ff_out; //= 1'b0; //output of D flip flops
parameter ss1 = 1'b0;
parameter ss2 = 1'b1;

reg state; //= ss1;
reg [11:0] time60_2; //= 12'b000000000000;
reg[31:0] timersec; //= 32'h00000000;
reg tim_en; //= 1'b0;

always @(posedge clk) 
begin // input sinyalini 2 tane D flip flop'tan ge?irdik metastabiliteyi ?nlemek i?in
     if(reset_count==1'b0) 
        begin
            Q1 <= 1'b0;
            D_ff_out <= 1'b0;
        end
        else
        begin
             Q1 <= i_sicaklik;
             D_ff_out <= Q1; 
        end
end
//--------------------------------- 100 miliSANIYEDE BIR KERE COUNTERLARI RESETLEMEK ICIN-------------------------------
always @(posedge(clk))
begin
    if(reset_count==1'b0) 
    begin
        timersec <= 24'h000000;
        tim_en <= 1'b0;
    end
    else
    begin
        
            if(timersec == 24'hC34FFF) // 100 mili saniye için clock
                begin
                    timersec <= 24'h000000;
                    tim_en <= 1'b1;
                end
                else 
                begin
                     timersec <= timersec + 24'h000001;
                     tim_en <= 1'b0;
                end
        
    end
end
//--------------------------------- 100 miliSANIYEDE BIR KERE COUNTERLARI RESETLEMEK ICIN-------------------------------
//------------------------ COUNTER_sicaklik 100 miliSANIYEDE BIR RESETLENIYOR-------------------------------------
always@(posedge clk) 
begin
        if(reset_count == 1'b0 || tim_en==1'b1) begin  
            state <= ss1;
            time60_2 <= 12'b000000000000;
            counter_sicaklik <= 24'h000000;
        end
        else begin
            
                case(state)
                    ss1: if(D_ff_out == 1'b1)begin
                            state <= ss2;
                            counter_sicaklik <= counter_sicaklik + 24'h000001;
                        end
                        else begin
                            state <= ss1;
                        end
                    ss2: if (time60_2 == 12'h5A9) begin //  time deadtime cycle number (88336 clock for 128MHz)
                            state <= ss1;
                            time60_2 <= 12'b000000000000;
                        end
                        else begin
                            time60_2 <= time60_2 + 12'b000000000001;
                            state <= ss2;
                        end

                    default : begin
                            state <= ss1;
                            time60_2 <= 12'b000000000000;
                            counter_sicaklik <= 24'h000000; end
                endcase
            
        end
end 
//------------------------ COUNTER_sickalik 100  MILISANIYEDE BIR RESETLENIYOR-------------------------------------
//--------------------PULSE TOPLAMNLAR 100 MILISANIYEDE 1 EKLENIYOR---------------------------------------
always @(posedge(clk))
begin
    if(reset_count == 1'b0 )
    begin
        sicaklik_o    <= 8'h00;
      
    end
    else begin
        if (tim_en==1'b1) begin // 1 SANIYEDE BIR KERE DEGERLER EKLENECEK
            sicaklik_o    <= (((counter_sicaklik*256)/4096)-50); 
                              
        end
    end
end
//--------------------PULSE TOPLAMNLAR 100 MILISANIYEDE 1 EKLENIYOR---------------------------------------
endmodule
