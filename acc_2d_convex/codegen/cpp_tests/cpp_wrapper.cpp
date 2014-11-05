#include "../matlab_c/definitions.h"
#include "cpp_wrapper.h"

void qp_vars_wrapper(const VectorXd & x0, MatrixXd & H, 
	         		 VectorXd & f, MatrixXd & A_ineq, VectorXd & b_ineq) {

	// Change input to array
	double x0_arr[QP_XDIM];
	Map<VectorXd>(x0_arr,QP_XDIM) = x0;
	
	// Allocate output variables
	double H_out[QP_UDIM*QP_N*QP_UDIM*QP_N];
	double f_out[QP_UDIM*QP_N];
	double A_ineq_out[QP_MAX_INEQ*QP_UDIM*QP_N];
	double b_ineq_out[QP_MAX_INEQ];
		
	// Call to Matlab converted function
	qp_vars(x0_arr,H_out,f_out,A_ineq_out,b_ineq_out);
		
	// Create maps for outputs
	Map<MatrixXd> A_ineq1(A_ineq_out,QP_MAX_INEQ,QP_UDIM*QP_N);
	Map<VectorXd> b_ineq1(b_ineq_out,QP_MAX_INEQ);
	Map<MatrixXd> H1(H_out,QP_UDIM*QP_N,QP_UDIM*QP_N);
	Map<VectorXd> f1(f_out,QP_UDIM*QP_N);

	// Copy results
	H = H1;
	f = f1;

	A_ineq = A_ineq1;
	b_ineq = b_ineq1;
	
}
