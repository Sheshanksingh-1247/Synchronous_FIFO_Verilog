`timescale 1ns/1ps

module fifo_tb;

// Parameters
parameter DATA_WIDTH = 8;
parameter DEPTH = 8;

// Inputs
reg clk;
reg reset;
reg wr_en;
reg rd_en;
reg [DATA_WIDTH-1:0] data_in;

// Outputs
wire [DATA_WIDTH-1:0] data_out;
wire full;
wire empty;
wire almost_full;
wire almost_empty;

// Instantiate FIFO

fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) DUT (

    .clk(clk),
    .reset(reset),

    .wr_en(wr_en),
    .rd_en(rd_en),

    .data_in(data_in),
    .data_out(data_out),

    .full(full),
    .empty(empty),
    
    .almost_full(almost_full),
    .almost_empty(almost_empty)

);

// Clock Generation
always #5 clk = ~clk;

//------------------------------------------------
// Test Sequence
//------------------------------------------------

initial
begin

    clk = 0;
    reset = 1;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;

    //----------------------------
    // Reset
    //----------------------------

    #20;
    reset = 0;

    //----------------------------
    // Write 8 values
    //----------------------------

    repeat(8)
    begin
        @(posedge clk);
        wr_en = 1;
        data_in = data_in + 8'd10;
    end

    @(posedge clk);
    wr_en = 0;

    //----------------------------
    // Try writing when FULL
    //----------------------------

    @(posedge clk);
    wr_en = 1;
    data_in = 8'd200;

    @(posedge clk);
    wr_en = 0;

    //----------------------------
    // Read all values
    //----------------------------

    repeat(8)
    begin
        @(posedge clk);
        rd_en = 1;
    end

    @(posedge clk);
    rd_en = 0;

    //----------------------------
    // Try reading when EMPTY
    //----------------------------

    @(posedge clk);
    rd_en = 1;

    @(posedge clk);
    rd_en = 0;

    //----------------------------
    // Simultaneous Read & Write
    //----------------------------

    @(posedge clk);

    wr_en = 1;
    rd_en = 1;
    data_in = 8'd55;

    @(posedge clk);

    wr_en = 0;
    rd_en = 0;

    //----------------------------

    #50;

    $finish;

end

//------------------------------------------------
// Waveform
//------------------------------------------------

initial
begin

    $dumpfile("waveform/fifo.vcd");
    $dumpvars(0,fifo_tb);
    $dumpvars(0,DUT);

end

//------------------------------------------------
// Monitor
//------------------------------------------------

initial
begin

$monitor(
"Time=%0t | WR=%b RD=%b DIN=%d DOUT=%d COUNT=%d FULL=%b AFULL=%b EMPTY=%b AEMPTY=%b WR_PTR=%d RD_PTR=%d",

$time,

wr_en,
rd_en,

data_in,
data_out,

DUT.count,

full,
almost_full,
empty,
almost_empty,

DUT.wr_ptr,
DUT.rd_ptr
);

end

endmodule