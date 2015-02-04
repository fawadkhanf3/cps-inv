#include "eigen3/Eigen/Dense"
#include "qp_vars.h"
#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <stdlib.h>

using Eigen::MatrixXd;
using namespace std;

qp_var::qp_var()
{
	pwdyn.A = MatrixXd::Zero(1,1);
	pwdyn.B = MatrixXd::Zero(1,1);
	Hx = MatrixXd::Zero(1,1);
	Hu = MatrixXd::Zero(1,1);
	hu = MatrixXd::Zero(1,1);
};

void qp_var::read_matlab()
{
	string file;
	int i = 1;

	ifstream infile("output_file.txt");
	try
	{

		if(infile.is_open()) // check if file is opened
		{
			read_item(infile, Hx);
			read_item(infile, hx);
			read_item(infile, pwdyn.A);
			read_item(infile, pwdyn.B);
			read_item(infile, pwdyn.E);
			read_item(infile, pwdyn.K);  //this order could be changed as needed

			infile.close();
		}
		else throw "error";

		while(1)
		{
			file = "sets_" + to_string(i) + ".txt";

			ifstream infile2(file);

			if(infile2.is_open()) read_sets(infile2, i);
			else
			{
				if(i == 1) throw 5;
				i--;
				break;
			}

			i++;
		}

		cout << "MATLAB data loaded successfully." << endl;
		cout << "Loaded a total of " << i << " set files." << endl << endl;

		cout << "Sets[1][3].A =" << endl << "---" << endl << Sets[1][3].A << endl << "---" << endl;

		cout << "Check line 200 of sets_2.txt to verify" << endl;
	}
	catch (string e){
		cout << "Error opening file (Expected output_file.txt)." << endl;  // output error if file did not open
	}
	catch (int e){
		cout << "Error opening file (Expected set_i.txt where i is an integer)." << endl;  // output error if file did not open
	}
}

template <typename Type>
void qp_var::read_item(std::ifstream & file, Type & data_out)
{
	int rows, cols;
	float data_in;
	file >> rows >> cols;

	data_out.resize(rows, cols);	// resize matrix or vector to correct dimensions

	for(int i = 0; i < rows; i++)
	{
		for(int j = 0; j < cols; j++)
		{
			file >> data_in;
			data_out(i,j) = data_in;	// put data into matrix or vector
		}
	}
}

void qp_var::read_sets(std::ifstream & file, int number)
{
	int i = 0;

	vector<Polyhedron> new_set;

	while(!file.eof())
	{
		Polyhedron new_data;

		read_item(file, new_data.A);		// get data for the new set
		read_item(file, new_data.b);

		new_set.emplace_back(new_data);		// place new data into new set

		i++;
	}

	Sets.emplace_back(new_set);	// add new set to vector of sets
}
