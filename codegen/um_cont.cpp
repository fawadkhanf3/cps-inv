/***********************************************************************************
 * Code for calculating the error in the actual and desired velocity of the car using
 * the using a PWM signal inputed after solving a Model Independent version of the QP. 
 * The testing is being done on the SMALL electric car. 
 * 
 * Also, parts of it has been taken from Forrest Berg's code for the Arduino DUE and from
 * Eric Cousineau's code for the C++ QP solver.
 *
 * The code is a node for the ROS environemnt which is run using the terminal
 * after we upload the code onto the port connecting the Arduino board. 
 * This is test code for the main project of Adaptive Crusie Control before testing PID.
 *
 **************  Author  **************  Date  ***************  Project  ***************
 *             Aakar Mehra            June 9, 2014       Adaptive Cruise Control 
 * 
 ****************************************************************************************
 */


#include <cstdlib>
#include <iostream>
#include <cmath>
#include "ros/ros.h"
#include <std_msgs/Float64.h>
#include "std_msgs/UInt16.h"
#include "std_msgs/Bool.h"
#include "std_msgs/Int32.h"
#include "std_msgs/Int16.h"
#include "umcont.h"
#include "definitions.h"

#include "eiquadprog/eiquadprog.hpp"

#include <yaml_eigen_utilities/binary_utilities.hpp>

using namespace std;
using namespace Eigen;
using namespace eiquadprog;

double convert_rpm_to_vel = 0.00932;
double convert_vel_to_rpm = 1/ 0.00932;
double v_desired = 3;
int last_vel = 0;
int pwm;
//double input_vel;
double input_pwm = 1400;
int pwm_low = 1450;
int pwm_high = 1300;
double current_rpm;
double current_vel;
//double Kp = 0.00000004;
double Kp = 0.8;     // 0.8
double Kp_brake = 1.2;     // 0.8
double Kp_acc = 1;     // 0.8 
double error;
double P = 0;
double v_internal;
void calc_speed();
void calc_torque();
bool new_data = false;
bool internal_is_initialized = false;
double dist_0 = 0;
//double dist_1 = 0;
double dist = 0;
//void calc_distance();
double u_qp;
double limit = 0.5;
//bool counter = false;
double Bcalc;
double Distcalc;
double V;
double V_dot;
double B_dot;
double bar_gain = 0.3;
double relax_error = 0.001;

//// Things to possibly change
/// Increase the relax_error if QP is failing
/// Change bar_gain if the distance is too large or too small
/// Change between v_interal and current_vel in the QP error calculation**** See notes below

/// Small epsilon if running internal velocity epsilon = 1-10
/// Large epsilon if running the current_vel epsilon = 30

void hall_callback(const std_msgs::UInt16& hall_msg) {
  ROS_INFO ("Received hall_data");
  current_rpm = hall_msg.data;
  current_vel = current_rpm*convert_rpm_to_vel;
  new_data = true;
}

void desired_cb(const std_msgs::UInt16& desired_msg) {
  ROS_INFO ("Received desired velocity");
  v_desired = desired_msg.data;
}

void dist_0_cb(const std_msgs::Int16& dist_0_msg) {
  //ROS_INFO ("Received desired velocity");
  dist_0 = dist_0_msg.data;
  new_data = true;
}

/*void dist_1_cb(const std_msgs::Int64& dist_1_msg)
{
 dist_1 = dist_1_msg.data;
 new_data = true;
}*/

/*void switch_callback(const std_msgs::Int32ConstPtr &msg)
{
    solver = msg->data;
}*/

void reset_internal_cb(const std_msgs::Bool& msg) {
  ROS_INFO ("Received reset_internal");
  if (msg.data) {
    internal_is_initialized = false;
  }
}

/** @brief Desired loop rate */
int loop_rate = 200;

/** @brief Desired loop duration */
double dt_loop = 1. / loop_rate;
// ROS_INFO("dt_loop: %g", dt_loop);

/** @brief Internally integrated time */
double t_internal = 0.;


