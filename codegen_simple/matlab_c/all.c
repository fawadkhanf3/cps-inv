/*
 * all.c
 *
 * Code generation for function 'all'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman.h"
#include "kalman_4d.h"
#include "qp_vars.h"
#include "all.h"

/* Function Definitions */
boolean_T all(const boolean_T x[8])
{
  boolean_T y;
  int32_T k;
  boolean_T exitg1;
  y = TRUE;
  k = 0;
  exitg1 = FALSE;
  while ((exitg1 == FALSE) && (k < 8)) {
    if (x[k] == 0) {
      y = FALSE;
      exitg1 = TRUE;
    } else {
      k++;
    }
  }

  return y;
}

boolean_T b_all(const boolean_T x[7])
{
  boolean_T y;
  int32_T k;
  boolean_T exitg1;
  y = TRUE;
  k = 0;
  exitg1 = FALSE;
  while ((exitg1 == FALSE) && (k < 7)) {
    if (x[k] == 0) {
      y = FALSE;
      exitg1 = TRUE;
    } else {
      k++;
    }
  }

  return y;
}

boolean_T c_all(const boolean_T x[28])
{
  boolean_T y;
  int32_T k;
  boolean_T exitg1;
  y = TRUE;
  k = 0;
  exitg1 = FALSE;
  while ((exitg1 == FALSE) && (k < 28)) {
    if (x[k] == 0) {
      y = FALSE;
      exitg1 = TRUE;
    } else {
      k++;
    }
  }

  return y;
}

boolean_T d_all(const boolean_T x[29])
{
  boolean_T y;
  int32_T k;
  boolean_T exitg1;
  y = TRUE;
  k = 0;
  exitg1 = FALSE;
  while ((exitg1 == FALSE) && (k < 29)) {
    if (x[k] == 0) {
      y = FALSE;
      exitg1 = TRUE;
    } else {
      k++;
    }
  }

  return y;
}

/* End of code generation (all.c) */
