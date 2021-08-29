AC/DC Converter Empirical Model Fitting
=======================================

This directory contains  MATLAB/GNU Octave scripts for generating interpolation-
based AC/DC converter efficiency and harmonic models. The scripts are modular;
different sections of the model generation are distributed across multiple
scripts and functions. The output of these scripts is a '.mat' file suitable for
import to Modelica/BEEAM.

The resulting models are normalized with respect to  device power, voltage, and
current ratings, such that the models can be scaled easily in BEEAM for devices
with arbitrary ratings. Such scaling is accomplished solely by changing the
device ratings in BEEAM; the underlying '.mat' file remains unchanged.

Workflow
--------

**TO DO:** Update

1) Get converter data from the csv file and put it in a struct named 'convData'
Example: convData = getConverterData(dataDirectory, device)
where, 'dataDirectory' is the path (string) to the data folder containing csv 
files. 'device' is the name of the folder containing data.
2) Run 'generate_harmonic_load_model' script to generate model
The mode is in the form of variables:
X, Y, Z_mag, Z_arg, alpha, beta, gamma

NOTE: One can generate multiple models using additional script 'iterate_converters'

Example:
--------
Included is a folder (Example Data) containing data for an AC/DC converter.
Steps to generate model: (copy and run the following lines in the 
command window)
% get converter data from csv data files;
dataDir = './Example Data/';
device = 'AC-DC - HP Laptop Charger - LBNL1 - 19.5V, 90W';
convData = getConverterData(dataDir, device)
% generate harmonic model
generate_harmonic_load_model


Model variables description
---------------------------
X:                  harmonic numbers in meshgrid format
Y:                  converter power at fundamental (h=1) in meshgrid format
Z_mag:              converter harmonic magnitude data
Z_arg:              converter harmonic angle data
alpha, beta, gamma: parameters for converter loss model


Dependencies:
-------------
GNU Octave requires 'io' package to read the csv file and return a cell array.
Install the package from Octave forge. The script automatically detects if it is
a MATLAB and Octave environment and load the package.