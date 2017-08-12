module clk_rst_gen
(
    input         ref_clk_i,
    input         rst_ni,
    output        rstn_pulpino_o,
    output        clk_pulpino_o
);

    wire s_clk_int;

    xilinx_clock_manager clk_manager_i
    (
        .clk50_i       ( ref_clk_i          ),
        .clk50_o       (                    ),
        .clk5_o        ( s_clk_int          ),
        .rst_ni        ( rst_ni             ),
        .rst_no        (                    )
    );

    assign rstn_pulpino_o          = rst_ni;
    assign clk_pulpino_o           = s_clk_int;

endmodule
