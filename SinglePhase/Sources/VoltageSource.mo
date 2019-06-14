within HPF.SinglePhase.Sources;

model VoltageSource "Voltage Source"
/*
  Constant voltage source.
  
  Workflow:
  * The voltage source acts a harmonic voltage source when solving the Harmonic power flow.
  * The first step in HPF is to determine the voltages across the nonlinear loads.
  * Solver would run the system as a power flow solver at the fundamental.
  * In this mode, the voltage source acts as an ideal voltage source with harmonic 
    voltages set at zero.
  * In the next operation, using the voltage values at the nonlinear loads, one would
    perform a nodal analysis, (injecting harmonic currents from the harmonic load).
  * The voltage source would switch operation from being an ideal voltage source at the 
    fundamental to a harmonic voltage source.
*/

  extends HPF.SinglePhase.Interface.Source;
  
  import  Modelica.ComplexMath.j;
  parameter Real vMag[:] = {1} "Voltage Magnitude";
  parameter Real vArg[:] = {0} "Voltage angle";
  
equation

  /*
    extra constraint definition for loop breaking.
  */
  omega = 2 * Modelica.Constants.pi * systemDef.fFund;

  /*
    mode 1: running power flow at fundamental
  */
  //if systemDef.modeSelect == true then
    //v[1] = Complex(vMag[1]*cos(vArg[1]), vMag[1]*sin(vArg[1]));
    // TODO: this implementation might be problematic
    //v[2:end] = {Complex(0.0) for i in 1:(systemDef.numHrm - 1)};
  //else
  /*
    mode 2: running harmonic solver
  */

   /*
   Observation: 
   Dymola is throwing error when performing arithematic operations on complex
   arrays.
   Erros of the type:
   - No match for constructor.
   - No match for overloaded binary operator '+'.
   Workaround:
   - assign values separately to the real and imaginary parts
   
   Error Type 1
   */
  Modelica.ComplexMath.real(v) = vMag.*cos(vArg);
  Modelica.ComplexMath.imag(v) = vMag.*sin(vArg);

annotation(
  defaultComponentName = "v",
    Icon(coordinateSystem(grid = {0, 0}, initialScale = 0.1), graphics = {Ellipse(extent = {{-48, 50}, {48, -50}}, endAngle = 360), Line(origin = {-69, 0}, points = {{-21, 0}, {21, 0}}), Line(origin = {69, 0}, points = {{-21, 0}, {21, 0}}), Line(origin = {-8.2246, 18.6487}, points = {{8.50128, 21.0747}, {2.50128, 19.0747}, {-5.49872, 13.0747}, {-9.49872, 7.07465}, {-11.4987, -0.925349}, {-9.49872, -6.92535}, {-5.49872, -10.9253}, {0.501285, -14.9253}, {6.50128, -18.9253}, {8.50128, -18.9253}, {8.5013, -18.9253}}), Line(origin = {7.309, -18.9402}, rotation = 180, points = {{8.50128, 21.0747}, {2.50128, 19.0747}, {-5.49872, 13.0747}, {-9.49872, 7.07465}, {-11.4987, -0.925349}, {-9.49872, -6.92535}, {-5.49872, -10.9253}, {0.501285, -14.9253}, {6.50128, -18.9253}, {8.50128, -18.9253}, {8.5013, -18.9253}}), Text(origin = {-84, 47}, rotation = 90, extent = {{-14, 23}, {56, -19}}, textString = "%name")}),
    Diagram(coordinateSystem(extent = {{-200, -200}, {200, 200}}, grid = {0, 0})));
    
end VoltageSource;