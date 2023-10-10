
module pulse_sensor(clk, i_pulse, reset_count, pulse_o);
input i_pulse; // Pulse girişi 
input clk; // Saat girişi
input reset_count;
output reg [7:0] pulse_o; //= 24'h000000;

reg [23:0] counter_pulse; //= 24'h000000;
reg Q1;  //=1'b0;
reg D_ff_out; //= 1'b0; // D flip flop'un çıkışı
parameter ps1 = 1'b0;
parameter ps2 = 1'b1;

reg state; //= ps1;
reg [11:0] time60_2; //= 12'b000000000000;
reg[31:0] timersec; //= 32'h00000000;
reg tim_en; //= 1'b0;

always @(posedge clk) 
begin // Giriş sinyalini iki D flip flop üzerinden geçiriyoruz, metastabiliteyi önlemek için
     if(reset_count == 1'b0) 
        begin
            Q1 <= 1'b0;
            D_ff_out <= 1'b0;
        end
        else
        begin
             Q1 <= i_pulse;
             D_ff_out <= Q1; 
        end
end

//--------------------------------- 100 milisaniyede bir sayaçları sıfırlamak için-------------------------------
always @(posedge(clk))
begin
    if(reset_count == 1'b0) 
    begin
        timersec <= 24'h000000;
        tim_en <= 1'b0;
    end
    else
    begin
        if(timersec == 24'hC34FFF) // 100 milisaniye için saat
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
//--------------------------------- 100 milisaniyede bir sayaçları sıfırlamak için-------------------------------

//------------------------ COUNTER_pulse 100 milisaniyede bir sıfırlanıyor-------------------------------------
always @(posedge clk) 
begin
        if(reset_count == 1'b0 || tim_en == 1'b1) begin  
            state <= ps1;
            time60_2 <= 12'b000000000000;
            counter_pulse <= 24'h000000;
        end
        else begin
            
            case(state)
                ps1: if(D_ff_out == 1'b1)begin
                        state <= ps2;
                        counter_pulse <= counter_pulse + 24'h000001;
                    end
                    else begin
                        state <= ps1;
                    end
                ps2: if (time60_2 == 12'h5A9) begin //  Zaman ölü döngü sayısı (128MHz için 88336 saat)
                        state <= ps1;
                        time60_2 <= 12'b000000000000;
                    end
                    else begin
                        time60_2 <= time60_2 + 12'b000000000001;
                        state <= ps2;
                    end

                default : begin
                        state <= ps1;
                        time60_2 <= 12'b000000000000;
                        counter_pulse <= 24'h000000; end
            endcase
            
        end
end 
//------------------------ COUNTER_pulse 100 milisaniyede bir sıfırlanıyor-------------------------------------

//--------------------PULSE TOPLAMLARI 100 milisaniyede bir ekleniyor---------------------------------------
always @(posedge clk)
begin
    if(reset_count == 1'b0 )
    begin
        pulse_o <= 8'h00;
    end
    else begin
        if (tim_en == 1'b1) begin // 1 saniyede bir değerler ekleniyor
            pulse_o <= (((counter_pulse*256)/4096)-50); 
        end
    end
end
//--------------------PULSE TOPLAMLARI 100 milisaniyede bir ekleniyor---------------------------------------
endmodule
