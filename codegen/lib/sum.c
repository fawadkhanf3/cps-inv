/*
 * sum.c
 *
 * Code generation for function 'sum'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman.h"
#include "kalman_4d.h"
#include "qp_vars.h"
#include "sum.h"

/* Function Definitions */
void sum(const real_T x[300], real_T y[30])
{
  int32_T iy;
  int32_T ixstart;
  int32_T j;
  int32_T ix;
  real_T s;
  int32_T k;
  iy = -1;
  ixstart = -1;
  for (j = 0; j < 30; j++) {
    ixstart++;
    ix = ixstart;
    s = x[ixstart];
    for (k = 0; k < 9; k++) {
      ix += 30;
      s += x[ix];
    }

    iy++;
    y[iy] = s;
  }
}

/* End of code generation (sum.c) */
