#include <iostream>
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Core>

#include "cpp_wrapper.h"

using namespace Eigen;
using namespace std;

int main(int argc, char const *argv[])
{

	VectorXd x0(2), x1(2);
	x0 << 2, 4; // 4;
	x1 << 3.5,-1; // ,4;
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

	return 0;
}
