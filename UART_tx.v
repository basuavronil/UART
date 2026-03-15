module uart(
    input        clk,      
    input        rst,       
    input        tx_start,  
    input  [7:0] tx_data,   
    output reg   tx,      
    output reg   tx_busy    
);

   
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state;
    reg [6:0] baud_cnt;       
    reg [2:0] bit_cnt;        
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;   // idle high
            tx_busy   <= 1'b0;
            baud_cnt  <= 0;
            bit_cnt   <= 0;
            shift_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    baud_cnt <= 0;
                    bit_cnt <= 0;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        state <= START;
                        tx_busy <= 1'b1;
                        baud_cnt <= 0;
                    end
                end

                START: begin
                    tx <= 1'b0; // start bit
                    if (baud_cnt == 103) begin
                        baud_cnt <= 0;
                        state <= DATA;
                        bit_cnt <= 0;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                DATA: begin
                    tx <= shift_reg[0];
                    if (baud_cnt == 103) begin
                        baud_cnt <= 0;
                        shift_reg <= shift_reg >> 1; 
                        if (bit_cnt == 7)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                STOP: begin
                    tx <= 1'b1; 
                    if (baud_cnt == 103) begin
                        baud_cnt <= 0;
                        state <= IDLE;
                        tx_busy <= 1'b0;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end
            endcase
        end
    end
endmodule
