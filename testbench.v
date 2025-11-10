`timescale 1ns/1ps

module tb_i2c_master;

    localparam CLK_PERIOD = 20;  // 50 MHz
    localparam I2C_CLK_PERIOD = 10000; // 100 kHz I2C

    reg clk;
    reg rst_n;
    reg start;
    reg [6:0] addr;
    reg rw;           // 0 = write, 1 = read
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire busy;
    wire ack_error;

    wire scl;
    wire sda;

    always #(CLK_PERIOD/2) clk = ~clk;

    i2c_master uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .addr(addr),
        .rw(rw),
        .data_i(data_in),
        .data_o(data_out),
        .busy(busy),
        .ack_error(ack_error),
        .scl(scl),
        .sda(sda)
    );

    pullup(sda);
    pullup(scl);

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        addr = 7'h50;
        rw = 0;           // Запис
        data_in = 8'hA5;

        #100;
        rst_n = 1;

        #100;
        start = 1;
        #20;
        start = 0;

        wait(!busy);
        #1000;

        rw = 1;
        #100;
        start = 1;
        #20;
        start = 0;

        wait(!busy);
        #1000;

        $display("I2C Simulation Done. Data read: %h", data_out);
        $stop;
    end

endmodule