/*
 * kalman_4d.c
 *
 * Code generation for function 'kalman_4d'
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

/* Function Declarations */
static real_T rt_powd_snf(real_T u0, real_T u1);

/* Function Definitions */
static real_T rt_powd_snf(real_T u0, real_T u1)
{
  real_T y;
  real_T d2;
  real_T d3;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = rtNaN;
  } else {
    d2 = fabs(u0);
    d3 = fabs(u1);
    if (rtIsInf(u1)) {
      if (d2 == 1.0) {
        y = rtNaN;
      } else if (d2 > 1.0) {
        if (u1 > 0.0) {
          y = rtInf;
        } else {
          y = 0.0;
        }
      } else if (u1 > 0.0) {
        y = 0.0;
      } else {
        y = rtInf;
      }
    } else if (d3 == 0.0) {
      y = 1.0;
    } else if (d3 == 1.0) {
      if (u1 > 0.0) {
        y = u0;
      } else {
        y = 1.0 / u0;
      }
    } else if (u1 == 2.0) {
      y = u0 * u0;
    } else if ((u1 == 0.5) && (u0 >= 0.0)) {
      y = sqrt(u0);
    } else if ((u0 < 0.0) && (u1 > floor(u1))) {
      y = rtNaN;
    } else {
      y = pow(u0, u1);
    }
  }

  return y;
}

