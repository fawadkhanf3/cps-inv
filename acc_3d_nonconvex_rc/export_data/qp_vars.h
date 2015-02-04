#include <vector>
#include "eigen3/Eigen/Dense"
#include <fstream>
using Eigen::MatrixXd;
using Eigen::VectorXd;
using namespace std;

class qp_var
{
	public:

		struct Polyhedron {
			MatrixXd A;
			VectorXd b;
		};

		struct Dynamics {
			MatrixXd A;
			MatrixXd B;
			MatrixXd E;
			VectorXd K;
			MatrixXd Em;

			Polyhedron XU_set;  //using above Polyhedron struct
			MatrixXd XD_plus;
			MatrixXd XD_minus;
		};

		//constructor
		qp_var();
		void read_matlab();
		void get_input(MatrixXd x0, MatrixXd Rx, MatrixXd rx, MatrixXd Ru, MatrixXd ru);
	protected:

	private:
		template <typename Type>
		void read_item(std::ifstream & file, Type &);
		void read_sets(std::ifstream & file, int number);

		// Sets of input constraints
		Dynamics pwdyn;

		// Define Polyhedron to steer to
		MatrixXd Hx;
		MatrixXd hx;

		// Input constraints
		MatrixXd Hu;
		VectorXd hu;

		// Disturbance assumptions
		MatrixXd XDplus, XDminus;

		// Sets
		vector<vector<Polyhedron> > Sets;
};
