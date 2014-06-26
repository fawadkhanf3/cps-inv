#include <iostream>
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Core>

#include "umcont.h"

using namespace Eigen;
using namespace std;

int main(int argc, char const *argv[])
{

	VectorXd x0(3);
	x0 << 3, 4, 5;
	MatrixXd H, Aiq;
	VectorXd f, biq;

	qp_vars_wrapper(x0,H,f,Aiq,biq);

	cout << H << endl;
	cout << f << endl;
	// cout << Aiq << endl;
	// cout << biq << endl;

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

