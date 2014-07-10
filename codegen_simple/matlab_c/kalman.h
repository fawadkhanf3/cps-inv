/*
 * kalman.h
 *
 * Code generation for function 'kalman'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

#ifndef __KALMAN_H__
#define __KALMAN_H__
/* Include files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"

#include "rtwtypes.h"
#include "qp_vars_types.h"

/* Function Declarations */
extern void kalman(const real_T x[3], const real_T P[9], const real_T y[2], real_T u, real_T dt, real_T x_next[3], real_T P_next[9]);
#endif
/* End of code generation (kalman.h) */
