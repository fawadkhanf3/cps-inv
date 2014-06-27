#include "umcont.h"
#include "definitions.h"
#include <eigen3/Eigen/Dense>
#include <eigen3/Eigen/Core>

using namespace std;

double v_internal = 3;

void calc_torque() {
  double F_r = (0.1 + 5*v_internal + 0.25*v_internal);
  std::cout << "Inside the calc torque" << std::endl;

  int nvar = QP_N;
  int neq = 0;

  MatrixXd Aeq(neq, nvar);
  MatrixXd H, Aiq;
  VectorXd beq(neq);
  VectorXd f, biq;

  VectorXd x0(3);
  x0 << 1,2,3;

  cout << "Trying wrapper with x0: " << x0 << endl;
  qp_vars_wrapper(x0, H, f, Aiq, biq);
  cout << "Finished wrapper" << endl;

  VectorXd x_actual(nvar);
  double obj_actual;

  double equality_tolerance = 1e-8;
  uint iter_max = 100;
  uint iters = 0;

}

int main(int argc, char const *argv[])
{
  calc_torque();
  return 0;
}
