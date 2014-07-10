/*
 * eye.c
 *
 * Code generation for function 'eye'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman.h"
#include "kalman_4d.h"
#include "qp_vars.h"
#include "eye.h"

/* Function Definitions */
void eye(real_T n, real_T I_data[100], int32_T I_size[2])
{
  int32_T loop_ub;
  int32_T i3;
  real_T minval;
  I_size[0] = (int32_T)n;
  I_size[1] = (int32_T)n;
  loop_ub = (int32_T)n * (int32_T)n;
  for (i3 = 0; i3 < loop_ub; i3++) {
    I_data[i3] = 0.0;
  }

  if ((n <= n) || rtIsNaN(n)) {
    minval = n;
  } else {
    minval = n;
  }

  for (loop_ub = 0; loop_ub + 1 <= (int32_T)minval; loop_ub++) {
    I_data[loop_ub + (int32_T)n * loop_ub] = 1.0;
  }
}

/* End of code generation (eye.c) */
