module uart_rx (
    input clk, rst, rx,       
    output reg [7:0] rx_data, 
    output reg   rx_done    
);

    // State encoding
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state;
    reg [6:0] baud_cnt;   // adjust size for your baud rate
    reg [2:0] bit_cnt;    // 0 to 7 for 8-bit data
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            baud_cnt  <= 0;
            bit_cnt   <= 0;
            shift_reg <= 0;
            rx_data   <= 0;
            rx_done   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    baud_cnt <= 0;
                    bit_cnt <= 0;
                    if (rx == 0) begin // start bit detected
                        state <= START;
                        baud_cnt <= 0;
                    end
                end

                START: begin
                    if (baud_cnt == 51) begin // sample middle of start bit
                        baud_cnt <= 0;
                        state <= DATA;
                        bit_cnt <= 0;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                DATA: begin
                    if (baud_cnt == 103) begin // sample each data bit
                        baud_cnt <= 0;
                        shift_reg <= {rx, shift_reg[7:1]}; // shift in LSB first
                        if (bit_cnt == 7)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                STOP: begin
                    if (baud_cnt == 103) begin
                        baud_cnt <= 0;
                        state <= IDLE;
                        rx_done <= 1'b1;
                        rx_data <= shift_reg; // latch received data
                    end else
                        baud_cnt <= baud_cnt + 1;
                end
            endcase
        end
    end
endmodule
