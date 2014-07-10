/*
 * repmat.c
 *
 * Code generation for function 'repmat'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman.h"
#include "kalman_4d.h"
#include "qp_vars.h"
#include "repmat.h"

/* Function Definitions */
void b_repmat(const real_T a[4], real_T b[36])
{
  int32_T ib;
  int32_T itilerow;
  int32_T ia;
  int32_T k;
  ib = 0;
  for (itilerow = 0; itilerow < 9; itilerow++) {
    ia = 0;
    for (k = 0; k < 4; k++) {
      b[ib] = a[ia];
      ia++;
      ib++;
    }
  }
}

void c_repmat(const real_T a[29], real_T b[290])
{
  int32_T ib;
  int32_T itilerow;
  int32_T ia;
  int32_T k;
  ib = 0;
  for (itilerow = 0; itilerow < 10; itilerow++) {
    ia = 0;
    for (k = 0; k < 29; k++) {
      b[ib] = a[ia];
      ia++;
      ib++;
    }
  }
}

void repmat(const real_T a[3], real_T b[30])
{
  int32_T ib;
  int32_T itilerow;
  int32_T ia;
  int32_T k;
  ib = 0;
  for (itilerow = 0; itilerow < 10; itilerow++) {
    ia = 0;
    for (k = 0; k < 3; k++) {
      b[ib] = a[ia];
      ia++;
      ib++;
    }
  }
}

/* End of code generation (repmat.c) */
