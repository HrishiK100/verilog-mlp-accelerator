module mac(
    // clock
    input wire clk,
    //reset
    input wire rst,
    //enable
    input wire en,
    // weight
    input wire signed [7:0] weight,
    // input
    input wire signed [7:0] inp,
    // running total
    output wire signed [31:0] acc
);

//decleration of the accumulator
reg signed [31:0] acc_reg;

// update accumulator
always @(posedge clk) begin
    if (rst)
        acc_reg <= 32'd0;
    else if (en)
        acc_reg <= acc_reg + (weight*inp);
    // no else to hold value
end

//output accumulator
assign acc = acc_reg;
endmodule