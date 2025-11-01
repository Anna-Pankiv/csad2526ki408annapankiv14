module uart_rx #(
    parameter CLK_FREQ_HZ = 50000000,
    parameter BAUD_RATE   = 115200
)(
    input  wire       clk,           // ????????? ????
    input  wire       rst_n,         // ???????? ??????? ?????? ????????
    input  wire       rx_serial,     // UART RX ????? (idle = 1)
    output reg [7:0]  data_out,      // ????????? ????
    output reg        valid,         // ????? ?? 1 ????, ???? ???? ????????
    output reg        framing_error  // 1, ???? ????-??? ???????????
);

    // ?????????? ?????????? ???????
    localparam BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;

    // ??????? ??????
    localparam IDLE        = 2'd0;
    localparam START_WAIT  = 2'd1;
    localparam RECEIVE     = 2'd2;
    localparam STOP_CHECK  = 2'd3;

    reg [1:0] state;

    // ??????? ??????? ??? ??????? ?????????? ????
    reg [15:0] baud_divider_cnt;
    reg [3:0]  bit_index;
    reg [7:0]  rx_shift_reg;
    reg        rx_sync1, rx_sync2;

    // ????????????? ????? rx_serial
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx_serial;
            rx_sync2 <= rx_sync1;
        end
    end

    // ?????????????
    initial begin
        data_out        = 8'h00;
        valid           = 1'b0;
        framing_error   = 1'b0;
        state           = IDLE;
        baud_divider_cnt= 16'd0;
        bit_index       = 4'd0;
        rx_shift_reg    = 8'h00;
    end

    // ??????? ?????? ??????? UART
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= IDLE;
            baud_divider_cnt<= 16'd0;
            bit_index       <= 4'd0;
            rx_shift_reg    <= 8'h00;
            data_out        <= 8'h00;
            valid           <= 1'b0;
            framing_error   <= 1'b0;
        end else begin
            valid <= 1'b0; // ?? ?????????????

            case (state)
                IDLE: begin
                    framing_error <= 1'b0;
                    if (rx_sync2 == 1'b0) begin
                        baud_divider_cnt <= 0;
                        state <= START_WAIT;
                    end
                end

                START_WAIT: begin
                    if (baud_divider_cnt == (BAUD_DIV >> 1)) begin
                        baud_divider_cnt <= 0;
                        if (rx_sync2 == 1'b0) begin
                            bit_index    <= 0;
                            rx_shift_reg <= 8'h00;
                            state        <= RECEIVE;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        baud_divider_cnt <= baud_divider_cnt + 1'b1;
                    end
                end

                RECEIVE: begin
                    if (baud_divider_cnt == BAUD_DIV - 1) begin
                        baud_divider_cnt <= 0;
                        rx_shift_reg <= {rx_sync2, rx_shift_reg[7:1]}; // LSB first
                        if (bit_index == 7) begin
                            state <= STOP_CHECK;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        baud_divider_cnt <= baud_divider_cnt + 1'b1;
                    end
                end

                STOP_CHECK: begin
                    if (baud_divider_cnt == BAUD_DIV - 1) begin
                        baud_divider_cnt <= 0;
                        if (rx_sync2 == 1'b1) begin
                            data_out      <= rx_shift_reg;
                            valid         <= 1'b1;
                            framing_error <= 1'b0;
                        end else begin
                            data_out      <= rx_shift_reg;
                            valid         <= 1'b1;
                            framing_error <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        baud_divider_cnt <= baud_divider_cnt + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
