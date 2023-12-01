module Core(
  input         clock,
  input         reset,
  output [31:0] io_imem_addr,
  input  [31:0] io_imem_inst,
  input         io_imem_valid,
  output [31:0] io_dmem_addr,
  input  [31:0] io_dmem_rdata,
  output        io_dmem_ren,
  input         io_dmem_rvalid,
  output        io_dmem_wen,
  output [3:0]  io_dmem_wstrb,
  output [31:0] io_dmem_wdata,
  input         io_interrupt_in,
  output        io_success,
  output        io_exit,
  output [31:0] io_debug_pc
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
  reg [31:0] _RAND_36;
  reg [31:0] _RAND_37;
  reg [31:0] _RAND_38;
  reg [31:0] _RAND_39;
  reg [31:0] _RAND_40;
  reg [31:0] _RAND_41;
  reg [31:0] _RAND_42;
  reg [31:0] _RAND_43;
  reg [31:0] _RAND_44;
  reg [31:0] _RAND_45;
  reg [31:0] _RAND_46;
  reg [31:0] _RAND_47;
  reg [31:0] _RAND_48;
  reg [31:0] _RAND_49;
  reg [31:0] _RAND_50;
  reg [31:0] _RAND_51;
  reg [31:0] _RAND_52;
  reg [31:0] _RAND_53;
  reg [31:0] _RAND_54;
  reg [31:0] _RAND_55;
  reg [31:0] _RAND_56;
  reg [31:0] _RAND_57;
  reg [31:0] _RAND_58;
  reg [31:0] _RAND_59;
  reg [31:0] _RAND_60;
  reg [31:0] _RAND_61;
  reg [31:0] _RAND_62;
  reg [31:0] _RAND_63;
  reg [31:0] _RAND_64;
  reg [31:0] _RAND_65;
  reg [31:0] _RAND_66;
  reg [31:0] _RAND_67;
  reg [31:0] _RAND_68;
  reg [31:0] _RAND_69;
  reg [31:0] _RAND_70;
  reg [31:0] _RAND_71;
  reg [31:0] _RAND_72;
  reg [31:0] _RAND_73;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] regfile [0:31]; // @[Core.scala 21:20]
  wire  regfile_id_rs1_data_MPORT_en; // @[Core.scala 21:20]
  wire [4:0] regfile_id_rs1_data_MPORT_addr; // @[Core.scala 21:20]
  wire [31:0] regfile_id_rs1_data_MPORT_data; // @[Core.scala 21:20]
  wire  regfile_id_rs2_data_MPORT_en; // @[Core.scala 21:20]
  wire [4:0] regfile_id_rs2_data_MPORT_addr; // @[Core.scala 21:20]
  wire [31:0] regfile_id_rs2_data_MPORT_data; // @[Core.scala 21:20]
  wire [31:0] regfile_MPORT_data; // @[Core.scala 21:20]
  wire [4:0] regfile_MPORT_addr; // @[Core.scala 21:20]
  wire  regfile_MPORT_mask; // @[Core.scala 21:20]
  wire  regfile_MPORT_en; // @[Core.scala 21:20]
  reg [31:0] csr_gpio_out; // @[Core.scala 23:29]
  reg [31:0] csr_trap_vector; // @[Core.scala 24:32]
  reg  csr_mstatus_wpri0; // @[Core.scala 26:28]
  reg  csr_mstatus_sie; // @[Core.scala 26:28]
  reg  csr_mstatus_wpri1; // @[Core.scala 26:28]
  reg  csr_mstatus_mie; // @[Core.scala 26:28]
  reg  csr_mstatus_wpri2; // @[Core.scala 26:28]
  reg  csr_mstatus_spie; // @[Core.scala 26:28]
  reg  csr_mstatus_ube; // @[Core.scala 26:28]
  reg  csr_mstatus_mpie; // @[Core.scala 26:28]
  reg  csr_mstatus_spp; // @[Core.scala 26:28]
  reg [1:0] csr_mstatus_vs; // @[Core.scala 26:28]
  reg [1:0] csr_mstatus_mpp; // @[Core.scala 26:28]
  reg [1:0] csr_mstatus_fs; // @[Core.scala 26:28]
  reg [1:0] csr_mstatus_xs; // @[Core.scala 26:28]
  reg  csr_mstatus_mprv; // @[Core.scala 26:28]
  reg  csr_mstatus_sum; // @[Core.scala 26:28]
  reg  csr_mstatus_mxr; // @[Core.scala 26:28]
  reg  csr_mstatus_tvm; // @[Core.scala 26:28]
  reg  csr_mstatus_tw; // @[Core.scala 26:28]
  reg  csr_mstatus_tsr; // @[Core.scala 26:28]
  reg [8:0] csr_mstatus_wpri3; // @[Core.scala 26:28]
  reg  csr_mstatus_sbe; // @[Core.scala 26:28]
  reg  csr_mstatus_mbe; // @[Core.scala 26:28]
  reg [24:0] csr_mstatus_wpri4; // @[Core.scala 26:28]
  reg  csr_mstatus_sd; // @[Core.scala 26:28]
  reg [3:0] csr_mstatus_wpri5; // @[Core.scala 26:28]
  reg  csr_mie_ssie; // @[Core.scala 27:24]
  reg  csr_mie_msie; // @[Core.scala 27:24]
  reg  csr_mie_stie; // @[Core.scala 27:24]
  reg  csr_mie_mtie; // @[Core.scala 27:24]
  reg  csr_mie_seie; // @[Core.scala 27:24]
  reg  csr_mie_meie; // @[Core.scala 27:24]
  reg [31:0] csr_mscratch; // @[Core.scala 29:29]
  reg [31:0] csr_mepc; // @[Core.scala 30:25]
  reg [31:0] csr_mcause; // @[Core.scala 31:27]
  reg [31:0] csr_mtval; // @[Core.scala 32:26]
  reg [31:0] id_reg_pc; // @[Core.scala 52:38]
  reg [31:0] id_reg_inst; // @[Core.scala 53:38]
  reg [31:0] exe_reg_pc; // @[Core.scala 56:38]
  reg [4:0] exe_reg_wb_addr; // @[Core.scala 57:38]
  reg [31:0] exe_reg_op1_data; // @[Core.scala 58:38]
  reg [31:0] exe_reg_op2_data; // @[Core.scala 59:38]
  reg [31:0] exe_reg_rs2_data; // @[Core.scala 60:38]
  reg [4:0] exe_reg_exe_fun; // @[Core.scala 61:38]
  reg [1:0] exe_reg_mem_wen; // @[Core.scala 62:38]
  reg [1:0] exe_reg_rf_wen; // @[Core.scala 63:38]
  reg [2:0] exe_reg_wb_sel; // @[Core.scala 64:38]
  reg [11:0] exe_reg_csr_addr; // @[Core.scala 65:38]
  reg [2:0] exe_reg_csr_cmd; // @[Core.scala 66:38]
  reg [31:0] exe_reg_imm_b_sext; // @[Core.scala 69:38]
  reg [31:0] exe_reg_mem_w; // @[Core.scala 72:38]
  reg  exe_reg_has_pending_interrupt; // @[Core.scala 73:46]
  reg [31:0] exe_reg_exception_target; // @[Core.scala 74:41]
  reg [31:0] exe_reg_mcause; // @[Core.scala 75:38]
  reg  exe_reg_mret; // @[Core.scala 76:38]
  reg [31:0] mem_reg_pc; // @[Core.scala 79:38]
  reg [4:0] mem_reg_wb_addr; // @[Core.scala 80:38]
  reg [31:0] mem_reg_op1_data; // @[Core.scala 81:38]
  reg [31:0] mem_reg_rs2_data; // @[Core.scala 82:38]
  reg [1:0] mem_reg_mem_wen; // @[Core.scala 83:38]
  reg [1:0] mem_reg_rf_wen; // @[Core.scala 84:38]
  reg [2:0] mem_reg_wb_sel; // @[Core.scala 85:38]
  reg [11:0] mem_reg_csr_addr; // @[Core.scala 86:38]
  reg [2:0] mem_reg_csr_cmd; // @[Core.scala 87:38]
  reg [31:0] mem_reg_alu_out; // @[Core.scala 89:38]
  reg [31:0] mem_reg_mem_w; // @[Core.scala 90:38]
  reg [3:0] mem_reg_mem_wstrb; // @[Core.scala 91:38]
  reg [4:0] wb_reg_wb_addr; // @[Core.scala 94:38]
  reg [1:0] wb_reg_rf_wen; // @[Core.scala 95:38]
  reg [31:0] wb_reg_wb_data; // @[Core.scala 96:38]
  reg [31:0] if_reg_pc; // @[Core.scala 106:26]
  wire [31:0] if_inst = io_imem_valid ? io_imem_inst : 32'h13; // @[Core.scala 108:20]
  wire [31:0] if_pc_plus4 = if_reg_pc + 32'h4; // @[Core.scala 117:31]
  wire  _if_pc_next_T_1 = 32'h73 == if_inst; // @[Core.scala 122:14]
  wire  _if_pc_next_T_2 = ~io_imem_valid; // @[Core.scala 123:19]
  wire  _id_rs1_data_hazard_T = exe_reg_rf_wen == 2'h1; // @[Core.scala 145:44]
  wire [4:0] id_rs1_addr_b = id_reg_inst[19:15]; // @[Core.scala 141:34]
  wire  id_rs1_data_hazard = exe_reg_rf_wen == 2'h1 & id_rs1_addr_b != 5'h0 & id_rs1_addr_b == exe_reg_wb_addr; // @[Core.scala 145:82]
  wire [4:0] id_rs2_addr_b = id_reg_inst[24:20]; // @[Core.scala 142:34]
  wire  id_rs2_data_hazard = _id_rs1_data_hazard_T & id_rs2_addr_b != 5'h0 & id_rs2_addr_b == exe_reg_wb_addr; // @[Core.scala 146:82]
  wire  mem_stall_flg = io_dmem_ren & ~io_dmem_rvalid; // @[Core.scala 370:32]
  wire  stall_flg = id_rs1_data_hazard | id_rs2_data_hazard | mem_stall_flg; // @[Core.scala 147:58]
  wire  _if_pc_next_T_3 = stall_flg | ~io_imem_valid; // @[Core.scala 123:16]
  wire [31:0] _if_pc_next_T_4 = _if_pc_next_T_3 ? if_reg_pc : if_pc_plus4; // @[Mux.scala 101:16]
  wire  exe_jmp_flg = exe_reg_wb_sel == 3'h2; // @[Core.scala 335:34]
  wire  _exe_alu_out_T = exe_reg_exe_fun == 5'h1; // @[Core.scala 293:22]
  wire [31:0] _exe_alu_out_T_2 = exe_reg_op1_data + exe_reg_op2_data; // @[Core.scala 293:58]
  wire  _exe_alu_out_T_3 = exe_reg_exe_fun == 5'h2; // @[Core.scala 294:22]
  wire [31:0] _exe_alu_out_T_5 = exe_reg_op1_data - exe_reg_op2_data; // @[Core.scala 294:58]
  wire  _exe_alu_out_T_6 = exe_reg_exe_fun == 5'h3; // @[Core.scala 295:22]
  wire [31:0] _exe_alu_out_T_7 = exe_reg_op1_data & exe_reg_op2_data; // @[Core.scala 295:58]
  wire  _exe_alu_out_T_8 = exe_reg_exe_fun == 5'h4; // @[Core.scala 296:22]
  wire [31:0] _exe_alu_out_T_9 = exe_reg_op1_data | exe_reg_op2_data; // @[Core.scala 296:58]
  wire  _exe_alu_out_T_10 = exe_reg_exe_fun == 5'h5; // @[Core.scala 297:22]
  wire [31:0] _exe_alu_out_T_11 = exe_reg_op1_data ^ exe_reg_op2_data; // @[Core.scala 297:58]
  wire  _exe_alu_out_T_12 = exe_reg_exe_fun == 5'h6; // @[Core.scala 298:22]
  wire [62:0] _GEN_7 = {{31'd0}, exe_reg_op1_data}; // @[Core.scala 298:58]
  wire [62:0] _exe_alu_out_T_14 = _GEN_7 << exe_reg_op2_data[4:0]; // @[Core.scala 298:58]
  wire  _exe_alu_out_T_16 = exe_reg_exe_fun == 5'h7; // @[Core.scala 299:22]
  wire [31:0] _exe_alu_out_T_18 = exe_reg_op1_data >> exe_reg_op2_data[4:0]; // @[Core.scala 299:58]
  wire  _exe_alu_out_T_19 = exe_reg_exe_fun == 5'h8; // @[Core.scala 300:22]
  wire [31:0] _exe_alu_out_T_23 = $signed(exe_reg_op1_data) >>> exe_reg_op2_data[4:0]; // @[Core.scala 300:100]
  wire  _exe_alu_out_T_24 = exe_reg_exe_fun == 5'h9; // @[Core.scala 301:22]
  wire  _exe_alu_out_T_27 = $signed(exe_reg_op1_data) < $signed(exe_reg_op2_data); // @[Core.scala 301:67]
  wire  _exe_alu_out_T_28 = exe_reg_exe_fun == 5'ha; // @[Core.scala 302:22]
  wire  _exe_alu_out_T_29 = exe_reg_op1_data < exe_reg_op2_data; // @[Core.scala 302:58]
  wire  _exe_alu_out_T_30 = exe_reg_exe_fun == 5'h11; // @[Core.scala 303:22]
  wire [31:0] _exe_alu_out_T_34 = _exe_alu_out_T_2 & 32'hfffffffe; // @[Core.scala 303:79]
  wire  _exe_alu_out_T_35 = exe_reg_exe_fun == 5'h12; // @[Core.scala 304:22]
  wire [31:0] _exe_alu_out_T_36 = _exe_alu_out_T_35 ? exe_reg_op1_data : 32'h0; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_37 = _exe_alu_out_T_30 ? _exe_alu_out_T_34 : _exe_alu_out_T_36; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_38 = _exe_alu_out_T_28 ? {{31'd0}, _exe_alu_out_T_29} : _exe_alu_out_T_37; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_39 = _exe_alu_out_T_24 ? {{31'd0}, _exe_alu_out_T_27} : _exe_alu_out_T_38; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_40 = _exe_alu_out_T_19 ? _exe_alu_out_T_23 : _exe_alu_out_T_39; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_41 = _exe_alu_out_T_16 ? _exe_alu_out_T_18 : _exe_alu_out_T_40; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_42 = _exe_alu_out_T_12 ? _exe_alu_out_T_14[31:0] : _exe_alu_out_T_41; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_43 = _exe_alu_out_T_10 ? _exe_alu_out_T_11 : _exe_alu_out_T_42; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_44 = _exe_alu_out_T_8 ? _exe_alu_out_T_9 : _exe_alu_out_T_43; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_45 = _exe_alu_out_T_6 ? _exe_alu_out_T_7 : _exe_alu_out_T_44; // @[Mux.scala 101:16]
  wire [31:0] _exe_alu_out_T_46 = _exe_alu_out_T_3 ? _exe_alu_out_T_5 : _exe_alu_out_T_45; // @[Mux.scala 101:16]
  wire [31:0] exe_alu_out = _exe_alu_out_T ? _exe_alu_out_T_2 : _exe_alu_out_T_46; // @[Mux.scala 101:16]
  wire  _exe_br_flg_T = exe_reg_exe_fun == 5'hb; // @[Core.scala 311:22]
  wire  _exe_br_flg_T_1 = exe_reg_op1_data == exe_reg_op2_data; // @[Core.scala 311:57]
  wire  _exe_br_flg_T_2 = exe_reg_exe_fun == 5'hc; // @[Core.scala 312:22]
  wire  _exe_br_flg_T_4 = ~_exe_br_flg_T_1; // @[Core.scala 312:38]
  wire  _exe_br_flg_T_5 = exe_reg_exe_fun == 5'hd; // @[Core.scala 313:22]
  wire  _exe_br_flg_T_9 = exe_reg_exe_fun == 5'he; // @[Core.scala 314:22]
  wire  _exe_br_flg_T_13 = ~_exe_alu_out_T_27; // @[Core.scala 314:38]
  wire  _exe_br_flg_T_14 = exe_reg_exe_fun == 5'hf; // @[Core.scala 315:22]
  wire  _exe_br_flg_T_16 = exe_reg_exe_fun == 5'h10; // @[Core.scala 316:22]
  wire  _exe_br_flg_T_18 = ~_exe_alu_out_T_29; // @[Core.scala 316:38]
  wire  _exe_br_flg_T_20 = _exe_br_flg_T_14 ? _exe_alu_out_T_29 : _exe_br_flg_T_16 & _exe_br_flg_T_18; // @[Mux.scala 101:16]
  wire  _exe_br_flg_T_21 = _exe_br_flg_T_9 ? _exe_br_flg_T_13 : _exe_br_flg_T_20; // @[Mux.scala 101:16]
  wire  _exe_br_flg_T_22 = _exe_br_flg_T_5 ? _exe_alu_out_T_27 : _exe_br_flg_T_21; // @[Mux.scala 101:16]
  wire  _exe_br_flg_T_23 = _exe_br_flg_T_2 ? _exe_br_flg_T_4 : _exe_br_flg_T_22; // @[Mux.scala 101:16]
  wire  _exe_br_flg_T_24 = _exe_br_flg_T ? _exe_br_flg_T_1 : _exe_br_flg_T_23; // @[Mux.scala 101:16]
  wire  exe_br_flg = exe_reg_has_pending_interrupt | (exe_reg_mret | _exe_br_flg_T_24); // @[Mux.scala 101:16]
  wire [31:0] _exe_br_target_T_1 = exe_reg_pc + exe_reg_imm_b_sext; // @[Core.scala 318:39]
  wire  _id_reg_inst_T = exe_br_flg | exe_jmp_flg; // @[Core.scala 133:17]
  wire [15:0] _id_enabled_mip_T = {4'h0,io_interrupt_in,2'h0,3'h0,6'h0}; // @[Cat.scala 33:92]
  wire [5:0] id_enabled_mip_lo_1 = {csr_mie_stie,1'h0,csr_mie_msie,1'h0,csr_mie_ssie,1'h0}; // @[Cat.scala 33:92]
  wire [15:0] _id_enabled_mip_T_1 = {4'h0,csr_mie_meie,1'h0,csr_mie_seie,1'h0,csr_mie_mtie,1'h0,id_enabled_mip_lo_1}; // @[Cat.scala 33:92]
  wire [15:0] _id_enabled_mip_T_2 = _id_enabled_mip_T & _id_enabled_mip_T_1; // @[Core.scala 150:52]
  wire  id_enabled_mip_ssip = _id_enabled_mip_T_2[1]; // @[CSR.scala 138:22]
  wire  id_enabled_mip_msip = _id_enabled_mip_T_2[3]; // @[CSR.scala 139:22]
  wire  id_enabled_mip_stip = _id_enabled_mip_T_2[5]; // @[CSR.scala 140:22]
  wire  id_enabled_mip_mtip = _id_enabled_mip_T_2[7]; // @[CSR.scala 141:22]
  wire  id_enabled_mip_seip = _id_enabled_mip_T_2[9]; // @[CSR.scala 142:22]
  wire  id_enabled_mip_meip = _id_enabled_mip_T_2[11]; // @[CSR.scala 143:22]
  wire  _id_has_pending_interrupt_T_4 = id_enabled_mip_ssip | id_enabled_mip_msip | id_enabled_mip_stip |
    id_enabled_mip_mtip | id_enabled_mip_seip | id_enabled_mip_meip; // @[CSR.scala 121:42]
  wire  id_has_pending_interrupt = _id_has_pending_interrupt_T_4 & csr_mstatus_mie; // @[Core.scala 151:62]
  wire [5:0] id_exception_cause_lo = {id_enabled_mip_stip,1'h0,id_enabled_mip_msip,1'h0,id_enabled_mip_ssip,1'h0}; // @[Cat.scala 33:92]
  wire [15:0] _id_exception_cause_T = {4'h0,id_enabled_mip_meip,1'h0,id_enabled_mip_seip,1'h0,id_enabled_mip_mtip,1'h0,
    id_exception_cause_lo}; // @[Cat.scala 33:92]
  wire [3:0] _id_exception_cause_T_17 = _id_exception_cause_T[14] ? 4'he : 4'hf; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_18 = _id_exception_cause_T[13] ? 4'hd : _id_exception_cause_T_17; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_19 = _id_exception_cause_T[12] ? 4'hc : _id_exception_cause_T_18; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_20 = _id_exception_cause_T[11] ? 4'hb : _id_exception_cause_T_19; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_21 = _id_exception_cause_T[10] ? 4'ha : _id_exception_cause_T_20; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_22 = _id_exception_cause_T[9] ? 4'h9 : _id_exception_cause_T_21; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_23 = _id_exception_cause_T[8] ? 4'h8 : _id_exception_cause_T_22; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_24 = _id_exception_cause_T[7] ? 4'h7 : _id_exception_cause_T_23; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_25 = _id_exception_cause_T[6] ? 4'h6 : _id_exception_cause_T_24; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_26 = _id_exception_cause_T[5] ? 4'h5 : _id_exception_cause_T_25; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_27 = _id_exception_cause_T[4] ? 4'h4 : _id_exception_cause_T_26; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_28 = _id_exception_cause_T[3] ? 4'h3 : _id_exception_cause_T_27; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_29 = _id_exception_cause_T[2] ? 4'h2 : _id_exception_cause_T_28; // @[Mux.scala 47:70]
  wire [3:0] _id_exception_cause_T_30 = _id_exception_cause_T[1] ? 4'h1 : _id_exception_cause_T_29; // @[Mux.scala 47:70]
  wire [3:0] id_exception_cause = _id_exception_cause_T[0] ? 4'h0 : _id_exception_cause_T_30; // @[Mux.scala 47:70]
  wire [31:0] _id_exception_target_T_1 = csr_trap_vector & 32'hfffffffc; // @[Core.scala 154:46]
  wire [31:0] _id_exception_target_T_2 = csr_trap_vector & 32'h3; // @[Core.scala 154:89]
  wire [5:0] _id_exception_target_T_4 = {id_exception_cause, 2'h0}; // @[Core.scala 154:129]
  wire [5:0] _id_exception_target_T_5 = _id_exception_target_T_2 == 32'h0 ? 6'h0 : _id_exception_target_T_4; // @[Core.scala 154:71]
  wire [31:0] _GEN_310 = {{26'd0}, _id_exception_target_T_5}; // @[Core.scala 154:66]
  wire [31:0] id_exception_target = _id_exception_target_T_1 + _GEN_310; // @[Core.scala 154:66]
  wire [31:0] id_mcause = {id_has_pending_interrupt,27'h0,id_exception_cause}; // @[Cat.scala 33:92]
  wire [31:0] id_inst = _id_reg_inst_T | stall_flg ? 32'h13 : id_reg_inst; // @[Core.scala 158:20]
  wire [4:0] id_rs1_addr = id_inst[19:15]; // @[Core.scala 160:28]
  wire [4:0] id_rs2_addr = id_inst[24:20]; // @[Core.scala 161:28]
  wire [4:0] id_wb_addr = id_inst[11:7]; // @[Core.scala 162:28]
  wire  _id_rs1_data_T = id_rs1_addr == 5'h0; // @[Core.scala 166:18]
  wire  _id_rs1_data_T_2 = mem_reg_rf_wen == 2'h1; // @[Core.scala 167:59]
  wire  _id_rs1_data_T_3 = id_rs1_addr == mem_reg_wb_addr & mem_reg_rf_wen == 2'h1; // @[Core.scala 167:40]
  wire  _id_rs1_data_T_5 = wb_reg_rf_wen == 2'h1; // @[Core.scala 168:59]
  wire  _id_rs1_data_T_6 = id_rs1_addr == wb_reg_wb_addr & wb_reg_rf_wen == 2'h1; // @[Core.scala 168:40]
  wire [31:0] _id_rs1_data_T_7 = _id_rs1_data_T_6 ? wb_reg_wb_data : regfile_id_rs1_data_MPORT_data; // @[Mux.scala 101:16]
  wire  _mem_wb_data_T = mem_reg_wb_sel == 3'h1; // @[Core.scala 427:21]
  wire  _mem_wb_data_load_T = mem_reg_mem_w == 32'h3; // @[Core.scala 420:20]
  wire [1:0] mem_wb_byte_offset = mem_reg_alu_out[1:0]; // @[Core.scala 417:43]
  wire [5:0] _mem_wb_rdata_T = 4'h8 * mem_wb_byte_offset; // @[Core.scala 418:44]
  wire [31:0] mem_wb_rdata = io_dmem_rdata >> _mem_wb_rdata_T; // @[Core.scala 418:36]
  wire [23:0] _mem_wb_data_load_T_3 = mem_wb_rdata[7] ? 24'hffffff : 24'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _mem_wb_data_load_T_5 = {_mem_wb_data_load_T_3,mem_wb_rdata[7:0]}; // @[Core.scala 412:38]
  wire  _mem_wb_data_load_T_6 = mem_reg_mem_w == 32'h2; // @[Core.scala 421:20]
  wire [15:0] _mem_wb_data_load_T_9 = mem_wb_rdata[15] ? 16'hffff : 16'h0; // @[Bitwise.scala 77:12]
  wire [31:0] _mem_wb_data_load_T_11 = {_mem_wb_data_load_T_9,mem_wb_rdata[15:0]}; // @[Core.scala 412:38]
  wire  _mem_wb_data_load_T_12 = mem_reg_mem_w == 32'h5; // @[Core.scala 422:20]
  wire [31:0] _mem_wb_data_load_T_15 = {24'h0,mem_wb_rdata[7:0]}; // @[Core.scala 415:29]
  wire  _mem_wb_data_load_T_16 = mem_reg_mem_w == 32'h4; // @[Core.scala 423:20]
  wire [31:0] _mem_wb_data_load_T_19 = {16'h0,mem_wb_rdata[15:0]}; // @[Core.scala 415:29]
  wire [31:0] _mem_wb_data_load_T_20 = _mem_wb_data_load_T_16 ? _mem_wb_data_load_T_19 : mem_wb_rdata; // @[Mux.scala 101:16]
  wire [31:0] _mem_wb_data_load_T_21 = _mem_wb_data_load_T_12 ? _mem_wb_data_load_T_15 : _mem_wb_data_load_T_20; // @[Mux.scala 101:16]
  wire [31:0] _mem_wb_data_load_T_22 = _mem_wb_data_load_T_6 ? _mem_wb_data_load_T_11 : _mem_wb_data_load_T_21; // @[Mux.scala 101:16]
  wire [31:0] mem_wb_data_load = _mem_wb_data_load_T ? _mem_wb_data_load_T_5 : _mem_wb_data_load_T_22; // @[Mux.scala 101:16]
  wire  _mem_wb_data_T_1 = mem_reg_wb_sel == 3'h2; // @[Core.scala 428:21]
  wire [31:0] _mem_wb_data_T_3 = mem_reg_pc + 32'h4; // @[Core.scala 428:48]
  wire  _mem_wb_data_T_4 = mem_reg_wb_sel == 3'h3; // @[Core.scala 429:21]
  wire  _csr_rdata_T_24 = 12'h343 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_22 = 12'h342 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_20 = 12'h341 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_18 = 12'h340 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_16 = 12'h310 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire [31:0] _csr_rdata_T_4 = {csr_mstatus_wpri4,csr_mstatus_wpri3[8],csr_mstatus_mbe,csr_mstatus_sbe,csr_mstatus_wpri5
    }; // @[Cat.scala 33:92]
  wire  _csr_rdata_T_14 = 12'h305 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_12 = 12'h304 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_10 = 12'h301 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire  _csr_rdata_T_8 = 12'h300 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire [7:0] csr_rdata_hi_lo = {csr_mstatus_sum,csr_mstatus_mprv,csr_mstatus_xs,csr_mstatus_fs,csr_mstatus_mpp}; // @[Cat.scala 33:92]
  wire [10:0] csr_rdata_lo = {csr_mstatus_vs,csr_mstatus_spp,csr_mstatus_mpie,csr_mstatus_ube,csr_mstatus_spie,
    csr_mstatus_wpri2,csr_mstatus_mie,csr_mstatus_wpri1,csr_mstatus_sie,csr_mstatus_wpri0}; // @[Cat.scala 33:92]
  wire [31:0] _csr_rdata_T_1 = {csr_mstatus_sd,csr_mstatus_wpri3[7:0],csr_mstatus_tsr,csr_mstatus_tw,csr_mstatus_tvm,
    csr_mstatus_mxr,csr_rdata_hi_lo,csr_rdata_lo}; // @[Cat.scala 33:92]
  wire  _csr_rdata_T_6 = 12'h7c0 == mem_reg_csr_addr; // @[Mux.scala 81:61]
  wire [31:0] _csr_rdata_T_7 = 12'h7c0 == mem_reg_csr_addr ? csr_gpio_out : 32'h0; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_9 = 12'h300 == mem_reg_csr_addr ? _csr_rdata_T_1 : _csr_rdata_T_7; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_11 = 12'h301 == mem_reg_csr_addr ? 32'h0 : _csr_rdata_T_9; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_13 = 12'h304 == mem_reg_csr_addr ? {{16'd0}, _id_enabled_mip_T_1} : _csr_rdata_T_11; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_15 = 12'h305 == mem_reg_csr_addr ? csr_trap_vector : _csr_rdata_T_13; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_17 = 12'h310 == mem_reg_csr_addr ? _csr_rdata_T_4 : _csr_rdata_T_15; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_19 = 12'h340 == mem_reg_csr_addr ? csr_mscratch : _csr_rdata_T_17; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_21 = 12'h341 == mem_reg_csr_addr ? csr_mepc : _csr_rdata_T_19; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_23 = 12'h342 == mem_reg_csr_addr ? csr_mcause : _csr_rdata_T_21; // @[Mux.scala 81:58]
  wire [31:0] _csr_rdata_T_25 = 12'h343 == mem_reg_csr_addr ? csr_mtval : _csr_rdata_T_23; // @[Mux.scala 81:58]
  wire [31:0] csr_rdata = 12'h344 == mem_reg_csr_addr ? {{16'd0}, _id_enabled_mip_T} : _csr_rdata_T_25; // @[Mux.scala 81:58]
  wire [31:0] _mem_wb_data_T_5 = _mem_wb_data_T_4 ? csr_rdata : mem_reg_alu_out; // @[Mux.scala 101:16]
  wire [31:0] _mem_wb_data_T_6 = _mem_wb_data_T_1 ? _mem_wb_data_T_3 : _mem_wb_data_T_5; // @[Mux.scala 101:16]
  wire [31:0] mem_wb_data = _mem_wb_data_T ? mem_wb_data_load : _mem_wb_data_T_6; // @[Mux.scala 101:16]
  wire [31:0] _id_rs1_data_T_8 = _id_rs1_data_T_3 ? mem_wb_data : _id_rs1_data_T_7; // @[Mux.scala 101:16]
  wire [31:0] id_rs1_data = _id_rs1_data_T ? 32'h0 : _id_rs1_data_T_8; // @[Mux.scala 101:16]
  wire  _id_rs2_data_T = id_rs2_addr == 5'h0; // @[Core.scala 171:18]
  wire  _id_rs2_data_T_3 = id_rs2_addr == mem_reg_wb_addr & _id_rs1_data_T_2; // @[Core.scala 172:40]
  wire  _id_rs2_data_T_6 = id_rs2_addr == wb_reg_wb_addr & _id_rs1_data_T_5; // @[Core.scala 173:40]
  wire [31:0] _id_rs2_data_T_7 = _id_rs2_data_T_6 ? wb_reg_wb_data : regfile_id_rs2_data_MPORT_data; // @[Mux.scala 101:16]
  wire [31:0] _id_rs2_data_T_8 = _id_rs2_data_T_3 ? mem_wb_data : _id_rs2_data_T_7; // @[Mux.scala 101:16]
  wire [31:0] id_rs2_data = _id_rs2_data_T ? 32'h0 : _id_rs2_data_T_8; // @[Mux.scala 101:16]
  wire [11:0] id_imm_i = id_inst[31:20]; // @[Core.scala 176:25]
  wire [19:0] _id_imm_i_sext_T_2 = id_imm_i[11] ? 20'hfffff : 20'h0; // @[Bitwise.scala 77:12]
  wire [31:0] id_imm_i_sext = {_id_imm_i_sext_T_2,id_imm_i}; // @[Cat.scala 33:92]
  wire [11:0] id_imm_s = {id_inst[31:25],id_wb_addr}; // @[Cat.scala 33:92]
  wire [19:0] _id_imm_s_sext_T_2 = id_imm_s[11] ? 20'hfffff : 20'h0; // @[Bitwise.scala 77:12]
  wire [31:0] id_imm_s_sext = {_id_imm_s_sext_T_2,id_inst[31:25],id_wb_addr}; // @[Cat.scala 33:92]
  wire [11:0] id_imm_b = {id_inst[31],id_inst[7],id_inst[30:25],id_inst[11:8]}; // @[Cat.scala 33:92]
  wire [18:0] _id_imm_b_sext_T_2 = id_imm_b[11] ? 19'h7ffff : 19'h0; // @[Bitwise.scala 77:12]
  wire [31:0] id_imm_b_sext = {_id_imm_b_sext_T_2,id_inst[31],id_inst[7],id_inst[30:25],id_inst[11:8],1'h0}; // @[Cat.scala 33:92]
  wire [19:0] id_imm_j = {id_inst[31],id_inst[19:12],id_inst[20],id_inst[30:21]}; // @[Cat.scala 33:92]
  wire [10:0] _id_imm_j_sext_T_2 = id_imm_j[19] ? 11'h7ff : 11'h0; // @[Bitwise.scala 77:12]
  wire [31:0] id_imm_j_sext = {_id_imm_j_sext_T_2,id_inst[31],id_inst[19:12],id_inst[20],id_inst[30:21],1'h0}; // @[Cat.scala 33:92]
  wire [19:0] id_imm_u = id_inst[31:12]; // @[Core.scala 184:25]
  wire [31:0] id_imm_u_shifted = {id_imm_u,12'h0}; // @[Cat.scala 33:92]
  wire [31:0] id_imm_z_uext = {27'h0,id_rs1_addr}; // @[Cat.scala 33:92]
  wire [31:0] _csignals_T = id_inst & 32'h707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_1 = 32'h3 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_3 = 32'h4003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_5 = 32'h23 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_7 = 32'h1003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_9 = 32'h5003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_11 = 32'h1023 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_13 = 32'h2003 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_15 = 32'h2023 == _csignals_T; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_16 = id_inst & 32'hfe00707f; // @[Lookup.scala 31:38]
  wire  _csignals_T_17 = 32'h33 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_19 = 32'h13 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_21 = 32'h40000033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_23 = 32'h7033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_25 = 32'h6033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_27 = 32'h4033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_29 = 32'h7013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_31 = 32'h6013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_33 = 32'h4013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_35 = 32'h1033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_37 = 32'h5033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_39 = 32'h40005033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_41 = 32'h1013 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_43 = 32'h5013 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_45 = 32'h40005013 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_47 = 32'h2033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_49 = 32'h3033 == _csignals_T_16; // @[Lookup.scala 31:38]
  wire  _csignals_T_51 = 32'h2013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_53 = 32'h3013 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_55 = 32'h63 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_57 = 32'h1063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_59 = 32'h5063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_61 = 32'h7063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_63 = 32'h4063 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_65 = 32'h6063 == _csignals_T; // @[Lookup.scala 31:38]
  wire [31:0] _csignals_T_66 = id_inst & 32'h7f; // @[Lookup.scala 31:38]
  wire  _csignals_T_67 = 32'h6f == _csignals_T_66; // @[Lookup.scala 31:38]
  wire  _csignals_T_69 = 32'h67 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_71 = 32'h37 == _csignals_T_66; // @[Lookup.scala 31:38]
  wire  _csignals_T_73 = 32'h17 == _csignals_T_66; // @[Lookup.scala 31:38]
  wire  _csignals_T_75 = 32'h1073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_77 = 32'h5073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_79 = 32'h2073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_81 = 32'h6073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_83 = 32'h3073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_85 = 32'h7073 == _csignals_T; // @[Lookup.scala 31:38]
  wire  _csignals_T_87 = 32'h73 == id_inst; // @[Lookup.scala 31:38]
  wire [4:0] _csignals_T_89 = _csignals_T_85 ? 5'h12 : 5'h0; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_90 = _csignals_T_83 ? 5'h12 : _csignals_T_89; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_91 = _csignals_T_81 ? 5'h12 : _csignals_T_90; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_92 = _csignals_T_79 ? 5'h12 : _csignals_T_91; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_93 = _csignals_T_77 ? 5'h12 : _csignals_T_92; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_94 = _csignals_T_75 ? 5'h12 : _csignals_T_93; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_95 = _csignals_T_73 ? 5'h1 : _csignals_T_94; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_96 = _csignals_T_71 ? 5'h1 : _csignals_T_95; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_97 = _csignals_T_69 ? 5'h11 : _csignals_T_96; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_98 = _csignals_T_67 ? 5'h1 : _csignals_T_97; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_99 = _csignals_T_65 ? 5'hf : _csignals_T_98; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_100 = _csignals_T_63 ? 5'hd : _csignals_T_99; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_101 = _csignals_T_61 ? 5'h10 : _csignals_T_100; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_102 = _csignals_T_59 ? 5'he : _csignals_T_101; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_103 = _csignals_T_57 ? 5'hc : _csignals_T_102; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_104 = _csignals_T_55 ? 5'hb : _csignals_T_103; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_105 = _csignals_T_53 ? 5'ha : _csignals_T_104; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_106 = _csignals_T_51 ? 5'h9 : _csignals_T_105; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_107 = _csignals_T_49 ? 5'ha : _csignals_T_106; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_108 = _csignals_T_47 ? 5'h9 : _csignals_T_107; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_109 = _csignals_T_45 ? 5'h8 : _csignals_T_108; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_110 = _csignals_T_43 ? 5'h7 : _csignals_T_109; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_111 = _csignals_T_41 ? 5'h6 : _csignals_T_110; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_112 = _csignals_T_39 ? 5'h8 : _csignals_T_111; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_113 = _csignals_T_37 ? 5'h7 : _csignals_T_112; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_114 = _csignals_T_35 ? 5'h6 : _csignals_T_113; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_115 = _csignals_T_33 ? 5'h5 : _csignals_T_114; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_116 = _csignals_T_31 ? 5'h4 : _csignals_T_115; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_117 = _csignals_T_29 ? 5'h3 : _csignals_T_116; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_118 = _csignals_T_27 ? 5'h5 : _csignals_T_117; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_119 = _csignals_T_25 ? 5'h4 : _csignals_T_118; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_120 = _csignals_T_23 ? 5'h3 : _csignals_T_119; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_121 = _csignals_T_21 ? 5'h2 : _csignals_T_120; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_122 = _csignals_T_19 ? 5'h1 : _csignals_T_121; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_123 = _csignals_T_17 ? 5'h1 : _csignals_T_122; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_124 = _csignals_T_15 ? 5'h1 : _csignals_T_123; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_125 = _csignals_T_13 ? 5'h1 : _csignals_T_124; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_126 = _csignals_T_11 ? 5'h1 : _csignals_T_125; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_127 = _csignals_T_9 ? 5'h1 : _csignals_T_126; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_128 = _csignals_T_7 ? 5'h1 : _csignals_T_127; // @[Lookup.scala 34:39]
  wire [4:0] _csignals_T_129 = _csignals_T_5 ? 5'h1 : _csignals_T_128; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_131 = _csignals_T_87 ? 2'h2 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_132 = _csignals_T_85 ? 2'h3 : _csignals_T_131; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_133 = _csignals_T_83 ? 2'h0 : _csignals_T_132; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_134 = _csignals_T_81 ? 2'h3 : _csignals_T_133; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_135 = _csignals_T_79 ? 2'h0 : _csignals_T_134; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_136 = _csignals_T_77 ? 2'h3 : _csignals_T_135; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_137 = _csignals_T_75 ? 2'h0 : _csignals_T_136; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_138 = _csignals_T_73 ? 2'h1 : _csignals_T_137; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_139 = _csignals_T_71 ? 2'h2 : _csignals_T_138; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_140 = _csignals_T_69 ? 2'h0 : _csignals_T_139; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_141 = _csignals_T_67 ? 2'h1 : _csignals_T_140; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_142 = _csignals_T_65 ? 2'h0 : _csignals_T_141; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_143 = _csignals_T_63 ? 2'h0 : _csignals_T_142; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_144 = _csignals_T_61 ? 2'h0 : _csignals_T_143; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_145 = _csignals_T_59 ? 2'h0 : _csignals_T_144; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_146 = _csignals_T_57 ? 2'h0 : _csignals_T_145; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_147 = _csignals_T_55 ? 2'h0 : _csignals_T_146; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_148 = _csignals_T_53 ? 2'h0 : _csignals_T_147; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_149 = _csignals_T_51 ? 2'h0 : _csignals_T_148; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_150 = _csignals_T_49 ? 2'h0 : _csignals_T_149; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_151 = _csignals_T_47 ? 2'h0 : _csignals_T_150; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_152 = _csignals_T_45 ? 2'h0 : _csignals_T_151; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_153 = _csignals_T_43 ? 2'h0 : _csignals_T_152; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_154 = _csignals_T_41 ? 2'h0 : _csignals_T_153; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_155 = _csignals_T_39 ? 2'h0 : _csignals_T_154; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_156 = _csignals_T_37 ? 2'h0 : _csignals_T_155; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_157 = _csignals_T_35 ? 2'h0 : _csignals_T_156; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_158 = _csignals_T_33 ? 2'h0 : _csignals_T_157; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_159 = _csignals_T_31 ? 2'h0 : _csignals_T_158; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_160 = _csignals_T_29 ? 2'h0 : _csignals_T_159; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_161 = _csignals_T_27 ? 2'h0 : _csignals_T_160; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_162 = _csignals_T_25 ? 2'h0 : _csignals_T_161; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_163 = _csignals_T_23 ? 2'h0 : _csignals_T_162; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_164 = _csignals_T_21 ? 2'h0 : _csignals_T_163; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_165 = _csignals_T_19 ? 2'h0 : _csignals_T_164; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_166 = _csignals_T_17 ? 2'h0 : _csignals_T_165; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_167 = _csignals_T_15 ? 2'h0 : _csignals_T_166; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_168 = _csignals_T_13 ? 2'h0 : _csignals_T_167; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_169 = _csignals_T_11 ? 2'h0 : _csignals_T_168; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_170 = _csignals_T_9 ? 2'h0 : _csignals_T_169; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_171 = _csignals_T_7 ? 2'h0 : _csignals_T_170; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_172 = _csignals_T_5 ? 2'h0 : _csignals_T_171; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_173 = _csignals_T_3 ? 2'h0 : _csignals_T_172; // @[Lookup.scala 34:39]
  wire [1:0] csignals_1 = _csignals_T_1 ? 2'h0 : _csignals_T_173; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_174 = _csignals_T_87 ? 3'h0 : 3'h1; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_175 = _csignals_T_85 ? 3'h0 : _csignals_T_174; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_176 = _csignals_T_83 ? 3'h0 : _csignals_T_175; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_177 = _csignals_T_81 ? 3'h0 : _csignals_T_176; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_178 = _csignals_T_79 ? 3'h0 : _csignals_T_177; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_179 = _csignals_T_77 ? 3'h0 : _csignals_T_178; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_180 = _csignals_T_75 ? 3'h0 : _csignals_T_179; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_181 = _csignals_T_73 ? 3'h5 : _csignals_T_180; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_182 = _csignals_T_71 ? 3'h5 : _csignals_T_181; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_183 = _csignals_T_69 ? 3'h2 : _csignals_T_182; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_184 = _csignals_T_67 ? 3'h4 : _csignals_T_183; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_185 = _csignals_T_65 ? 3'h1 : _csignals_T_184; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_186 = _csignals_T_63 ? 3'h1 : _csignals_T_185; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_187 = _csignals_T_61 ? 3'h1 : _csignals_T_186; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_188 = _csignals_T_59 ? 3'h1 : _csignals_T_187; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_189 = _csignals_T_57 ? 3'h1 : _csignals_T_188; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_190 = _csignals_T_55 ? 3'h1 : _csignals_T_189; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_191 = _csignals_T_53 ? 3'h2 : _csignals_T_190; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_192 = _csignals_T_51 ? 3'h2 : _csignals_T_191; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_193 = _csignals_T_49 ? 3'h1 : _csignals_T_192; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_194 = _csignals_T_47 ? 3'h1 : _csignals_T_193; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_195 = _csignals_T_45 ? 3'h2 : _csignals_T_194; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_196 = _csignals_T_43 ? 3'h2 : _csignals_T_195; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_197 = _csignals_T_41 ? 3'h2 : _csignals_T_196; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_198 = _csignals_T_39 ? 3'h1 : _csignals_T_197; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_199 = _csignals_T_37 ? 3'h1 : _csignals_T_198; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_200 = _csignals_T_35 ? 3'h1 : _csignals_T_199; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_201 = _csignals_T_33 ? 3'h2 : _csignals_T_200; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_202 = _csignals_T_31 ? 3'h2 : _csignals_T_201; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_203 = _csignals_T_29 ? 3'h2 : _csignals_T_202; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_204 = _csignals_T_27 ? 3'h1 : _csignals_T_203; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_205 = _csignals_T_25 ? 3'h1 : _csignals_T_204; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_206 = _csignals_T_23 ? 3'h1 : _csignals_T_205; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_207 = _csignals_T_21 ? 3'h1 : _csignals_T_206; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_208 = _csignals_T_19 ? 3'h2 : _csignals_T_207; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_209 = _csignals_T_17 ? 3'h1 : _csignals_T_208; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_210 = _csignals_T_15 ? 3'h3 : _csignals_T_209; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_211 = _csignals_T_13 ? 3'h2 : _csignals_T_210; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_212 = _csignals_T_11 ? 3'h3 : _csignals_T_211; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_213 = _csignals_T_9 ? 3'h2 : _csignals_T_212; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_214 = _csignals_T_7 ? 3'h2 : _csignals_T_213; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_215 = _csignals_T_5 ? 3'h3 : _csignals_T_214; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_216 = _csignals_T_3 ? 3'h2 : _csignals_T_215; // @[Lookup.scala 34:39]
  wire [2:0] csignals_2 = _csignals_T_1 ? 3'h2 : _csignals_T_216; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_253 = _csignals_T_15 ? 2'h1 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_254 = _csignals_T_13 ? 2'h0 : _csignals_T_253; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_255 = _csignals_T_11 ? 2'h1 : _csignals_T_254; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_256 = _csignals_T_9 ? 2'h0 : _csignals_T_255; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_257 = _csignals_T_7 ? 2'h0 : _csignals_T_256; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_258 = _csignals_T_5 ? 2'h1 : _csignals_T_257; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_261 = _csignals_T_85 ? 2'h1 : 2'h0; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_262 = _csignals_T_83 ? 2'h1 : _csignals_T_261; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_263 = _csignals_T_81 ? 2'h1 : _csignals_T_262; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_264 = _csignals_T_79 ? 2'h1 : _csignals_T_263; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_265 = _csignals_T_77 ? 2'h1 : _csignals_T_264; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_266 = _csignals_T_75 ? 2'h1 : _csignals_T_265; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_267 = _csignals_T_73 ? 2'h1 : _csignals_T_266; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_268 = _csignals_T_71 ? 2'h1 : _csignals_T_267; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_269 = _csignals_T_69 ? 2'h1 : _csignals_T_268; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_270 = _csignals_T_67 ? 2'h1 : _csignals_T_269; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_271 = _csignals_T_65 ? 2'h0 : _csignals_T_270; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_272 = _csignals_T_63 ? 2'h0 : _csignals_T_271; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_273 = _csignals_T_61 ? 2'h0 : _csignals_T_272; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_274 = _csignals_T_59 ? 2'h0 : _csignals_T_273; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_275 = _csignals_T_57 ? 2'h0 : _csignals_T_274; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_276 = _csignals_T_55 ? 2'h0 : _csignals_T_275; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_277 = _csignals_T_53 ? 2'h1 : _csignals_T_276; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_278 = _csignals_T_51 ? 2'h1 : _csignals_T_277; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_279 = _csignals_T_49 ? 2'h1 : _csignals_T_278; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_280 = _csignals_T_47 ? 2'h1 : _csignals_T_279; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_281 = _csignals_T_45 ? 2'h1 : _csignals_T_280; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_282 = _csignals_T_43 ? 2'h1 : _csignals_T_281; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_283 = _csignals_T_41 ? 2'h1 : _csignals_T_282; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_284 = _csignals_T_39 ? 2'h1 : _csignals_T_283; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_285 = _csignals_T_37 ? 2'h1 : _csignals_T_284; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_286 = _csignals_T_35 ? 2'h1 : _csignals_T_285; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_287 = _csignals_T_33 ? 2'h1 : _csignals_T_286; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_288 = _csignals_T_31 ? 2'h1 : _csignals_T_287; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_289 = _csignals_T_29 ? 2'h1 : _csignals_T_288; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_290 = _csignals_T_27 ? 2'h1 : _csignals_T_289; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_291 = _csignals_T_25 ? 2'h1 : _csignals_T_290; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_292 = _csignals_T_23 ? 2'h1 : _csignals_T_291; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_293 = _csignals_T_21 ? 2'h1 : _csignals_T_292; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_294 = _csignals_T_19 ? 2'h1 : _csignals_T_293; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_295 = _csignals_T_17 ? 2'h1 : _csignals_T_294; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_296 = _csignals_T_15 ? 2'h0 : _csignals_T_295; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_297 = _csignals_T_13 ? 2'h1 : _csignals_T_296; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_298 = _csignals_T_11 ? 2'h0 : _csignals_T_297; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_299 = _csignals_T_9 ? 2'h1 : _csignals_T_298; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_300 = _csignals_T_7 ? 2'h1 : _csignals_T_299; // @[Lookup.scala 34:39]
  wire [1:0] _csignals_T_301 = _csignals_T_5 ? 2'h0 : _csignals_T_300; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_304 = _csignals_T_85 ? 3'h3 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_305 = _csignals_T_83 ? 3'h3 : _csignals_T_304; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_306 = _csignals_T_81 ? 3'h3 : _csignals_T_305; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_307 = _csignals_T_79 ? 3'h3 : _csignals_T_306; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_308 = _csignals_T_77 ? 3'h3 : _csignals_T_307; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_309 = _csignals_T_75 ? 3'h3 : _csignals_T_308; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_310 = _csignals_T_73 ? 3'h0 : _csignals_T_309; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_311 = _csignals_T_71 ? 3'h0 : _csignals_T_310; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_312 = _csignals_T_69 ? 3'h2 : _csignals_T_311; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_313 = _csignals_T_67 ? 3'h2 : _csignals_T_312; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_314 = _csignals_T_65 ? 3'h0 : _csignals_T_313; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_315 = _csignals_T_63 ? 3'h0 : _csignals_T_314; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_316 = _csignals_T_61 ? 3'h0 : _csignals_T_315; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_317 = _csignals_T_59 ? 3'h0 : _csignals_T_316; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_318 = _csignals_T_57 ? 3'h0 : _csignals_T_317; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_319 = _csignals_T_55 ? 3'h0 : _csignals_T_318; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_320 = _csignals_T_53 ? 3'h0 : _csignals_T_319; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_321 = _csignals_T_51 ? 3'h0 : _csignals_T_320; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_322 = _csignals_T_49 ? 3'h0 : _csignals_T_321; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_323 = _csignals_T_47 ? 3'h0 : _csignals_T_322; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_324 = _csignals_T_45 ? 3'h0 : _csignals_T_323; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_325 = _csignals_T_43 ? 3'h0 : _csignals_T_324; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_326 = _csignals_T_41 ? 3'h0 : _csignals_T_325; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_327 = _csignals_T_39 ? 3'h0 : _csignals_T_326; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_328 = _csignals_T_37 ? 3'h0 : _csignals_T_327; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_329 = _csignals_T_35 ? 3'h0 : _csignals_T_328; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_330 = _csignals_T_33 ? 3'h0 : _csignals_T_329; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_331 = _csignals_T_31 ? 3'h0 : _csignals_T_330; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_332 = _csignals_T_29 ? 3'h0 : _csignals_T_331; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_333 = _csignals_T_27 ? 3'h0 : _csignals_T_332; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_334 = _csignals_T_25 ? 3'h0 : _csignals_T_333; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_335 = _csignals_T_23 ? 3'h0 : _csignals_T_334; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_336 = _csignals_T_21 ? 3'h0 : _csignals_T_335; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_337 = _csignals_T_19 ? 3'h0 : _csignals_T_336; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_338 = _csignals_T_17 ? 3'h0 : _csignals_T_337; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_339 = _csignals_T_15 ? 3'h0 : _csignals_T_338; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_340 = _csignals_T_13 ? 3'h1 : _csignals_T_339; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_341 = _csignals_T_11 ? 3'h0 : _csignals_T_340; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_342 = _csignals_T_9 ? 3'h1 : _csignals_T_341; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_343 = _csignals_T_7 ? 3'h1 : _csignals_T_342; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_344 = _csignals_T_5 ? 3'h0 : _csignals_T_343; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_346 = _csignals_T_87 ? 3'h4 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_347 = _csignals_T_85 ? 3'h3 : _csignals_T_346; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_348 = _csignals_T_83 ? 3'h3 : _csignals_T_347; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_349 = _csignals_T_81 ? 3'h2 : _csignals_T_348; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_350 = _csignals_T_79 ? 3'h2 : _csignals_T_349; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_351 = _csignals_T_77 ? 3'h1 : _csignals_T_350; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_352 = _csignals_T_75 ? 3'h1 : _csignals_T_351; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_353 = _csignals_T_73 ? 3'h0 : _csignals_T_352; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_354 = _csignals_T_71 ? 3'h0 : _csignals_T_353; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_355 = _csignals_T_69 ? 3'h0 : _csignals_T_354; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_356 = _csignals_T_67 ? 3'h0 : _csignals_T_355; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_357 = _csignals_T_65 ? 3'h0 : _csignals_T_356; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_358 = _csignals_T_63 ? 3'h0 : _csignals_T_357; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_359 = _csignals_T_61 ? 3'h0 : _csignals_T_358; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_360 = _csignals_T_59 ? 3'h0 : _csignals_T_359; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_361 = _csignals_T_57 ? 3'h0 : _csignals_T_360; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_362 = _csignals_T_55 ? 3'h0 : _csignals_T_361; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_363 = _csignals_T_53 ? 3'h0 : _csignals_T_362; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_364 = _csignals_T_51 ? 3'h0 : _csignals_T_363; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_365 = _csignals_T_49 ? 3'h0 : _csignals_T_364; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_366 = _csignals_T_47 ? 3'h0 : _csignals_T_365; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_367 = _csignals_T_45 ? 3'h0 : _csignals_T_366; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_368 = _csignals_T_43 ? 3'h0 : _csignals_T_367; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_369 = _csignals_T_41 ? 3'h0 : _csignals_T_368; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_370 = _csignals_T_39 ? 3'h0 : _csignals_T_369; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_371 = _csignals_T_37 ? 3'h0 : _csignals_T_370; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_372 = _csignals_T_35 ? 3'h0 : _csignals_T_371; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_373 = _csignals_T_33 ? 3'h0 : _csignals_T_372; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_374 = _csignals_T_31 ? 3'h0 : _csignals_T_373; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_375 = _csignals_T_29 ? 3'h0 : _csignals_T_374; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_376 = _csignals_T_27 ? 3'h0 : _csignals_T_375; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_377 = _csignals_T_25 ? 3'h0 : _csignals_T_376; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_378 = _csignals_T_23 ? 3'h0 : _csignals_T_377; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_379 = _csignals_T_21 ? 3'h0 : _csignals_T_378; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_380 = _csignals_T_19 ? 3'h0 : _csignals_T_379; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_381 = _csignals_T_17 ? 3'h0 : _csignals_T_380; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_382 = _csignals_T_15 ? 3'h0 : _csignals_T_381; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_383 = _csignals_T_13 ? 3'h0 : _csignals_T_382; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_384 = _csignals_T_11 ? 3'h0 : _csignals_T_383; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_385 = _csignals_T_9 ? 3'h0 : _csignals_T_384; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_386 = _csignals_T_7 ? 3'h0 : _csignals_T_385; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_387 = _csignals_T_5 ? 3'h0 : _csignals_T_386; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_388 = _csignals_T_3 ? 3'h0 : _csignals_T_387; // @[Lookup.scala 34:39]
  wire [2:0] csignals_6 = _csignals_T_1 ? 3'h0 : _csignals_T_388; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_425 = _csignals_T_15 ? 3'h1 : 3'h0; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_426 = _csignals_T_13 ? 3'h1 : _csignals_T_425; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_427 = _csignals_T_11 ? 3'h2 : _csignals_T_426; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_428 = _csignals_T_9 ? 3'h4 : _csignals_T_427; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_429 = _csignals_T_7 ? 3'h2 : _csignals_T_428; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_430 = _csignals_T_5 ? 3'h3 : _csignals_T_429; // @[Lookup.scala 34:39]
  wire [2:0] _csignals_T_431 = _csignals_T_3 ? 3'h5 : _csignals_T_430; // @[Lookup.scala 34:39]
  wire [2:0] csignals_7 = _csignals_T_1 ? 3'h3 : _csignals_T_431; // @[Lookup.scala 34:39]
  wire  _id_op1_data_T = csignals_1 == 2'h0; // @[Core.scala 241:17]
  wire  _id_op1_data_T_1 = csignals_1 == 2'h1; // @[Core.scala 242:17]
  wire  _id_op1_data_T_2 = csignals_1 == 2'h3; // @[Core.scala 243:17]
  wire [31:0] _id_op1_data_T_3 = _id_op1_data_T_2 ? id_imm_z_uext : 32'h0; // @[Mux.scala 101:16]
  wire  _id_op2_data_T = csignals_2 == 3'h1; // @[Core.scala 246:17]
  wire  _id_op2_data_T_1 = csignals_2 == 3'h2; // @[Core.scala 247:17]
  wire  _id_op2_data_T_2 = csignals_2 == 3'h3; // @[Core.scala 248:17]
  wire  _id_op2_data_T_3 = csignals_2 == 3'h4; // @[Core.scala 249:17]
  wire  _id_op2_data_T_4 = csignals_2 == 3'h5; // @[Core.scala 250:17]
  wire [31:0] _id_op2_data_T_5 = _id_op2_data_T_4 ? id_imm_u_shifted : 32'h0; // @[Mux.scala 101:16]
  wire [31:0] _id_op2_data_T_6 = _id_op2_data_T_3 ? id_imm_j_sext : _id_op2_data_T_5; // @[Mux.scala 101:16]
  wire [31:0] _id_op2_data_T_7 = _id_op2_data_T_2 ? id_imm_s_sext : _id_op2_data_T_6; // @[Mux.scala 101:16]
  wire  id_mret = 32'h30200073 == id_inst; // @[Core.scala 255:25]
  wire  _T = ~mem_stall_flg; // @[Core.scala 260:9]
  wire [31:0] _GEN_22 = exe_reg_has_pending_interrupt ? exe_reg_mcause : csr_mcause; // @[Core.scala 324:39 325:16 31:27]
  wire [31:0] _GEN_23 = exe_reg_has_pending_interrupt ? exe_reg_pc : csr_mepc; // @[Core.scala 324:39 326:14 30:25]
  wire  _GEN_24 = exe_reg_has_pending_interrupt ? csr_mstatus_mie : csr_mstatus_mpie; // @[Core.scala 324:39 327:22 26:28]
  wire  _GEN_25 = exe_reg_has_pending_interrupt ? 1'h0 : csr_mstatus_mie; // @[Core.scala 324:39 328:21 26:28]
  wire  _GEN_26 = exe_reg_mret ? csr_mstatus_mpie : _GEN_25; // @[Core.scala 331:22 332:21]
  wire  _mem_reg_mem_wstrb_T = exe_reg_mem_w == 32'h3; // @[Core.scala 355:22]
  wire  _mem_reg_mem_wstrb_T_1 = exe_reg_mem_w == 32'h2; // @[Core.scala 356:22]
  wire [3:0] _mem_reg_mem_wstrb_T_4 = _mem_reg_mem_wstrb_T_1 ? 4'h3 : 4'hf; // @[Mux.scala 101:16]
  wire [3:0] _mem_reg_mem_wstrb_T_5 = _mem_reg_mem_wstrb_T ? 4'h1 : _mem_reg_mem_wstrb_T_4; // @[Mux.scala 101:16]
  wire [6:0] _GEN_8 = {{3'd0}, _mem_reg_mem_wstrb_T_5}; // @[Core.scala 358:8]
  wire [6:0] _mem_reg_mem_wstrb_T_7 = _GEN_8 << exe_alu_out[1:0]; // @[Core.scala 358:8]
  wire [94:0] _GEN_10 = {{63'd0}, mem_reg_rs2_data}; // @[Core.scala 368:38]
  wire [94:0] _io_dmem_wdata_T_2 = _GEN_10 << _mem_wb_rdata_T; // @[Core.scala 368:38]
  wire  _csr_wdata_T = mem_reg_csr_cmd == 3'h1; // @[Core.scala 388:22]
  wire  _csr_wdata_T_1 = mem_reg_csr_cmd == 3'h2; // @[Core.scala 389:22]
  wire [31:0] _csr_wdata_T_2 = csr_rdata | mem_reg_op1_data; // @[Core.scala 389:47]
  wire  _csr_wdata_T_3 = mem_reg_csr_cmd == 3'h3; // @[Core.scala 390:22]
  wire [31:0] _csr_wdata_T_4 = ~mem_reg_op1_data; // @[Core.scala 390:49]
  wire [31:0] _csr_wdata_T_5 = csr_rdata & _csr_wdata_T_4; // @[Core.scala 390:47]
  wire  _csr_wdata_T_6 = mem_reg_csr_cmd == 3'h4; // @[Core.scala 391:22]
  wire [31:0] _csr_wdata_T_7 = _csr_wdata_T_6 ? 32'hb : 32'h0; // @[Mux.scala 101:16]
  wire [31:0] _csr_wdata_T_8 = _csr_wdata_T_3 ? _csr_wdata_T_5 : _csr_wdata_T_7; // @[Mux.scala 101:16]
  wire [31:0] _csr_wdata_T_9 = _csr_wdata_T_1 ? _csr_wdata_T_2 : _csr_wdata_T_8; // @[Mux.scala 101:16]
  wire [31:0] csr_wdata = _csr_wdata_T ? mem_reg_op1_data : _csr_wdata_T_9; // @[Mux.scala 101:16]
  wire  csr_mstatus_mstatus_1_wpri0 = csr_wdata[0]; // @[CSR.scala 49:28]
  wire  csr_mstatus_mstatus_1_sie = csr_wdata[1]; // @[CSR.scala 50:26]
  wire  csr_mstatus_mstatus_1_wpri1 = csr_wdata[2]; // @[CSR.scala 51:28]
  wire  csr_mstatus_mstatus_1_mie = csr_wdata[3]; // @[CSR.scala 52:26]
  wire  csr_mstatus_mstatus_1_wpri2 = csr_wdata[4]; // @[CSR.scala 53:28]
  wire  csr_mstatus_mstatus_1_spie = csr_wdata[5]; // @[CSR.scala 54:27]
  wire  csr_mstatus_mstatus_1_ube = csr_wdata[6]; // @[CSR.scala 55:26]
  wire  csr_mstatus_mstatus_1_mpie = csr_wdata[7]; // @[CSR.scala 56:27]
  wire  csr_mstatus_mstatus_1_spp = csr_wdata[8]; // @[CSR.scala 57:26]
  wire [1:0] csr_mstatus_mstatus_1_vs = csr_wdata[10:9]; // @[CSR.scala 58:25]
  wire [1:0] csr_mstatus_mstatus_1_mpp = csr_wdata[12:11]; // @[CSR.scala 59:26]
  wire [1:0] csr_mstatus_mstatus_1_fs = csr_wdata[14:13]; // @[CSR.scala 60:25]
  wire [1:0] csr_mstatus_mstatus_1_xs = csr_wdata[16:15]; // @[CSR.scala 61:25]
  wire  csr_mstatus_mstatus_1_mprv = csr_wdata[17]; // @[CSR.scala 62:27]
  wire  csr_mstatus_mstatus_1_sum = csr_wdata[18]; // @[CSR.scala 63:26]
  wire  csr_mstatus_mstatus_1_mxr = csr_wdata[19]; // @[CSR.scala 64:26]
  wire  csr_mstatus_mstatus_1_tvm = csr_wdata[20]; // @[CSR.scala 65:26]
  wire  csr_mstatus_mstatus_1_tw = csr_wdata[21]; // @[CSR.scala 66:25]
  wire  csr_mstatus_mstatus_1_tsr = csr_wdata[22]; // @[CSR.scala 67:26]
  wire [8:0] csr_mstatus_mstatus_1_wpri3 = {_csr_rdata_T_4[6],csr_wdata[30:23]}; // @[Cat.scala 33:92]
  wire  csr_mstatus_mstatus_1_sd = csr_wdata[31]; // @[CSR.scala 69:25]
  wire [3:0] csr_mstatus_mstatus_1_wpri5 = _csr_rdata_T_4[3:0]; // @[CSR.scala 70:28]
  wire  csr_mstatus_mstatus_1_sbe = _csr_rdata_T_4[4]; // @[CSR.scala 71:26]
  wire  csr_mstatus_mstatus_1_mbe = _csr_rdata_T_4[5]; // @[CSR.scala 72:26]
  wire  csr_mie_mip_seie = csr_wdata[9]; // @[CSR.scala 179:22]
  wire  csr_mie_mip_meie = csr_wdata[11]; // @[CSR.scala 180:22]
  wire  csr_mstatus_mstatus_2_wpri0 = _csr_rdata_T_1[0]; // @[CSR.scala 49:28]
  wire  csr_mstatus_mstatus_2_sie = _csr_rdata_T_1[1]; // @[CSR.scala 50:26]
  wire  csr_mstatus_mstatus_2_wpri1 = _csr_rdata_T_1[2]; // @[CSR.scala 51:28]
  wire  csr_mstatus_mstatus_2_mie = _csr_rdata_T_1[3]; // @[CSR.scala 52:26]
  wire  csr_mstatus_mstatus_2_wpri2 = _csr_rdata_T_1[4]; // @[CSR.scala 53:28]
  wire  csr_mstatus_mstatus_2_spie = _csr_rdata_T_1[5]; // @[CSR.scala 54:27]
  wire  csr_mstatus_mstatus_2_ube = _csr_rdata_T_1[6]; // @[CSR.scala 55:26]
  wire  csr_mstatus_mstatus_2_mpie = _csr_rdata_T_1[7]; // @[CSR.scala 56:27]
  wire  csr_mstatus_mstatus_2_spp = _csr_rdata_T_1[8]; // @[CSR.scala 57:26]
  wire [1:0] csr_mstatus_mstatus_2_vs = _csr_rdata_T_1[10:9]; // @[CSR.scala 58:25]
  wire [1:0] csr_mstatus_mstatus_2_mpp = _csr_rdata_T_1[12:11]; // @[CSR.scala 59:26]
  wire [1:0] csr_mstatus_mstatus_2_fs = _csr_rdata_T_1[14:13]; // @[CSR.scala 60:25]
  wire [1:0] csr_mstatus_mstatus_2_xs = _csr_rdata_T_1[16:15]; // @[CSR.scala 61:25]
  wire  csr_mstatus_mstatus_2_mprv = _csr_rdata_T_1[17]; // @[CSR.scala 62:27]
  wire  csr_mstatus_mstatus_2_sum = _csr_rdata_T_1[18]; // @[CSR.scala 63:26]
  wire  csr_mstatus_mstatus_2_mxr = _csr_rdata_T_1[19]; // @[CSR.scala 64:26]
  wire  csr_mstatus_mstatus_2_tvm = _csr_rdata_T_1[20]; // @[CSR.scala 65:26]
  wire  csr_mstatus_mstatus_2_tw = _csr_rdata_T_1[21]; // @[CSR.scala 66:25]
  wire  csr_mstatus_mstatus_2_tsr = _csr_rdata_T_1[22]; // @[CSR.scala 67:26]
  wire [8:0] csr_mstatus_mstatus_2_wpri3 = {csr_mstatus_mstatus_1_ube,_csr_rdata_T_1[30:23]}; // @[Cat.scala 33:92]
  wire  csr_mstatus_mstatus_2_sd = _csr_rdata_T_1[31]; // @[CSR.scala 69:25]
  wire [3:0] csr_mstatus_mstatus_2_wpri5 = csr_wdata[3:0]; // @[CSR.scala 70:28]
  wire [31:0] _GEN_40 = _csr_rdata_T_24 ? csr_wdata : csr_mtval; // @[Core.scala 32:26 395:30 405:41]
  wire [31:0] _GEN_41 = _csr_rdata_T_22 ? csr_wdata : _GEN_22; // @[Core.scala 395:30 404:42]
  wire [31:0] _GEN_42 = _csr_rdata_T_22 ? csr_mtval : _GEN_40; // @[Core.scala 32:26 395:30]
  wire [31:0] _GEN_43 = _csr_rdata_T_20 ? csr_wdata : _GEN_23; // @[Core.scala 395:30 403:40]
  wire [31:0] _GEN_44 = _csr_rdata_T_20 ? _GEN_22 : _GEN_41; // @[Core.scala 395:30]
  wire [31:0] _GEN_45 = _csr_rdata_T_20 ? csr_mtval : _GEN_42; // @[Core.scala 32:26 395:30]
  wire [31:0] _GEN_46 = _csr_rdata_T_18 ? csr_wdata : csr_mscratch; // @[Core.scala 29:29 395:30 402:44]
  wire [31:0] _GEN_47 = _csr_rdata_T_18 ? _GEN_23 : _GEN_43; // @[Core.scala 395:30]
  wire [31:0] _GEN_48 = _csr_rdata_T_18 ? _GEN_22 : _GEN_44; // @[Core.scala 395:30]
  wire [31:0] _GEN_49 = _csr_rdata_T_18 ? csr_mtval : _GEN_45; // @[Core.scala 32:26 395:30]
  wire  _GEN_50 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_wpri0 : csr_mstatus_wpri0; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_51 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_sie : csr_mstatus_sie; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_52 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_wpri1 : csr_mstatus_wpri1; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_53 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_mie : _GEN_26; // @[Core.scala 395:30 401:43]
  wire  _GEN_54 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_wpri2 : csr_mstatus_wpri2; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_55 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_spie : csr_mstatus_spie; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_56 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_ube : csr_mstatus_ube; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_57 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_mpie : _GEN_24; // @[Core.scala 395:30 401:43]
  wire  _GEN_58 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_spp : csr_mstatus_spp; // @[Core.scala 26:28 395:30 401:43]
  wire [1:0] _GEN_59 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_vs : csr_mstatus_vs; // @[Core.scala 26:28 395:30 401:43]
  wire [1:0] _GEN_60 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_mpp : csr_mstatus_mpp; // @[Core.scala 26:28 395:30 401:43]
  wire [1:0] _GEN_61 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_fs : csr_mstatus_fs; // @[Core.scala 26:28 395:30 401:43]
  wire [1:0] _GEN_62 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_xs : csr_mstatus_xs; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_63 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_mprv : csr_mstatus_mprv; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_64 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_sum : csr_mstatus_sum; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_65 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_mxr : csr_mstatus_mxr; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_66 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_tvm : csr_mstatus_tvm; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_67 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_tw : csr_mstatus_tw; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_68 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_tsr : csr_mstatus_tsr; // @[Core.scala 26:28 395:30 401:43]
  wire [8:0] _GEN_69 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_wpri3 : csr_mstatus_wpri3; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_72 = _csr_rdata_T_16 ? csr_mstatus_mstatus_1_wpri2 : csr_mstatus_sbe; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_73 = _csr_rdata_T_16 ? csr_mstatus_mstatus_1_spie : csr_mstatus_mbe; // @[Core.scala 26:28 395:30 401:43]
  wire [24:0] csr_mstatus_mstatus_2_wpri4 = csr_wdata[30:6]; // @[CSR.scala 73:19 78:23]
  wire [24:0] _GEN_74 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_wpri4 : csr_mstatus_wpri4; // @[Core.scala 26:28 395:30 401:43]
  wire  _GEN_75 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_sd : csr_mstatus_sd; // @[Core.scala 26:28 395:30 401:43]
  wire [3:0] _GEN_76 = _csr_rdata_T_16 ? csr_mstatus_mstatus_2_wpri5 : csr_mstatus_wpri5; // @[Core.scala 26:28 395:30 401:43]
  wire [31:0] _GEN_77 = _csr_rdata_T_16 ? csr_mscratch : _GEN_46; // @[Core.scala 29:29 395:30]
  wire [31:0] _GEN_78 = _csr_rdata_T_16 ? _GEN_23 : _GEN_47; // @[Core.scala 395:30]
  wire [31:0] _GEN_79 = _csr_rdata_T_16 ? _GEN_22 : _GEN_48; // @[Core.scala 395:30]
  wire [31:0] _GEN_80 = _csr_rdata_T_16 ? csr_mtval : _GEN_49; // @[Core.scala 32:26 395:30]
  wire [31:0] _GEN_81 = _csr_rdata_T_14 ? csr_wdata : csr_trap_vector; // @[Core.scala 395:30 24:32 400:47]
  wire  _GEN_82 = _csr_rdata_T_14 ? csr_mstatus_wpri0 : _GEN_50; // @[Core.scala 26:28 395:30]
  wire  _GEN_83 = _csr_rdata_T_14 ? csr_mstatus_sie : _GEN_51; // @[Core.scala 26:28 395:30]
  wire  _GEN_84 = _csr_rdata_T_14 ? csr_mstatus_wpri1 : _GEN_52; // @[Core.scala 26:28 395:30]
  wire  _GEN_85 = _csr_rdata_T_14 ? _GEN_26 : _GEN_53; // @[Core.scala 395:30]
  wire  _GEN_86 = _csr_rdata_T_14 ? csr_mstatus_wpri2 : _GEN_54; // @[Core.scala 26:28 395:30]
  wire  _GEN_87 = _csr_rdata_T_14 ? csr_mstatus_spie : _GEN_55; // @[Core.scala 26:28 395:30]
  wire  _GEN_88 = _csr_rdata_T_14 ? csr_mstatus_ube : _GEN_56; // @[Core.scala 26:28 395:30]
  wire  _GEN_89 = _csr_rdata_T_14 ? _GEN_24 : _GEN_57; // @[Core.scala 395:30]
  wire  _GEN_90 = _csr_rdata_T_14 ? csr_mstatus_spp : _GEN_58; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_91 = _csr_rdata_T_14 ? csr_mstatus_vs : _GEN_59; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_92 = _csr_rdata_T_14 ? csr_mstatus_mpp : _GEN_60; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_93 = _csr_rdata_T_14 ? csr_mstatus_fs : _GEN_61; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_94 = _csr_rdata_T_14 ? csr_mstatus_xs : _GEN_62; // @[Core.scala 26:28 395:30]
  wire  _GEN_95 = _csr_rdata_T_14 ? csr_mstatus_mprv : _GEN_63; // @[Core.scala 26:28 395:30]
  wire  _GEN_96 = _csr_rdata_T_14 ? csr_mstatus_sum : _GEN_64; // @[Core.scala 26:28 395:30]
  wire  _GEN_97 = _csr_rdata_T_14 ? csr_mstatus_mxr : _GEN_65; // @[Core.scala 26:28 395:30]
  wire  _GEN_98 = _csr_rdata_T_14 ? csr_mstatus_tvm : _GEN_66; // @[Core.scala 26:28 395:30]
  wire  _GEN_99 = _csr_rdata_T_14 ? csr_mstatus_tw : _GEN_67; // @[Core.scala 26:28 395:30]
  wire  _GEN_100 = _csr_rdata_T_14 ? csr_mstatus_tsr : _GEN_68; // @[Core.scala 26:28 395:30]
  wire [8:0] _GEN_101 = _csr_rdata_T_14 ? csr_mstatus_wpri3 : _GEN_69; // @[Core.scala 26:28 395:30]
  wire  _GEN_104 = _csr_rdata_T_14 ? csr_mstatus_sbe : _GEN_72; // @[Core.scala 26:28 395:30]
  wire  _GEN_105 = _csr_rdata_T_14 ? csr_mstatus_mbe : _GEN_73; // @[Core.scala 26:28 395:30]
  wire [24:0] _GEN_106 = _csr_rdata_T_14 ? csr_mstatus_wpri4 : _GEN_74; // @[Core.scala 26:28 395:30]
  wire  _GEN_107 = _csr_rdata_T_14 ? csr_mstatus_sd : _GEN_75; // @[Core.scala 26:28 395:30]
  wire [3:0] _GEN_108 = _csr_rdata_T_14 ? csr_mstatus_wpri5 : _GEN_76; // @[Core.scala 26:28 395:30]
  wire [31:0] _GEN_109 = _csr_rdata_T_14 ? csr_mscratch : _GEN_77; // @[Core.scala 29:29 395:30]
  wire [31:0] _GEN_110 = _csr_rdata_T_14 ? _GEN_23 : _GEN_78; // @[Core.scala 395:30]
  wire [31:0] _GEN_111 = _csr_rdata_T_14 ? _GEN_22 : _GEN_79; // @[Core.scala 395:30]
  wire [31:0] _GEN_112 = _csr_rdata_T_14 ? csr_mtval : _GEN_80; // @[Core.scala 32:26 395:30]
  wire  _GEN_113 = _csr_rdata_T_12 ? csr_mstatus_mstatus_1_sie : csr_mie_ssie; // @[Core.scala 27:24 395:30 399:39]
  wire  _GEN_114 = _csr_rdata_T_12 ? csr_mstatus_mstatus_1_mie : csr_mie_msie; // @[Core.scala 27:24 395:30 399:39]
  wire  _GEN_115 = _csr_rdata_T_12 ? csr_mstatus_mstatus_1_spie : csr_mie_stie; // @[Core.scala 27:24 395:30 399:39]
  wire  _GEN_116 = _csr_rdata_T_12 ? csr_mstatus_mstatus_1_mpie : csr_mie_mtie; // @[Core.scala 27:24 395:30 399:39]
  wire  _GEN_117 = _csr_rdata_T_12 ? csr_mie_mip_seie : csr_mie_seie; // @[Core.scala 27:24 395:30 399:39]
  wire  _GEN_118 = _csr_rdata_T_12 ? csr_mie_mip_meie : csr_mie_meie; // @[Core.scala 27:24 395:30 399:39]
  wire [31:0] _GEN_119 = _csr_rdata_T_12 ? csr_trap_vector : _GEN_81; // @[Core.scala 395:30 24:32]
  wire  _GEN_120 = _csr_rdata_T_12 ? csr_mstatus_wpri0 : _GEN_82; // @[Core.scala 26:28 395:30]
  wire  _GEN_121 = _csr_rdata_T_12 ? csr_mstatus_sie : _GEN_83; // @[Core.scala 26:28 395:30]
  wire  _GEN_122 = _csr_rdata_T_12 ? csr_mstatus_wpri1 : _GEN_84; // @[Core.scala 26:28 395:30]
  wire  _GEN_123 = _csr_rdata_T_12 ? _GEN_26 : _GEN_85; // @[Core.scala 395:30]
  wire  _GEN_124 = _csr_rdata_T_12 ? csr_mstatus_wpri2 : _GEN_86; // @[Core.scala 26:28 395:30]
  wire  _GEN_125 = _csr_rdata_T_12 ? csr_mstatus_spie : _GEN_87; // @[Core.scala 26:28 395:30]
  wire  _GEN_126 = _csr_rdata_T_12 ? csr_mstatus_ube : _GEN_88; // @[Core.scala 26:28 395:30]
  wire  _GEN_127 = _csr_rdata_T_12 ? _GEN_24 : _GEN_89; // @[Core.scala 395:30]
  wire  _GEN_128 = _csr_rdata_T_12 ? csr_mstatus_spp : _GEN_90; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_129 = _csr_rdata_T_12 ? csr_mstatus_vs : _GEN_91; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_130 = _csr_rdata_T_12 ? csr_mstatus_mpp : _GEN_92; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_131 = _csr_rdata_T_12 ? csr_mstatus_fs : _GEN_93; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_132 = _csr_rdata_T_12 ? csr_mstatus_xs : _GEN_94; // @[Core.scala 26:28 395:30]
  wire  _GEN_133 = _csr_rdata_T_12 ? csr_mstatus_mprv : _GEN_95; // @[Core.scala 26:28 395:30]
  wire  _GEN_134 = _csr_rdata_T_12 ? csr_mstatus_sum : _GEN_96; // @[Core.scala 26:28 395:30]
  wire  _GEN_135 = _csr_rdata_T_12 ? csr_mstatus_mxr : _GEN_97; // @[Core.scala 26:28 395:30]
  wire  _GEN_136 = _csr_rdata_T_12 ? csr_mstatus_tvm : _GEN_98; // @[Core.scala 26:28 395:30]
  wire  _GEN_137 = _csr_rdata_T_12 ? csr_mstatus_tw : _GEN_99; // @[Core.scala 26:28 395:30]
  wire  _GEN_138 = _csr_rdata_T_12 ? csr_mstatus_tsr : _GEN_100; // @[Core.scala 26:28 395:30]
  wire [8:0] _GEN_139 = _csr_rdata_T_12 ? csr_mstatus_wpri3 : _GEN_101; // @[Core.scala 26:28 395:30]
  wire  _GEN_142 = _csr_rdata_T_12 ? csr_mstatus_sbe : _GEN_104; // @[Core.scala 26:28 395:30]
  wire  _GEN_143 = _csr_rdata_T_12 ? csr_mstatus_mbe : _GEN_105; // @[Core.scala 26:28 395:30]
  wire [24:0] _GEN_144 = _csr_rdata_T_12 ? csr_mstatus_wpri4 : _GEN_106; // @[Core.scala 26:28 395:30]
  wire  _GEN_145 = _csr_rdata_T_12 ? csr_mstatus_sd : _GEN_107; // @[Core.scala 26:28 395:30]
  wire [3:0] _GEN_146 = _csr_rdata_T_12 ? csr_mstatus_wpri5 : _GEN_108; // @[Core.scala 26:28 395:30]
  wire [31:0] _GEN_147 = _csr_rdata_T_12 ? csr_mscratch : _GEN_109; // @[Core.scala 29:29 395:30]
  wire [31:0] _GEN_148 = _csr_rdata_T_12 ? _GEN_23 : _GEN_110; // @[Core.scala 395:30]
  wire [31:0] _GEN_149 = _csr_rdata_T_12 ? _GEN_22 : _GEN_111; // @[Core.scala 395:30]
  wire [31:0] _GEN_150 = _csr_rdata_T_12 ? csr_mtval : _GEN_112; // @[Core.scala 32:26 395:30]
  wire  _GEN_151 = _csr_rdata_T_10 ? csr_mie_ssie : _GEN_113; // @[Core.scala 27:24 395:30]
  wire  _GEN_152 = _csr_rdata_T_10 ? csr_mie_msie : _GEN_114; // @[Core.scala 27:24 395:30]
  wire  _GEN_153 = _csr_rdata_T_10 ? csr_mie_stie : _GEN_115; // @[Core.scala 27:24 395:30]
  wire  _GEN_154 = _csr_rdata_T_10 ? csr_mie_mtie : _GEN_116; // @[Core.scala 27:24 395:30]
  wire  _GEN_155 = _csr_rdata_T_10 ? csr_mie_seie : _GEN_117; // @[Core.scala 27:24 395:30]
  wire  _GEN_156 = _csr_rdata_T_10 ? csr_mie_meie : _GEN_118; // @[Core.scala 27:24 395:30]
  wire [31:0] _GEN_157 = _csr_rdata_T_10 ? csr_trap_vector : _GEN_119; // @[Core.scala 395:30 24:32]
  wire  _GEN_158 = _csr_rdata_T_10 ? csr_mstatus_wpri0 : _GEN_120; // @[Core.scala 26:28 395:30]
  wire  _GEN_159 = _csr_rdata_T_10 ? csr_mstatus_sie : _GEN_121; // @[Core.scala 26:28 395:30]
  wire  _GEN_160 = _csr_rdata_T_10 ? csr_mstatus_wpri1 : _GEN_122; // @[Core.scala 26:28 395:30]
  wire  _GEN_161 = _csr_rdata_T_10 ? _GEN_26 : _GEN_123; // @[Core.scala 395:30]
  wire  _GEN_162 = _csr_rdata_T_10 ? csr_mstatus_wpri2 : _GEN_124; // @[Core.scala 26:28 395:30]
  wire  _GEN_163 = _csr_rdata_T_10 ? csr_mstatus_spie : _GEN_125; // @[Core.scala 26:28 395:30]
  wire  _GEN_164 = _csr_rdata_T_10 ? csr_mstatus_ube : _GEN_126; // @[Core.scala 26:28 395:30]
  wire  _GEN_165 = _csr_rdata_T_10 ? _GEN_24 : _GEN_127; // @[Core.scala 395:30]
  wire  _GEN_166 = _csr_rdata_T_10 ? csr_mstatus_spp : _GEN_128; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_167 = _csr_rdata_T_10 ? csr_mstatus_vs : _GEN_129; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_168 = _csr_rdata_T_10 ? csr_mstatus_mpp : _GEN_130; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_169 = _csr_rdata_T_10 ? csr_mstatus_fs : _GEN_131; // @[Core.scala 26:28 395:30]
  wire [1:0] _GEN_170 = _csr_rdata_T_10 ? csr_mstatus_xs : _GEN_132; // @[Core.scala 26:28 395:30]
  wire  _GEN_171 = _csr_rdata_T_10 ? csr_mstatus_mprv : _GEN_133; // @[Core.scala 26:28 395:30]
  wire  _GEN_172 = _csr_rdata_T_10 ? csr_mstatus_sum : _GEN_134; // @[Core.scala 26:28 395:30]
  wire  _GEN_173 = _csr_rdata_T_10 ? csr_mstatus_mxr : _GEN_135; // @[Core.scala 26:28 395:30]
  wire  _GEN_174 = _csr_rdata_T_10 ? csr_mstatus_tvm : _GEN_136; // @[Core.scala 26:28 395:30]
  wire  _GEN_175 = _csr_rdata_T_10 ? csr_mstatus_tw : _GEN_137; // @[Core.scala 26:28 395:30]
  wire  _GEN_176 = _csr_rdata_T_10 ? csr_mstatus_tsr : _GEN_138; // @[Core.scala 26:28 395:30]
  wire [8:0] _GEN_177 = _csr_rdata_T_10 ? csr_mstatus_wpri3 : _GEN_139; // @[Core.scala 26:28 395:30]
  wire  _GEN_180 = _csr_rdata_T_10 ? csr_mstatus_sbe : _GEN_142; // @[Core.scala 26:28 395:30]
  wire  _GEN_181 = _csr_rdata_T_10 ? csr_mstatus_mbe : _GEN_143; // @[Core.scala 26:28 395:30]
  wire [24:0] _GEN_182 = _csr_rdata_T_10 ? csr_mstatus_wpri4 : _GEN_144; // @[Core.scala 26:28 395:30]
  wire  _GEN_183 = _csr_rdata_T_10 ? csr_mstatus_sd : _GEN_145; // @[Core.scala 26:28 395:30]
  wire [3:0] _GEN_184 = _csr_rdata_T_10 ? csr_mstatus_wpri5 : _GEN_146; // @[Core.scala 26:28 395:30]
  wire [31:0] _GEN_185 = _csr_rdata_T_10 ? csr_mscratch : _GEN_147; // @[Core.scala 29:29 395:30]
  wire [31:0] _GEN_186 = _csr_rdata_T_10 ? _GEN_23 : _GEN_148; // @[Core.scala 395:30]
  wire [31:0] _GEN_187 = _csr_rdata_T_10 ? _GEN_22 : _GEN_149; // @[Core.scala 395:30]
  wire [31:0] _GEN_188 = _csr_rdata_T_10 ? csr_mtval : _GEN_150; // @[Core.scala 32:26 395:30]
  wire [24:0] csr_mstatus_mstatus_1_wpri4 = _csr_rdata_T_4[30:6]; // @[CSR.scala 73:19 78:23]
  reg  successDetected; // @[Core.scala 450:32]
  wire  _T_20 = ~reset; // @[Core.scala 456:11]
  assign regfile_id_rs1_data_MPORT_en = 1'h1;
  assign regfile_id_rs1_data_MPORT_addr = id_inst[19:15];
  assign regfile_id_rs1_data_MPORT_data = regfile[regfile_id_rs1_data_MPORT_addr]; // @[Core.scala 21:20]
  assign regfile_id_rs2_data_MPORT_en = 1'h1;
  assign regfile_id_rs2_data_MPORT_addr = id_inst[24:20];
  assign regfile_id_rs2_data_MPORT_data = regfile[regfile_id_rs2_data_MPORT_addr]; // @[Core.scala 21:20]
  assign regfile_MPORT_data = wb_reg_wb_data;
  assign regfile_MPORT_addr = wb_reg_wb_addr;
  assign regfile_MPORT_mask = 1'h1;
  assign regfile_MPORT_en = wb_reg_rf_wen == 2'h1;
  assign io_imem_addr = if_reg_pc; // @[Core.scala 107:16]
  assign io_dmem_addr = mem_reg_alu_out; // @[Core.scala 364:17]
  assign io_dmem_ren = mem_reg_wb_sel == 3'h1; // @[Core.scala 365:35]
  assign io_dmem_wen = mem_reg_mem_wen[0]; // @[Core.scala 366:17]
  assign io_dmem_wstrb = mem_reg_mem_wstrb; // @[Core.scala 367:17]
  assign io_dmem_wdata = _io_dmem_wdata_T_2[31:0]; // @[Core.scala 368:71]
  assign io_success = successDetected; // @[Core.scala 452:14]
  assign io_exit = 32'h73 == if_inst; // @[Core.scala 453:22]
  assign io_debug_pc = if_reg_pc; // @[Core.scala 454:15]
  always @(posedge clock) begin
    if (regfile_MPORT_en & regfile_MPORT_mask) begin
      regfile[regfile_MPORT_addr] <= regfile_MPORT_data; // @[Core.scala 21:20]
    end
    if (reset) begin // @[Core.scala 23:29]
      csr_gpio_out <= 32'h0; // @[Core.scala 23:29]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (_csr_rdata_T_6) begin // @[Core.scala 395:30]
        if (_csr_wdata_T) begin // @[Mux.scala 101:16]
          csr_gpio_out <= mem_reg_op1_data;
        end else begin
          csr_gpio_out <= _csr_wdata_T_9;
        end
      end
    end
    if (reset) begin // @[Core.scala 24:32]
      csr_trap_vector <= 32'h0; // @[Core.scala 24:32]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_trap_vector <= _GEN_157;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_wpri0 <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_wpri0 <= csr_mstatus_mstatus_1_wpri0; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_wpri0 <= _GEN_158;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_sie <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_sie <= csr_mstatus_mstatus_1_sie; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_sie <= _GEN_159;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_wpri1 <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_wpri1 <= csr_mstatus_mstatus_1_wpri1; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_wpri1 <= _GEN_160;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_mie <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (_csr_rdata_T_6) begin // @[Core.scala 395:30]
        csr_mstatus_mie <= _GEN_26;
      end else if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
        csr_mstatus_mie <= csr_mstatus_mstatus_1_mie; // @[Core.scala 397:43]
      end else begin
        csr_mstatus_mie <= _GEN_161;
      end
    end else begin
      csr_mstatus_mie <= _GEN_26;
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_wpri2 <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_wpri2 <= csr_mstatus_mstatus_1_wpri2; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_wpri2 <= _GEN_162;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_spie <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_spie <= csr_mstatus_mstatus_1_spie; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_spie <= _GEN_163;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_ube <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_ube <= csr_mstatus_mstatus_1_ube; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_ube <= _GEN_164;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_mpie <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (_csr_rdata_T_6) begin // @[Core.scala 395:30]
        csr_mstatus_mpie <= _GEN_24;
      end else if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
        csr_mstatus_mpie <= csr_mstatus_mstatus_1_mpie; // @[Core.scala 397:43]
      end else begin
        csr_mstatus_mpie <= _GEN_165;
      end
    end else begin
      csr_mstatus_mpie <= _GEN_24;
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_spp <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_spp <= csr_mstatus_mstatus_1_spp; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_spp <= _GEN_166;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_vs <= 2'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_vs <= csr_mstatus_mstatus_1_vs; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_vs <= _GEN_167;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_mpp <= 2'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_mpp <= csr_mstatus_mstatus_1_mpp; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_mpp <= _GEN_168;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_fs <= 2'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_fs <= csr_mstatus_mstatus_1_fs; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_fs <= _GEN_169;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_xs <= 2'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_xs <= csr_mstatus_mstatus_1_xs; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_xs <= _GEN_170;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_mprv <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_mprv <= csr_mstatus_mstatus_1_mprv; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_mprv <= _GEN_171;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_sum <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_sum <= csr_mstatus_mstatus_1_sum; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_sum <= _GEN_172;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_mxr <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_mxr <= csr_mstatus_mstatus_1_mxr; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_mxr <= _GEN_173;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_tvm <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_tvm <= csr_mstatus_mstatus_1_tvm; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_tvm <= _GEN_174;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_tw <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_tw <= csr_mstatus_mstatus_1_tw; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_tw <= _GEN_175;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_tsr <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_tsr <= csr_mstatus_mstatus_1_tsr; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_tsr <= _GEN_176;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_wpri3 <= 9'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_wpri3 <= csr_mstatus_mstatus_1_wpri3; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_wpri3 <= _GEN_177;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_sbe <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_sbe <= csr_mstatus_mstatus_1_sbe; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_sbe <= _GEN_180;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_mbe <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_mbe <= csr_mstatus_mstatus_1_mbe; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_mbe <= _GEN_181;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_wpri4 <= 25'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_wpri4 <= csr_mstatus_mstatus_1_wpri4; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_wpri4 <= _GEN_182;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_sd <= 1'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_sd <= csr_mstatus_mstatus_1_sd; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_sd <= _GEN_183;
        end
      end
    end
    if (reset) begin // @[Core.scala 26:28]
      csr_mstatus_wpri5 <= 4'h0; // @[Core.scala 26:28]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
          csr_mstatus_wpri5 <= csr_mstatus_mstatus_1_wpri5; // @[Core.scala 397:43]
        end else begin
          csr_mstatus_wpri5 <= _GEN_184;
        end
      end
    end
    if (reset) begin // @[Core.scala 27:24]
      csr_mie_ssie <= 1'h0; // @[Core.scala 27:24]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mie_ssie <= _GEN_151;
        end
      end
    end
    if (reset) begin // @[Core.scala 27:24]
      csr_mie_msie <= 1'h0; // @[Core.scala 27:24]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mie_msie <= _GEN_152;
        end
      end
    end
    if (reset) begin // @[Core.scala 27:24]
      csr_mie_stie <= 1'h0; // @[Core.scala 27:24]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mie_stie <= _GEN_153;
        end
      end
    end
    if (reset) begin // @[Core.scala 27:24]
      csr_mie_mtie <= 1'h0; // @[Core.scala 27:24]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mie_mtie <= _GEN_154;
        end
      end
    end
    if (reset) begin // @[Core.scala 27:24]
      csr_mie_seie <= 1'h0; // @[Core.scala 27:24]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mie_seie <= _GEN_155;
        end
      end
    end
    if (reset) begin // @[Core.scala 27:24]
      csr_mie_meie <= 1'h0; // @[Core.scala 27:24]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mie_meie <= _GEN_156;
        end
      end
    end
    if (reset) begin // @[Core.scala 29:29]
      csr_mscratch <= 32'h0; // @[Core.scala 29:29]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mscratch <= _GEN_185;
        end
      end
    end
    if (reset) begin // @[Core.scala 30:25]
      csr_mepc <= 32'h0; // @[Core.scala 30:25]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (_csr_rdata_T_6) begin // @[Core.scala 395:30]
        csr_mepc <= _GEN_23;
      end else if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
        csr_mepc <= _GEN_23;
      end else begin
        csr_mepc <= _GEN_186;
      end
    end else begin
      csr_mepc <= _GEN_23;
    end
    if (reset) begin // @[Core.scala 31:27]
      csr_mcause <= 32'h0; // @[Core.scala 31:27]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (_csr_rdata_T_6) begin // @[Core.scala 395:30]
        csr_mcause <= _GEN_22;
      end else if (_csr_rdata_T_8) begin // @[Core.scala 395:30]
        csr_mcause <= _GEN_22;
      end else begin
        csr_mcause <= _GEN_187;
      end
    end else begin
      csr_mcause <= _GEN_22;
    end
    if (reset) begin // @[Core.scala 32:26]
      csr_mtval <= 32'h0; // @[Core.scala 32:26]
    end else if (mem_reg_csr_cmd > 3'h0) begin // @[Core.scala 394:30]
      if (!(_csr_rdata_T_6)) begin // @[Core.scala 395:30]
        if (!(_csr_rdata_T_8)) begin // @[Core.scala 395:30]
          csr_mtval <= _GEN_188;
        end
      end
    end
    if (reset) begin // @[Core.scala 52:38]
      id_reg_pc <= 32'h0; // @[Core.scala 52:38]
    end else if (!(stall_flg | exe_br_flg | exe_jmp_flg | _if_pc_next_T_2)) begin // @[Core.scala 130:21]
      id_reg_pc <= if_reg_pc;
    end
    if (reset) begin // @[Core.scala 53:38]
      id_reg_inst <= 32'h0; // @[Core.scala 53:38]
    end else if (_id_reg_inst_T) begin // @[Mux.scala 101:16]
      id_reg_inst <= 32'h13;
    end else if (!(stall_flg)) begin // @[Mux.scala 101:16]
      if (io_imem_valid) begin // @[Core.scala 108:20]
        id_reg_inst <= io_imem_inst;
      end else begin
        id_reg_inst <= 32'h13;
      end
    end
    if (reset) begin // @[Core.scala 56:38]
      exe_reg_pc <= 32'h0; // @[Core.scala 56:38]
    end else if (_T & ~_id_reg_inst_T) begin // @[Core.scala 282:59]
      exe_reg_pc <= id_reg_pc; // @[Core.scala 283:27]
    end
    if (reset) begin // @[Core.scala 57:38]
      exe_reg_wb_addr <= 5'h0; // @[Core.scala 57:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_wb_addr <= id_wb_addr; // @[Core.scala 264:27]
    end
    if (reset) begin // @[Core.scala 58:38]
      exe_reg_op1_data <= 32'h0; // @[Core.scala 58:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_id_op1_data_T) begin // @[Mux.scala 101:16]
        if (_id_rs1_data_T) begin // @[Mux.scala 101:16]
          exe_reg_op1_data <= 32'h0;
        end else begin
          exe_reg_op1_data <= _id_rs1_data_T_8;
        end
      end else if (_id_op1_data_T_1) begin // @[Mux.scala 101:16]
        exe_reg_op1_data <= id_reg_pc;
      end else begin
        exe_reg_op1_data <= _id_op1_data_T_3;
      end
    end
    if (reset) begin // @[Core.scala 59:38]
      exe_reg_op2_data <= 32'h0; // @[Core.scala 59:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_id_op2_data_T) begin // @[Mux.scala 101:16]
        if (_id_rs2_data_T) begin // @[Mux.scala 101:16]
          exe_reg_op2_data <= 32'h0;
        end else begin
          exe_reg_op2_data <= _id_rs2_data_T_8;
        end
      end else if (_id_op2_data_T_1) begin // @[Mux.scala 101:16]
        exe_reg_op2_data <= id_imm_i_sext;
      end else begin
        exe_reg_op2_data <= _id_op2_data_T_7;
      end
    end
    if (reset) begin // @[Core.scala 60:38]
      exe_reg_rs2_data <= 32'h0; // @[Core.scala 60:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_id_rs2_data_T) begin // @[Mux.scala 101:16]
        exe_reg_rs2_data <= 32'h0;
      end else if (_id_rs2_data_T_3) begin // @[Mux.scala 101:16]
        exe_reg_rs2_data <= mem_wb_data;
      end else begin
        exe_reg_rs2_data <= _id_rs2_data_T_7;
      end
    end
    if (reset) begin // @[Core.scala 61:38]
      exe_reg_exe_fun <= 5'h0; // @[Core.scala 61:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_csignals_T_1) begin // @[Lookup.scala 34:39]
        exe_reg_exe_fun <= 5'h1;
      end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
        exe_reg_exe_fun <= 5'h1;
      end else begin
        exe_reg_exe_fun <= _csignals_T_129;
      end
    end
    if (reset) begin // @[Core.scala 62:38]
      exe_reg_mem_wen <= 2'h0; // @[Core.scala 62:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_csignals_T_1) begin // @[Lookup.scala 34:39]
        exe_reg_mem_wen <= 2'h0;
      end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
        exe_reg_mem_wen <= 2'h0;
      end else begin
        exe_reg_mem_wen <= _csignals_T_258;
      end
    end
    if (reset) begin // @[Core.scala 63:38]
      exe_reg_rf_wen <= 2'h0; // @[Core.scala 63:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_csignals_T_1) begin // @[Lookup.scala 34:39]
        exe_reg_rf_wen <= 2'h1;
      end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
        exe_reg_rf_wen <= 2'h1;
      end else begin
        exe_reg_rf_wen <= _csignals_T_301;
      end
    end
    if (reset) begin // @[Core.scala 64:38]
      exe_reg_wb_sel <= 3'h0; // @[Core.scala 64:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_csignals_T_1) begin // @[Lookup.scala 34:39]
        exe_reg_wb_sel <= 3'h1;
      end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
        exe_reg_wb_sel <= 3'h1;
      end else begin
        exe_reg_wb_sel <= _csignals_T_344;
      end
    end
    if (reset) begin // @[Core.scala 65:38]
      exe_reg_csr_addr <= 12'h0; // @[Core.scala 65:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (csignals_6 == 3'h4) begin // @[Core.scala 253:24]
        exe_reg_csr_addr <= 12'h342;
      end else begin
        exe_reg_csr_addr <= id_imm_i;
      end
    end
    if (reset) begin // @[Core.scala 66:38]
      exe_reg_csr_cmd <= 3'h0; // @[Core.scala 66:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      if (_csignals_T_1) begin // @[Lookup.scala 34:39]
        exe_reg_csr_cmd <= 3'h0;
      end else if (_csignals_T_3) begin // @[Lookup.scala 34:39]
        exe_reg_csr_cmd <= 3'h0;
      end else begin
        exe_reg_csr_cmd <= _csignals_T_387;
      end
    end
    if (reset) begin // @[Core.scala 69:38]
      exe_reg_imm_b_sext <= 32'h0; // @[Core.scala 69:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_imm_b_sext <= id_imm_b_sext; // @[Core.scala 270:27]
    end
    if (reset) begin // @[Core.scala 72:38]
      exe_reg_mem_w <= 32'h0; // @[Core.scala 72:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_mem_w <= {{29'd0}, csignals_7}; // @[Core.scala 276:27]
    end
    if (reset) begin // @[Core.scala 73:46]
      exe_reg_has_pending_interrupt <= 1'h0; // @[Core.scala 73:46]
    end else if (exe_reg_has_pending_interrupt) begin // @[Core.scala 285:41]
      exe_reg_has_pending_interrupt <= 1'h0; // @[Core.scala 286:35]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_has_pending_interrupt <= id_has_pending_interrupt; // @[Core.scala 277:35]
    end
    if (reset) begin // @[Core.scala 74:41]
      exe_reg_exception_target <= 32'h0; // @[Core.scala 74:41]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_exception_target <= id_exception_target; // @[Core.scala 278:30]
    end
    if (reset) begin // @[Core.scala 75:38]
      exe_reg_mcause <= 32'h0; // @[Core.scala 75:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_mcause <= id_mcause; // @[Core.scala 279:27]
    end
    if (reset) begin // @[Core.scala 76:38]
      exe_reg_mret <= 1'h0; // @[Core.scala 76:38]
    end else if (~mem_stall_flg) begin // @[Core.scala 260:26]
      exe_reg_mret <= id_mret; // @[Core.scala 280:27]
    end
    if (reset) begin // @[Core.scala 79:38]
      mem_reg_pc <= 32'h0; // @[Core.scala 79:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_pc <= exe_reg_pc; // @[Core.scala 342:24]
    end
    if (reset) begin // @[Core.scala 80:38]
      mem_reg_wb_addr <= 5'h0; // @[Core.scala 80:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_wb_addr <= exe_reg_wb_addr; // @[Core.scala 345:24]
    end
    if (reset) begin // @[Core.scala 81:38]
      mem_reg_op1_data <= 32'h0; // @[Core.scala 81:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_op1_data <= exe_reg_op1_data; // @[Core.scala 343:24]
    end
    if (reset) begin // @[Core.scala 82:38]
      mem_reg_rs2_data <= 32'h0; // @[Core.scala 82:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_rs2_data <= exe_reg_rs2_data; // @[Core.scala 344:24]
    end
    if (reset) begin // @[Core.scala 83:38]
      mem_reg_mem_wen <= 2'h0; // @[Core.scala 83:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_mem_wen <= exe_reg_mem_wen; // @[Core.scala 352:24]
    end
    if (reset) begin // @[Core.scala 84:38]
      mem_reg_rf_wen <= 2'h0; // @[Core.scala 84:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_rf_wen <= exe_reg_rf_wen; // @[Core.scala 347:24]
    end
    if (reset) begin // @[Core.scala 85:38]
      mem_reg_wb_sel <= 3'h0; // @[Core.scala 85:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_wb_sel <= exe_reg_wb_sel; // @[Core.scala 348:24]
    end
    if (reset) begin // @[Core.scala 86:38]
      mem_reg_csr_addr <= 12'h0; // @[Core.scala 86:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_csr_addr <= exe_reg_csr_addr; // @[Core.scala 349:24]
    end
    if (reset) begin // @[Core.scala 87:38]
      mem_reg_csr_cmd <= 3'h0; // @[Core.scala 87:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_csr_cmd <= exe_reg_csr_cmd; // @[Core.scala 350:24]
    end
    if (reset) begin // @[Core.scala 89:38]
      mem_reg_alu_out <= 32'h0; // @[Core.scala 89:38]
    end else if (_T) begin // @[Core.scala 341:26]
      if (_exe_alu_out_T) begin // @[Mux.scala 101:16]
        mem_reg_alu_out <= _exe_alu_out_T_2;
      end else if (_exe_alu_out_T_3) begin // @[Mux.scala 101:16]
        mem_reg_alu_out <= _exe_alu_out_T_5;
      end else begin
        mem_reg_alu_out <= _exe_alu_out_T_45;
      end
    end
    if (reset) begin // @[Core.scala 90:38]
      mem_reg_mem_w <= 32'h0; // @[Core.scala 90:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_mem_w <= exe_reg_mem_w; // @[Core.scala 353:24]
    end
    if (reset) begin // @[Core.scala 91:38]
      mem_reg_mem_wstrb <= 4'h0; // @[Core.scala 91:38]
    end else if (_T) begin // @[Core.scala 341:26]
      mem_reg_mem_wstrb <= _mem_reg_mem_wstrb_T_7[3:0]; // @[Core.scala 354:24]
    end
    if (reset) begin // @[Core.scala 94:38]
      wb_reg_wb_addr <= 5'h0; // @[Core.scala 94:38]
    end else begin
      wb_reg_wb_addr <= mem_reg_wb_addr; // @[Core.scala 435:18]
    end
    if (reset) begin // @[Core.scala 95:38]
      wb_reg_rf_wen <= 2'h0; // @[Core.scala 95:38]
    end else if (_T) begin // @[Core.scala 436:24]
      wb_reg_rf_wen <= mem_reg_rf_wen;
    end else begin
      wb_reg_rf_wen <= 2'h0;
    end
    if (reset) begin // @[Core.scala 96:38]
      wb_reg_wb_data <= 32'h0; // @[Core.scala 96:38]
    end else if (_mem_wb_data_T) begin // @[Mux.scala 101:16]
      if (_mem_wb_data_load_T) begin // @[Mux.scala 101:16]
        wb_reg_wb_data <= _mem_wb_data_load_T_5;
      end else if (_mem_wb_data_load_T_6) begin // @[Mux.scala 101:16]
        wb_reg_wb_data <= _mem_wb_data_load_T_11;
      end else begin
        wb_reg_wb_data <= _mem_wb_data_load_T_21;
      end
    end else if (_mem_wb_data_T_1) begin // @[Mux.scala 101:16]
      wb_reg_wb_data <= _mem_wb_data_T_3;
    end else if (_mem_wb_data_T_4) begin // @[Mux.scala 101:16]
      wb_reg_wb_data <= csr_rdata;
    end else begin
      wb_reg_wb_data <= mem_reg_alu_out;
    end
    if (reset) begin // @[Core.scala 106:26]
      if_reg_pc <= 32'h0; // @[Core.scala 106:26]
    end else if (exe_br_flg) begin // @[Mux.scala 101:16]
      if (exe_reg_has_pending_interrupt) begin // @[Mux.scala 101:16]
        if_reg_pc <= exe_reg_exception_target;
      end else if (exe_reg_mret) begin // @[Mux.scala 101:16]
        if_reg_pc <= csr_mepc;
      end else begin
        if_reg_pc <= _exe_br_target_T_1;
      end
    end else if (exe_jmp_flg) begin // @[Mux.scala 101:16]
      if (_exe_alu_out_T) begin // @[Mux.scala 101:16]
        if_reg_pc <= _exe_alu_out_T_2;
      end else begin
        if_reg_pc <= _exe_alu_out_T_46;
      end
    end else if (_if_pc_next_T_1) begin // @[Mux.scala 101:16]
      if_reg_pc <= csr_trap_vector;
    end else begin
      if_reg_pc <= _if_pc_next_T_4;
    end
    if (reset) begin // @[Core.scala 450:32]
      successDetected <= 1'h0; // @[Core.scala 450:32]
    end else if (if_inst != 32'h13) begin // @[Core.scala 451:25]
      successDetected <= if_inst == 32'h513;
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,"if_reg_pc        : 0x%x\n",if_reg_pc); // @[Core.scala 456:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"id_reg_pc        : 0x%x\n",id_reg_pc); // @[Core.scala 457:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"id_reg_inst      : 0x%x\n",id_reg_inst); // @[Core.scala 458:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"stall_flg        : 0x%x\n",stall_flg); // @[Core.scala 459:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"id_inst          : 0x%x\n",id_inst); // @[Core.scala 460:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"id_rs1_data      : 0x%x\n",id_rs1_data); // @[Core.scala 461:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"id_rs2_data      : 0x%x\n",id_rs2_data); // @[Core.scala 462:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"exe_reg_pc       : 0x%x\n",exe_reg_pc); // @[Core.scala 463:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"exe_reg_op1_data : 0x%x\n",exe_reg_op1_data); // @[Core.scala 464:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"exe_reg_op2_data : 0x%x\n",exe_reg_op2_data); // @[Core.scala 465:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"exe_alu_out      : 0x%x\n",exe_alu_out); // @[Core.scala 466:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"mem_reg_pc       : 0x%x\n",mem_reg_pc); // @[Core.scala 467:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"mem_wb_data      : 0x%x\n",mem_wb_data); // @[Core.scala 468:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"wb_reg_wb_data   : 0x%x\n",wb_reg_wb_data); // @[Core.scala 469:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (_T_20) begin
          $fwrite(32'h80000002,"---------\n"); // @[Core.scala 470:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 32; initvar = initvar+1)
    regfile[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  csr_gpio_out = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  csr_trap_vector = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  csr_mstatus_wpri0 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  csr_mstatus_sie = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  csr_mstatus_wpri1 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  csr_mstatus_mie = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  csr_mstatus_wpri2 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  csr_mstatus_spie = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  csr_mstatus_ube = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  csr_mstatus_mpie = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  csr_mstatus_spp = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  csr_mstatus_vs = _RAND_12[1:0];
  _RAND_13 = {1{`RANDOM}};
  csr_mstatus_mpp = _RAND_13[1:0];
  _RAND_14 = {1{`RANDOM}};
  csr_mstatus_fs = _RAND_14[1:0];
  _RAND_15 = {1{`RANDOM}};
  csr_mstatus_xs = _RAND_15[1:0];
  _RAND_16 = {1{`RANDOM}};
  csr_mstatus_mprv = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  csr_mstatus_sum = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  csr_mstatus_mxr = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  csr_mstatus_tvm = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  csr_mstatus_tw = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  csr_mstatus_tsr = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  csr_mstatus_wpri3 = _RAND_22[8:0];
  _RAND_23 = {1{`RANDOM}};
  csr_mstatus_sbe = _RAND_23[0:0];
  _RAND_24 = {1{`RANDOM}};
  csr_mstatus_mbe = _RAND_24[0:0];
  _RAND_25 = {1{`RANDOM}};
  csr_mstatus_wpri4 = _RAND_25[24:0];
  _RAND_26 = {1{`RANDOM}};
  csr_mstatus_sd = _RAND_26[0:0];
  _RAND_27 = {1{`RANDOM}};
  csr_mstatus_wpri5 = _RAND_27[3:0];
  _RAND_28 = {1{`RANDOM}};
  csr_mie_ssie = _RAND_28[0:0];
  _RAND_29 = {1{`RANDOM}};
  csr_mie_msie = _RAND_29[0:0];
  _RAND_30 = {1{`RANDOM}};
  csr_mie_stie = _RAND_30[0:0];
  _RAND_31 = {1{`RANDOM}};
  csr_mie_mtie = _RAND_31[0:0];
  _RAND_32 = {1{`RANDOM}};
  csr_mie_seie = _RAND_32[0:0];
  _RAND_33 = {1{`RANDOM}};
  csr_mie_meie = _RAND_33[0:0];
  _RAND_34 = {1{`RANDOM}};
  csr_mscratch = _RAND_34[31:0];
  _RAND_35 = {1{`RANDOM}};
  csr_mepc = _RAND_35[31:0];
  _RAND_36 = {1{`RANDOM}};
  csr_mcause = _RAND_36[31:0];
  _RAND_37 = {1{`RANDOM}};
  csr_mtval = _RAND_37[31:0];
  _RAND_38 = {1{`RANDOM}};
  id_reg_pc = _RAND_38[31:0];
  _RAND_39 = {1{`RANDOM}};
  id_reg_inst = _RAND_39[31:0];
  _RAND_40 = {1{`RANDOM}};
  exe_reg_pc = _RAND_40[31:0];
  _RAND_41 = {1{`RANDOM}};
  exe_reg_wb_addr = _RAND_41[4:0];
  _RAND_42 = {1{`RANDOM}};
  exe_reg_op1_data = _RAND_42[31:0];
  _RAND_43 = {1{`RANDOM}};
  exe_reg_op2_data = _RAND_43[31:0];
  _RAND_44 = {1{`RANDOM}};
  exe_reg_rs2_data = _RAND_44[31:0];
  _RAND_45 = {1{`RANDOM}};
  exe_reg_exe_fun = _RAND_45[4:0];
  _RAND_46 = {1{`RANDOM}};
  exe_reg_mem_wen = _RAND_46[1:0];
  _RAND_47 = {1{`RANDOM}};
  exe_reg_rf_wen = _RAND_47[1:0];
  _RAND_48 = {1{`RANDOM}};
  exe_reg_wb_sel = _RAND_48[2:0];
  _RAND_49 = {1{`RANDOM}};
  exe_reg_csr_addr = _RAND_49[11:0];
  _RAND_50 = {1{`RANDOM}};
  exe_reg_csr_cmd = _RAND_50[2:0];
  _RAND_51 = {1{`RANDOM}};
  exe_reg_imm_b_sext = _RAND_51[31:0];
  _RAND_52 = {1{`RANDOM}};
  exe_reg_mem_w = _RAND_52[31:0];
  _RAND_53 = {1{`RANDOM}};
  exe_reg_has_pending_interrupt = _RAND_53[0:0];
  _RAND_54 = {1{`RANDOM}};
  exe_reg_exception_target = _RAND_54[31:0];
  _RAND_55 = {1{`RANDOM}};
  exe_reg_mcause = _RAND_55[31:0];
  _RAND_56 = {1{`RANDOM}};
  exe_reg_mret = _RAND_56[0:0];
  _RAND_57 = {1{`RANDOM}};
  mem_reg_pc = _RAND_57[31:0];
  _RAND_58 = {1{`RANDOM}};
  mem_reg_wb_addr = _RAND_58[4:0];
  _RAND_59 = {1{`RANDOM}};
  mem_reg_op1_data = _RAND_59[31:0];
  _RAND_60 = {1{`RANDOM}};
  mem_reg_rs2_data = _RAND_60[31:0];
  _RAND_61 = {1{`RANDOM}};
  mem_reg_mem_wen = _RAND_61[1:0];
  _RAND_62 = {1{`RANDOM}};
  mem_reg_rf_wen = _RAND_62[1:0];
  _RAND_63 = {1{`RANDOM}};
  mem_reg_wb_sel = _RAND_63[2:0];
  _RAND_64 = {1{`RANDOM}};
  mem_reg_csr_addr = _RAND_64[11:0];
  _RAND_65 = {1{`RANDOM}};
  mem_reg_csr_cmd = _RAND_65[2:0];
  _RAND_66 = {1{`RANDOM}};
  mem_reg_alu_out = _RAND_66[31:0];
  _RAND_67 = {1{`RANDOM}};
  mem_reg_mem_w = _RAND_67[31:0];
  _RAND_68 = {1{`RANDOM}};
  mem_reg_mem_wstrb = _RAND_68[3:0];
  _RAND_69 = {1{`RANDOM}};
  wb_reg_wb_addr = _RAND_69[4:0];
  _RAND_70 = {1{`RANDOM}};
  wb_reg_rf_wen = _RAND_70[1:0];
  _RAND_71 = {1{`RANDOM}};
  wb_reg_wb_data = _RAND_71[31:0];
  _RAND_72 = {1{`RANDOM}};
  if_reg_pc = _RAND_72[31:0];
  _RAND_73 = {1{`RANDOM}};
  successDetected = _RAND_73[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Memory(
  input         clock,
  input         reset,
  input  [31:0] io_imem_addr,
  output [31:0] io_imem_inst,
  output        io_imem_valid,
  input  [31:0] io_dmem_addr,
  output [31:0] io_dmem_rdata,
  input         io_dmem_ren,
  output        io_dmem_rvalid,
  input         io_dmem_wen,
  input  [3:0]  io_dmem_wstrb,
  input  [31:0] io_dmem_wdata
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] mems_0 [0:2047]; // @[Memory.scala 30:43]
  wire  mems_0_io_imem_inst_MPORT_en; // @[Memory.scala 30:43]
  wire [10:0] mems_0_io_imem_inst_MPORT_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_0_io_imem_inst_MPORT_data; // @[Memory.scala 30:43]
  wire  mems_0_rdata_MPORT_en; // @[Memory.scala 30:43]
  wire [10:0] mems_0_rdata_MPORT_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_0_rdata_MPORT_data; // @[Memory.scala 30:43]
  wire [7:0] mems_0_MPORT_data; // @[Memory.scala 30:43]
  wire [10:0] mems_0_MPORT_addr; // @[Memory.scala 30:43]
  wire  mems_0_MPORT_mask; // @[Memory.scala 30:43]
  wire  mems_0_MPORT_en; // @[Memory.scala 30:43]
  reg  mems_0_io_imem_inst_MPORT_en_pipe_0;
  reg [10:0] mems_0_io_imem_inst_MPORT_addr_pipe_0;
  reg  mems_0_rdata_MPORT_en_pipe_0;
  reg [10:0] mems_0_rdata_MPORT_addr_pipe_0;
  reg [7:0] mems_1 [0:2047]; // @[Memory.scala 30:43]
  wire  mems_1_io_imem_inst_MPORT_1_en; // @[Memory.scala 30:43]
  wire [10:0] mems_1_io_imem_inst_MPORT_1_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_1_io_imem_inst_MPORT_1_data; // @[Memory.scala 30:43]
  wire  mems_1_rdata_MPORT_1_en; // @[Memory.scala 30:43]
  wire [10:0] mems_1_rdata_MPORT_1_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_1_rdata_MPORT_1_data; // @[Memory.scala 30:43]
  wire [7:0] mems_1_MPORT_1_data; // @[Memory.scala 30:43]
  wire [10:0] mems_1_MPORT_1_addr; // @[Memory.scala 30:43]
  wire  mems_1_MPORT_1_mask; // @[Memory.scala 30:43]
  wire  mems_1_MPORT_1_en; // @[Memory.scala 30:43]
  reg  mems_1_io_imem_inst_MPORT_1_en_pipe_0;
  reg [10:0] mems_1_io_imem_inst_MPORT_1_addr_pipe_0;
  reg  mems_1_rdata_MPORT_1_en_pipe_0;
  reg [10:0] mems_1_rdata_MPORT_1_addr_pipe_0;
  reg [7:0] mems_2 [0:2047]; // @[Memory.scala 30:43]
  wire  mems_2_io_imem_inst_MPORT_2_en; // @[Memory.scala 30:43]
  wire [10:0] mems_2_io_imem_inst_MPORT_2_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_2_io_imem_inst_MPORT_2_data; // @[Memory.scala 30:43]
  wire  mems_2_rdata_MPORT_2_en; // @[Memory.scala 30:43]
  wire [10:0] mems_2_rdata_MPORT_2_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_2_rdata_MPORT_2_data; // @[Memory.scala 30:43]
  wire [7:0] mems_2_MPORT_2_data; // @[Memory.scala 30:43]
  wire [10:0] mems_2_MPORT_2_addr; // @[Memory.scala 30:43]
  wire  mems_2_MPORT_2_mask; // @[Memory.scala 30:43]
  wire  mems_2_MPORT_2_en; // @[Memory.scala 30:43]
  reg  mems_2_io_imem_inst_MPORT_2_en_pipe_0;
  reg [10:0] mems_2_io_imem_inst_MPORT_2_addr_pipe_0;
  reg  mems_2_rdata_MPORT_2_en_pipe_0;
  reg [10:0] mems_2_rdata_MPORT_2_addr_pipe_0;
  reg [7:0] mems_3 [0:2047]; // @[Memory.scala 30:43]
  wire  mems_3_io_imem_inst_MPORT_3_en; // @[Memory.scala 30:43]
  wire [10:0] mems_3_io_imem_inst_MPORT_3_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_3_io_imem_inst_MPORT_3_data; // @[Memory.scala 30:43]
  wire  mems_3_rdata_MPORT_3_en; // @[Memory.scala 30:43]
  wire [10:0] mems_3_rdata_MPORT_3_addr; // @[Memory.scala 30:43]
  wire [7:0] mems_3_rdata_MPORT_3_data; // @[Memory.scala 30:43]
  wire [7:0] mems_3_MPORT_3_data; // @[Memory.scala 30:43]
  wire [10:0] mems_3_MPORT_3_addr; // @[Memory.scala 30:43]
  wire  mems_3_MPORT_3_mask; // @[Memory.scala 30:43]
  wire  mems_3_MPORT_3_en; // @[Memory.scala 30:43]
  reg  mems_3_io_imem_inst_MPORT_3_en_pipe_0;
  reg [10:0] mems_3_io_imem_inst_MPORT_3_addr_pipe_0;
  reg  mems_3_rdata_MPORT_3_en_pipe_0;
  reg [10:0] mems_3_rdata_MPORT_3_addr_pipe_0;
  wire [31:0] _imemWordAddr_T_1 = io_imem_addr - 32'h0; // @[Memory.scala 38:36]
  wire [29:0] imemWordAddr = _imemWordAddr_T_1[31:2]; // @[Memory.scala 38:51]
  reg [29:0] imemWordAddrFetched; // @[Memory.scala 39:32]
  reg  isFirstCycle; // @[Memory.scala 40:29]
  wire [15:0] io_imem_inst_lo = {mems_1_io_imem_inst_MPORT_1_data,mems_0_io_imem_inst_MPORT_data}; // @[Cat.scala 33:92]
  wire [15:0] io_imem_inst_hi = {mems_3_io_imem_inst_MPORT_3_data,mems_2_io_imem_inst_MPORT_2_data}; // @[Cat.scala 33:92]
  wire [31:0] _dmemWordAddr_T_1 = io_dmem_addr - 32'h0; // @[Memory.scala 49:36]
  wire [29:0] dmemWordAddr = _dmemWordAddr_T_1[31:2]; // @[Memory.scala 49:51]
  reg  rvalid; // @[Memory.scala 50:23]
  wire [15:0] rdata_lo = {mems_1_rdata_MPORT_1_data,mems_0_rdata_MPORT_data}; // @[Cat.scala 33:92]
  wire [15:0] rdata_hi = {mems_3_rdata_MPORT_3_data,mems_2_rdata_MPORT_2_data}; // @[Cat.scala 33:92]
  wire [31:0] rdata = {mems_3_rdata_MPORT_3_data,mems_2_rdata_MPORT_2_data,mems_1_rdata_MPORT_1_data,
    mems_0_rdata_MPORT_data}; // @[Cat.scala 33:92]
  reg [31:0] dmemAddrReg; // @[Memory.scala 57:24]
  wire  _T_3 = io_dmem_ren & ~io_dmem_wen & ~rvalid; // @[Memory.scala 58:37]
  assign mems_0_io_imem_inst_MPORT_en = mems_0_io_imem_inst_MPORT_en_pipe_0;
  assign mems_0_io_imem_inst_MPORT_addr = mems_0_io_imem_inst_MPORT_addr_pipe_0;
  assign mems_0_io_imem_inst_MPORT_data = mems_0[mems_0_io_imem_inst_MPORT_addr]; // @[Memory.scala 30:43]
  assign mems_0_rdata_MPORT_en = mems_0_rdata_MPORT_en_pipe_0;
  assign mems_0_rdata_MPORT_addr = mems_0_rdata_MPORT_addr_pipe_0;
  assign mems_0_rdata_MPORT_data = mems_0[mems_0_rdata_MPORT_addr]; // @[Memory.scala 30:43]
  assign mems_0_MPORT_data = io_dmem_wdata[7:0];
  assign mems_0_MPORT_addr = dmemWordAddr[10:0];
  assign mems_0_MPORT_mask = 1'h1;
  assign mems_0_MPORT_en = io_dmem_wen & io_dmem_wstrb[0];
  assign mems_1_io_imem_inst_MPORT_1_en = mems_1_io_imem_inst_MPORT_1_en_pipe_0;
  assign mems_1_io_imem_inst_MPORT_1_addr = mems_1_io_imem_inst_MPORT_1_addr_pipe_0;
  assign mems_1_io_imem_inst_MPORT_1_data = mems_1[mems_1_io_imem_inst_MPORT_1_addr]; // @[Memory.scala 30:43]
  assign mems_1_rdata_MPORT_1_en = mems_1_rdata_MPORT_1_en_pipe_0;
  assign mems_1_rdata_MPORT_1_addr = mems_1_rdata_MPORT_1_addr_pipe_0;
  assign mems_1_rdata_MPORT_1_data = mems_1[mems_1_rdata_MPORT_1_addr]; // @[Memory.scala 30:43]
  assign mems_1_MPORT_1_data = io_dmem_wdata[15:8];
  assign mems_1_MPORT_1_addr = dmemWordAddr[10:0];
  assign mems_1_MPORT_1_mask = 1'h1;
  assign mems_1_MPORT_1_en = io_dmem_wen & io_dmem_wstrb[1];
  assign mems_2_io_imem_inst_MPORT_2_en = mems_2_io_imem_inst_MPORT_2_en_pipe_0;
  assign mems_2_io_imem_inst_MPORT_2_addr = mems_2_io_imem_inst_MPORT_2_addr_pipe_0;
  assign mems_2_io_imem_inst_MPORT_2_data = mems_2[mems_2_io_imem_inst_MPORT_2_addr]; // @[Memory.scala 30:43]
  assign mems_2_rdata_MPORT_2_en = mems_2_rdata_MPORT_2_en_pipe_0;
  assign mems_2_rdata_MPORT_2_addr = mems_2_rdata_MPORT_2_addr_pipe_0;
  assign mems_2_rdata_MPORT_2_data = mems_2[mems_2_rdata_MPORT_2_addr]; // @[Memory.scala 30:43]
  assign mems_2_MPORT_2_data = io_dmem_wdata[23:16];
  assign mems_2_MPORT_2_addr = dmemWordAddr[10:0];
  assign mems_2_MPORT_2_mask = 1'h1;
  assign mems_2_MPORT_2_en = io_dmem_wen & io_dmem_wstrb[2];
  assign mems_3_io_imem_inst_MPORT_3_en = mems_3_io_imem_inst_MPORT_3_en_pipe_0;
  assign mems_3_io_imem_inst_MPORT_3_addr = mems_3_io_imem_inst_MPORT_3_addr_pipe_0;
  assign mems_3_io_imem_inst_MPORT_3_data = mems_3[mems_3_io_imem_inst_MPORT_3_addr]; // @[Memory.scala 30:43]
  assign mems_3_rdata_MPORT_3_en = mems_3_rdata_MPORT_3_en_pipe_0;
  assign mems_3_rdata_MPORT_3_addr = mems_3_rdata_MPORT_3_addr_pipe_0;
  assign mems_3_rdata_MPORT_3_data = mems_3[mems_3_rdata_MPORT_3_addr]; // @[Memory.scala 30:43]
  assign mems_3_MPORT_3_data = io_dmem_wdata[31:24];
  assign mems_3_MPORT_3_addr = dmemWordAddr[10:0];
  assign mems_3_MPORT_3_mask = 1'h1;
  assign mems_3_MPORT_3_en = io_dmem_wen & io_dmem_wstrb[3];
  assign io_imem_inst = {io_imem_inst_hi,io_imem_inst_lo}; // @[Cat.scala 33:92]
  assign io_imem_valid = ~isFirstCycle & imemWordAddrFetched == imemWordAddr; // @[Memory.scala 43:34]
  assign io_dmem_rdata = {rdata_hi,rdata_lo}; // @[Cat.scala 33:92]
  assign io_dmem_rvalid = rvalid; // @[Memory.scala 54:18]
  always @(posedge clock) begin
    if (mems_0_MPORT_en & mems_0_MPORT_mask) begin
      mems_0[mems_0_MPORT_addr] <= mems_0_MPORT_data; // @[Memory.scala 30:43]
    end
    mems_0_io_imem_inst_MPORT_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_0_io_imem_inst_MPORT_addr_pipe_0 <= imemWordAddr[10:0];
    end
    mems_0_rdata_MPORT_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_0_rdata_MPORT_addr_pipe_0 <= dmemWordAddr[10:0];
    end
    if (mems_1_MPORT_1_en & mems_1_MPORT_1_mask) begin
      mems_1[mems_1_MPORT_1_addr] <= mems_1_MPORT_1_data; // @[Memory.scala 30:43]
    end
    mems_1_io_imem_inst_MPORT_1_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_1_io_imem_inst_MPORT_1_addr_pipe_0 <= imemWordAddr[10:0];
    end
    mems_1_rdata_MPORT_1_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_1_rdata_MPORT_1_addr_pipe_0 <= dmemWordAddr[10:0];
    end
    if (mems_2_MPORT_2_en & mems_2_MPORT_2_mask) begin
      mems_2[mems_2_MPORT_2_addr] <= mems_2_MPORT_2_data; // @[Memory.scala 30:43]
    end
    mems_2_io_imem_inst_MPORT_2_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_2_io_imem_inst_MPORT_2_addr_pipe_0 <= imemWordAddr[10:0];
    end
    mems_2_rdata_MPORT_2_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_2_rdata_MPORT_2_addr_pipe_0 <= dmemWordAddr[10:0];
    end
    if (mems_3_MPORT_3_en & mems_3_MPORT_3_mask) begin
      mems_3[mems_3_MPORT_3_addr] <= mems_3_MPORT_3_data; // @[Memory.scala 30:43]
    end
    mems_3_io_imem_inst_MPORT_3_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_3_io_imem_inst_MPORT_3_addr_pipe_0 <= imemWordAddr[10:0];
    end
    mems_3_rdata_MPORT_3_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mems_3_rdata_MPORT_3_addr_pipe_0 <= dmemWordAddr[10:0];
    end
    imemWordAddrFetched <= _imemWordAddr_T_1[31:2]; // @[Memory.scala 38:51]
    isFirstCycle <= reset; // @[Memory.scala 40:{29,29} 41:16]
    if (reset) begin // @[Memory.scala 50:23]
      rvalid <= 1'h0; // @[Memory.scala 50:23]
    end else begin
      rvalid <= _T_3;
    end
    if (io_dmem_ren & ~io_dmem_wen & ~rvalid) begin // @[Memory.scala 58:50]
      dmemAddrReg <= io_dmem_addr; // @[Memory.scala 60:17]
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (rvalid & ~reset) begin
          $fwrite(32'h80000002,"Data read address=0x%x data=0x%x\n",dmemAddrReg,rdata); // @[Memory.scala 63:11]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  mems_0_io_imem_inst_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  mems_0_io_imem_inst_MPORT_addr_pipe_0 = _RAND_1[10:0];
  _RAND_2 = {1{`RANDOM}};
  mems_0_rdata_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  mems_0_rdata_MPORT_addr_pipe_0 = _RAND_3[10:0];
  _RAND_4 = {1{`RANDOM}};
  mems_1_io_imem_inst_MPORT_1_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  mems_1_io_imem_inst_MPORT_1_addr_pipe_0 = _RAND_5[10:0];
  _RAND_6 = {1{`RANDOM}};
  mems_1_rdata_MPORT_1_en_pipe_0 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  mems_1_rdata_MPORT_1_addr_pipe_0 = _RAND_7[10:0];
  _RAND_8 = {1{`RANDOM}};
  mems_2_io_imem_inst_MPORT_2_en_pipe_0 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  mems_2_io_imem_inst_MPORT_2_addr_pipe_0 = _RAND_9[10:0];
  _RAND_10 = {1{`RANDOM}};
  mems_2_rdata_MPORT_2_en_pipe_0 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  mems_2_rdata_MPORT_2_addr_pipe_0 = _RAND_11[10:0];
  _RAND_12 = {1{`RANDOM}};
  mems_3_io_imem_inst_MPORT_3_en_pipe_0 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  mems_3_io_imem_inst_MPORT_3_addr_pipe_0 = _RAND_13[10:0];
  _RAND_14 = {1{`RANDOM}};
  mems_3_rdata_MPORT_3_en_pipe_0 = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  mems_3_rdata_MPORT_3_addr_pipe_0 = _RAND_15[10:0];
  _RAND_16 = {1{`RANDOM}};
  imemWordAddrFetched = _RAND_16[29:0];
  _RAND_17 = {1{`RANDOM}};
  isFirstCycle = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  rvalid = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  dmemAddrReg = _RAND_19[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemh("../sw/bootrom_0.hex", mems_0);
  $readmemh("../sw/bootrom_1.hex", mems_1);
  $readmemh("../sw/bootrom_2.hex", mems_2);
  $readmemh("../sw/bootrom_3.hex", mems_3);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module GpioArray(
  input         clock,
  input         reset,
  input  [31:0] io_mem_addr,
  output [31:0] io_mem_rdata,
  input         io_mem_wen,
  input  [3:0]  io_mem_wstrb,
  input  [31:0] io_mem_wdata,
  input  [31:0] io_in_5,
  output [31:0] io_out_0,
  output [31:0] io_out_1,
  output [31:0] io_out_2,
  output [31:0] io_out_3,
  output [31:0] io_out_4
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] outReg_0; // @[Gpio.scala 45:23]
  reg [31:0] outReg_1; // @[Gpio.scala 45:23]
  reg [31:0] outReg_2; // @[Gpio.scala 45:23]
  reg [31:0] outReg_3; // @[Gpio.scala 45:23]
  reg [31:0] outReg_4; // @[Gpio.scala 45:23]
  reg [31:0] outReg_5; // @[Gpio.scala 45:23]
  reg [31:0] inReg_5; // @[Gpio.scala 46:22]
  wire [31:0] _io_mem_rdata_T_14 = 5'h0 == io_mem_addr[6:2] ? outReg_0 : 32'hdeadbeef; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_16 = 5'h1 == io_mem_addr[6:2] ? 32'h0 : _io_mem_rdata_T_14; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_18 = 5'h4 == io_mem_addr[6:2] ? outReg_1 : _io_mem_rdata_T_16; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_20 = 5'h5 == io_mem_addr[6:2] ? 32'h0 : _io_mem_rdata_T_18; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_22 = 5'h8 == io_mem_addr[6:2] ? outReg_2 : _io_mem_rdata_T_20; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_24 = 5'h9 == io_mem_addr[6:2] ? 32'h0 : _io_mem_rdata_T_22; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_26 = 5'hc == io_mem_addr[6:2] ? outReg_3 : _io_mem_rdata_T_24; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_28 = 5'hd == io_mem_addr[6:2] ? 32'h0 : _io_mem_rdata_T_26; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_30 = 5'h10 == io_mem_addr[6:2] ? outReg_4 : _io_mem_rdata_T_28; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_32 = 5'h11 == io_mem_addr[6:2] ? 32'h0 : _io_mem_rdata_T_30; // @[Mux.scala 81:58]
  wire [31:0] _io_mem_rdata_T_34 = 5'h14 == io_mem_addr[6:2] ? outReg_5 : _io_mem_rdata_T_32; // @[Mux.scala 81:58]
  wire [7:0] _mask_T_1 = io_mem_wstrb[0] ? 8'hff : 8'h0; // @[Gpio.scala 55:39]
  wire [7:0] _mask_T_3 = io_mem_wstrb[1] ? 8'hff : 8'h0; // @[Gpio.scala 55:39]
  wire [7:0] _mask_T_5 = io_mem_wstrb[2] ? 8'hff : 8'h0; // @[Gpio.scala 55:39]
  wire [7:0] _mask_T_7 = io_mem_wstrb[3] ? 8'hff : 8'h0; // @[Gpio.scala 55:39]
  wire [31:0] mask = {_mask_T_7,_mask_T_5,_mask_T_3,_mask_T_1}; // @[Cat.scala 33:92]
  wire [31:0] _outReg_0_T = ~mask; // @[Gpio.scala 63:52]
  wire [31:0] _outReg_0_T_1 = outReg_0 & _outReg_0_T; // @[Gpio.scala 63:50]
  wire [31:0] _outReg_0_T_2 = io_mem_wdata & mask; // @[Gpio.scala 63:75]
  wire [31:0] _outReg_0_T_3 = _outReg_0_T_1 | _outReg_0_T_2; // @[Gpio.scala 63:59]
  wire [31:0] _outReg_1_T_1 = outReg_1 & _outReg_0_T; // @[Gpio.scala 63:50]
  wire [31:0] _outReg_1_T_3 = _outReg_1_T_1 | _outReg_0_T_2; // @[Gpio.scala 63:59]
  wire [31:0] _outReg_2_T_1 = outReg_2 & _outReg_0_T; // @[Gpio.scala 63:50]
  wire [31:0] _outReg_2_T_3 = _outReg_2_T_1 | _outReg_0_T_2; // @[Gpio.scala 63:59]
  wire [31:0] _outReg_3_T_1 = outReg_3 & _outReg_0_T; // @[Gpio.scala 63:50]
  wire [31:0] _outReg_3_T_3 = _outReg_3_T_1 | _outReg_0_T_2; // @[Gpio.scala 63:59]
  wire [31:0] _outReg_4_T_1 = outReg_4 & _outReg_0_T; // @[Gpio.scala 63:50]
  wire [31:0] _outReg_4_T_3 = _outReg_4_T_1 | _outReg_0_T_2; // @[Gpio.scala 63:59]
  wire [31:0] _outReg_5_T_1 = outReg_5 & _outReg_0_T; // @[Gpio.scala 63:50]
  wire [31:0] _outReg_5_T_3 = _outReg_5_T_1 | _outReg_0_T_2; // @[Gpio.scala 63:59]
  assign io_mem_rdata = 5'h15 == io_mem_addr[6:2] ? inReg_5 : _io_mem_rdata_T_34; // @[Mux.scala 81:58]
  assign io_out_0 = outReg_0; // @[Gpio.scala 59:23]
  assign io_out_1 = outReg_1; // @[Gpio.scala 59:23]
  assign io_out_2 = outReg_2; // @[Gpio.scala 59:23]
  assign io_out_3 = outReg_3; // @[Gpio.scala 59:23]
  assign io_out_4 = outReg_4; // @[Gpio.scala 59:23]
  always @(posedge clock) begin
    if (reset) begin // @[Gpio.scala 45:23]
      outReg_0 <= 32'h0; // @[Gpio.scala 45:23]
    end else if (io_mem_wen) begin // @[Gpio.scala 60:22]
      if (io_mem_addr[7:2] == 6'h0) begin // @[Gpio.scala 61:81]
        outReg_0 <= _outReg_0_T_3; // @[Gpio.scala 63:27]
      end
    end
    if (reset) begin // @[Gpio.scala 45:23]
      outReg_1 <= 32'h0; // @[Gpio.scala 45:23]
    end else if (io_mem_wen) begin // @[Gpio.scala 60:22]
      if (io_mem_addr[7:2] == 6'h4) begin // @[Gpio.scala 61:81]
        outReg_1 <= _outReg_1_T_3; // @[Gpio.scala 63:27]
      end
    end
    if (reset) begin // @[Gpio.scala 45:23]
      outReg_2 <= 32'h0; // @[Gpio.scala 45:23]
    end else if (io_mem_wen) begin // @[Gpio.scala 60:22]
      if (io_mem_addr[7:2] == 6'h8) begin // @[Gpio.scala 61:81]
        outReg_2 <= _outReg_2_T_3; // @[Gpio.scala 63:27]
      end
    end
    if (reset) begin // @[Gpio.scala 45:23]
      outReg_3 <= 32'h0; // @[Gpio.scala 45:23]
    end else if (io_mem_wen) begin // @[Gpio.scala 60:22]
      if (io_mem_addr[7:2] == 6'hc) begin // @[Gpio.scala 61:81]
        outReg_3 <= _outReg_3_T_3; // @[Gpio.scala 63:27]
      end
    end
    if (reset) begin // @[Gpio.scala 45:23]
      outReg_4 <= 32'h0; // @[Gpio.scala 45:23]
    end else if (io_mem_wen) begin // @[Gpio.scala 60:22]
      if (io_mem_addr[7:2] == 6'h10) begin // @[Gpio.scala 61:81]
        outReg_4 <= _outReg_4_T_3; // @[Gpio.scala 63:27]
      end
    end
    if (reset) begin // @[Gpio.scala 45:23]
      outReg_5 <= 32'h0; // @[Gpio.scala 45:23]
    end else if (io_mem_wen) begin // @[Gpio.scala 60:22]
      if (io_mem_addr[7:2] == 6'h14) begin // @[Gpio.scala 61:81]
        outReg_5 <= _outReg_5_T_3; // @[Gpio.scala 63:27]
      end
    end
    if (reset) begin // @[Gpio.scala 46:22]
      inReg_5 <= 32'h0; // @[Gpio.scala 46:22]
    end else begin
      inReg_5 <= io_in_5; // @[Gpio.scala 58:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  outReg_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  outReg_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  outReg_2 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  outReg_3 = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  outReg_4 = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  outReg_5 = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  inReg_5 = _RAND_6[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module IORegister(
  input  [31:0] io_mem_addr,
  output [31:0] io_mem_rdata,
  input         io_mem_ren,
  output        io_mem_rvalid,
  input         io_mem_wen,
  input  [3:0]  io_mem_wstrb,
  input  [31:0] io_mem_wdata,
  output        io_in_0_ready,
  input  [31:0] io_in_0_bits,
  input  [31:0] io_in_1_bits,
  output        io_out_0_valid,
  output [31:0] io_out_0_bits
);
  wire [31:0] _inSignals_T_2 = io_in_0_bits & 32'h100ff; // @[IORegister.scala 21:49]
  wire [32:0] _inSignals_T_3 = {1'h1,_inSignals_T_2}; // @[Cat.scala 33:92]
  wire [31:0] _inSignals_T_4 = io_in_1_bits & 32'h3; // @[IORegister.scala 21:49]
  wire [32:0] _inSignals_T_5 = {1'h1,_inSignals_T_4}; // @[Cat.scala 33:92]
  wire [32:0] inSignals = io_mem_addr[2] ? _inSignals_T_5 : _inSignals_T_3; // @[Mux.scala 81:58]
  wire [7:0] _mask_T_1 = io_mem_wstrb[0] ? 8'hff : 8'h0; // @[IORegister.scala 27:39]
  wire [7:0] _mask_T_3 = io_mem_wstrb[1] ? 8'hff : 8'h0; // @[IORegister.scala 27:39]
  wire [7:0] _mask_T_5 = io_mem_wstrb[2] ? 8'hff : 8'h0; // @[IORegister.scala 27:39]
  wire [7:0] _mask_T_7 = io_mem_wstrb[3] ? 8'hff : 8'h0; // @[IORegister.scala 27:39]
  wire [31:0] mask = {_mask_T_7,_mask_T_5,_mask_T_3,_mask_T_1}; // @[Cat.scala 33:92]
  wire [31:0] _io_out_0_bits_T = io_mem_wdata & mask; // @[IORegister.scala 32:45]
  assign io_mem_rdata = inSignals[31:0]; // @[IORegister.scala 25:28]
  assign io_mem_rvalid = inSignals[32]; // @[IORegister.scala 24:29]
  assign io_in_0_ready = io_mem_addr[3:2] == 2'h0 & io_mem_ren; // @[IORegister.scala 31:28 33:56 35:30]
  assign io_out_0_valid = io_mem_addr[3:2] == 2'h0 & io_mem_wen; // @[IORegister.scala 30:29 33:56 34:31]
  assign io_out_0_bits = _io_out_0_bits_T & 32'hff; // @[IORegister.scala 32:53]
endmodule
module DMemDecoder(
  input  [31:0] io_initiator_addr,
  output [31:0] io_initiator_rdata,
  input         io_initiator_ren,
  output        io_initiator_rvalid,
  input         io_initiator_wen,
  input  [3:0]  io_initiator_wstrb,
  input  [31:0] io_initiator_wdata,
  output [31:0] io_targets_0_addr,
  input  [31:0] io_targets_0_rdata,
  output        io_targets_0_ren,
  input         io_targets_0_rvalid,
  output        io_targets_0_wen,
  output [3:0]  io_targets_0_wstrb,
  output [31:0] io_targets_0_wdata,
  output [31:0] io_targets_1_addr,
  input  [31:0] io_targets_1_rdata,
  output        io_targets_1_wen,
  output [3:0]  io_targets_1_wstrb,
  output [31:0] io_targets_1_wdata,
  output [31:0] io_targets_2_addr,
  input  [31:0] io_targets_2_rdata,
  output        io_targets_2_ren,
  input         io_targets_2_rvalid,
  output        io_targets_2_wen,
  output [3:0]  io_targets_2_wstrb,
  output [31:0] io_targets_2_wdata
);
  wire [31:0] _addr_T_1 = io_initiator_addr - 32'h0; // @[Decoder.scala 37:33]
  wire  _GEN_2 = io_initiator_addr < 32'h2000 ? io_targets_0_rvalid : 1'h1; // @[Decoder.scala 36:83 39:14]
  wire [31:0] _GEN_3 = io_initiator_addr < 32'h2000 ? io_targets_0_rdata : 32'hdeadbeef; // @[Decoder.scala 36:83 40:13]
  wire [31:0] _addr_T_3 = io_initiator_addr - 32'ha0000000; // @[Decoder.scala 37:33]
  wire [31:0] _GEN_10 = 32'ha0000000 <= io_initiator_addr & io_initiator_addr < 32'ha0000060 ? io_targets_1_rdata :
    _GEN_3; // @[Decoder.scala 36:83 40:13]
  wire [31:0] _addr_T_5 = io_initiator_addr - 32'ha0001000; // @[Decoder.scala 37:33]
  assign io_initiator_rdata = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 ? io_targets_2_rdata
     : _GEN_10; // @[Decoder.scala 36:83 40:13]
  assign io_initiator_rvalid = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 ?
    io_targets_2_rvalid : 32'ha0000000 <= io_initiator_addr & io_initiator_addr < 32'ha0000060 | _GEN_2; // @[Decoder.scala 36:83 39:14]
  assign io_targets_0_addr = io_initiator_addr < 32'h2000 ? _addr_T_1 : 32'h0; // @[Decoder.scala 36:83 37:12]
  assign io_targets_0_ren = io_initiator_addr < 32'h2000 & io_initiator_ren; // @[Decoder.scala 36:83 38:11]
  assign io_targets_0_wen = io_initiator_addr < 32'h2000 & io_initiator_wen; // @[Decoder.scala 36:83 41:11]
  assign io_targets_0_wstrb = io_initiator_addr < 32'h2000 ? io_initiator_wstrb : 4'hf; // @[Decoder.scala 36:83 43:13]
  assign io_targets_0_wdata = io_initiator_addr < 32'h2000 ? io_initiator_wdata : 32'hdeadbeef; // @[Decoder.scala 36:83 42:13]
  assign io_targets_1_addr = 32'ha0000000 <= io_initiator_addr & io_initiator_addr < 32'ha0000060 ? _addr_T_3 : 32'h0; // @[Decoder.scala 36:83 37:12]
  assign io_targets_1_wen = 32'ha0000000 <= io_initiator_addr & io_initiator_addr < 32'ha0000060 & io_initiator_wen; // @[Decoder.scala 36:83 41:11]
  assign io_targets_1_wstrb = 32'ha0000000 <= io_initiator_addr & io_initiator_addr < 32'ha0000060 ? io_initiator_wstrb
     : 4'hf; // @[Decoder.scala 36:83 43:13]
  assign io_targets_1_wdata = 32'ha0000000 <= io_initiator_addr & io_initiator_addr < 32'ha0000060 ? io_initiator_wdata
     : 32'hdeadbeef; // @[Decoder.scala 36:83 42:13]
  assign io_targets_2_addr = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 ? _addr_T_5 : 32'h0; // @[Decoder.scala 36:83 37:12]
  assign io_targets_2_ren = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 & io_initiator_ren; // @[Decoder.scala 36:83 38:11]
  assign io_targets_2_wen = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 & io_initiator_wen; // @[Decoder.scala 36:83 41:11]
  assign io_targets_2_wstrb = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 ? io_initiator_wstrb
     : 4'hf; // @[Decoder.scala 36:83 43:13]
  assign io_targets_2_wdata = 32'ha0001000 <= io_initiator_addr & io_initiator_addr < 32'ha0001008 ? io_initiator_wdata
     : 32'hdeadbeef; // @[Decoder.scala 36:83 42:13]
endmodule
module SegmentLedWithShiftRegs(
  input        clock,
  input        reset,
  output       io_segmentOut_outputEnable,
  output       io_segmentOut_shiftClock,
  output       io_segmentOut_latch,
  output       io_segmentOut_data,
  output       io_digitSelector_outputEnable,
  output       io_digitSelector_shiftClock,
  output       io_digitSelector_latch,
  output       io_digitSelector_data,
  input  [7:0] io_digits_0,
  input  [7:0] io_digits_1,
  input  [7:0] io_digits_2,
  input  [7:0] io_digits_3,
  input  [7:0] io_digits_4,
  input  [7:0] io_digits_5
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
`endif // RANDOMIZE_REG_INIT
  reg [11:0] segmentUpdateCounter; // @[multi_segment_led.scala 32:39]
  reg [2:0] state; // @[multi_segment_led.scala 40:24]
  reg [2:0] digitIndex; // @[multi_segment_led.scala 41:29]
  reg [2:0] segmentCounter; // @[multi_segment_led.scala 42:33]
  reg [1:0] shiftClockCounter; // @[multi_segment_led.scala 43:36]
  reg [7:0] segmentShiftReg; // @[multi_segment_led.scala 44:34]
  reg  segmentOutputEnable; // @[multi_segment_led.scala 46:38]
  reg  segmentShiftClock; // @[multi_segment_led.scala 47:36]
  reg  segmentLatch; // @[multi_segment_led.scala 48:31]
  reg  segmentData; // @[multi_segment_led.scala 49:30]
  reg  digitOutputEnable; // @[multi_segment_led.scala 50:36]
  reg  digitShiftClock; // @[multi_segment_led.scala 51:34]
  reg  digitLatch; // @[multi_segment_led.scala 52:29]
  reg  digitData; // @[multi_segment_led.scala 53:28]
  wire [7:0] _GEN_1 = 3'h1 == digitIndex ? io_digits_1 : io_digits_0; // @[multi_segment_led.scala 84:{29,29}]
  wire [7:0] _GEN_2 = 3'h2 == digitIndex ? io_digits_2 : _GEN_1; // @[multi_segment_led.scala 84:{29,29}]
  wire [7:0] _GEN_3 = 3'h3 == digitIndex ? io_digits_3 : _GEN_2; // @[multi_segment_led.scala 84:{29,29}]
  wire [7:0] _GEN_4 = 3'h4 == digitIndex ? io_digits_4 : _GEN_3; // @[multi_segment_led.scala 84:{29,29}]
  wire [2:0] _digitIndex_T_2 = digitIndex + 3'h1; // @[multi_segment_led.scala 89:86]
  wire  _T_9 = shiftClockCounter == 2'h0; // @[multi_segment_led.scala 92:37]
  wire [2:0] _GEN_6 = digitShiftClock ? 3'h3 : state; // @[multi_segment_led.scala 40:24 95:41 96:27]
  wire [1:0] _shiftClockCounter_T_1 = shiftClockCounter - 2'h1; // @[multi_segment_led.scala 99:56]
  wire  _GEN_7 = shiftClockCounter == 2'h0 ? ~digitShiftClock : digitShiftClock; // @[multi_segment_led.scala 92:47 93:33 51:34]
  wire [1:0] _GEN_8 = shiftClockCounter == 2'h0 ? 2'h2 : _shiftClockCounter_T_1; // @[multi_segment_led.scala 92:47 94:35 99:35]
  wire [2:0] _GEN_9 = shiftClockCounter == 2'h0 ? _GEN_6 : state; // @[multi_segment_led.scala 40:24 92:47]
  wire [7:0] _segmentShiftReg_T_1 = {segmentShiftReg[6:0],1'h0}; // @[Cat.scala 33:92]
  wire [2:0] _segmentCounter_T_1 = segmentCounter - 3'h1; // @[multi_segment_led.scala 117:58]
  wire [2:0] _GEN_10 = segmentCounter == 3'h0 ? 3'h5 : 3'h3; // @[multi_segment_led.scala 114:52 115:31 118:31]
  wire [2:0] _GEN_11 = segmentCounter == 3'h0 ? segmentCounter : _segmentCounter_T_1; // @[multi_segment_led.scala 114:52 42:33 117:40]
  wire [2:0] _GEN_12 = segmentShiftClock ? _GEN_10 : state; // @[multi_segment_led.scala 113:43 40:24]
  wire [2:0] _GEN_13 = segmentShiftClock ? _GEN_11 : segmentCounter; // @[multi_segment_led.scala 113:43 42:33]
  wire  _GEN_14 = _T_9 ? ~segmentShiftClock : segmentShiftClock; // @[multi_segment_led.scala 110:47 111:35 47:36]
  wire [2:0] _GEN_16 = _T_9 ? _GEN_12 : state; // @[multi_segment_led.scala 110:47 40:24]
  wire [2:0] _GEN_17 = _T_9 ? _GEN_13 : segmentCounter; // @[multi_segment_led.scala 110:47 42:33]
  wire [11:0] _segmentUpdateCounter_T_1 = segmentUpdateCounter - 12'h1; // @[multi_segment_led.scala 139:62]
  wire [2:0] _GEN_18 = segmentUpdateCounter == 12'h0 ? 3'h1 : state; // @[multi_segment_led.scala 136:51 137:23 40:24]
  wire [11:0] _GEN_19 = segmentUpdateCounter == 12'h0 ? segmentUpdateCounter : _segmentUpdateCounter_T_1; // @[multi_segment_led.scala 136:51 139:38 32:39]
  wire [2:0] _GEN_20 = 3'h6 == state ? _GEN_18 : state; // @[multi_segment_led.scala 64:19 40:24]
  wire [11:0] _GEN_21 = 3'h6 == state ? _GEN_19 : segmentUpdateCounter; // @[multi_segment_led.scala 64:19 32:39]
  wire  _GEN_22 = 3'h5 == state | digitLatch; // @[multi_segment_led.scala 64:19 127:24 52:29]
  wire  _GEN_23 = 3'h5 == state | segmentLatch; // @[multi_segment_led.scala 64:19 128:26 48:31]
  wire  _GEN_24 = 3'h5 == state ? 1'h0 : digitOutputEnable; // @[multi_segment_led.scala 64:19 129:31 50:36]
  wire  _GEN_25 = 3'h5 == state ? 1'h0 : segmentOutputEnable; // @[multi_segment_led.scala 64:19 130:33 46:38]
  wire [11:0] _GEN_26 = 3'h5 == state ? 12'ha8c : _GEN_21; // @[multi_segment_led.scala 64:19 131:34]
  wire [2:0] _GEN_27 = 3'h5 == state ? 3'h6 : _GEN_20; // @[multi_segment_led.scala 132:19 64:19]
  wire  _GEN_28 = 3'h4 == state ? _GEN_14 : segmentShiftClock; // @[multi_segment_led.scala 64:19 47:36]
  wire [1:0] _GEN_29 = 3'h4 == state ? _GEN_8 : shiftClockCounter; // @[multi_segment_led.scala 64:19 43:36]
  wire [2:0] _GEN_30 = 3'h4 == state ? _GEN_16 : _GEN_27; // @[multi_segment_led.scala 64:19]
  wire [2:0] _GEN_31 = 3'h4 == state ? _GEN_17 : segmentCounter; // @[multi_segment_led.scala 64:19 42:33]
  wire  _GEN_32 = 3'h4 == state ? digitLatch : _GEN_22; // @[multi_segment_led.scala 64:19 52:29]
  wire  _GEN_33 = 3'h4 == state ? segmentLatch : _GEN_23; // @[multi_segment_led.scala 64:19 48:31]
  wire  _GEN_34 = 3'h4 == state ? digitOutputEnable : _GEN_24; // @[multi_segment_led.scala 64:19 50:36]
  wire  _GEN_35 = 3'h4 == state ? segmentOutputEnable : _GEN_25; // @[multi_segment_led.scala 64:19 46:38]
  wire [11:0] _GEN_36 = 3'h4 == state ? segmentUpdateCounter : _GEN_26; // @[multi_segment_led.scala 64:19 32:39]
  wire  _GEN_37 = 3'h3 == state ? segmentShiftReg[7] : segmentData; // @[multi_segment_led.scala 64:19 103:25 49:30]
  wire [7:0] _GEN_38 = 3'h3 == state ? _segmentShiftReg_T_1 : segmentShiftReg; // @[multi_segment_led.scala 64:19 104:29 44:34]
  wire  _GEN_39 = 3'h3 == state ? 1'h0 : _GEN_28; // @[multi_segment_led.scala 64:19 105:31]
  wire [1:0] _GEN_40 = 3'h3 == state ? 2'h2 : _GEN_29; // @[multi_segment_led.scala 64:19 106:31]
  wire [2:0] _GEN_41 = 3'h3 == state ? 3'h4 : _GEN_30; // @[multi_segment_led.scala 107:19 64:19]
  wire [2:0] _GEN_42 = 3'h3 == state ? segmentCounter : _GEN_31; // @[multi_segment_led.scala 64:19 42:33]
  wire  _GEN_43 = 3'h3 == state ? digitLatch : _GEN_32; // @[multi_segment_led.scala 64:19 52:29]
  wire  _GEN_44 = 3'h3 == state ? segmentLatch : _GEN_33; // @[multi_segment_led.scala 64:19 48:31]
  wire  _GEN_45 = 3'h3 == state ? digitOutputEnable : _GEN_34; // @[multi_segment_led.scala 64:19 50:36]
  wire  _GEN_46 = 3'h3 == state ? segmentOutputEnable : _GEN_35; // @[multi_segment_led.scala 64:19 46:38]
  wire [11:0] _GEN_47 = 3'h3 == state ? segmentUpdateCounter : _GEN_36; // @[multi_segment_led.scala 64:19 32:39]
  wire  _GEN_57 = 3'h2 == state ? digitOutputEnable : _GEN_45; // @[multi_segment_led.scala 64:19 50:36]
  wire  _GEN_58 = 3'h2 == state ? segmentOutputEnable : _GEN_46; // @[multi_segment_led.scala 64:19 46:38]
  wire  _GEN_71 = 3'h1 == state ? digitOutputEnable : _GEN_57; // @[multi_segment_led.scala 64:19 50:36]
  wire  _GEN_72 = 3'h1 == state ? segmentOutputEnable : _GEN_58; // @[multi_segment_led.scala 64:19 46:38]
  wire  _GEN_79 = 3'h0 == state | _GEN_71; // @[multi_segment_led.scala 64:19 71:31]
  wire  _GEN_80 = 3'h0 == state | _GEN_72; // @[multi_segment_led.scala 64:19 72:33]
  assign io_segmentOut_outputEnable = segmentOutputEnable; // @[multi_segment_led.scala 55:32]
  assign io_segmentOut_shiftClock = segmentShiftClock; // @[multi_segment_led.scala 56:30]
  assign io_segmentOut_latch = segmentLatch; // @[multi_segment_led.scala 57:25]
  assign io_segmentOut_data = segmentData; // @[multi_segment_led.scala 58:24]
  assign io_digitSelector_outputEnable = digitOutputEnable; // @[multi_segment_led.scala 59:35]
  assign io_digitSelector_shiftClock = digitShiftClock; // @[multi_segment_led.scala 60:33]
  assign io_digitSelector_latch = digitLatch; // @[multi_segment_led.scala 61:28]
  assign io_digitSelector_data = digitData; // @[multi_segment_led.scala 62:27]
  always @(posedge clock) begin
    if (reset) begin // @[multi_segment_led.scala 32:39]
      segmentUpdateCounter <= 12'h0; // @[multi_segment_led.scala 32:39]
    end else if (!(3'h0 == state)) begin // @[multi_segment_led.scala 64:19]
      if (!(3'h1 == state)) begin // @[multi_segment_led.scala 64:19]
        if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
          segmentUpdateCounter <= _GEN_47;
        end
      end
    end
    if (reset) begin // @[multi_segment_led.scala 40:24]
      state <= 3'h0; // @[multi_segment_led.scala 40:24]
    end else if (3'h0 == state) begin // @[multi_segment_led.scala 64:19]
      state <= 3'h1; // @[multi_segment_led.scala 73:19]
    end else if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
      state <= 3'h2; // @[multi_segment_led.scala 86:19]
    end else if (3'h2 == state) begin // @[multi_segment_led.scala 64:19]
      state <= _GEN_9;
    end else begin
      state <= _GEN_41;
    end
    if (reset) begin // @[multi_segment_led.scala 41:29]
      digitIndex <= 3'h0; // @[multi_segment_led.scala 41:29]
    end else if (3'h0 == state) begin // @[multi_segment_led.scala 64:19]
      digitIndex <= 3'h0; // @[multi_segment_led.scala 66:24]
    end else if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
      if (digitIndex == 3'h5) begin // @[multi_segment_led.scala 89:30]
        digitIndex <= 3'h0;
      end else begin
        digitIndex <= _digitIndex_T_2;
      end
    end
    if (reset) begin // @[multi_segment_led.scala 42:33]
      segmentCounter <= 3'h0; // @[multi_segment_led.scala 42:33]
    end else if (3'h0 == state) begin // @[multi_segment_led.scala 64:19]
      segmentCounter <= 3'h0; // @[multi_segment_led.scala 67:28]
    end else if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
      segmentCounter <= 3'h7; // @[multi_segment_led.scala 85:28]
    end else if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
      segmentCounter <= _GEN_42;
    end
    if (reset) begin // @[multi_segment_led.scala 43:36]
      shiftClockCounter <= 2'h0; // @[multi_segment_led.scala 43:36]
    end else if (3'h0 == state) begin // @[multi_segment_led.scala 64:19]
      shiftClockCounter <= 2'h0; // @[multi_segment_led.scala 68:31]
    end else if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
      shiftClockCounter <= 2'h2; // @[multi_segment_led.scala 83:31]
    end else if (3'h2 == state) begin // @[multi_segment_led.scala 64:19]
      shiftClockCounter <= _GEN_8;
    end else begin
      shiftClockCounter <= _GEN_40;
    end
    if (reset) begin // @[multi_segment_led.scala 44:34]
      segmentShiftReg <= 8'h0; // @[multi_segment_led.scala 44:34]
    end else if (!(3'h0 == state)) begin // @[multi_segment_led.scala 64:19]
      if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
        if (3'h5 == digitIndex) begin // @[multi_segment_led.scala 84:29]
          segmentShiftReg <= io_digits_5; // @[multi_segment_led.scala 84:29]
        end else begin
          segmentShiftReg <= _GEN_4;
        end
      end else if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
        segmentShiftReg <= _GEN_38;
      end
    end
    segmentOutputEnable <= reset | _GEN_80; // @[multi_segment_led.scala 46:{38,38}]
    if (reset) begin // @[multi_segment_led.scala 47:36]
      segmentShiftClock <= 1'h0; // @[multi_segment_led.scala 47:36]
    end else if (!(3'h0 == state)) begin // @[multi_segment_led.scala 64:19]
      if (!(3'h1 == state)) begin // @[multi_segment_led.scala 64:19]
        if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
          segmentShiftClock <= _GEN_39;
        end
      end
    end
    if (reset) begin // @[multi_segment_led.scala 48:31]
      segmentLatch <= 1'h0; // @[multi_segment_led.scala 48:31]
    end else if (3'h0 == state) begin // @[multi_segment_led.scala 64:19]
      segmentLatch <= 1'h0; // @[multi_segment_led.scala 69:26]
    end else if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
      segmentLatch <= 1'h0; // @[multi_segment_led.scala 78:26]
    end else if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
      segmentLatch <= _GEN_44;
    end
    if (reset) begin // @[multi_segment_led.scala 49:30]
      segmentData <= 1'h0; // @[multi_segment_led.scala 49:30]
    end else if (!(3'h0 == state)) begin // @[multi_segment_led.scala 64:19]
      if (!(3'h1 == state)) begin // @[multi_segment_led.scala 64:19]
        if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
          segmentData <= _GEN_37;
        end
      end
    end
    digitOutputEnable <= reset | _GEN_79; // @[multi_segment_led.scala 50:{36,36}]
    if (reset) begin // @[multi_segment_led.scala 51:34]
      digitShiftClock <= 1'h0; // @[multi_segment_led.scala 51:34]
    end else if (!(3'h0 == state)) begin // @[multi_segment_led.scala 64:19]
      if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
        digitShiftClock <= 1'h0; // @[multi_segment_led.scala 82:29]
      end else if (3'h2 == state) begin // @[multi_segment_led.scala 64:19]
        digitShiftClock <= _GEN_7;
      end
    end
    if (reset) begin // @[multi_segment_led.scala 52:29]
      digitLatch <= 1'h0; // @[multi_segment_led.scala 52:29]
    end else if (3'h0 == state) begin // @[multi_segment_led.scala 64:19]
      digitLatch <= 1'h0; // @[multi_segment_led.scala 70:24]
    end else if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
      digitLatch <= 1'h0; // @[multi_segment_led.scala 77:24]
    end else if (!(3'h2 == state)) begin // @[multi_segment_led.scala 64:19]
      digitLatch <= _GEN_43;
    end
    if (reset) begin // @[multi_segment_led.scala 53:28]
      digitData <= 1'h0; // @[multi_segment_led.scala 53:28]
    end else if (!(3'h0 == state)) begin // @[multi_segment_led.scala 64:19]
      if (3'h1 == state) begin // @[multi_segment_led.scala 64:19]
        if (digitIndex == 3'h0) begin // @[multi_segment_led.scala 81:29]
          digitData <= 1'h0;
        end else begin
          digitData <= 1'h1;
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  segmentUpdateCounter = _RAND_0[11:0];
  _RAND_1 = {1{`RANDOM}};
  state = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  digitIndex = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  segmentCounter = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  shiftClockCounter = _RAND_4[1:0];
  _RAND_5 = {1{`RANDOM}};
  segmentShiftReg = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  segmentOutputEnable = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  segmentShiftClock = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  segmentLatch = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  segmentData = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  digitOutputEnable = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  digitShiftClock = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  digitLatch = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  digitData = _RAND_13[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module MatrixLed(
  input        clock,
  input        reset,
  output [7:0] io_row,
  output [7:0] io_column,
  input  [7:0] io_matrix_0,
  input  [7:0] io_matrix_1,
  input  [7:0] io_matrix_2,
  input  [7:0] io_matrix_3,
  input  [7:0] io_matrix_4,
  input  [7:0] io_matrix_5,
  input  [7:0] io_matrix_6,
  input  [7:0] io_matrix_7
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [11:0] refreshCounter; // @[matrix_led.scala 21:33]
  reg [7:0] rowReg; // @[matrix_led.scala 22:25]
  wire  _GEN_1 = refreshCounter < 12'ha8b ? 1'h0 : 1'h1; // @[matrix_led.scala 33:68 34:17]
  wire  _GEN_3 = refreshCounter == 12'ha81 ? 1'h0 : _GEN_1; // @[matrix_led.scala 30:100 31:17]
  wire  rowEnable = refreshCounter < 12'ha77 | _GEN_3; // @[matrix_led.scala 29:93]
  wire  _io_column_T_1 = rowReg == 8'h1; // @[matrix_led.scala 26:72]
  wire  _io_column_T_3 = rowReg == 8'h2; // @[matrix_led.scala 26:72]
  wire  _io_column_T_5 = rowReg == 8'h4; // @[matrix_led.scala 26:72]
  wire  _io_column_T_7 = rowReg == 8'h8; // @[matrix_led.scala 26:72]
  wire  _io_column_T_9 = rowReg == 8'h10; // @[matrix_led.scala 26:72]
  wire  _io_column_T_11 = rowReg == 8'h20; // @[matrix_led.scala 26:72]
  wire  _io_column_T_13 = rowReg == 8'h40; // @[matrix_led.scala 26:72]
  wire  _io_column_T_15 = rowReg == 8'h80; // @[matrix_led.scala 26:72]
  wire [7:0] _io_column_T_16 = _io_column_T_15 ? io_matrix_7 : 8'h0; // @[Mux.scala 101:16]
  wire [7:0] _io_column_T_17 = _io_column_T_13 ? io_matrix_6 : _io_column_T_16; // @[Mux.scala 101:16]
  wire [7:0] _io_column_T_18 = _io_column_T_11 ? io_matrix_5 : _io_column_T_17; // @[Mux.scala 101:16]
  wire [7:0] _io_column_T_19 = _io_column_T_9 ? io_matrix_4 : _io_column_T_18; // @[Mux.scala 101:16]
  wire [7:0] _io_column_T_20 = _io_column_T_7 ? io_matrix_3 : _io_column_T_19; // @[Mux.scala 101:16]
  wire [7:0] _io_column_T_21 = _io_column_T_5 ? io_matrix_2 : _io_column_T_20; // @[Mux.scala 101:16]
  wire [7:0] _io_column_T_22 = _io_column_T_3 ? io_matrix_1 : _io_column_T_21; // @[Mux.scala 101:16]
  wire [11:0] _refreshCounter_T_1 = refreshCounter + 12'h1; // @[matrix_led.scala 28:38]
  wire [8:0] _rowReg_T = {rowReg, 1'h0}; // @[matrix_led.scala 32:25]
  wire [8:0] _GEN_9 = {{8'd0}, rowReg[7]}; // @[matrix_led.scala 32:31]
  wire [8:0] _rowReg_T_2 = _rowReg_T | _GEN_9; // @[matrix_led.scala 32:31]
  wire [11:0] _GEN_0 = refreshCounter == 12'ha8b ? 12'h0 : _refreshCounter_T_1; // @[matrix_led.scala 28:20 35:70 36:22]
  wire [8:0] _GEN_4 = refreshCounter == 12'ha81 ? _rowReg_T_2 : {{1'd0}, rowReg}; // @[matrix_led.scala 30:100 32:14 22:25]
  wire [8:0] _GEN_7 = refreshCounter < 12'ha77 ? {{1'd0}, rowReg} : _GEN_4; // @[matrix_led.scala 22:25 29:93]
  wire [8:0] _GEN_10 = reset ? 9'h1 : _GEN_7; // @[matrix_led.scala 22:{25,25}]
  assign io_row = rowEnable ? rowReg : 8'h0; // @[matrix_led.scala 25:18]
  assign io_column = _io_column_T_1 ? io_matrix_0 : _io_column_T_22; // @[Mux.scala 101:16]
  always @(posedge clock) begin
    if (reset) begin // @[matrix_led.scala 21:33]
      refreshCounter <= 12'h0; // @[matrix_led.scala 21:33]
    end else if (refreshCounter < 12'ha77) begin // @[matrix_led.scala 29:93]
      refreshCounter <= _refreshCounter_T_1; // @[matrix_led.scala 28:20]
    end else if (refreshCounter == 12'ha81) begin // @[matrix_led.scala 30:100]
      refreshCounter <= _refreshCounter_T_1; // @[matrix_led.scala 28:20]
    end else if (refreshCounter < 12'ha8b) begin // @[matrix_led.scala 33:68]
      refreshCounter <= _refreshCounter_T_1; // @[matrix_led.scala 28:20]
    end else begin
      refreshCounter <= _GEN_0;
    end
    rowReg <= _GEN_10[7:0]; // @[matrix_led.scala 22:{25,25}]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  refreshCounter = _RAND_0[11:0];
  _RAND_1 = {1{`RANDOM}};
  rowReg = _RAND_1[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module UartTx(
  input        clock,
  input        reset,
  output       io_in_ready,
  input        io_in_valid,
  input  [7:0] io_in_bits,
  output       io_tx
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] rateCounter; // @[UartTx.scala 18:30]
  reg [3:0] bitCounter; // @[UartTx.scala 19:29]
  reg  bits_0; // @[UartTx.scala 20:19]
  reg  bits_1; // @[UartTx.scala 20:19]
  reg  bits_2; // @[UartTx.scala 20:19]
  reg  bits_3; // @[UartTx.scala 20:19]
  reg  bits_4; // @[UartTx.scala 20:19]
  reg  bits_5; // @[UartTx.scala 20:19]
  reg  bits_6; // @[UartTx.scala 20:19]
  reg  bits_7; // @[UartTx.scala 20:19]
  reg  bits_8; // @[UartTx.scala 20:19]
  reg  bits_9; // @[UartTx.scala 20:19]
  wire [9:0] _T_1 = {1'h1,io_in_bits,1'h0}; // @[Cat.scala 33:92]
  wire  _GEN_0 = io_in_valid & io_in_ready ? _T_1[0] : bits_0; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_1 = io_in_valid & io_in_ready ? _T_1[1] : bits_1; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_2 = io_in_valid & io_in_ready ? _T_1[2] : bits_2; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_3 = io_in_valid & io_in_ready ? _T_1[3] : bits_3; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_4 = io_in_valid & io_in_ready ? _T_1[4] : bits_4; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_5 = io_in_valid & io_in_ready ? _T_1[5] : bits_5; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_6 = io_in_valid & io_in_ready ? _T_1[6] : bits_6; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_7 = io_in_valid & io_in_ready ? _T_1[7] : bits_7; // @[UartTx.scala 25:38 26:14 20:19]
  wire  _GEN_8 = io_in_valid & io_in_ready ? _T_1[8] : bits_8; // @[UartTx.scala 25:38 26:14 20:19]
  wire [3:0] _GEN_10 = io_in_valid & io_in_ready ? 4'ha : bitCounter; // @[UartTx.scala 25:38 27:20 19:29]
  wire [3:0] _bitCounter_T_1 = bitCounter - 4'h1; // @[UartTx.scala 35:38]
  wire [7:0] _rateCounter_T_1 = rateCounter - 8'h1; // @[UartTx.scala 38:40]
  assign io_in_ready = bitCounter == 4'h0; // @[UartTx.scala 23:31]
  assign io_tx = bitCounter == 4'h0 | bits_0; // @[UartTx.scala 22:33]
  always @(posedge clock) begin
    if (reset) begin // @[UartTx.scala 18:30]
      rateCounter <= 8'h0; // @[UartTx.scala 18:30]
    end else if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        rateCounter <= 8'he9; // @[UartTx.scala 36:25]
      end else begin
        rateCounter <= _rateCounter_T_1; // @[UartTx.scala 38:25]
      end
    end else if (io_in_valid & io_in_ready) begin // @[UartTx.scala 25:38]
      rateCounter <= 8'he9; // @[UartTx.scala 28:21]
    end
    if (reset) begin // @[UartTx.scala 19:29]
      bitCounter <= 4'h0; // @[UartTx.scala 19:29]
    end else if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bitCounter <= _bitCounter_T_1; // @[UartTx.scala 35:24]
      end else begin
        bitCounter <= _GEN_10;
      end
    end else begin
      bitCounter <= _GEN_10;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_0 <= bits_1; // @[UartTx.scala 34:54]
      end else begin
        bits_0 <= _GEN_0;
      end
    end else begin
      bits_0 <= _GEN_0;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_1 <= bits_2; // @[UartTx.scala 34:54]
      end else begin
        bits_1 <= _GEN_1;
      end
    end else begin
      bits_1 <= _GEN_1;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_2 <= bits_3; // @[UartTx.scala 34:54]
      end else begin
        bits_2 <= _GEN_2;
      end
    end else begin
      bits_2 <= _GEN_2;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_3 <= bits_4; // @[UartTx.scala 34:54]
      end else begin
        bits_3 <= _GEN_3;
      end
    end else begin
      bits_3 <= _GEN_3;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_4 <= bits_5; // @[UartTx.scala 34:54]
      end else begin
        bits_4 <= _GEN_4;
      end
    end else begin
      bits_4 <= _GEN_4;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_5 <= bits_6; // @[UartTx.scala 34:54]
      end else begin
        bits_5 <= _GEN_5;
      end
    end else begin
      bits_5 <= _GEN_5;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_6 <= bits_7; // @[UartTx.scala 34:54]
      end else begin
        bits_6 <= _GEN_6;
      end
    end else begin
      bits_6 <= _GEN_6;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_7 <= bits_8; // @[UartTx.scala 34:54]
      end else begin
        bits_7 <= _GEN_7;
      end
    end else begin
      bits_7 <= _GEN_7;
    end
    if (bitCounter > 4'h0) begin // @[UartTx.scala 31:30]
      if (rateCounter == 8'h0) begin // @[UartTx.scala 32:35]
        bits_8 <= bits_9; // @[UartTx.scala 34:54]
      end else begin
        bits_8 <= _GEN_8;
      end
    end else begin
      bits_8 <= _GEN_8;
    end
    if (io_in_valid & io_in_ready) begin // @[UartTx.scala 25:38]
      bits_9 <= _T_1[9]; // @[UartTx.scala 26:14]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  rateCounter = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  bitCounter = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  bits_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  bits_1 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  bits_2 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  bits_3 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  bits_4 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  bits_5 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  bits_6 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  bits_7 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  bits_8 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  bits_9 = _RAND_11[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module UartRx(
  input        clock,
  input        reset,
  input        io_out_ready,
  output       io_out_valid,
  output [7:0] io_out_bits,
  input        io_rx
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
`endif // RANDOMIZE_REG_INIT
  reg [8:0] rateCounter; // @[UartRx.scala 19:30]
  reg [2:0] bitCounter; // @[UartRx.scala 20:29]
  reg  bits_1; // @[UartRx.scala 21:19]
  reg  bits_2; // @[UartRx.scala 21:19]
  reg  bits_3; // @[UartRx.scala 21:19]
  reg  bits_4; // @[UartRx.scala 21:19]
  reg  bits_5; // @[UartRx.scala 21:19]
  reg  bits_6; // @[UartRx.scala 21:19]
  reg  bits_7; // @[UartRx.scala 21:19]
  reg  rxRegs_0; // @[UartRx.scala 22:25]
  reg  rxRegs_1; // @[UartRx.scala 22:25]
  reg  rxRegs_2; // @[UartRx.scala 22:25]
  reg  running; // @[UartRx.scala 24:26]
  reg  outValid; // @[UartRx.scala 26:27]
  reg [7:0] outBits; // @[UartRx.scala 27:22]
  wire  _GEN_0 = outValid & io_out_ready ? 1'h0 : outValid; // @[UartRx.scala 32:32 33:18 26:27]
  wire  _GEN_3 = ~rxRegs_1 & rxRegs_0 | running; // @[UartRx.scala 43:39 46:21 24:26]
  wire [7:0] _outBits_T_1 = {rxRegs_0,bits_7,bits_6,bits_5,bits_4,bits_3,bits_2,bits_1}; // @[Cat.scala 33:92]
  wire [2:0] _bitCounter_T_1 = bitCounter - 3'h1; // @[UartRx.scala 59:42]
  wire  _GEN_4 = bitCounter == 3'h0 | _GEN_0; // @[UartRx.scala 52:38 53:26]
  wire [8:0] _rateCounter_T_1 = rateCounter - 9'h1; // @[UartRx.scala 62:40]
  assign io_out_valid = outValid; // @[UartRx.scala 29:18]
  assign io_out_bits = outBits; // @[UartRx.scala 30:17]
  always @(posedge clock) begin
    if (reset) begin // @[UartRx.scala 19:30]
      rateCounter <= 9'h0; // @[UartRx.scala 19:30]
    end else if (~running) begin // @[UartRx.scala 42:20]
      if (~rxRegs_1 & rxRegs_0) begin // @[UartRx.scala 43:39]
        rateCounter <= 9'h15e; // @[UartRx.scala 44:25]
      end
    end else if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
      if (!(bitCounter == 3'h0)) begin // @[UartRx.scala 52:38]
        rateCounter <= 9'he9; // @[UartRx.scala 58:29]
      end
    end else begin
      rateCounter <= _rateCounter_T_1; // @[UartRx.scala 62:25]
    end
    if (reset) begin // @[UartRx.scala 20:29]
      bitCounter <= 3'h0; // @[UartRx.scala 20:29]
    end else if (~running) begin // @[UartRx.scala 42:20]
      if (~rxRegs_1 & rxRegs_0) begin // @[UartRx.scala 43:39]
        bitCounter <= 3'h7; // @[UartRx.scala 45:24]
      end
    end else if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
      if (!(bitCounter == 3'h0)) begin // @[UartRx.scala 52:38]
        bitCounter <= _bitCounter_T_1; // @[UartRx.scala 59:28]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_1 <= bits_2; // @[UartRx.scala 51:58]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_2 <= bits_3; // @[UartRx.scala 51:58]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_3 <= bits_4; // @[UartRx.scala 51:58]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_4 <= bits_5; // @[UartRx.scala 51:58]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_5 <= bits_6; // @[UartRx.scala 51:58]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_6 <= bits_7; // @[UartRx.scala 51:58]
      end
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        bits_7 <= rxRegs_0; // @[UartRx.scala 50:34]
      end
    end
    if (reset) begin // @[UartRx.scala 22:25]
      rxRegs_0 <= 1'h0; // @[UartRx.scala 22:25]
    end else begin
      rxRegs_0 <= rxRegs_1; // @[UartRx.scala 38:52]
    end
    if (reset) begin // @[UartRx.scala 22:25]
      rxRegs_1 <= 1'h0; // @[UartRx.scala 22:25]
    end else begin
      rxRegs_1 <= rxRegs_2; // @[UartRx.scala 38:52]
    end
    if (reset) begin // @[UartRx.scala 22:25]
      rxRegs_2 <= 1'h0; // @[UartRx.scala 22:25]
    end else begin
      rxRegs_2 <= io_rx; // @[UartRx.scala 37:26]
    end
    if (reset) begin // @[UartRx.scala 24:26]
      running <= 1'h0; // @[UartRx.scala 24:26]
    end else if (~running) begin // @[UartRx.scala 42:20]
      running <= _GEN_3;
    end else if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
      if (bitCounter == 3'h0) begin // @[UartRx.scala 52:38]
        running <= 1'h0; // @[UartRx.scala 56:25]
      end
    end
    if (reset) begin // @[UartRx.scala 26:27]
      outValid <= 1'h0; // @[UartRx.scala 26:27]
    end else if (~running) begin // @[UartRx.scala 42:20]
      outValid <= _GEN_0;
    end else if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
      outValid <= _GEN_4;
    end else begin
      outValid <= _GEN_0;
    end
    if (!(~running)) begin // @[UartRx.scala 42:20]
      if (rateCounter == 9'h0) begin // @[UartRx.scala 49:35]
        if (bitCounter == 3'h0) begin // @[UartRx.scala 52:38]
          outBits <= _outBits_T_1; // @[UartRx.scala 54:25]
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  rateCounter = _RAND_0[8:0];
  _RAND_1 = {1{`RANDOM}};
  bitCounter = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  bits_1 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  bits_2 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  bits_3 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  bits_4 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  bits_5 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  bits_6 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  bits_7 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  rxRegs_0 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  rxRegs_1 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  rxRegs_2 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  running = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  outValid = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  outBits = _RAND_14[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [7:0] io_enq_bits,
  input        io_deq_ready,
  output       io_deq_valid,
  output [7:0] io_deq_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:15]; // @[Decoupled.scala 275:95]
  wire  ram_io_deq_bits_MPORT_en; // @[Decoupled.scala 275:95]
  wire [3:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 275:95]
  wire [7:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 275:95]
  wire [7:0] ram_MPORT_data; // @[Decoupled.scala 275:95]
  wire [3:0] ram_MPORT_addr; // @[Decoupled.scala 275:95]
  wire  ram_MPORT_mask; // @[Decoupled.scala 275:95]
  wire  ram_MPORT_en; // @[Decoupled.scala 275:95]
  reg [3:0] enq_ptr_value; // @[Counter.scala 61:40]
  reg [3:0] deq_ptr_value; // @[Counter.scala 61:40]
  reg  maybe_full; // @[Decoupled.scala 278:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 279:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 280:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 281:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 52:35]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 52:35]
  wire [3:0] _value_T_1 = enq_ptr_value + 4'h1; // @[Counter.scala 77:24]
  wire [3:0] _value_T_3 = deq_ptr_value + 4'h1; // @[Counter.scala 77:24]
  assign ram_io_deq_bits_MPORT_en = 1'h1;
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 275:95]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 305:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 304:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 312:17]
  always @(posedge clock) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 275:95]
    end
    if (reset) begin // @[Counter.scala 61:40]
      enq_ptr_value <= 4'h0; // @[Counter.scala 61:40]
    end else if (do_enq) begin // @[Decoupled.scala 288:16]
      enq_ptr_value <= _value_T_1; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Counter.scala 61:40]
      deq_ptr_value <= 4'h0; // @[Counter.scala 61:40]
    end else if (do_deq) begin // @[Decoupled.scala 292:16]
      deq_ptr_value <= _value_T_3; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Decoupled.scala 278:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 278:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 295:27]
      maybe_full <= do_enq; // @[Decoupled.scala 296:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  enq_ptr_value = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  deq_ptr_value = _RAND_2[3:0];
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_1(
  input        clock,
  input        reset,
  output       io_enq_ready,
  input        io_enq_valid,
  input  [7:0] io_enq_bits,
  input        io_deq_ready,
  output       io_deq_valid,
  output [7:0] io_deq_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:15]; // @[Decoupled.scala 275:95]
  wire  ram_io_deq_bits_MPORT_en; // @[Decoupled.scala 275:95]
  wire [3:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 275:95]
  wire [7:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 275:95]
  wire [7:0] ram_MPORT_data; // @[Decoupled.scala 275:95]
  wire [3:0] ram_MPORT_addr; // @[Decoupled.scala 275:95]
  wire  ram_MPORT_mask; // @[Decoupled.scala 275:95]
  wire  ram_MPORT_en; // @[Decoupled.scala 275:95]
  reg [3:0] enq_ptr_value; // @[Counter.scala 61:40]
  reg [3:0] deq_ptr_value; // @[Counter.scala 61:40]
  reg  maybe_full; // @[Decoupled.scala 278:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 279:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 280:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 281:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 52:35]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 52:35]
  wire [3:0] _value_T_1 = enq_ptr_value + 4'h1; // @[Counter.scala 77:24]
  wire [3:0] _value_T_3 = deq_ptr_value + 4'h1; // @[Counter.scala 77:24]
  assign ram_io_deq_bits_MPORT_en = 1'h1;
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 275:95]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 305:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 304:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 312:17]
  always @(posedge clock) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 275:95]
    end
    if (reset) begin // @[Counter.scala 61:40]
      enq_ptr_value <= 4'h0; // @[Counter.scala 61:40]
    end else if (do_enq) begin // @[Decoupled.scala 288:16]
      enq_ptr_value <= _value_T_1; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Counter.scala 61:40]
      deq_ptr_value <= 4'h0; // @[Counter.scala 61:40]
    end else if (do_deq) begin // @[Decoupled.scala 292:16]
      deq_ptr_value <= _value_T_3; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Decoupled.scala 278:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 278:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 295:27]
      maybe_full <= do_enq; // @[Decoupled.scala 296:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  enq_ptr_value = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  deq_ptr_value = _RAND_2[3:0];
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Queue_2(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [32:0] io_enq_bits,
  input         io_deq_ready,
  output        io_deq_valid,
  output [32:0] io_deq_bits,
  input         io_flush
);
`ifdef RANDOMIZE_MEM_INIT
  reg [63:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [32:0] ram [0:511]; // @[Decoupled.scala 275:44]
  wire  ram_io_deq_bits_MPORT_en; // @[Decoupled.scala 275:44]
  wire [8:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 275:44]
  wire [32:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 275:44]
  wire [32:0] ram_MPORT_data; // @[Decoupled.scala 275:44]
  wire [8:0] ram_MPORT_addr; // @[Decoupled.scala 275:44]
  wire  ram_MPORT_mask; // @[Decoupled.scala 275:44]
  wire  ram_MPORT_en; // @[Decoupled.scala 275:44]
  reg  ram_io_deq_bits_MPORT_en_pipe_0;
  reg [8:0] ram_io_deq_bits_MPORT_addr_pipe_0;
  reg [8:0] enq_ptr_value; // @[Counter.scala 61:40]
  reg [8:0] deq_ptr_value; // @[Counter.scala 61:40]
  reg  maybe_full; // @[Decoupled.scala 278:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 279:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 280:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 281:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 52:35]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 52:35]
  wire [8:0] _value_T_1 = enq_ptr_value + 9'h1; // @[Counter.scala 77:24]
  wire [8:0] _value_T_3 = deq_ptr_value + 9'h1; // @[Counter.scala 77:24]
  wire [9:0] _deq_ptr_next_T_1 = 10'h200 - 10'h1; // @[Decoupled.scala 308:57]
  wire [9:0] _GEN_15 = {{1'd0}, deq_ptr_value}; // @[Decoupled.scala 308:42]
  assign ram_io_deq_bits_MPORT_en = ram_io_deq_bits_MPORT_en_pipe_0;
  assign ram_io_deq_bits_MPORT_addr = ram_io_deq_bits_MPORT_addr_pipe_0;
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 275:44]
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 305:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 304:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 310:17]
  always @(posedge clock) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 275:44]
    end
    ram_io_deq_bits_MPORT_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      if (do_deq) begin
        if (_GEN_15 == _deq_ptr_next_T_1) begin // @[Decoupled.scala 308:27]
          ram_io_deq_bits_MPORT_addr_pipe_0 <= 9'h0;
        end else begin
          ram_io_deq_bits_MPORT_addr_pipe_0 <= _value_T_3;
        end
      end else begin
        ram_io_deq_bits_MPORT_addr_pipe_0 <= deq_ptr_value;
      end
    end
    if (reset) begin // @[Counter.scala 61:40]
      enq_ptr_value <= 9'h0; // @[Counter.scala 61:40]
    end else if (io_flush) begin // @[Decoupled.scala 298:15]
      enq_ptr_value <= 9'h0; // @[Counter.scala 98:11]
    end else if (do_enq) begin // @[Decoupled.scala 288:16]
      enq_ptr_value <= _value_T_1; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Counter.scala 61:40]
      deq_ptr_value <= 9'h0; // @[Counter.scala 61:40]
    end else if (io_flush) begin // @[Decoupled.scala 298:15]
      deq_ptr_value <= 9'h0; // @[Counter.scala 98:11]
    end else if (do_deq) begin // @[Decoupled.scala 292:16]
      deq_ptr_value <= _value_T_3; // @[Counter.scala 77:15]
    end
    if (reset) begin // @[Decoupled.scala 278:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 278:27]
    end else if (io_flush) begin // @[Decoupled.scala 298:15]
      maybe_full <= 1'h0; // @[Decoupled.scala 301:16]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 295:27]
      maybe_full <= do_enq; // @[Decoupled.scala 296:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {2{`RANDOM}};
  for (initvar = 0; initvar < 512; initvar = initvar+1)
    ram[initvar] = _RAND_0[32:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  ram_io_deq_bits_MPORT_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  ram_io_deq_bits_MPORT_addr_pipe_0 = _RAND_2[8:0];
  _RAND_3 = {1{`RANDOM}};
  enq_ptr_value = _RAND_3[8:0];
  _RAND_4 = {1{`RANDOM}};
  deq_ptr_value = _RAND_4[8:0];
  _RAND_5 = {1{`RANDOM}};
  maybe_full = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Probe(
  input         clock,
  input         reset,
  input  [32:0] io_in,
  input         io_out_ready,
  output        io_out_valid,
  output [32:0] io_out_bits_data,
  output        io_out_bits_last,
  input         io_trigger
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [63:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  wire  buffer_clock; // @[Decoupled.scala 377:21]
  wire  buffer_reset; // @[Decoupled.scala 377:21]
  wire  buffer_io_enq_ready; // @[Decoupled.scala 377:21]
  wire  buffer_io_enq_valid; // @[Decoupled.scala 377:21]
  wire [32:0] buffer_io_enq_bits; // @[Decoupled.scala 377:21]
  wire  buffer_io_deq_ready; // @[Decoupled.scala 377:21]
  wire  buffer_io_deq_valid; // @[Decoupled.scala 377:21]
  wire [32:0] buffer_io_deq_bits; // @[Decoupled.scala 377:21]
  wire  buffer_io_flush; // @[Decoupled.scala 377:21]
  reg [2:0] state; // @[probe.scala 56:24]
  reg [8:0] triggerCount; // @[probe.scala 65:31]
  reg  outValid; // @[probe.scala 69:27]
  reg [32:0] outData; // @[probe.scala 70:26]
  reg  hasTriggered; // @[probe.scala 80:31]
  wire  _GEN_0 = io_trigger | hasTriggered; // @[probe.scala 81:24 82:22 80:31]
  wire [8:0] _triggerCount_T_1 = triggerCount + 9'h1; // @[probe.scala 101:42]
  wire [511:0] _T_8 = 512'h1f0 - 512'h1; // @[probe.scala 102:51]
  wire [511:0] _GEN_50 = {{503'd0}, triggerCount}; // @[probe.scala 102:31]
  wire [2:0] _GEN_4 = _GEN_0 ? 3'h3 : state; // @[probe.scala 108:48 110:23 56:24]
  wire  _GEN_5 = _GEN_0 ? 1'h0 : 1'h1; // @[probe.scala 108:48 112:29]
  wire  in_ready = buffer_io_enq_ready; // @[Decoupled.scala 381:17 probe.scala 59:18]
  wire [2:0] _GEN_6 = ~in_ready ? 3'h4 : state; // @[probe.scala 117:31 119:23 56:24]
  wire  _T_22 = ~outValid | io_out_ready; // @[probe.scala 127:29]
  wire  _GEN_7 = ~outValid | io_out_ready ? buffer_io_deq_valid : outValid; // @[probe.scala 127:47 128:26 69:27]
  wire [32:0] _GEN_8 = ~outValid | io_out_ready ? buffer_io_deq_bits : outData; // @[probe.scala 127:47 129:25 70:26]
  wire  _GEN_12 = 3'h4 == state & ~buffer_io_deq_valid; // @[probe.scala 85:19 126:21]
  wire  _GEN_20 = 3'h3 == state ? 1'h0 : _GEN_12; // @[probe.scala 85:19]
  wire  _GEN_29 = 3'h2 == state ? 1'h0 : _GEN_20; // @[probe.scala 85:19]
  wire  _GEN_38 = 3'h1 == state ? 1'h0 : _GEN_29; // @[probe.scala 85:19]
  wire  outLast = 3'h0 == state ? 1'h0 : _GEN_38; // @[probe.scala 85:19 89:21]
  wire [2:0] _GEN_10 = outValid & io_out_ready & outLast ? 3'h0 : state; // @[probe.scala 132:57 133:23 56:24]
  wire  _GEN_11 = 3'h4 == state ? 1'h0 : _GEN_0; // @[probe.scala 85:19 124:26]
  wire  _GEN_13 = 3'h4 == state ? _GEN_7 : outValid; // @[probe.scala 85:19 69:27]
  wire [32:0] _GEN_14 = 3'h4 == state ? _GEN_8 : outData; // @[probe.scala 85:19 70:26]
  wire [2:0] _GEN_16 = 3'h4 == state ? _GEN_10 : state; // @[probe.scala 85:19 56:24]
  wire [2:0] _GEN_18 = 3'h3 == state ? _GEN_6 : _GEN_16; // @[probe.scala 85:19]
  wire  _GEN_19 = 3'h3 == state ? _GEN_0 : _GEN_11; // @[probe.scala 85:19]
  wire  _GEN_21 = 3'h3 == state ? outValid : _GEN_13; // @[probe.scala 85:19 69:27]
  wire [32:0] _GEN_22 = 3'h3 == state ? outData : _GEN_14; // @[probe.scala 85:19 70:26]
  wire  _GEN_23 = 3'h3 == state ? 1'h0 : 3'h4 == state & _T_22; // @[probe.scala 85:19]
  wire  _GEN_24 = 3'h2 == state | 3'h3 == state; // @[probe.scala 85:19 107:22]
  wire  _GEN_27 = 3'h2 == state ? _GEN_5 : _GEN_23; // @[probe.scala 85:19]
  wire  _GEN_32 = 3'h1 == state | _GEN_24; // @[probe.scala 85:19 100:22]
  wire  _GEN_36 = 3'h1 == state ? 1'h0 : _GEN_27; // @[probe.scala 85:19]
  Queue_2 buffer ( // @[Decoupled.scala 377:21]
    .clock(buffer_clock),
    .reset(buffer_reset),
    .io_enq_ready(buffer_io_enq_ready),
    .io_enq_valid(buffer_io_enq_valid),
    .io_enq_bits(buffer_io_enq_bits),
    .io_deq_ready(buffer_io_deq_ready),
    .io_deq_valid(buffer_io_deq_valid),
    .io_deq_bits(buffer_io_deq_bits),
    .io_flush(buffer_io_flush)
  );
  assign io_out_valid = outValid; // @[probe.scala 73:18]
  assign io_out_bits_data = outData; // @[probe.scala 74:22]
  assign io_out_bits_last = 3'h0 == state ? 1'h0 : _GEN_38; // @[probe.scala 85:19 89:21]
  assign buffer_clock = clock;
  assign buffer_reset = reset;
  assign buffer_io_enq_valid = 3'h0 == state ? 1'h0 : _GEN_32; // @[probe.scala 60:14 85:19]
  assign buffer_io_enq_bits = io_in; // @[probe.scala 59:18 61:13]
  assign buffer_io_deq_ready = 3'h0 == state ? 1'h0 : _GEN_36; // @[probe.scala 85:19]
  assign buffer_io_flush = state == 3'h0; // @[probe.scala 57:41]
  always @(posedge clock) begin
    if (reset) begin // @[probe.scala 56:24]
      state <= 3'h0; // @[probe.scala 56:24]
    end else if (3'h0 == state) begin // @[probe.scala 85:19]
      state <= 3'h1;
    end else if (3'h1 == state) begin // @[probe.scala 85:19]
      if (_GEN_50 == _T_8) begin // @[probe.scala 102:58]
        state <= 3'h2; // @[probe.scala 103:23]
      end
    end else if (3'h2 == state) begin // @[probe.scala 85:19]
      state <= _GEN_4;
    end else begin
      state <= _GEN_18;
    end
    if (reset) begin // @[probe.scala 65:31]
      triggerCount <= 9'h0; // @[probe.scala 65:31]
    end else if (3'h0 == state) begin // @[probe.scala 85:19]
      triggerCount <= 9'h0; // @[probe.scala 87:26]
    end else if (3'h1 == state) begin // @[probe.scala 85:19]
      triggerCount <= _triggerCount_T_1; // @[probe.scala 101:26]
    end
    if (reset) begin // @[probe.scala 69:27]
      outValid <= 1'h0; // @[probe.scala 69:27]
    end else if (3'h0 == state) begin // @[probe.scala 85:19]
      outValid <= 1'h0; // @[probe.scala 88:22]
    end else if (!(3'h1 == state)) begin // @[probe.scala 85:19]
      if (!(3'h2 == state)) begin // @[probe.scala 85:19]
        outValid <= _GEN_21;
      end
    end
    if (reset) begin // @[probe.scala 70:26]
      outData <= 33'h0; // @[probe.scala 70:26]
    end else if (!(3'h0 == state)) begin // @[probe.scala 85:19]
      if (!(3'h1 == state)) begin // @[probe.scala 85:19]
        if (!(3'h2 == state)) begin // @[probe.scala 85:19]
          outData <= _GEN_22;
        end
      end
    end
    if (reset) begin // @[probe.scala 80:31]
      hasTriggered <= 1'h0; // @[probe.scala 80:31]
    end else if (3'h0 == state) begin // @[probe.scala 85:19]
      hasTriggered <= _GEN_0;
    end else if (3'h1 == state) begin // @[probe.scala 85:19]
      hasTriggered <= _GEN_0;
    end else if (3'h2 == state) begin // @[probe.scala 85:19]
      hasTriggered <= _GEN_0;
    end else begin
      hasTriggered <= _GEN_19;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  triggerCount = _RAND_1[8:0];
  _RAND_2 = {1{`RANDOM}};
  outValid = _RAND_2[0:0];
  _RAND_3 = {2{`RANDOM}};
  outData = _RAND_3[32:0];
  _RAND_4 = {1{`RANDOM}};
  hasTriggered = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ProbeOutWidthConverter(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [32:0] io_in_bits_data,
  input         io_in_bits_last,
  input         io_out_ready,
  output        io_out_valid,
  output [7:0]  io_out_bits_data,
  output        io_out_bits_last
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [2:0] phaseCounter; // @[probe.scala 160:35]
  reg [34:0] inData; // @[probe.scala 161:29]
  reg  inLast; // @[probe.scala 162:29]
  reg  outValid; // @[probe.scala 163:31]
  reg [6:0] outData; // @[probe.scala 164:30]
  reg  outLast; // @[probe.scala 165:30]
  wire  _GEN_0 = outValid & io_out_ready ? 1'h0 : outValid; // @[probe.scala 172:40 173:22 163:31]
  wire [2:0] _phaseCounter_T_1 = phaseCounter - 3'h1; // @[probe.scala 182:42]
  wire  _T_6 = phaseCounter == 3'h1; // @[probe.scala 185:35]
  wire [6:0] _GEN_4 = phaseCounter == 3'h1 ? inData[34:28] : outData; // @[probe.scala 185:48 187:29 164:30]
  wire [6:0] _GEN_5 = phaseCounter == 3'h2 ? inData[27:21] : _GEN_4; // @[probe.scala 185:48 187:29]
  wire [6:0] _GEN_6 = phaseCounter == 3'h3 ? inData[20:14] : _GEN_5; // @[probe.scala 185:48 187:29]
  wire  _GEN_10 = phaseCounter > 3'h0 & (~outValid | io_out_ready) | _GEN_0; // @[probe.scala 181:66 183:22]
  assign io_in_ready = phaseCounter == 3'h0; // @[probe.scala 167:37]
  assign io_out_valid = outValid; // @[probe.scala 168:22]
  assign io_out_bits_data = {1'h0,outData}; // @[Cat.scala 33:92]
  assign io_out_bits_last = outLast; // @[probe.scala 170:26]
  always @(posedge clock) begin
    if (reset) begin // @[probe.scala 160:35]
      phaseCounter <= 3'h0; // @[probe.scala 160:35]
    end else if (phaseCounter > 3'h0 & (~outValid | io_out_ready)) begin // @[probe.scala 181:66]
      phaseCounter <= _phaseCounter_T_1; // @[probe.scala 182:26]
    end else if (io_in_valid & io_in_ready) begin // @[probe.scala 175:42]
      phaseCounter <= 3'h5; // @[probe.scala 179:26]
    end
    if (reset) begin // @[probe.scala 161:29]
      inData <= 35'h0; // @[probe.scala 161:29]
    end else if (io_in_valid & io_in_ready) begin // @[probe.scala 175:42]
      inData <= {{2'd0}, io_in_bits_data}; // @[probe.scala 177:20]
    end
    if (reset) begin // @[probe.scala 162:29]
      inLast <= 1'h0; // @[probe.scala 162:29]
    end else if (io_in_valid & io_in_ready) begin // @[probe.scala 175:42]
      inLast <= io_in_bits_last; // @[probe.scala 178:20]
    end
    if (reset) begin // @[probe.scala 163:31]
      outValid <= 1'h0; // @[probe.scala 163:31]
    end else begin
      outValid <= _GEN_10;
    end
    if (reset) begin // @[probe.scala 164:30]
      outData <= 7'h0; // @[probe.scala 164:30]
    end else if (phaseCounter > 3'h0 & (~outValid | io_out_ready)) begin // @[probe.scala 181:66]
      if (phaseCounter == 3'h5) begin // @[probe.scala 185:48]
        outData <= inData[6:0]; // @[probe.scala 187:29]
      end else if (phaseCounter == 3'h4) begin // @[probe.scala 185:48]
        outData <= inData[13:7]; // @[probe.scala 187:29]
      end else begin
        outData <= _GEN_6;
      end
    end
    if (reset) begin // @[probe.scala 165:30]
      outLast <= 1'h0; // @[probe.scala 165:30]
    end else if (phaseCounter > 3'h0 & (~outValid | io_out_ready)) begin // @[probe.scala 181:66]
      outLast <= _T_6 & inLast; // @[probe.scala 190:21]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  phaseCounter = _RAND_0[2:0];
  _RAND_1 = {2{`RANDOM}};
  inData = _RAND_1[34:0];
  _RAND_2 = {1{`RANDOM}};
  inLast = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  outValid = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  outData = _RAND_4[6:0];
  _RAND_5 = {1{`RANDOM}};
  outLast = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ProbeFrameAdapter(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [32:0] io_in_bits_data,
  input         io_in_bits_last,
  input         io_out_ready,
  output        io_out_valid,
  output [7:0]  io_out_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  wire  widthConverter_clock; // @[probe.scala 214:32]
  wire  widthConverter_reset; // @[probe.scala 214:32]
  wire  widthConverter_io_in_ready; // @[probe.scala 214:32]
  wire  widthConverter_io_in_valid; // @[probe.scala 214:32]
  wire [32:0] widthConverter_io_in_bits_data; // @[probe.scala 214:32]
  wire  widthConverter_io_in_bits_last; // @[probe.scala 214:32]
  wire  widthConverter_io_out_ready; // @[probe.scala 214:32]
  wire  widthConverter_io_out_valid; // @[probe.scala 214:32]
  wire [7:0] widthConverter_io_out_bits_data; // @[probe.scala 214:32]
  wire  widthConverter_io_out_bits_last; // @[probe.scala 214:32]
  reg  outValid; // @[probe.scala 219:27]
  reg [7:0] outData; // @[probe.scala 220:26]
  reg [1:0] state; // @[probe.scala 224:24]
  wire  _GEN_0 = outValid & io_out_ready ? 1'h0 : outValid; // @[probe.scala 226:36 227:18 219:27]
  wire  _T_5 = ~outValid | io_out_ready; // @[probe.scala 232:60]
  wire  _GEN_1 = widthConverter_io_out_valid & (~outValid | io_out_ready) | _GEN_0; // @[probe.scala 232:78 234:26]
  wire  _GEN_14 = 2'h1 == state & _T_5; // @[probe.scala 230:19 241:21]
  wire  inReady = 2'h0 == state ? 1'h0 : _GEN_14; // @[probe.scala 230:19]
  wire [1:0] _GEN_4 = widthConverter_io_out_bits_last ? 2'h2 : state; // @[probe.scala 224:24 246:55 247:27]
  wire  _GEN_5 = widthConverter_io_out_valid & inReady | _GEN_0; // @[probe.scala 242:59 243:26]
  wire  _GEN_8 = _T_5 | _GEN_0; // @[probe.scala 252:47 255:26]
  wire [7:0] _GEN_9 = _T_5 ? 8'h81 : outData; // @[probe.scala 252:47 256:25 220:26]
  wire [1:0] _GEN_10 = _T_5 ? 2'h0 : state; // @[probe.scala 252:47 257:23 224:24]
  ProbeOutWidthConverter widthConverter ( // @[probe.scala 214:32]
    .clock(widthConverter_clock),
    .reset(widthConverter_reset),
    .io_in_ready(widthConverter_io_in_ready),
    .io_in_valid(widthConverter_io_in_valid),
    .io_in_bits_data(widthConverter_io_in_bits_data),
    .io_in_bits_last(widthConverter_io_in_bits_last),
    .io_out_ready(widthConverter_io_out_ready),
    .io_out_valid(widthConverter_io_out_valid),
    .io_out_bits_data(widthConverter_io_out_bits_data),
    .io_out_bits_last(widthConverter_io_out_bits_last)
  );
  assign io_in_ready = widthConverter_io_in_ready; // @[probe.scala 215:26]
  assign io_out_valid = outValid; // @[probe.scala 221:18]
  assign io_out_bits = outData; // @[probe.scala 222:17]
  assign widthConverter_clock = clock;
  assign widthConverter_reset = reset;
  assign widthConverter_io_in_valid = io_in_valid; // @[probe.scala 215:26]
  assign widthConverter_io_in_bits_data = io_in_bits_data; // @[probe.scala 215:26]
  assign widthConverter_io_in_bits_last = io_in_bits_last; // @[probe.scala 215:26]
  assign widthConverter_io_out_ready = 2'h0 == state ? 1'h0 : _GEN_14; // @[probe.scala 230:19]
  always @(posedge clock) begin
    if (reset) begin // @[probe.scala 219:27]
      outValid <= 1'h0; // @[probe.scala 219:27]
    end else if (2'h0 == state) begin // @[probe.scala 230:19]
      outValid <= _GEN_1;
    end else if (2'h1 == state) begin // @[probe.scala 230:19]
      outValid <= _GEN_5;
    end else if (2'h2 == state) begin // @[probe.scala 230:19]
      outValid <= _GEN_8;
    end else begin
      outValid <= _GEN_0;
    end
    if (reset) begin // @[probe.scala 220:26]
      outData <= 8'h0; // @[probe.scala 220:26]
    end else if (2'h0 == state) begin // @[probe.scala 230:19]
      if (widthConverter_io_out_valid & (~outValid | io_out_ready)) begin // @[probe.scala 232:78]
        outData <= 8'h80; // @[probe.scala 235:25]
      end
    end else if (2'h1 == state) begin // @[probe.scala 230:19]
      if (widthConverter_io_out_valid & inReady) begin // @[probe.scala 242:59]
        outData <= widthConverter_io_out_bits_data; // @[probe.scala 244:25]
      end
    end else if (2'h2 == state) begin // @[probe.scala 230:19]
      outData <= _GEN_9;
    end
    if (reset) begin // @[probe.scala 224:24]
      state <= 2'h0; // @[probe.scala 224:24]
    end else if (2'h0 == state) begin // @[probe.scala 230:19]
      if (widthConverter_io_out_valid & (~outValid | io_out_ready)) begin // @[probe.scala 232:78]
        state <= 2'h1; // @[probe.scala 236:23]
      end
    end else if (2'h1 == state) begin // @[probe.scala 230:19]
      if (widthConverter_io_out_valid & inReady) begin // @[probe.scala 242:59]
        state <= _GEN_4;
      end
    end else if (2'h2 == state) begin // @[probe.scala 230:19]
      state <= _GEN_10;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  outValid = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  outData = _RAND_1[7:0];
  _RAND_2 = {1{`RANDOM}};
  state = _RAND_2[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TopWithSegmentLed(
  input         clock,
  input         reset,
  output [31:0] io_debug_pc,
  output        io_uartTx,
  input         io_uartRx,
  output        io_success,
  output        io_segmentOut_outputEnable,
  output        io_segmentOut_shiftClock,
  output        io_segmentOut_latch,
  output        io_segmentOut_data,
  output        io_digitSelector_outputEnable,
  output        io_digitSelector_shiftClock,
  output        io_digitSelector_latch,
  output        io_digitSelector_data,
  output [31:0] io_ledOut,
  input  [31:0] io_switchIn,
  output [7:0]  io_matrixColumnOut,
  output [7:0]  io_matrixRowOut,
  output        io_probeOut,
  output        io_exit
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  wire  core_clock; // @[TopWithSegmentLed.scala 32:20]
  wire  core_reset; // @[TopWithSegmentLed.scala 32:20]
  wire [31:0] core_io_imem_addr; // @[TopWithSegmentLed.scala 32:20]
  wire [31:0] core_io_imem_inst; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_imem_valid; // @[TopWithSegmentLed.scala 32:20]
  wire [31:0] core_io_dmem_addr; // @[TopWithSegmentLed.scala 32:20]
  wire [31:0] core_io_dmem_rdata; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_dmem_ren; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_dmem_rvalid; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_dmem_wen; // @[TopWithSegmentLed.scala 32:20]
  wire [3:0] core_io_dmem_wstrb; // @[TopWithSegmentLed.scala 32:20]
  wire [31:0] core_io_dmem_wdata; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_interrupt_in; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_success; // @[TopWithSegmentLed.scala 32:20]
  wire  core_io_exit; // @[TopWithSegmentLed.scala 32:20]
  wire [31:0] core_io_debug_pc; // @[TopWithSegmentLed.scala 32:20]
  wire  memory_clock; // @[TopWithSegmentLed.scala 34:22]
  wire  memory_reset; // @[TopWithSegmentLed.scala 34:22]
  wire [31:0] memory_io_imem_addr; // @[TopWithSegmentLed.scala 34:22]
  wire [31:0] memory_io_imem_inst; // @[TopWithSegmentLed.scala 34:22]
  wire  memory_io_imem_valid; // @[TopWithSegmentLed.scala 34:22]
  wire [31:0] memory_io_dmem_addr; // @[TopWithSegmentLed.scala 34:22]
  wire [31:0] memory_io_dmem_rdata; // @[TopWithSegmentLed.scala 34:22]
  wire  memory_io_dmem_ren; // @[TopWithSegmentLed.scala 34:22]
  wire  memory_io_dmem_rvalid; // @[TopWithSegmentLed.scala 34:22]
  wire  memory_io_dmem_wen; // @[TopWithSegmentLed.scala 34:22]
  wire [3:0] memory_io_dmem_wstrb; // @[TopWithSegmentLed.scala 34:22]
  wire [31:0] memory_io_dmem_wdata; // @[TopWithSegmentLed.scala 34:22]
  wire  gpios_clock; // @[TopWithSegmentLed.scala 35:21]
  wire  gpios_reset; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_mem_addr; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_mem_rdata; // @[TopWithSegmentLed.scala 35:21]
  wire  gpios_io_mem_wen; // @[TopWithSegmentLed.scala 35:21]
  wire [3:0] gpios_io_mem_wstrb; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_mem_wdata; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_in_5; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_out_0; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_out_1; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_out_2; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_out_3; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] gpios_io_out_4; // @[TopWithSegmentLed.scala 35:21]
  wire [31:0] uartRegs_io_mem_addr; // @[TopWithSegmentLed.scala 36:24]
  wire [31:0] uartRegs_io_mem_rdata; // @[TopWithSegmentLed.scala 36:24]
  wire  uartRegs_io_mem_ren; // @[TopWithSegmentLed.scala 36:24]
  wire  uartRegs_io_mem_rvalid; // @[TopWithSegmentLed.scala 36:24]
  wire  uartRegs_io_mem_wen; // @[TopWithSegmentLed.scala 36:24]
  wire [3:0] uartRegs_io_mem_wstrb; // @[TopWithSegmentLed.scala 36:24]
  wire [31:0] uartRegs_io_mem_wdata; // @[TopWithSegmentLed.scala 36:24]
  wire  uartRegs_io_in_0_ready; // @[TopWithSegmentLed.scala 36:24]
  wire [31:0] uartRegs_io_in_0_bits; // @[TopWithSegmentLed.scala 36:24]
  wire [31:0] uartRegs_io_in_1_bits; // @[TopWithSegmentLed.scala 36:24]
  wire  uartRegs_io_out_0_valid; // @[TopWithSegmentLed.scala 36:24]
  wire [31:0] uartRegs_io_out_0_bits; // @[TopWithSegmentLed.scala 36:24]
  wire [31:0] decoder_io_initiator_addr; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_initiator_rdata; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_initiator_ren; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_initiator_rvalid; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_initiator_wen; // @[TopWithSegmentLed.scala 38:23]
  wire [3:0] decoder_io_initiator_wstrb; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_initiator_wdata; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_0_addr; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_0_rdata; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_0_ren; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_0_rvalid; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_0_wen; // @[TopWithSegmentLed.scala 38:23]
  wire [3:0] decoder_io_targets_0_wstrb; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_0_wdata; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_1_addr; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_1_rdata; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_1_wen; // @[TopWithSegmentLed.scala 38:23]
  wire [3:0] decoder_io_targets_1_wstrb; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_1_wdata; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_2_addr; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_2_rdata; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_2_ren; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_2_rvalid; // @[TopWithSegmentLed.scala 38:23]
  wire  decoder_io_targets_2_wen; // @[TopWithSegmentLed.scala 38:23]
  wire [3:0] decoder_io_targets_2_wstrb; // @[TopWithSegmentLed.scala 38:23]
  wire [31:0] decoder_io_targets_2_wdata; // @[TopWithSegmentLed.scala 38:23]
  wire  segmentLeds_clock; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_reset; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_segmentOut_outputEnable; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_segmentOut_shiftClock; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_segmentOut_latch; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_segmentOut_data; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_digitSelector_outputEnable; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_digitSelector_shiftClock; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_digitSelector_latch; // @[TopWithSegmentLed.scala 51:27]
  wire  segmentLeds_io_digitSelector_data; // @[TopWithSegmentLed.scala 51:27]
  wire [7:0] segmentLeds_io_digits_0; // @[TopWithSegmentLed.scala 51:27]
  wire [7:0] segmentLeds_io_digits_1; // @[TopWithSegmentLed.scala 51:27]
  wire [7:0] segmentLeds_io_digits_2; // @[TopWithSegmentLed.scala 51:27]
  wire [7:0] segmentLeds_io_digits_3; // @[TopWithSegmentLed.scala 51:27]
  wire [7:0] segmentLeds_io_digits_4; // @[TopWithSegmentLed.scala 51:27]
  wire [7:0] segmentLeds_io_digits_5; // @[TopWithSegmentLed.scala 51:27]
  wire  matrixLed_clock; // @[TopWithSegmentLed.scala 59:25]
  wire  matrixLed_reset; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_row; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_column; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_0; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_1; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_2; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_3; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_4; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_5; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_6; // @[TopWithSegmentLed.scala 59:25]
  wire [7:0] matrixLed_io_matrix_7; // @[TopWithSegmentLed.scala 59:25]
  wire  uartTx_clock; // @[TopWithSegmentLed.scala 73:22]
  wire  uartTx_reset; // @[TopWithSegmentLed.scala 73:22]
  wire  uartTx_io_in_ready; // @[TopWithSegmentLed.scala 73:22]
  wire  uartTx_io_in_valid; // @[TopWithSegmentLed.scala 73:22]
  wire [7:0] uartTx_io_in_bits; // @[TopWithSegmentLed.scala 73:22]
  wire  uartTx_io_tx; // @[TopWithSegmentLed.scala 73:22]
  wire  uartRx_clock; // @[TopWithSegmentLed.scala 74:22]
  wire  uartRx_reset; // @[TopWithSegmentLed.scala 74:22]
  wire  uartRx_io_out_ready; // @[TopWithSegmentLed.scala 74:22]
  wire  uartRx_io_out_valid; // @[TopWithSegmentLed.scala 74:22]
  wire [7:0] uartRx_io_out_bits; // @[TopWithSegmentLed.scala 74:22]
  wire  uartRx_io_rx; // @[TopWithSegmentLed.scala 74:22]
  wire  uartTxQueue_clock; // @[Decoupled.scala 377:21]
  wire  uartTxQueue_reset; // @[Decoupled.scala 377:21]
  wire  uartTxQueue_io_enq_ready; // @[Decoupled.scala 377:21]
  wire  uartTxQueue_io_enq_valid; // @[Decoupled.scala 377:21]
  wire [7:0] uartTxQueue_io_enq_bits; // @[Decoupled.scala 377:21]
  wire  uartTxQueue_io_deq_ready; // @[Decoupled.scala 377:21]
  wire  uartTxQueue_io_deq_valid; // @[Decoupled.scala 377:21]
  wire [7:0] uartTxQueue_io_deq_bits; // @[Decoupled.scala 377:21]
  wire  uartRxQueue_clock; // @[Decoupled.scala 377:21]
  wire  uartRxQueue_reset; // @[Decoupled.scala 377:21]
  wire  uartRxQueue_io_enq_ready; // @[Decoupled.scala 377:21]
  wire  uartRxQueue_io_enq_valid; // @[Decoupled.scala 377:21]
  wire [7:0] uartRxQueue_io_enq_bits; // @[Decoupled.scala 377:21]
  wire  uartRxQueue_io_deq_ready; // @[Decoupled.scala 377:21]
  wire  uartRxQueue_io_deq_valid; // @[Decoupled.scala 377:21]
  wire [7:0] uartRxQueue_io_deq_bits; // @[Decoupled.scala 377:21]
  wire  probe_clock; // @[TopWithSegmentLed.scala 97:21]
  wire  probe_reset; // @[TopWithSegmentLed.scala 97:21]
  wire [32:0] probe_io_in; // @[TopWithSegmentLed.scala 97:21]
  wire  probe_io_out_ready; // @[TopWithSegmentLed.scala 97:21]
  wire  probe_io_out_valid; // @[TopWithSegmentLed.scala 97:21]
  wire [32:0] probe_io_out_bits_data; // @[TopWithSegmentLed.scala 97:21]
  wire  probe_io_out_bits_last; // @[TopWithSegmentLed.scala 97:21]
  wire  probe_io_trigger; // @[TopWithSegmentLed.scala 97:21]
  wire  probeFrameAdapter_clock; // @[TopWithSegmentLed.scala 106:33]
  wire  probeFrameAdapter_reset; // @[TopWithSegmentLed.scala 106:33]
  wire  probeFrameAdapter_io_in_ready; // @[TopWithSegmentLed.scala 106:33]
  wire  probeFrameAdapter_io_in_valid; // @[TopWithSegmentLed.scala 106:33]
  wire [32:0] probeFrameAdapter_io_in_bits_data; // @[TopWithSegmentLed.scala 106:33]
  wire  probeFrameAdapter_io_in_bits_last; // @[TopWithSegmentLed.scala 106:33]
  wire  probeFrameAdapter_io_out_ready; // @[TopWithSegmentLed.scala 106:33]
  wire  probeFrameAdapter_io_out_valid; // @[TopWithSegmentLed.scala 106:33]
  wire [7:0] probeFrameAdapter_io_out_bits; // @[TopWithSegmentLed.scala 106:33]
  wire  probeUartTx_clock; // @[TopWithSegmentLed.scala 108:27]
  wire  probeUartTx_reset; // @[TopWithSegmentLed.scala 108:27]
  wire  probeUartTx_io_in_ready; // @[TopWithSegmentLed.scala 108:27]
  wire  probeUartTx_io_in_valid; // @[TopWithSegmentLed.scala 108:27]
  wire [7:0] probeUartTx_io_in_bits; // @[TopWithSegmentLed.scala 108:27]
  wire  probeUartTx_io_tx; // @[TopWithSegmentLed.scala 108:27]
  wire [30:0] uartRegs_io_in_1_bits_hi = {30'h0,uartRxQueue_io_deq_valid}; // @[Cat.scala 33:92]
  wire  uartTxValidReady_ready = uartTxQueue_io_enq_ready; // @[Decoupled.scala 381:17 TopWithSegmentLed.scala 75:30]
  wire [15:0] uartRegs_io_in_0_bits_lo = {8'h0,uartRxQueue_io_deq_bits}; // @[Cat.scala 33:92]
  wire [15:0] uartRegs_io_in_0_bits_hi = {15'h0,uartRxQueue_io_deq_valid}; // @[Cat.scala 33:92]
  reg [7:0] noActivityCounter; // @[TopWithSegmentLed.scala 99:34]
  wire [7:0] _noActivityCounter_T_1 = noActivityCounter + 8'h1; // @[TopWithSegmentLed.scala 103:44]
  Core core ( // @[TopWithSegmentLed.scala 32:20]
    .clock(core_clock),
    .reset(core_reset),
    .io_imem_addr(core_io_imem_addr),
    .io_imem_inst(core_io_imem_inst),
    .io_imem_valid(core_io_imem_valid),
    .io_dmem_addr(core_io_dmem_addr),
    .io_dmem_rdata(core_io_dmem_rdata),
    .io_dmem_ren(core_io_dmem_ren),
    .io_dmem_rvalid(core_io_dmem_rvalid),
    .io_dmem_wen(core_io_dmem_wen),
    .io_dmem_wstrb(core_io_dmem_wstrb),
    .io_dmem_wdata(core_io_dmem_wdata),
    .io_interrupt_in(core_io_interrupt_in),
    .io_success(core_io_success),
    .io_exit(core_io_exit),
    .io_debug_pc(core_io_debug_pc)
  );
  Memory memory ( // @[TopWithSegmentLed.scala 34:22]
    .clock(memory_clock),
    .reset(memory_reset),
    .io_imem_addr(memory_io_imem_addr),
    .io_imem_inst(memory_io_imem_inst),
    .io_imem_valid(memory_io_imem_valid),
    .io_dmem_addr(memory_io_dmem_addr),
    .io_dmem_rdata(memory_io_dmem_rdata),
    .io_dmem_ren(memory_io_dmem_ren),
    .io_dmem_rvalid(memory_io_dmem_rvalid),
    .io_dmem_wen(memory_io_dmem_wen),
    .io_dmem_wstrb(memory_io_dmem_wstrb),
    .io_dmem_wdata(memory_io_dmem_wdata)
  );
  GpioArray gpios ( // @[TopWithSegmentLed.scala 35:21]
    .clock(gpios_clock),
    .reset(gpios_reset),
    .io_mem_addr(gpios_io_mem_addr),
    .io_mem_rdata(gpios_io_mem_rdata),
    .io_mem_wen(gpios_io_mem_wen),
    .io_mem_wstrb(gpios_io_mem_wstrb),
    .io_mem_wdata(gpios_io_mem_wdata),
    .io_in_5(gpios_io_in_5),
    .io_out_0(gpios_io_out_0),
    .io_out_1(gpios_io_out_1),
    .io_out_2(gpios_io_out_2),
    .io_out_3(gpios_io_out_3),
    .io_out_4(gpios_io_out_4)
  );
  IORegister uartRegs ( // @[TopWithSegmentLed.scala 36:24]
    .io_mem_addr(uartRegs_io_mem_addr),
    .io_mem_rdata(uartRegs_io_mem_rdata),
    .io_mem_ren(uartRegs_io_mem_ren),
    .io_mem_rvalid(uartRegs_io_mem_rvalid),
    .io_mem_wen(uartRegs_io_mem_wen),
    .io_mem_wstrb(uartRegs_io_mem_wstrb),
    .io_mem_wdata(uartRegs_io_mem_wdata),
    .io_in_0_ready(uartRegs_io_in_0_ready),
    .io_in_0_bits(uartRegs_io_in_0_bits),
    .io_in_1_bits(uartRegs_io_in_1_bits),
    .io_out_0_valid(uartRegs_io_out_0_valid),
    .io_out_0_bits(uartRegs_io_out_0_bits)
  );
  DMemDecoder decoder ( // @[TopWithSegmentLed.scala 38:23]
    .io_initiator_addr(decoder_io_initiator_addr),
    .io_initiator_rdata(decoder_io_initiator_rdata),
    .io_initiator_ren(decoder_io_initiator_ren),
    .io_initiator_rvalid(decoder_io_initiator_rvalid),
    .io_initiator_wen(decoder_io_initiator_wen),
    .io_initiator_wstrb(decoder_io_initiator_wstrb),
    .io_initiator_wdata(decoder_io_initiator_wdata),
    .io_targets_0_addr(decoder_io_targets_0_addr),
    .io_targets_0_rdata(decoder_io_targets_0_rdata),
    .io_targets_0_ren(decoder_io_targets_0_ren),
    .io_targets_0_rvalid(decoder_io_targets_0_rvalid),
    .io_targets_0_wen(decoder_io_targets_0_wen),
    .io_targets_0_wstrb(decoder_io_targets_0_wstrb),
    .io_targets_0_wdata(decoder_io_targets_0_wdata),
    .io_targets_1_addr(decoder_io_targets_1_addr),
    .io_targets_1_rdata(decoder_io_targets_1_rdata),
    .io_targets_1_wen(decoder_io_targets_1_wen),
    .io_targets_1_wstrb(decoder_io_targets_1_wstrb),
    .io_targets_1_wdata(decoder_io_targets_1_wdata),
    .io_targets_2_addr(decoder_io_targets_2_addr),
    .io_targets_2_rdata(decoder_io_targets_2_rdata),
    .io_targets_2_ren(decoder_io_targets_2_ren),
    .io_targets_2_rvalid(decoder_io_targets_2_rvalid),
    .io_targets_2_wen(decoder_io_targets_2_wen),
    .io_targets_2_wstrb(decoder_io_targets_2_wstrb),
    .io_targets_2_wdata(decoder_io_targets_2_wdata)
  );
  SegmentLedWithShiftRegs segmentLeds ( // @[TopWithSegmentLed.scala 51:27]
    .clock(segmentLeds_clock),
    .reset(segmentLeds_reset),
    .io_segmentOut_outputEnable(segmentLeds_io_segmentOut_outputEnable),
    .io_segmentOut_shiftClock(segmentLeds_io_segmentOut_shiftClock),
    .io_segmentOut_latch(segmentLeds_io_segmentOut_latch),
    .io_segmentOut_data(segmentLeds_io_segmentOut_data),
    .io_digitSelector_outputEnable(segmentLeds_io_digitSelector_outputEnable),
    .io_digitSelector_shiftClock(segmentLeds_io_digitSelector_shiftClock),
    .io_digitSelector_latch(segmentLeds_io_digitSelector_latch),
    .io_digitSelector_data(segmentLeds_io_digitSelector_data),
    .io_digits_0(segmentLeds_io_digits_0),
    .io_digits_1(segmentLeds_io_digits_1),
    .io_digits_2(segmentLeds_io_digits_2),
    .io_digits_3(segmentLeds_io_digits_3),
    .io_digits_4(segmentLeds_io_digits_4),
    .io_digits_5(segmentLeds_io_digits_5)
  );
  MatrixLed matrixLed ( // @[TopWithSegmentLed.scala 59:25]
    .clock(matrixLed_clock),
    .reset(matrixLed_reset),
    .io_row(matrixLed_io_row),
    .io_column(matrixLed_io_column),
    .io_matrix_0(matrixLed_io_matrix_0),
    .io_matrix_1(matrixLed_io_matrix_1),
    .io_matrix_2(matrixLed_io_matrix_2),
    .io_matrix_3(matrixLed_io_matrix_3),
    .io_matrix_4(matrixLed_io_matrix_4),
    .io_matrix_5(matrixLed_io_matrix_5),
    .io_matrix_6(matrixLed_io_matrix_6),
    .io_matrix_7(matrixLed_io_matrix_7)
  );
  UartTx uartTx ( // @[TopWithSegmentLed.scala 73:22]
    .clock(uartTx_clock),
    .reset(uartTx_reset),
    .io_in_ready(uartTx_io_in_ready),
    .io_in_valid(uartTx_io_in_valid),
    .io_in_bits(uartTx_io_in_bits),
    .io_tx(uartTx_io_tx)
  );
  UartRx uartRx ( // @[TopWithSegmentLed.scala 74:22]
    .clock(uartRx_clock),
    .reset(uartRx_reset),
    .io_out_ready(uartRx_io_out_ready),
    .io_out_valid(uartRx_io_out_valid),
    .io_out_bits(uartRx_io_out_bits),
    .io_rx(uartRx_io_rx)
  );
  Queue uartTxQueue ( // @[Decoupled.scala 377:21]
    .clock(uartTxQueue_clock),
    .reset(uartTxQueue_reset),
    .io_enq_ready(uartTxQueue_io_enq_ready),
    .io_enq_valid(uartTxQueue_io_enq_valid),
    .io_enq_bits(uartTxQueue_io_enq_bits),
    .io_deq_ready(uartTxQueue_io_deq_ready),
    .io_deq_valid(uartTxQueue_io_deq_valid),
    .io_deq_bits(uartTxQueue_io_deq_bits)
  );
  Queue_1 uartRxQueue ( // @[Decoupled.scala 377:21]
    .clock(uartRxQueue_clock),
    .reset(uartRxQueue_reset),
    .io_enq_ready(uartRxQueue_io_enq_ready),
    .io_enq_valid(uartRxQueue_io_enq_valid),
    .io_enq_bits(uartRxQueue_io_enq_bits),
    .io_deq_ready(uartRxQueue_io_deq_ready),
    .io_deq_valid(uartRxQueue_io_deq_valid),
    .io_deq_bits(uartRxQueue_io_deq_bits)
  );
  Probe probe ( // @[TopWithSegmentLed.scala 97:21]
    .clock(probe_clock),
    .reset(probe_reset),
    .io_in(probe_io_in),
    .io_out_ready(probe_io_out_ready),
    .io_out_valid(probe_io_out_valid),
    .io_out_bits_data(probe_io_out_bits_data),
    .io_out_bits_last(probe_io_out_bits_last),
    .io_trigger(probe_io_trigger)
  );
  ProbeFrameAdapter probeFrameAdapter ( // @[TopWithSegmentLed.scala 106:33]
    .clock(probeFrameAdapter_clock),
    .reset(probeFrameAdapter_reset),
    .io_in_ready(probeFrameAdapter_io_in_ready),
    .io_in_valid(probeFrameAdapter_io_in_valid),
    .io_in_bits_data(probeFrameAdapter_io_in_bits_data),
    .io_in_bits_last(probeFrameAdapter_io_in_bits_last),
    .io_out_ready(probeFrameAdapter_io_out_ready),
    .io_out_valid(probeFrameAdapter_io_out_valid),
    .io_out_bits(probeFrameAdapter_io_out_bits)
  );
  UartTx probeUartTx ( // @[TopWithSegmentLed.scala 108:27]
    .clock(probeUartTx_clock),
    .reset(probeUartTx_reset),
    .io_in_ready(probeUartTx_io_in_ready),
    .io_in_valid(probeUartTx_io_in_valid),
    .io_in_bits(probeUartTx_io_in_bits),
    .io_tx(probeUartTx_io_tx)
  );
  assign io_debug_pc = core_io_debug_pc; // @[TopWithSegmentLed.scala 94:15]
  assign io_uartTx = uartTx_io_tx; // @[TopWithSegmentLed.scala 79:13]
  assign io_success = core_io_success; // @[TopWithSegmentLed.scala 92:14]
  assign io_segmentOut_outputEnable = segmentLeds_io_segmentOut_outputEnable; // @[TopWithSegmentLed.scala 52:17]
  assign io_segmentOut_shiftClock = segmentLeds_io_segmentOut_shiftClock; // @[TopWithSegmentLed.scala 52:17]
  assign io_segmentOut_latch = segmentLeds_io_segmentOut_latch; // @[TopWithSegmentLed.scala 52:17]
  assign io_segmentOut_data = segmentLeds_io_segmentOut_data; // @[TopWithSegmentLed.scala 52:17]
  assign io_digitSelector_outputEnable = segmentLeds_io_digitSelector_outputEnable; // @[TopWithSegmentLed.scala 53:20]
  assign io_digitSelector_shiftClock = segmentLeds_io_digitSelector_shiftClock; // @[TopWithSegmentLed.scala 53:20]
  assign io_digitSelector_latch = segmentLeds_io_digitSelector_latch; // @[TopWithSegmentLed.scala 53:20]
  assign io_digitSelector_data = segmentLeds_io_digitSelector_data; // @[TopWithSegmentLed.scala 53:20]
  assign io_ledOut = gpios_io_out_4; // @[TopWithSegmentLed.scala 67:13]
  assign io_matrixColumnOut = matrixLed_io_column; // @[TopWithSegmentLed.scala 61:22]
  assign io_matrixRowOut = matrixLed_io_row; // @[TopWithSegmentLed.scala 62:19]
  assign io_probeOut = probeUartTx_io_tx; // @[TopWithSegmentLed.scala 110:15]
  assign io_exit = core_io_exit; // @[TopWithSegmentLed.scala 93:11]
  assign core_clock = clock;
  assign core_reset = reset;
  assign core_io_imem_inst = memory_io_imem_inst; // @[TopWithSegmentLed.scala 43:16]
  assign core_io_imem_valid = memory_io_imem_valid; // @[TopWithSegmentLed.scala 43:16]
  assign core_io_dmem_rdata = decoder_io_initiator_rdata; // @[TopWithSegmentLed.scala 44:16]
  assign core_io_dmem_rvalid = decoder_io_initiator_rvalid; // @[TopWithSegmentLed.scala 44:16]
  assign core_io_interrupt_in = uartRxQueue_io_deq_valid; // @[TopWithSegmentLed.scala 85:24]
  assign memory_clock = clock;
  assign memory_reset = reset;
  assign memory_io_imem_addr = core_io_imem_addr; // @[TopWithSegmentLed.scala 43:16]
  assign memory_io_dmem_addr = decoder_io_targets_0_addr; // @[TopWithSegmentLed.scala 46:25]
  assign memory_io_dmem_ren = decoder_io_targets_0_ren; // @[TopWithSegmentLed.scala 46:25]
  assign memory_io_dmem_wen = decoder_io_targets_0_wen; // @[TopWithSegmentLed.scala 46:25]
  assign memory_io_dmem_wstrb = decoder_io_targets_0_wstrb; // @[TopWithSegmentLed.scala 46:25]
  assign memory_io_dmem_wdata = decoder_io_targets_0_wdata; // @[TopWithSegmentLed.scala 46:25]
  assign gpios_clock = clock;
  assign gpios_reset = reset;
  assign gpios_io_mem_addr = decoder_io_targets_1_addr; // @[TopWithSegmentLed.scala 47:25]
  assign gpios_io_mem_wen = decoder_io_targets_1_wen; // @[TopWithSegmentLed.scala 47:25]
  assign gpios_io_mem_wstrb = decoder_io_targets_1_wstrb; // @[TopWithSegmentLed.scala 47:25]
  assign gpios_io_mem_wdata = decoder_io_targets_1_wdata; // @[TopWithSegmentLed.scala 47:25]
  assign gpios_io_in_5 = io_switchIn; // @[TopWithSegmentLed.scala 71:15]
  assign uartRegs_io_mem_addr = decoder_io_targets_2_addr; // @[TopWithSegmentLed.scala 48:25]
  assign uartRegs_io_mem_ren = decoder_io_targets_2_ren; // @[TopWithSegmentLed.scala 48:25]
  assign uartRegs_io_mem_wen = decoder_io_targets_2_wen; // @[TopWithSegmentLed.scala 48:25]
  assign uartRegs_io_mem_wstrb = decoder_io_targets_2_wstrb; // @[TopWithSegmentLed.scala 48:25]
  assign uartRegs_io_mem_wdata = decoder_io_targets_2_wdata; // @[TopWithSegmentLed.scala 48:25]
  assign uartRegs_io_in_0_bits = {uartRegs_io_in_0_bits_hi,uartRegs_io_in_0_bits_lo}; // @[Cat.scala 33:92]
  assign uartRegs_io_in_1_bits = {uartRegs_io_in_1_bits_hi,uartTxValidReady_ready}; // @[Cat.scala 33:92]
  assign decoder_io_initiator_addr = core_io_dmem_addr; // @[TopWithSegmentLed.scala 44:16]
  assign decoder_io_initiator_ren = core_io_dmem_ren; // @[TopWithSegmentLed.scala 44:16]
  assign decoder_io_initiator_wen = core_io_dmem_wen; // @[TopWithSegmentLed.scala 44:16]
  assign decoder_io_initiator_wstrb = core_io_dmem_wstrb; // @[TopWithSegmentLed.scala 44:16]
  assign decoder_io_initiator_wdata = core_io_dmem_wdata; // @[TopWithSegmentLed.scala 44:16]
  assign decoder_io_targets_0_rdata = memory_io_dmem_rdata; // @[TopWithSegmentLed.scala 46:25]
  assign decoder_io_targets_0_rvalid = memory_io_dmem_rvalid; // @[TopWithSegmentLed.scala 46:25]
  assign decoder_io_targets_1_rdata = gpios_io_mem_rdata; // @[TopWithSegmentLed.scala 47:25]
  assign decoder_io_targets_2_rdata = uartRegs_io_mem_rdata; // @[TopWithSegmentLed.scala 48:25]
  assign decoder_io_targets_2_rvalid = uartRegs_io_mem_rvalid; // @[TopWithSegmentLed.scala 48:25]
  assign segmentLeds_clock = clock;
  assign segmentLeds_reset = reset;
  assign segmentLeds_io_digits_0 = gpios_io_out_0[7:0]; // @[TopWithSegmentLed.scala 54:69]
  assign segmentLeds_io_digits_1 = gpios_io_out_0[15:8]; // @[TopWithSegmentLed.scala 54:69]
  assign segmentLeds_io_digits_2 = gpios_io_out_0[23:16]; // @[TopWithSegmentLed.scala 54:69]
  assign segmentLeds_io_digits_3 = gpios_io_out_0[31:24]; // @[TopWithSegmentLed.scala 54:69]
  assign segmentLeds_io_digits_4 = gpios_io_out_1[7:0]; // @[TopWithSegmentLed.scala 54:125]
  assign segmentLeds_io_digits_5 = gpios_io_out_1[15:8]; // @[TopWithSegmentLed.scala 54:125]
  assign matrixLed_clock = clock;
  assign matrixLed_reset = reset;
  assign matrixLed_io_matrix_0 = gpios_io_out_2[7:0]; // @[TopWithSegmentLed.scala 60:67]
  assign matrixLed_io_matrix_1 = gpios_io_out_2[15:8]; // @[TopWithSegmentLed.scala 60:67]
  assign matrixLed_io_matrix_2 = gpios_io_out_2[23:16]; // @[TopWithSegmentLed.scala 60:67]
  assign matrixLed_io_matrix_3 = gpios_io_out_2[31:24]; // @[TopWithSegmentLed.scala 60:67]
  assign matrixLed_io_matrix_4 = gpios_io_out_3[7:0]; // @[TopWithSegmentLed.scala 60:123]
  assign matrixLed_io_matrix_5 = gpios_io_out_3[15:8]; // @[TopWithSegmentLed.scala 60:123]
  assign matrixLed_io_matrix_6 = gpios_io_out_3[23:16]; // @[TopWithSegmentLed.scala 60:123]
  assign matrixLed_io_matrix_7 = gpios_io_out_3[31:24]; // @[TopWithSegmentLed.scala 60:123]
  assign uartTx_clock = clock;
  assign uartTx_reset = reset;
  assign uartTx_io_in_valid = uartTxQueue_io_deq_valid; // @[TopWithSegmentLed.scala 80:16]
  assign uartTx_io_in_bits = uartTxQueue_io_deq_bits; // @[TopWithSegmentLed.scala 80:16]
  assign uartRx_clock = clock;
  assign uartRx_reset = reset;
  assign uartRx_io_out_ready = uartRxQueue_io_enq_ready; // @[Decoupled.scala 381:17]
  assign uartRx_io_rx = io_uartRx; // @[TopWithSegmentLed.scala 87:13]
  assign uartTxQueue_clock = clock;
  assign uartTxQueue_reset = reset;
  assign uartTxQueue_io_enq_valid = uartRegs_io_out_0_valid; // @[TopWithSegmentLed.scala 75:30 81:26]
  assign uartTxQueue_io_enq_bits = uartRegs_io_out_0_bits[7:0]; // @[TopWithSegmentLed.scala 75:30 82:25]
  assign uartTxQueue_io_deq_ready = uartTx_io_in_ready; // @[TopWithSegmentLed.scala 80:16]
  assign uartRxQueue_clock = clock;
  assign uartRxQueue_reset = reset;
  assign uartRxQueue_io_enq_valid = uartRx_io_out_valid; // @[Decoupled.scala 379:22]
  assign uartRxQueue_io_enq_bits = uartRx_io_out_bits; // @[Decoupled.scala 380:21]
  assign uartRxQueue_io_deq_ready = uartRegs_io_in_0_ready; // @[TopWithSegmentLed.scala 90:21]
  assign probe_clock = clock;
  assign probe_reset = reset;
  assign probe_io_in = {io_switchIn[0],core_io_debug_pc}; // @[Cat.scala 33:92]
  assign probe_io_out_ready = probeFrameAdapter_io_in_ready; // @[TopWithSegmentLed.scala 107:27]
  assign probe_io_trigger = noActivityCounter == 8'hff | ~io_switchIn[0]; // @[TopWithSegmentLed.scala 105:53]
  assign probeFrameAdapter_clock = clock;
  assign probeFrameAdapter_reset = reset;
  assign probeFrameAdapter_io_in_valid = probe_io_out_valid; // @[TopWithSegmentLed.scala 107:27]
  assign probeFrameAdapter_io_in_bits_data = probe_io_out_bits_data; // @[TopWithSegmentLed.scala 107:27]
  assign probeFrameAdapter_io_in_bits_last = probe_io_out_bits_last; // @[TopWithSegmentLed.scala 107:27]
  assign probeFrameAdapter_io_out_ready = probeUartTx_io_in_ready; // @[TopWithSegmentLed.scala 109:21]
  assign probeUartTx_clock = clock;
  assign probeUartTx_reset = reset;
  assign probeUartTx_io_in_valid = probeFrameAdapter_io_out_valid; // @[TopWithSegmentLed.scala 109:21]
  assign probeUartTx_io_in_bits = probeFrameAdapter_io_out_bits; // @[TopWithSegmentLed.scala 109:21]
  always @(posedge clock) begin
    if (reset) begin // @[TopWithSegmentLed.scala 99:34]
      noActivityCounter <= 8'h0; // @[TopWithSegmentLed.scala 99:34]
    end else if (gpios_io_mem_wen) begin // @[TopWithSegmentLed.scala 100:28]
      noActivityCounter <= 8'h0; // @[TopWithSegmentLed.scala 101:23]
    end else begin
      noActivityCounter <= _noActivityCounter_T_1; // @[TopWithSegmentLed.scala 103:23]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  noActivityCounter = _RAND_0[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
