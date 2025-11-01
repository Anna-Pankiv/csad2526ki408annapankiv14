
module uart_rx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE    = 115200
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        rx_serial,
    output reg [7:0]   data_out,
    output reg         valid,
    output reg         framing_error
);

    localparam integer BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer DIV_WIDTH = $clog2(BAUD_DIV + 1);

    // sync input to clk domain (two-stage)
    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        if (rst) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx_serial;
            rx_sync2 <= rx_sync1;
        end
    end

    // FSM states
    localparam IDLE = 2'd0;
    localparam START_WAIT = 2'd1;
    localparam RECEIVE = 2'd2;
    localparam STOP_CHECK = 2'd3;

    reg [1:0] state;
    reg [DIV_WIDTH-1:0] baud_divider_cnt;
    reg [3:0] bit_index;
    reg [7:0] rx_shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            data_out <= 8'h00;
            valid <= 1'b0;
            framing_error <= 1'b0;
            state <= IDLE;
            baud_divider_cnt <= {DIV_WIDTH{1'b0}};
            bit_index <= 4'd0;
            rx_shift_reg <= 8'h00;
        end else begin
            valid <= 1'b0; // default deassert
            case (state)
                IDLE: begin
                    framing_error <= 1'b0;
                    baud_divider_cnt <= {DIV_WIDTH{1'b0}};
                    bit_index <= 4'd0;
                    if (rx_sync2 == 1'b0) begin
                        // detected potential start bit
                        state <= START_WAIT;
                        baud_divider_cnt <= 0;
                    end
                end

                START_WAIT: begin
                    // wait half bit to sample middle of start bit
                    if (baud_divider_cnt == (BAUD_DIV/2 - 1)) begin
                        baud_divider_cnt <= 0;
                        if (rx_sync2 == 1'b0) begin
                            // confirmed start, begin receiving bits
                            bit_index <= 4'd0;
                            rx_shift_reg <= 8'h00;
                            state <= RECEIVE;
                        end else begin
                            // false start
                            state <= IDLE;
                        end
                    end else begin
                        baud_divider_cnt <= baud_divider_cnt + 1'b1;
                    end
                end

                RECEIVE: begin
                    if (baud_divider_cnt == BAUD_DIV-1) begin
                        baud_divider_cnt <= 0;
                        // sample in middle of bit (we use complete intervals after initial half)
                        // shift LSB first: new bit goes to MSB position then rotate down
                        rx_shift_reg <= {rx_sync2, rx_shift_reg[7:1]};
                        if (bit_index == 4'd7) begin
                            state <= STOP_CHECK;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        baud_divider_cnt <= baud_divider_cnt + 1'b1;
                    end
                end

                STOP_CHECK: begin
                    if (baud_divider_cnt == BAUD_DIV-1) begin
                        baud_divider_cnt <= 0;
                        if (rx_sync2 == 1'b1) begin
                            data_out <= rx_shift_reg;
                            valid <= 1'b1;
                            framing_error <= 1'b0;
                        end else begin
                            data_out <= rx_shift_reg;
                            valid <= 1'b1;
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