void kalman_4d(const real_T x[4], const real_T P[16], const real_T y[2], real_T
               u, real_T dt, real_T x_next[4], real_T P_next[16])
{
  real_T ekt;
  real_T A[16];
  int32_T i;
  static const int8_T iv4[4] = { 0, 0, 0, 1 };

  real_T qvec[4];
  real_T b_y;
  real_T a[4];
  real_T b_A[4];
  real_T d1;
  int32_T i6;
  real_T dv23[4];
  real_T c_A[16];
  real_T d_A[16];
  real_T x_next_pred[4];
  real_T b_qvec[16];
  int32_T i7;
  real_T P_next_pred[16];
  real_T b_a[8];
  static const int8_T c_a[8] = { 1, 0, 0, 1, 0, 0, 0, 0 };

  static const int8_T b[8] = { 1, 0, 0, 0, 0, 1, 0, 0 };

  static const int8_T b_b[4] = { 1, 0, 0, 1 };

  real_T gain[8];
  real_T c_y[2];

  /*  */
  /*  Model: x(k+1) = Ax(k) + Bu(k) + K + w */
  /*         y(k) = C*x(k) + v */
  /*   where w ~ N(0,Q), v ~ N(0,R) */
  /*   */
  /*  load some constants */
  /*  Calculate discrete dynamics (depends on dt!) */
  ekt = exp(-0.55126791620727666 * dt);
  A[0] = ekt;
  A[4] = 0.0;
  A[8] = 0.0;
  A[12] = 0.0;
  A[1] = (ekt - 1.0) / 0.55126791620727666;
  A[5] = 1.0;
  A[9] = dt;
  A[13] = dt * dt / 2.0;
  A[2] = 0.0;
  A[6] = 0.0;
  A[10] = 1.0;
  A[14] = dt;
  for (i = 0; i < 4; i++) {
    A[3 + (i << 2)] = iv4[i];
  }

  /*  Q = diag([0 dt^3/3 dt^2/2 dt]); */
  qvec[0] = 0.0;
  qvec[1] = sqrt(rt_powd_snf(dt, 3.0) / 3.0);
  qvec[2] = sqrt(dt * dt / 2.0);
  qvec[3] = sqrt(dt);
  b_y = 0.1 * dt;

  /*  Do Kalman updates */
  a[0] = 5.0 * (1.0 - ekt);
  a[1] = 9.07 * (1.0 - ekt) - dt * 5.0;
  a[2] = 0.0;
  a[3] = 0.0;
  for (i = 0; i < 4; i++) {
    d1 = 0.0;
    for (i6 = 0; i6 < 4; i6++) {
      d1 += A[i + (i6 << 2)] * x[i6];
    }

    b_A[i] = d1 + 0.04 * a[i] * u;
  }

  dv23[0] = 0.1814 * (ekt - 1.0);
  dv23[1] = 0.03628 * (dt * 5.0 + 9.07 * (ekt - 1.0));
  dv23[2] = 0.0;
  dv23[3] = 0.0;
  for (i = 0; i < 4; i++) {
    x_next_pred[i] = b_A[i] + dv23[i];
    for (i6 = 0; i6 < 4; i6++) {
      c_A[i + (i6 << 2)] = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        c_A[i + (i6 << 2)] += A[i + (i7 << 2)] * P[i7 + (i6 << 2)];
      }
    }

    for (i6 = 0; i6 < 4; i6++) {
      d_A[i + (i6 << 2)] = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        d_A[i + (i6 << 2)] += c_A[i + (i7 << 2)] * A[i6 + (i7 << 2)];
      }

      b_qvec[i + (i6 << 2)] = qvec[i] * qvec[i6];
    }
  }

  for (i = 0; i < 4; i++) {
    for (i6 = 0; i6 < 4; i6++) {
      P_next_pred[i6 + (i << 2)] = d_A[i6 + (i << 2)] + b_qvec[i6 + (i << 2)];
    }
  }

  for (i = 0; i < 2; i++) {
    for (i6 = 0; i6 < 4; i6++) {
      b_a[i + (i6 << 1)] = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        b_a[i + (i6 << 1)] += (real_T)c_a[i + (i7 << 1)] * P_next_pred[i7 + (i6 <<
          2)];
      }
    }
  }

  for (i = 0; i < 2; i++) {
    for (i6 = 0; i6 < 2; i6++) {
      d1 = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        d1 += b_a[i + (i7 << 1)] * (real_T)b[i7 + (i6 << 2)];
      }

      a[i + (i6 << 1)] = d1 + b_y * (real_T)b_b[i + (i6 << 1)];
    }
  }

  inv(a, qvec);
  for (i = 0; i < 4; i++) {
    for (i6 = 0; i6 < 2; i6++) {
      b_a[i + (i6 << 2)] = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        b_a[i + (i6 << 2)] += P_next_pred[i + (i7 << 2)] * (real_T)b[i7 + (i6 <<
          2)];
      }
    }

    for (i6 = 0; i6 < 2; i6++) {
      gain[i + (i6 << 2)] = 0.0;
      for (i7 = 0; i7 < 2; i7++) {
        gain[i + (i6 << 2)] += b_a[i + (i7 << 2)] * qvec[i7 + (i6 << 1)];
      }
    }
  }

  for (i = 0; i < 2; i++) {
    d1 = 0.0;
    for (i6 = 0; i6 < 4; i6++) {
      d1 += (real_T)c_a[i + (i6 << 1)] * x_next_pred[i6];
    }

    c_y[i] = y[i] - d1;
  }

  for (i = 0; i < 4; i++) {
    d1 = 0.0;
    for (i6 = 0; i6 < 2; i6++) {
      d1 += gain[i + (i6 << 2)] * c_y[i6];
    }

    x_next[i] = x_next_pred[i] + d1;
  }

  memset(&A[0], 0, sizeof(real_T) << 4);
  for (i = 0; i < 4; i++) {
    A[i + (i << 2)] = 1.0;
  }

  for (i = 0; i < 4; i++) {
    for (i6 = 0; i6 < 4; i6++) {
      d1 = 0.0;
      for (i7 = 0; i7 < 2; i7++) {
        d1 += gain[i + (i7 << 2)] * (real_T)c_a[i7 + (i6 << 1)];
      }

      c_A[i + (i6 << 2)] = A[i + (i6 << 2)] - d1;
    }
  }

  for (i = 0; i < 4; i++) {
    for (i6 = 0; i6 < 4; i6++) {
      P_next[i + (i6 << 2)] = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        P_next[i + (i6 << 2)] += c_A[i + (i7 << 2)] * P_next_pred[i7 + (i6 << 2)];
      }
    }
  }

  /*  Ugly hacks to keep speeds positive */
  ekt = x_next[0];
  if (ekt >= 0.0) {
    b_y = ekt;
  } else {
    b_y = 0.0;
  }

  x_next[0] = b_y;
  ekt = x_next[2];
  if (ekt >= 0.0) {
    b_y = ekt;
  } else {
    b_y = 0.0;
  }

  x_next[2] = b_y;
}

/* End of code generation (kalman_4d.c) */
