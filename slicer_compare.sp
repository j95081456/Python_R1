*** slicer comparison: ***
*** conventional / hold time reduction / S&H / double tail ***
*** single-ended hold time reduction / S&H + S2D ***
*** items: ***
*** data window / CK2Q ***
.prot
.lib '/home/m111/m111061571/hspice/slicer_compare/cic018_v3.l' TT
.unprot
.option
+ post 
+ captab
+ ABSTOL=1E-7 RELTOT=1E-7 ACCURATE=6 delmax=1E-10
+ sim_mode=hspice
.option measform=1  *// 1: single line, 3: output .csv file //*
.option probe


**** parameter ****
.param VDD    = 1.2V
.temp 25
**** circuit ****
.inc '/home/m111/m111061571/hspice/slicer_compare/circuit.sp'
xsa_conv   vip_rc_conv vin_rc_conv ck     vop_conv von_conv vdd1 vss conventional_SA
xsa_htr    vip_rc_htr  vin_rc_htr  ck     vop_htr  von_htr  vdd2 vss HTR_SA
xsa_sh     vip_rc_sh   vin_rc_sh   ck ckb vop_sh   von_sh   vdd3 vss SH_SA
xsa_dbt    vip_rc_dbt  vin_rc_dbt  ck     vop_dbt  von_dbt  vdd6 vss DBT_SA

xsa_single vip2 vref ck     vop_single von_single vdd4 vss single_ended_SA
xsa_sh_s2d vip2      ck ckb vop_sh_s2d von_sh_s2d vdd5 vss SH_S2D_SA
**** input ****
VDD1 VDD1 0 VDD
VDD2 VDD2 0 VDD
VDD3 VDD3 0 VDD
VDD4 VDD4 0 VDD
VDD5 VDD5 0 VDD
VDD6 VDD6 0 VDD
VSS  VSS  0 0

.param vcm = 0.8V
Vprbs1   vip1 0 LFSR ('vcm - 0.2' 'vcm + 0.2' 5n 50p 50p 5G 10 [7, 6])
Vprbs1_b vin1 0 LFSR ('vcm + 0.2' 'vcm - 0.2' 5n 50p 50p 5G 10 [7, 6])

Vprbs2   vip2 0 LFSR (0 VDD 5n 50p 50p 5G 10 [7, 6])
Vprbs2_b vin2 0 LFSR (VDD 0 5n 50p 50p 5G 10 [7, 6])

.param res = 50
.param cap = 3p
R1 vip1 vip_rc_conv  res
C1 vip_rc_conv     0 cap
R2 vip1 vip_rc_htr   res
C2 vip_rc_htr      0 cap
R3 vip1 vip_rc_sh    res
C3 vip_rc_sh       0 cap
R6 vip1 vip_rc_dbt   res
C6 vip_rc_dbt      0 cap

R1_b vin1 vin_rc_conv  res
C1_b vin_rc_conv     0 cap
R2_b vin1 vin_rc_htr   res
C2_b vin_rc_htr      0 cap
R3_b vin1 vin_rc_sh    res
C3_b vin_rc_sh       0 cap
R6_b vin1 vin_rc_dbt   res
C6_b vin_rc_dbt      0 cap

Vref vref 0 0.8

.param td = 1.2n
Vck  ck  0 pulse 0 VDD td 50p 50p 350p 800p
Vckb ckb 0 pulse VDD 0 td 50p 50p 350p 800p 
*--------------measure---------------*
.inc '/home/m111/m111061571/hspice/slicer_compare/measure.sp'

.op
.ic V(vop_conv) = 0
.ic V(von_conv) = VDD
.ic V(vop_htr ) = 0
.ic V(von_htr ) = VDD
.ic V(vop_sh  ) = 0
.ic V(von_sh  ) = VDD
.ic V(vop_dbt ) = 0
.ic V(von_dbt ) = VDD
.ic V(vop_single) = 0
.ic V(von_single) = VDD
.ic V(vop_sh_s2d) = 0
.ic V(von_sh_s2d) = VDD

.param sim_type = 2 *// 0: single, 1: all_corner, 2: CK2Q //*

.if (sim_type == 0)
 .param sim_time = 30n
 .tr 0.01p sim_time
 .probe V(vop_conv, von_conv) V(vop_htr, von_htr) V(vop_sh, von_sh) V(vop_dbt, von_dpt) V(vop_single, von_single) V(vop_sh_s2d, von_sh_s2d)
 .probe I(VDD1) I(VDD2) I(VDD3) I(VDD4) I(VDD5) I(VDD6)
 .probe V(*)
.elseif (sim_type == 1)
 .param sim_time = 70n
 .tr 0.01p sim_time sweep td lin 201 0.9n 1.3n
 .probe V(vop_conv, von_conv) V(vop_htr, von_htr) V(vop_sh, von_sh) V(vop_dbt, von_dpt) V(vop_single, von_single) V(vop_sh_s2d, von_sh_s2d)
 .probe I(VDD1) I(VDD2) I(VDD3) I(VDD4) I(VDD5) I(VDD6)
.else
 .param sim_time = 70n
 .tr 0.01p sim_time sweep td lin 11 0.9n 1.3n
 .probe V(vop_conv, von_conv) V(vop_htr, von_htr) V(vop_sh, von_sh) V(vop_dbt, von_dpt) V(vop_single, von_single) V(vop_sh_s2d, von_sh_s2d)
 .probe V(xsa_conv.ck_buf)    V(xsa_htr.ck_buf)   V(xsa_sh.ck_buf)  V(xsa_dbt.ck_buf)   V(xsa_single.ck_buf)      V(xsa_sh_s2d.ck_d)
 .probe I(VDD1) I(VDD2) I(VDD3) I(VDD4) I(VDD5) I(VDD6)
.endif

*.inc '/home/m111/m111061571/hspice/slicer_compare/corner.txt'

.end