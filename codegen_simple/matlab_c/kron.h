/*
 * kron.h
 *
 * Code generation for function 'kron'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

#ifndef __KRON_H__
#define __KRON_H__
/* Include files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"

#include "rtwtypes.h"
#include "qp_vars_types.h"

/* Function Declarations */
extern void b_kron(const real_T A_data[100], const int32_T A_size[2], const real_T B[3], real_T K_data[300], int32_T K_size[2]);
extern void c_kron(const real_T A[81], const real_T B[12], real_T K[972]);
extern void d_kron(const real_T A[81], const real_T B[4], real_T K[324]);
extern void e_kron(const real_T A[100], const real_T B[87], real_T K[8700]);
extern void kron(const real_T A[100], const real_T B[9], real_T K[900]);
#endif
/* End of code generation (kron.h) */
