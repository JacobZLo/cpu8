module reg_file_8x8 (
    input        clk,
    input        wr_en,    //write enable
    input  [2:0] wr_addr,  //write address
    input  [7:0] wr_data,  //write data
    input  [2:0] rd_addr1, //read address
    output [7:0] rd_data1, //read data
    input  [2:0] rd_addr2,
    output [7:0] rd_data2
);

reg [7:0] rf [0:7]; //register file

always @(posedge clk) begin
    if (wr_en) begin
        rf[wr_addr] <= wr_data;
    end
end

assign rd_data1 = rf[rd_addr1];
assign rd_data2 = rf[rd_addr2];

endmodule
