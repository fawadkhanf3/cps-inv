# Instructions for controller synthesis, testing, and exporting

## Synthesize

To synthesize the sets defining correct controllers, modify ``constants.m'' and do `run' in MATLAB.

## Export code

In the folder `codegen', do `export_code'. This creates code in the subfolder `matlab_c' which should be copied to ROS.

## Test controller

In the folder `simulation', run `um_simulation' to open a Simulink environment where the controller can be tested. Plot results with `um_plot'