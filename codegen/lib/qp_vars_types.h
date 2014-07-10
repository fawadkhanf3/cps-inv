/*
 * qp_vars_types.h
 *
 * Code generation for function 'qp_vars'
 *
 * C source code generated on: Fri Jun 27 17:20:59 2014
 *
 */

#ifndef __QP_VARS_TYPES_H__
#define __QP_VARS_TYPES_H__

/* Include files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef typedef_b_struct_T
#define typedef_b_struct_T
typedef struct
{
    real_T A[84];
    real_T b[28];
} b_struct_T;
#endif /*typedef_b_struct_T*/
#ifndef typedef_c_struct_T
#define typedef_c_struct_T
typedef struct
{
    real_T A[87];
    real_T b[29];
} c_struct_T;
#endif /*typedef_c_struct_T*/
#ifndef typedef_d_struct_T
#define typedef_d_struct_T
typedef struct
{
    real_T A[9];
    real_T B[3];
    real_T E[3];
    real_T K[3];
    real_T XUA[16];
    real_T XUb[4];
    real_T XD_plus[4];
    real_T XD_minus[4];
    real_T domainA[21];
    real_T domainb[7];
} d_struct_T;
#endif /*typedef_d_struct_T*/
#ifndef typedef_e_struct_T
#define typedef_e_struct_T
typedef struct
{
    real_T A[9];
    real_T B[3];
    real_T E[3];
    real_T K[3];
    real_T XUA[16];
    real_T XUb[4];
    real_T XD_plus[4];
    real_T XD_minus[4];
    real_T domainA[24];
    real_T domainb[8];
} e_struct_T;
#endif /*typedef_e_struct_T*/
#ifndef struct_emxArray_real_T_30x10
#define struct_emxArray_real_T_30x10
struct emxArray_real_T_30x10
{
    real_T data[300];
    int32_T size[2];
};
#endif /*struct_emxArray_real_T_30x10*/
#ifndef typedef_emxArray_real_T_30x10
#define typedef_emxArray_real_T_30x10
typedef struct emxArray_real_T_30x10 emxArray_real_T_30x10;
#endif /*typedef_emxArray_real_T_30x10*/
#ifndef typedef_struct_T
#define typedef_struct_T
typedef struct
{
    real_T N;
    real_T scale_factor;
    real_T f0;
    real_T f1;
    real_T f2;
    real_T f0_bar;
    real_T f1_bar;
    real_T mass;
    real_T v_des;
    real_T h_des;
} struct_T;
#endif /*typedef_struct_T*/

#endif
/* End of code generation (qp_vars_types.h) */