int main(int argc, char **argv) {

  ROS_INFO("Initializing");
  /* Initializing ROS to start communication */
  ros::init(argc, argv, "motor_qp_node");

  /* Setting up the Node Handle for the ROS */
  ros::NodeHandle nh;

  /* Subscribing for the data published by the Arduino */

  ros::Subscriber sub = nh.subscribe("hall_data", 1000, hall_callback);

  ros::Subscriber sub2 = nh.subscribe("desired", 1000, desired_cb);

  ros::Subscriber sub_dist_0 = nh.subscribe("encoder0_data", 1000, dist_0_cb);

  //ros::Subscriber sub_dist_1 = nh.subscribe("encoder1_data", 1000, dist_1_cb);

  ros::Subscriber sub_reset = nh.subscribe("reset_internal", 1000, reset_internal_cb);

  //  ros::Subscriber switchSub = nh.subscribe("solver", 1000, &switch_callback);

  /* publish PWM value for the motor to read */

  ros::Publisher pub_motor = nh.advertise<std_msgs::UInt16>("motor_pub", 1000);

  ros::Publisher pub_v_internal = nh.advertise<std_msgs::Float64>("v_internal", 1000);

  ros::Publisher pub_error = nh.advertise<std_msgs::UInt16>("error_pub", 1000);

  ros::Publisher pub_desired = nh.advertise<std_msgs::UInt16>("desired_pub", 1000);

  ros::Publisher pub_current = nh.advertise<std_msgs::Float64>("current_pub", 1000);

  ros::Publisher pub_force_qp = nh.advertise<std_msgs::Float64>("force_qp_pub", 1000);

  ros::Publisher pub_rel = nh.advertise<std_msgs::Float64>("rel_pub", 1000);

  ros::Publisher pub_barrier = nh.advertise<std_msgs::Float64>("barrier", 1000);

  ros::Publisher pub_V = nh.advertise<std_msgs::Float64>("lyapunov", 1000);

  ros::Publisher pub_vdot = nh.advertise<std_msgs::Float64>("Vdot", 1000);

  ros::Publisher pub_bdot = nh.advertise<std_msgs::Float64>("Bdot", 1000);

  //ros::Rate loop_rate(100);
  ros::Rate loop(loop_rate);

  while (ros::ok()) {
    if(new_data){
      /// @todo Implement logic for handling real-time switching between internal model trajectory generation and setpoint
      if (!internal_is_initialized) {
        v_internal = current_vel;
        ROS_INFO("Initialize v_internal: %g", v_internal);
        internal_is_initialized = true;
      }
      
      // ROS_INFO("Looping");
      std::cout << "v_desired " << v_desired << std::endl;

      dist = (dist_0)*0.00562;              //-(dist_1 - dist_0)*0.00562;
      std::cout << "distance_rel " << dist << std::endl;


      calc_torque();
      calc_speed();
      
      std_msgs::UInt16 pwm;
      //std_msgs::UInt16 error;

      pwm.data = input_pwm;
      //error.data = error;

      pub_motor.publish(pwm);     // publishing PWM
      {
        std_msgs::Float64 msg;
        msg.data = v_internal;        // publishing v_internal
        pub_v_internal.publish(msg);
      }
      
      {
        std_msgs::UInt16 msg;
        msg.data = error;             // publishing error at MI
        pub_error.publish(msg);
      }
      
      {
        std_msgs::UInt16 msg;
        msg.data = v_desired;             // publishing desired velocity 
        pub_desired.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = current_vel;                // publishing current velocity 
        pub_current.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = u_qp;                   // publishing force output from the QP 
        pub_force_qp.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = dist;                   // publishing relatve distance from the QP 
        pub_rel.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = Bcalc;                   // publishing barrier function from the QP 
        pub_barrier.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = Distcalc;                   // publishing Distcalc from the QP 
        pub_barrier.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = V;                   // publishing V from the QP 
        pub_V.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = V_dot;                   // publishing V_dot from the QP 
        pub_vdot.publish(msg);
      }
      
      {
        std_msgs::Float64 msg;
        msg.data = B_dot;                   // publishing B_dot from the QP 
        pub_bdot.publish(msg);
      }
      
      // Integrate time afterwards to be consistent with actual wall time
      t_internal = dt_loop + t_internal;

      ros::spinOnce();
      loop.sleep();

      last_vel = current_vel;
      new_data = false;
    }
    ros::spinOnce();
    usleep(100);
  }
}
void calc_speed() {
  std::cout << "v_internal " << v_internal << std::endl;
  error = current_vel - v_internal;
  std::cout << "current_vel " << current_vel << std::endl;
  std::cout << "error_MI " << error << std::endl;
  
  if (error < 0) {
    Kp = Kp_acc;
  } else {
    Kp = Kp_brake; 
  }

  P = error*Kp;
  input_pwm = input_pwm + P;  // this value needs to be scaled or mapped to the operating range of angles

  std::cout << "Final PWM " << input_pwm << std::endl;

  // @todo Address scaling and regions
  if (abs(input_pwm)< pwm_high) {
    input_pwm = pwm_high;
  }
  if (abs(input_pwm)> pwm_low) {
    input_pwm = pwm_low;
    current_vel = 0;
  }
}

void calc_torque() {
  std::cout << "Inside the calc torque" << std::endl;

  // Get QP variables from controller
  MatrixXd Aeq(neq, nvar);
  MatrixXd H, Aiq;
  VectorXd beq(neq);
  VectorXd f, biq;
  VectorXd x0(3);

  x0 << 1,2,3;
  cout << "Trying wrapper with x0:" << x0 << endl;
  cout << H << endl;
  cout << f << endl;
  cout << Aiq << endl;
  cout << biq << endl;
  qp_vars_wrapper(x0, H, f, Aiq, biq);
  cout << "Finished wrapper" << endl;

  int nvar = QP_N;
  int neq = 0;

  VectorXd x_actual(nvar);
  double obj_actual;

  double equality_tolerance = 1e-8;
  uint iter_max = 100;
  uint iters = 0;

  try {
    // Solve the QP 
    // @todo Note that for this specific problem, if we change H to H/2, we get same answer but 	different objective
    obj_actual = eiquadprog::solve_quadprog(H, f, -Aeq.transpose(), -beq.transpose(), 
                                                  -Aiq.transpose(), biq, x_actual, 
                                                  equality_tolerance, iter_max, &iters);
    //ROS_INFO("QP solved");
    u_qp = x_actual(0);
    
    // Integrate forward
    double F_r = (0.1 + 5*v_internal + 0.25*v_internal);
    v_internal += (u_qp - F_r)*dt_loop;
  } catch (eiquadprog::QPException &ex) {
    cerr << "Caught QP Exception. Dumping QP formulation, then re-throwing." << endl;
    using namespace YAML;
    #define YKV(x) out << Key << #x << Value; yaml_utilities::yaml_write_binary_dual(out, x); // Write the base64 representation just in case there is rounding error with strings
    //#define YKV(x) out << Key << #x << Value << x; // For just dumping value
    Emitter out;
    out << BeginMap;
    YKV(H);
    YKV(f);
    YKV(Aeq);
    YKV(beq);
    YKV(Aiq);
    YKV(biq);
    YKV(iter_max);
    YKV(iters);
    YKV(equality_tolerance);
    #undef YKV
    out << EndMap;
    cerr << out << endl;
    // Re-throw the exception to kill the program
    throw ex;
  }
}

