#include <iostream>
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Core>

#include "cpp_wrapper.h"

using namespace Eigen;
using namespace std;

int main(int argc, char const *argv[])
{

	VectorXd x0(3), x1(3);
	x0 << 2, 4, 4;
	x1 << 3.5,-1,4;
	MatrixXd H, Aiq;
	VectorXd f, biq;

	cout << "calling wrapper" << endl;
	qp_vars_wrapper(x0,H,f,Aiq,biq);

	cout << H << endl;
	cout << f << endl;
	cout << Aiq << endl;
	cout << biq << endl;

	cout << "calling wrapper" << endl;
	qp_vars_wrapper(x1,H,f,Aiq,biq);

	cout << H << endl;
	cout << f << endl;
	cout << Aiq << endl;
	cout << biq << endl;


	VectorXd x_obs(4);
	MatrixXd P_obs(4,4);
	P_obs.setIdentity(4, 4);
	cout << P_obs << endl;

	VectorXd y(2);
	double u = 400;
	double dt = 0.3;

	kalman_wrapper(x_obs, P_obs, y, u, dt);

	cout << x_obs << endl;
	cout << P_obs << endl;
	kalman_wrapper(x_obs, P_obs, y, u, dt);

	cout << x_obs << endl;
	cout << P_obs << endl;
	kalman_wrapper(x_obs, P_obs, y, u, dt);

	cout << x_obs[0] << endl;
	cout << P_obs << endl;

	return 0;
}
