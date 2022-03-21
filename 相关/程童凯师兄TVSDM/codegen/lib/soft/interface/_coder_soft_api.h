/*
 * File: _coder_soft_api.h
 *
 * MATLAB Coder version            : 4.2
 * C/C++ source code generated on  : 18-Mar-2022 18:55:20
 */

#ifndef _CODER_SOFT_API_H
#define _CODER_SOFT_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_soft_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern real_T soft(real_T x, real_T T);
extern void soft_api(const mxArray * const prhs[2], int32_T nlhs, const mxArray *
                     plhs[1]);
extern void soft_atexit(void);
extern void soft_initialize(void);
extern void soft_terminate(void);
extern void soft_xil_shutdown(void);
extern void soft_xil_terminate(void);

#endif

/*
 * File trailer for _coder_soft_api.h
 *
 * [EOF]
 */
