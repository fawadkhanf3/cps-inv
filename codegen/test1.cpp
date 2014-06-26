#include <iostream>
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Core>

#include "umcont.h"

using namespace Eigen;
using namespace std;

int main(int argc, char const *argv[])
{

	VectorXd x0(3), x1(3);
	x0 << 2, 4, 4;
	x1 << 3.5,4,4;
	MatrixXd H, H1, Aiq, Aiq1;
	VectorXd f, f1, biq, biq1;

	qp_vars_wrapper(x0,H,f,Aiq,biq);

	H1 = H;
	f1 = f;
	Aiq1 = Aiq;
	biq1 = biq;

	qp_vars_wrapper(x1,H,f,Aiq,biq);

	MatrixXd Hdiff, Adiff;
	VectorXd fdiff, bdiff;

	Hdiff = H-H1;
	fdiff = f-f1;
	bdiff = biq - biq1;
	Adiff = Aiq - Aiq1;

	cout << Hdiff << endl;
	cout << fdiff << endl;
	cout << bdiff << endl;
	cout << Adiff << endl;

	// VectorXd x_obs(4);
	// MatrixXd P_obs(4,4);

	// VectorXd y(2);
	// double u = 400;
	// double dt = 0.3;

	// kalman_wrapper(x_obs, P_obs, y, u, dt);

	// cout << x_obs << endl;
	// cout << P_obs << endl;

	return 0;
}

