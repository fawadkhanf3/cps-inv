#include "definitions.h"
#include "umcont.h"

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

void kalman_wrapper(VectorXd & x_obs, MatrixXd & P_obs, 
		    const VectorXd & y, const double & u, const double & dt ) {
	
	// Change input to array
	double x_obs_arr[KAL_XDIM];
	Map<VectorXd>(x_obs_arr,KAL_XDIM) = x_obs;
	double P_obs_arr[KAL_XDIM*KAL_XDIM];
	Map<MatrixXd>(P_obs_arr,KAL_XDIM,KAL_XDIM) = P_obs;
	double y_arr[KAL_YDIM];
	Map<VectorXd>(y_arr,KAL_YDIM) = y;
	
	// Assuming input of size 1, use this for larger input:
	// double u_arr[KAL_UDIM];
	// Map<VectorXd>(u_arr,KAL_UDIM) = u;

	// Create arrays for output
	double x_obs_next_out[KAL_XDIM];
	double P_obs_next_out[KAL_XDIM*KAL_XDIM];

	// Call to Matlab converted function
	kalman_4d(x_obs_arr, P_obs_arr, y_arr, u, dt, 
			  x_obs_next_out, P_obs_next_out);

	// Create maps for outputs
	Map<VectorXd> x_obs_next(x_obs_next_out, KAL_XDIM);
	Map<MatrixXd> P_obs_next(P_obs_next_out, KAL_XDIM, KAL_XDIM);

	// Save results
	x_obs = x_obs_next;
	P_obs = P_obs_next;
}