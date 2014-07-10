/*
 * kron.c
 *
 * Code generation for function 'kron'
 *
 * C source code generated on: Fri Jun 27 17:21:00 2014
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman.h"
#include "kalman_4d.h"
#include "qp_vars.h"
#include "kron.h"

/* Function Definitions */
void b_kron(const real_T A_data[100], const int32_T A_size[2], const real_T B[3],
            real_T K_data[300], int32_T K_size[2])
{
  int32_T kidx;
  int32_T b_j1;
  int32_T i1;
  int32_T i2;
  K_size[0] = (int8_T)(A_size[0] * 3);
  K_size[1] = (int8_T)A_size[1];
  kidx = -1;
  for (b_j1 = 1; b_j1 <= A_size[1]; b_j1++) {
    for (i1 = 1; i1 <= A_size[0]; i1++) {
      for (i2 = 0; i2 < 3; i2++) {
        kidx++;
        K_data[kidx] = A_data[(i1 + A_size[0] * (b_j1 - 1)) - 1] * B[i2];
      }
    }
  }
}

void c_kron(const real_T A[81], const real_T B[12], real_T K[972])
{
  int32_T kidx;
  int32_T b_j1;
  int32_T j2;
  int32_T i1;
  int32_T i2;
  kidx = -1;
  for (b_j1 = 0; b_j1 < 9; b_j1++) {
    for (j2 = 0; j2 < 3; j2++) {
      for (i1 = 0; i1 < 9; i1++) {
        for (i2 = 0; i2 < 4; i2++) {
          kidx++;
          K[kidx] = A[i1 + 9 * b_j1] * B[i2 + (j2 << 2)];
        }
      }
    }
  }
}

void d_kron(const real_T A[81], const real_T B[4], real_T K[324])
{
  int32_T kidx;
  int32_T b_j1;
  int32_T i1;
  int32_T i2;
  kidx = -1;
  for (b_j1 = 0; b_j1 < 9; b_j1++) {
    for (i1 = 0; i1 < 9; i1++) {
      for (i2 = 0; i2 < 4; i2++) {
        kidx++;
        K[kidx] = A[i1 + 9 * b_j1] * B[i2];
      }
    }
  }
}

void e_kron(const real_T A[100], const real_T B[87], real_T K[8700])
{
  int32_T kidx;
  int32_T b_j1;
  int32_T j2;
  int32_T i1;
  int32_T i2;
  kidx = -1;
  for (b_j1 = 0; b_j1 < 10; b_j1++) {
    for (j2 = 0; j2 < 3; j2++) {
      for (i1 = 0; i1 < 10; i1++) {
        for (i2 = 0; i2 < 29; i2++) {
          kidx++;
          K[kidx] = A[i1 + 10 * b_j1] * B[i2 + 29 * j2];
        }
      }
    }
  }
}

void kron(const real_T A[100], const real_T B[9], real_T K[900])
{
  int32_T kidx;
  int32_T b_j1;
  int32_T j2;
  int32_T i1;
  int32_T i2;
  kidx = -1;
  for (b_j1 = 0; b_j1 < 10; b_j1++) {
    for (j2 = 0; j2 < 3; j2++) {
      for (i1 = 0; i1 < 10; i1++) {
        for (i2 = 0; i2 < 3; i2++) {
          kidx++;
          K[kidx] = A[i1 + 10 * b_j1] * B[i2 + 3 * j2];
        }
      }
    }
  }
}

/* End of code generation (kron.c) */
