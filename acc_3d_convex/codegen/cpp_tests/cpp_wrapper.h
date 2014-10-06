#include <iostream>
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Core>

// Include files converted from matlab
extern "C" {
	#include "../matlab_c/qp_vars.h"
	#include "../matlab_c/kalman_4d.h"
}

#ifndef __UMCONT_H__
#define __UMCONT_H__

using namespace Eigen;
using namespace std;

void qp_vars_wrapper(const VectorXd &, MatrixXd &, VectorXd &, 
	         MatrixXd &, VectorXd &);

void kalman_wrapper(VectorXd &, MatrixXd &, 
	        const VectorXd &, const double &, const double &);

#endif
