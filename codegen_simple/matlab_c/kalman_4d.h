/*
 * kalman_4d.h
 *
 * Code generation for function 'kalman_4d'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

#ifndef __KALMAN_4D_H__
#define __KALMAN_4D_H__
/* Include files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"

#include "rtwtypes.h"
#include "qp_vars_types.h"

/* Function Declarations */
extern void kalman_4d(const real_T x[4], const real_T P[16], const real_T y[2], real_T u, real_T dt, real_T x_next[4], real_T P_next[16]);
#endif
/* End of code generation (kalman_4d.h) */
