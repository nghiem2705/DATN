/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_69(char*, char *);
extern void execute_70(char*, char *);
extern void execute_340(char*, char *);
extern void execute_341(char*, char *);
extern void execute_3(char*, char *);
extern void vlog_const_rhs_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_318(char*, char *);
extern void execute_319(char*, char *);
extern void execute_320(char*, char *);
extern void execute_321(char*, char *);
extern void execute_322(char*, char *);
extern void execute_323(char*, char *);
extern void execute_324(char*, char *);
extern void execute_325(char*, char *);
extern void execute_326(char*, char *);
extern void execute_327(char*, char *);
extern void execute_328(char*, char *);
extern void execute_329(char*, char *);
extern void execute_330(char*, char *);
extern void execute_331(char*, char *);
extern void execute_332(char*, char *);
extern void execute_333(char*, char *);
extern void execute_334(char*, char *);
extern void execute_335(char*, char *);
extern void execute_336(char*, char *);
extern void execute_337(char*, char *);
extern void execute_338(char*, char *);
extern void execute_339(char*, char *);
extern void execute_75(char*, char *);
extern void execute_76(char*, char *);
extern void vlog_timingcheck_execute_0(char*, char*, char*);
extern void execute_79(char*, char *);
extern void execute_6(char*, char *);
extern void execute_80(char*, char *);
extern void execute_10(char*, char *);
extern void execute_82(char*, char *);
extern void execute_83(char*, char *);
extern void execute_84(char*, char *);
extern void execute_13(char*, char *);
extern void execute_14(char*, char *);
extern void execute_85(char*, char *);
extern void vlog_simple_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_92(char*, char *);
extern void execute_93(char*, char *);
extern void execute_18(char*, char *);
extern void execute_88(char*, char *);
extern void execute_89(char*, char *);
extern void execute_90(char*, char *);
extern void execute_91(char*, char *);
extern void execute_87(char*, char *);
extern void execute_100(char*, char *);
extern void execute_101(char*, char *);
extern void execute_111(char*, char *);
extern void execute_112(char*, char *);
extern void execute_113(char*, char *);
extern void execute_29(char*, char *);
extern void execute_109(char*, char *);
extern void execute_110(char*, char *);
extern void execute_108(char*, char *);
extern void execute_123(char*, char *);
extern void execute_124(char*, char *);
extern void execute_125(char*, char *);
extern void execute_38(char*, char *);
extern void execute_39(char*, char *);
extern void execute_40(char*, char *);
extern void execute_41(char*, char *);
extern void execute_126(char*, char *);
extern void execute_127(char*, char *);
extern void execute_128(char*, char *);
extern void execute_129(char*, char *);
extern void execute_130(char*, char *);
extern void execute_131(char*, char *);
extern void execute_132(char*, char *);
extern void execute_133(char*, char *);
extern void execute_134(char*, char *);
extern void execute_135(char*, char *);
extern void execute_136(char*, char *);
extern void execute_137(char*, char *);
extern void execute_138(char*, char *);
extern void execute_139(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_1(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_2(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_79(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_80(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_81(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_82(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_83(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_84(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_85(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_86(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_87(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_88(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_89(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_90(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_91(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_92(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_93(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_94(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_95(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_96(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_97(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_98(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_99(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_100(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_101(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_102(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_27(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_28(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_29(char*, char *);
extern void timing_checker_condition_m_17764a0e_67151b0a_30(char*, char *);
extern void execute_158(char*, char *);
extern void execute_163(char*, char *);
extern void execute_164(char*, char *);
extern void execute_165(char*, char *);
extern void execute_166(char*, char *);
extern void execute_72(char*, char *);
extern void execute_73(char*, char *);
extern void execute_74(char*, char *);
extern void execute_342(char*, char *);
extern void execute_343(char*, char *);
extern void execute_344(char*, char *);
extern void execute_345(char*, char *);
extern void execute_346(char*, char *);
extern void transaction_2(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_3(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_4(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_5(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_6(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_7(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_12(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_13(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_14(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_15(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_16(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_17(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_18(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_19(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_20(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_21(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_22(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_23(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_24(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_25(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_26(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_27(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_28(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_29(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_30(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_31(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_32(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_33(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_34(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_35(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_36(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_37(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_38(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_39(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_40(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_41(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_42(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_59(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_60(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_61(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_67(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_68(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_69(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_75(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_76(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_77(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_78(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_79(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_88(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_89(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_90(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_91(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_92(char*, char*, unsigned, unsigned, unsigned);
extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
extern void transaction_108(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_134(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_160(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_186(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[181] = {(funcp)execute_69, (funcp)execute_70, (funcp)execute_340, (funcp)execute_341, (funcp)execute_3, (funcp)vlog_const_rhs_process_execute_0_fast_no_reg_no_agg, (funcp)execute_318, (funcp)execute_319, (funcp)execute_320, (funcp)execute_321, (funcp)execute_322, (funcp)execute_323, (funcp)execute_324, (funcp)execute_325, (funcp)execute_326, (funcp)execute_327, (funcp)execute_328, (funcp)execute_329, (funcp)execute_330, (funcp)execute_331, (funcp)execute_332, (funcp)execute_333, (funcp)execute_334, (funcp)execute_335, (funcp)execute_336, (funcp)execute_337, (funcp)execute_338, (funcp)execute_339, (funcp)execute_75, (funcp)execute_76, (funcp)vlog_timingcheck_execute_0, (funcp)execute_79, (funcp)execute_6, (funcp)execute_80, (funcp)execute_10, (funcp)execute_82, (funcp)execute_83, (funcp)execute_84, (funcp)execute_13, (funcp)execute_14, (funcp)execute_85, (funcp)vlog_simple_process_execute_0_fast_no_reg_no_agg, (funcp)execute_92, (funcp)execute_93, (funcp)execute_18, (funcp)execute_88, (funcp)execute_89, (funcp)execute_90, (funcp)execute_91, (funcp)execute_87, (funcp)execute_100, (funcp)execute_101, (funcp)execute_111, (funcp)execute_112, (funcp)execute_113, (funcp)execute_29, (funcp)execute_109, (funcp)execute_110, (funcp)execute_108, (funcp)execute_123, (funcp)execute_124, (funcp)execute_125, (funcp)execute_38, (funcp)execute_39, (funcp)execute_40, (funcp)execute_41, (funcp)execute_126, (funcp)execute_127, (funcp)execute_128, (funcp)execute_129, (funcp)execute_130, (funcp)execute_131, (funcp)execute_132, (funcp)execute_133, (funcp)execute_134, (funcp)execute_135, (funcp)execute_136, (funcp)execute_137, (funcp)execute_138, (funcp)execute_139, (funcp)timing_checker_condition_m_17764a0e_67151b0a_1, (funcp)timing_checker_condition_m_17764a0e_67151b0a_2, (funcp)timing_checker_condition_m_17764a0e_67151b0a_79, (funcp)timing_checker_condition_m_17764a0e_67151b0a_80, (funcp)timing_checker_condition_m_17764a0e_67151b0a_81, (funcp)timing_checker_condition_m_17764a0e_67151b0a_82, (funcp)timing_checker_condition_m_17764a0e_67151b0a_83, (funcp)timing_checker_condition_m_17764a0e_67151b0a_84, (funcp)timing_checker_condition_m_17764a0e_67151b0a_85, (funcp)timing_checker_condition_m_17764a0e_67151b0a_86, (funcp)timing_checker_condition_m_17764a0e_67151b0a_87, (funcp)timing_checker_condition_m_17764a0e_67151b0a_88, (funcp)timing_checker_condition_m_17764a0e_67151b0a_89, (funcp)timing_checker_condition_m_17764a0e_67151b0a_90, (funcp)timing_checker_condition_m_17764a0e_67151b0a_91, (funcp)timing_checker_condition_m_17764a0e_67151b0a_92, (funcp)timing_checker_condition_m_17764a0e_67151b0a_93, (funcp)timing_checker_condition_m_17764a0e_67151b0a_94, (funcp)timing_checker_condition_m_17764a0e_67151b0a_95, (funcp)timing_checker_condition_m_17764a0e_67151b0a_96, (funcp)timing_checker_condition_m_17764a0e_67151b0a_97, (funcp)timing_checker_condition_m_17764a0e_67151b0a_98, (funcp)timing_checker_condition_m_17764a0e_67151b0a_99, (funcp)timing_checker_condition_m_17764a0e_67151b0a_100, (funcp)timing_checker_condition_m_17764a0e_67151b0a_101, (funcp)timing_checker_condition_m_17764a0e_67151b0a_102, (funcp)timing_checker_condition_m_17764a0e_67151b0a_27, (funcp)timing_checker_condition_m_17764a0e_67151b0a_28, (funcp)timing_checker_condition_m_17764a0e_67151b0a_29, (funcp)timing_checker_condition_m_17764a0e_67151b0a_30, (funcp)execute_158, (funcp)execute_163, (funcp)execute_164, (funcp)execute_165, (funcp)execute_166, (funcp)execute_72, (funcp)execute_73, (funcp)execute_74, (funcp)execute_342, (funcp)execute_343, (funcp)execute_344, (funcp)execute_345, (funcp)execute_346, (funcp)transaction_2, (funcp)transaction_3, (funcp)transaction_4, (funcp)transaction_5, (funcp)transaction_6, (funcp)transaction_7, (funcp)transaction_12, (funcp)transaction_13, (funcp)transaction_14, (funcp)transaction_15, (funcp)transaction_16, (funcp)transaction_17, (funcp)transaction_18, (funcp)transaction_19, (funcp)transaction_20, (funcp)transaction_21, (funcp)transaction_22, (funcp)transaction_23, (funcp)transaction_24, (funcp)transaction_25, (funcp)transaction_26, (funcp)transaction_27, (funcp)transaction_28, (funcp)transaction_29, (funcp)transaction_30, (funcp)transaction_31, (funcp)transaction_32, (funcp)transaction_33, (funcp)transaction_34, (funcp)transaction_35, (funcp)transaction_36, (funcp)transaction_37, (funcp)transaction_38, (funcp)transaction_39, (funcp)transaction_40, (funcp)transaction_41, (funcp)transaction_42, (funcp)transaction_59, (funcp)transaction_60, (funcp)transaction_61, (funcp)transaction_67, (funcp)transaction_68, (funcp)transaction_69, (funcp)transaction_75, (funcp)transaction_76, (funcp)transaction_77, (funcp)transaction_78, (funcp)transaction_79, (funcp)transaction_88, (funcp)transaction_89, (funcp)transaction_90, (funcp)transaction_91, (funcp)transaction_92, (funcp)vlog_transfunc_eventcallback, (funcp)transaction_108, (funcp)transaction_134, (funcp)transaction_160, (funcp)transaction_186};
const int NumRelocateId= 181;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/s_trng_tb_time_impl/xsim.reloc",  (void **)funcTab, 181);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/s_trng_tb_time_impl/xsim.reloc");
}

void simulate(char *dp)
{
	iki_schedule_processes_at_time_zero(dp, "xsim.dir/s_trng_tb_time_impl/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstatiate();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/s_trng_tb_time_impl/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/s_trng_tb_time_impl/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/s_trng_tb_time_impl/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
