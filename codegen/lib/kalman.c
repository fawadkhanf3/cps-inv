/*
 * kalman.c
 *
 * Code generation for function 'kalman'
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
void kalman(const real_T x[3], const real_T P[9], const real_T y[2], real_T u,
            real_T dt, real_T x_next[3], real_T P_next[9])
{
  real_T ekt;
  real_T A[9];
  int32_T i4;
  static const int8_T iv3[3] = { 0, 0, 1 };

  real_T v[3];
  real_T Q[9];
  real_T b_y;
  real_T b_A[9];
  int32_T j;
  int32_T i5;
  real_T P_next_pred[9];
  real_T d0;
  real_T a[6];
  static const int8_T b_a[6] = { 1, 0, 0, 1, 0, 0 };

  real_T c_a[4];
  static const int8_T b[6] = { 1, 0, 0, 0, 1, 0 };

  static const int8_T b_b[4] = { 1, 0, 0, 1 };

  real_T c_b[4];
  real_T dv18[3];
  real_T dv19[3];
  real_T dv20[6];
  real_T dv21[2];
  real_T dv22[3];
  real_T gain[6];

  /*  */
  /*  Model: x(k+1) = Ax(k) + Bu(k) + K + w */
  /*         y(k) = C*x(k) + v */
  /*   where w ~ N(0,Q), v ~ N(0,R) */
  /*   */
  /*  Calculate discrete dynamics (depends on dt!) */
  ekt = exp(-0.55126791620727666 * dt);
  A[0] = ekt;
  A[3] = 0.0;
  A[6] = 0.0;
  A[1] = (ekt - 1.0) / 0.55126791620727666;
  A[4] = 1.0;
  A[7] = dt;
  for (i4 = 0; i4 < 3; i4++) {
    A[2 + 3 * i4] = iv3[i4];
  }

  v[0] = 0.0;
  v[1] = 0.0;
  v[2] = 3.0 * dt;
  memset(&Q[0], 0, 9U * sizeof(real_T));
  b_y = 0.5 * dt;

  /*  Do Kalman updates */
  for (j = 0; j < 3; j++) {
    Q[j + 3 * j] = v[j];
    for (i4 = 0; i4 < 3; i4++) {
      b_A[j + 3 * i4] = 0.0;
      for (i5 = 0; i5 < 3; i5++) {
        b_A[j + 3 * i4] += A[j + 3 * i5] * P[i5 + 3 * i4];
      }
    }
  }

  for (i4 = 0; i4 < 3; i4++) {
    for (i5 = 0; i5 < 3; i5++) {
      d0 = 0.0;
      for (j = 0; j < 3; j++) {
        d0 += b_A[i4 + 3 * j] * A[i5 + 3 * j];
      }

      P_next_pred[i4 + 3 * i5] = d0 + Q[i4 + 3 * i5];
    }
  }

  for (i4 = 0; i4 < 2; i4++) {
    for (i5 = 0; i5 < 3; i5++) {
      a[i4 + (i5 << 1)] = 0.0;
      for (j = 0; j < 3; j++) {
        a[i4 + (i5 << 1)] += (real_T)b_a[i4 + (j << 1)] * P_next_pred[j + 3 * i5];
      }
    }
  }

  for (i4 = 0; i4 < 2; i4++) {
    for (i5 = 0; i5 < 2; i5++) {
      d0 = 0.0;
      for (j = 0; j < 3; j++) {
        d0 += a[i4 + (j << 1)] * (real_T)b[j + 3 * i5];
      }

      c_a[i4 + (i5 << 1)] = d0 + b_y * (real_T)b_b[i4 + (i5 << 1)];
    }
  }

  inv(c_a, c_b);
  dv18[0] = 0.1814 * (ekt - 1.0);
  dv18[1] = 0.03628 * (dt * 5.0 + 9.07 * (ekt - 1.0));
  dv18[2] = 0.0;
  dv19[0] = 5.0 * (1.0 - ekt);
  dv19[1] = 9.07 * (1.0 - ekt) - dt * 5.0;
  dv19[2] = 0.0;
  dv21[0] = 1.0;
  dv21[1] = u;
  for (i4 = 0; i4 < 3; i4++) {
    for (i5 = 0; i5 < 2; i5++) {
      a[i4 + 3 * i5] = 0.0;
      for (j = 0; j < 3; j++) {
        a[i4 + 3 * i5] += P_next_pred[i4 + 3 * j] * (real_T)b[j + 3 * i5];
      }
    }

    for (i5 = 0; i5 < 2; i5++) {
      gain[i4 + 3 * i5] = 0.0;
      for (j = 0; j < 2; j++) {
        gain[i4 + 3 * i5] += a[i4 + 3 * j] * c_b[j + (i5 << 1)];
      }
    }

    dv20[i4] = dv18[i4];
    dv20[3 + i4] = 0.04 * dv19[i4];
    v[i4] = 0.0;
    for (i5 = 0; i5 < 3; i5++) {
      v[i4] += A[i4 + 3 * i5] * x[i5];
    }

    dv22[i4] = 0.0;
    for (i5 = 0; i5 < 2; i5++) {
      dv22[i4] += dv20[i4 + 3 * i5] * dv21[i5];
    }
  }

  for (i4 = 0; i4 < 3; i4++) {
    d0 = 0.0;
    for (i5 = 0; i5 < 2; i5++) {
      d0 += gain[i4 + 3 * i5] * y[i5];
    }

    x_next[i4] = (v[i4] + dv22[i4]) - d0;
  }

  memset(&A[0], 0, 9U * sizeof(real_T));
  for (j = 0; j < 3; j++) {
    A[j + 3 * j] = 1.0;
  }

  for (i4 = 0; i4 < 3; i4++) {
    for (i5 = 0; i5 < 3; i5++) {
      d0 = 0.0;
      for (j = 0; j < 2; j++) {
        d0 += gain[i4 + 3 * j] * (real_T)b_a[j + (i5 << 1)];
      }

      b_A[i4 + 3 * i5] = A[i4 + 3 * i5] - d0;
    }
  }

  for (i4 = 0; i4 < 3; i4++) {
    for (i5 = 0; i5 < 3; i5++) {
      P_next[i4 + 3 * i5] = 0.0;
      for (j = 0; j < 3; j++) {
        P_next[i4 + 3 * i5] += b_A[i4 + 3 * j] * P_next_pred[j + 3 * i5];
      }
    }
  }
}

/* End of code generation (kalman.c) */
