/*
 * repmat.h
 *
 * Code generation for function 'repmat'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

#ifndef __REPMAT_H__
#define __REPMAT_H__
/* Include files */
#include <math.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "rt_nonfinite.h"

#include "rtwtypes.h"
#include "qp_vars_types.h"

/* Function Declarations */
extern void b_repmat(const real_T a[4], real_T b[36]);
extern void c_repmat(const real_T a[29], real_T b[290]);
extern void repmat(const real_T a[3], real_T b[30]);
#endif
/* End of code generation (repmat.h) */
