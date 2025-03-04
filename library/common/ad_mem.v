module ad_mem
#(
    parameter                           DATA_WIDTH      = 16,
    parameter                           ADDRESS_WIDTH   = 5
)
(
    input                               clka,
    input                               wea,
    input  [(ADDRESS_WIDTH - 1) : 0]    addra,
    input  [(DATA_WIDTH - 1) : 0]       dina,

    input                               clkb,
    input                               reb,
    input  [(ADDRESS_WIDTH - 1) : 0]    addrb,
    output [(DATA_WIDTH - 1) : 0]       doutb
);
    altera_syncram #(
        .address_aclr_b         ("NONE"),
        .address_reg_b          ("CLOCK1"),
        .clock_enable_input_a   ("BYPASS"),
        .clock_enable_input_b   ("BYPASS"),
        .clock_enable_output_b  ("BYPASS"),
        .intended_device_family ("Arria 10"),
        .lpm_type               ("altera_syncram"),
        .numwords_a             (2**ADDRESS_WIDTH),
        .numwords_b             (2**ADDRESS_WIDTH),
        .operation_mode         ("DUAL_PORT"),
        .outdata_aclr_b         ("NONE"),
        .outdata_sclr_b         ("NONE"),
        .outdata_reg_b          ("UNREGISTERED"),
        .power_up_uninitialized ("FALSE"),
        .rdcontrol_reg_b        ("CLOCK1"),
        .widthad_a              (ADDRESS_WIDTH),
        .widthad_b              (ADDRESS_WIDTH),
        .width_a                (DATA_WIDTH),
        .width_b                (DATA_WIDTH),
        .width_byteena_a        (1)
    )
    altera_syncram_component (
        .address_a              (addra),
        .address_b              (addrb),
        .clock0                 (clka),
        .clock1                 (clkb),
        .data_a                 (dina),
        .rden_b                 (reb),
        .wren_a                 (wea),
        .q_b                    (doutb),
        .aclr0                  (1'b0),
        .aclr1                  (1'b0),
        .address2_a             (1'b1),
        .address2_b             (1'b1),
        .addressstall_a         (1'b0),
        .addressstall_b         (1'b0),
        .byteena_a              (1'b1),
        .byteena_b              (1'b1),
        .clocken0               (1'b1),
        .clocken1               (1'b1),
        .clocken2               (1'b1),
        .clocken3               (1'b1),
        .data_b                 ({DATA_WIDTH{1'b1}}),
        .eccencbypass           (1'b0),
        .eccencparity           (8'b0),
        .eccstatus              (),
        .q_a                    (),
        .rden_a                 (1'b1),
        .sclr                   (1'b0),
        .wren_b                 (1'b0)
    ); // altera_syncram_component
endmodule
