
module uart_tx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE    = 115200
)(
    input  wire        clk,
    input  wire        rst,        // synchronous active-high reset for simulation convenience
    input  wire [7:0]  data_in,
    input  wire        start_tx,
    output reg         tx_serial,
    output reg         busy
);

    localparam integer BAUD_DIV = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer DIV_WIDTH = $clog2(BAUD_DIV + 1);

    reg [DIV_WIDTH-1:0] baud_divider_cnt;
    reg                 baud_tick;

    reg [9:0] tx_frame; // {stop, data[7:0], start}
    reg [3:0] bit_cnt;

    // synchronous reset semantics - initialize on rst
    always @(posedge clk) begin
        if (rst) begin
            tx_serial <= 1'b1;
            busy <= 1'b0;
            baud_divider_cnt <= {DIV_WIDTH{1'b0}};
            baud_tick <= 1'b0;
            tx_frame <= 10'h3FF;
            bit_cnt <= 4'd0;
        end else begin
            // baud generator
            if (baud_divider_cnt == BAUD_DIV-1) begin
                baud_divider_cnt <= {DIV_WIDTH{1'b0}};
                baud_tick <= 1'b1;
            end else begin
                baud_divider_cnt <= baud_divider_cnt + 1'b1;
                baud_tick <= 1'b0;
            end

            // main tx FSM
            if (!busy) begin
                // Idle
                tx_serial <= 1'b1;
                if (start_tx) begin
                    // load frame: MSB stop bit = 1, then data[7:0], LSB start=0
                    tx_frame <= {1'b1, data_in[7:0], 1'b0};
                    bit_cnt <= 4'd0;
                    busy <= 1'b1;
                end
            end else begin
                if (baud_tick) begin
                    // output LSB of frame
                    tx_serial <= tx_frame[0];
                    // shift right (fill MSB with 1 to maintain idle/stop)
                    tx_frame <= {1'b1, tx_frame[9:1]};
                    if (bit_cnt == 4'd9) begin
                        busy <= 1'b0;
                        bit_cnt <= 4'd0;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end
            end
        end
    end

endmodule
