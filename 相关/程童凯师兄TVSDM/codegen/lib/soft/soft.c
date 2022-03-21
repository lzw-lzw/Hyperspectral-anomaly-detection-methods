/*
 * File: soft.c
 *
 * MATLAB Coder version            : 4.2
 * C/C++ source code generated on  : 18-Mar-2022 18:55:20
 */

/* Include Files */
#include <math.h>
#include "soft.h"

/* Function Definitions */

/*
 * Arguments    : double x
 *                double T
 * Return Type  : double
 */
double soft(double x, double T)
{
  double y;
  T += 2.2204460492503131E-16;
  y = fabs(x) - T;
  if (!(y > 0.0)) {
    y = 0.0;
  }

  return y / (y + T) * x;
}

/*
 * File trailer for soft.c
 *
 * [EOF]
 */
