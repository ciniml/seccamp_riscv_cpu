`default_nettype none
module reset_seq #(
    parameter int RESET_DELAY_CYCLES = 16
)(
    input wire reset_in,
    input wire clock,

    output logic reset_out
);

// Reset sequencer
logic [RESET_DELAY_CYCLES:0] reset_seq;
initial begin
  reset_seq = '1;
end
always_ff @(posedge clock) begin
  if(reset_in) begin
    reset_seq = '1;
  end
  else begin
    reset_seq <= reset_seq >> 1;
  end
end

assign reset_out = reset_seq[0];

endmodule


`default_nettype wire