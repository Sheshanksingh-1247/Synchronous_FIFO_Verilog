module fifo #(

    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8

)(

    input clk,
    input reset,

    input wr_en,
    input rd_en,

    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,

    output full,
    output empty,
    output almost_full,
    output almost_empty

);

//-------------------------------------
// Memory Declaration
//-------------------------------------

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

//-------------------------------------
// Pointer Declaration
//-------------------------------------

reg [2:0] wr_ptr;
reg [2:0] rd_ptr;

//-------------------------------------
// Counter
//-------------------------------------

reg [3:0] count;

//-------------------------------------
// Status Flags
//-------------------------------------

assign full  = (count == DEPTH);
assign empty = (count == 0);

assign almost_full = (count >= DEPTH-1);
assign almost_empty = (count <= 1);

//-------------------------------------
// FIFO Logic
//-------------------------------------

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        wr_ptr   <= 0;
        rd_ptr   <= 0;
        count    <= 0;
        data_out <= 0;
    end

    else
    begin

        //-------------------------
        // Write Operation
        //-------------------------

        if(wr_en && !full)
        begin

            mem[wr_ptr] <= data_in;

            if(wr_ptr == DEPTH-1)
                wr_ptr <= 0;
            else
                wr_ptr <= wr_ptr + 1;

        end

        //-------------------------
        // Read Operation
        //-------------------------

        if(rd_en && !empty)
        begin

            data_out <= mem[rd_ptr];

            if(rd_ptr == DEPTH-1)
                rd_ptr <= 0;
            else
                rd_ptr <= rd_ptr + 1;

        end

        //-------------------------
        // Count Logic
        //-------------------------

        if(wr_en && !rd_en && !full)
            count <= count + 1;

        else if(rd_en && !wr_en && !empty)
            count <= count - 1;

        // If both wr_en and rd_en are HIGH,
        // count remains unchanged.

    end

end

endmodule