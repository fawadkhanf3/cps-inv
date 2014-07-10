/*
 * inv.c
 *
 * Code generation for function 'inv'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman.h"
#include "kalman_4d.h"
#include "qp_vars.h"
#include "inv.h"

/* Function Definitions */
void inv(const real_T x[4], real_T y[4])
{
  real_T r;
  real_T t;
  if (fabs(x[1]) > fabs(x[0])) {
    r = x[0] / x[1];
    t = 1.0 / (r * x[3] - x[2]);
    y[0] = x[3] / x[1] * t;
    y[1] = -t;
    y[2] = -x[2] / x[1] * t;
    y[3] = r * t;
  } else {
    r = x[1] / x[0];
    t = 1.0 / (x[3] - r * x[2]);
    y[0] = x[3] / x[0] * t;
    y[1] = -r * t;
    y[2] = -x[2] / x[0] * t;
    y[3] = t;
  }
}

/* End of code generation (inv.c) */
