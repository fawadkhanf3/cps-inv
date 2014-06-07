# Correct-by-construction Autonomous Cruise Control

Result of an ongoing research project in Cyber-Physical Systems at the University of Michigan.

Files are matlab/simulink.

## Usage

The functionality is in the `libary' folder, while the other base folders provide functionality. To use the classes and functions in the `library', do
```
addpath('/path/to/library')
```
in MATLAB. Three main classes are included at the moment, they are
 * `Dyn' - Represents linear dynamics.
 * `PwDyn' - Piece-wise linear dynamics.
 * `HypArr' - A Hyperplane Arrangement, see paper from ETH.