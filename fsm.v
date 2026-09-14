module neuron_dp (
    input  wire               clk,
    input  wire               rst,
    input  wire               start,
    output wire signed [31:0] dot,
    output wire               done
);

reg signed [7:0] weight_mem [0:15];
reg signed [7:0] input_mem [0:15];
reg [4:0] i;
reg mac_en;
reg done_reg;

initial $readmemh("weights.hex", weight_mem);
initial $readmemh("vec0.hex", input_mem);

localparam IDLE=2'd0,
           CALC=2'd1,
           DONE=2'd2;

reg [1:0] state;


always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        mac_en <= 0;
        done_reg <= 0;
    end

    else begin
        case (state)

            IDLE: begin
                done_reg <= 0;
                if (start) begin
                    i<=0;
                    mac_en <= 1;
                    state <= CALC;
                end
            end

            CALC: begin
                i <= i+1;
                if (i==15) begin   
                    mac_en <= 0;
                    state <= DONE;
                end
            end

            DONE: begin
                done_reg <= 1;
                state <= IDLE;
            end

        endcase
    end
end

wire mac_rst = (state == IDLE);

mac mac_u(
    .clk    (clk),
    .rst    (mac_rst),
    .en     (mac_en),
    .weight (weight_mem[i]),
    .inp    (input_mem[i]),
    .acc    (dot)
);

assign done = done_reg;

endmodule