within HPF.PowerConverters.SinglePhase;
model ACDC_EmpMdl "AC to DC converter empirical model"
  outer SystemDef systemDef;
  // component properties for post processing
  HPF.Utilities.ComponentProperties properties(ComponentType = "NonlinearLoad");
  import Modelica.ComplexMath.j;
  Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
    Placement(visible = true, transformation(origin = {80, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
    Placement(visible = true, transformation(origin = {80, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.SinglePhase.Interface.HPin_P hPin_P(h = systemDef.numHrm) annotation (
    Placement(visible = true, transformation(origin = {-80, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.SinglePhase.Interface.HPin_N hPin_N(h = systemDef.numHrm) annotation(Placement(visible = true, transformation(origin = {-80, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  parameter String modelFileName = "HPF/Data/ConverterModels/SinglePhase/ACDC/demoModel.mat" "Rectifier harmonic model mat file"; // "modelica://HPF/Data/ConverterModels/SinglePhase/ACDC/demoModel.mat"
  parameter Modelica.SIunits.Voltage V_Rect(start = 0) = 1 "Rectifier DC output";
  parameter Modelica.SIunits.Power nomP = 50 "Rated nominal power";
  parameter Modelica.SIunits.Voltage nomV = 120 "Nominal operating voltage";
  parameter Modelica.SIunits.Power P_DCmin = 0.5 "P_DC minimum";
  parameter Modelica.SIunits.Power P_stby = 0 "Standby (no load) input AC power";
  // TODO: Document that a default value of zero sets the stanby power as computed by efficiency relation.
  Modelica.Electrical.Analog.Sources.ConstantVoltage vDC(V = V_Rect) annotation (
    Placement(visible = true, transformation(origin = {20, -12}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  HPF.SinglePhase.Interface.LoadBase loadBase(start_v_re = cat(1, {nomV}, {0.0 for i in 1:systemDef.numHrm - 1})) annotation (
    Placement(visible = true, transformation(origin = {-20, -10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  /*
        Fundamental power drawn on the AC harmonic side.
        Using converter efficiency model
        
        Pin = Pout + alpha + beta*Pout + gamma*Pout^2
      */
  Real P_DC = abs(vDC.v * vDC.i);
  /* Input output power relation (Total input AC Power (sum over all harmonics))
      P_AC = p*P_stby + (1 - p)*f_effi(P_DC)
    */
  Real P = HPF.PowerConverters.HelperFunctions.stbyPwrTransition(P_DCmin, P_stby, P_DC) * P_stby + (1 - HPF.PowerConverters.HelperFunctions.stbyPwrTransition(P_DCmin, P_stby, P_DC)) * (P_DC + alpha[1, 1] + beta[1, 1] * P_DC + gamma[1, 1] * P_DC ^ 2);
  /*
        Measurements
    */
  Real I_mag[systemDef.numHrm] = Modelica.ComplexMath.'abs'(loadBase.i);
  Real I_arg[systemDef.numHrm] = Modelica.ComplexMath.arg(loadBase.i);
  Real V_mag[systemDef.numHrm] = Modelica.ComplexMath.'abs'(loadBase.v);
  Real V_arg[systemDef.numHrm] = Modelica.ComplexMath.arg(loadBase.v);
  // intermediary variables
  Real P1(start = nomP, fixed = false) "Real power at fundamental";
  Real S1(start = nomP) "Apparent power at fundamental";
  Real Q1(start = 1) "Imaginary power at fundamental";
  // diagnostics: Check if the computed h=1 current mag matches the input surface model
  Real diag_I_mag_h1 = HPF.Utilities.interpolateBilinear(mdl_H, mdl_P_h1, mdl_Z_mag, 1, P);
  Modelica.Blocks.Interfaces.RealOutput PLoss annotation (
    Placement(visible = true, transformation(origin = {10, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, 110}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
protected
  final parameter String resourceRetValue = Modelica.Utilities.Files.loadResource("modelica://" + modelFileName);
  final parameter Integer matDim[2] = Modelica.Utilities.Streams.readMatrixSize(resourceRetValue, "X");
  // assuming matrices have same dimension
  final parameter Real mdl_H[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "X", matDim[1], matDim[2]);
  final parameter Real mdl_P_h1[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "Y", matDim[1], matDim[2]);
  final parameter Real mdl_Z_mag[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "Z_mag", matDim[1], matDim[2]);
  final parameter Real mdl_Z_arg[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "Z_arg", matDim[1], matDim[2]);
  // reading efficiency model
  final parameter Real alpha[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "alpha", 1, 1);
  final parameter Real beta[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "beta", 1, 1);
  final parameter Real gamma[:, :] = Modelica.Utilities.Streams.readRealMatrix(resourceRetValue, "gamma", 1, 1);
  Real argS1 "Phase angle for fundamental apparent power";
  Real magScale = Modelica.ComplexMath.'abs'(loadBase.i[1]);
  /*  The time domain plots are correct suggesting that there is no need to add the 
          anticipated phase shift suggesting a reverse direction for the current. 
      */
  // Querry arg interplation in 2D at harmonics h>1, at power level P
  Real arg_hh[systemDef.numHrm - 1] = {HPF.Utilities.interpolateBilinear(mdl_H, mdl_P_h1, mdl_Z_arg, systemDef.hrms[i], P) for i in 2:1:systemDef.numHrm};
  // Apply phase correction
  Real argAdj[systemDef.numHrm - 1] = arg_hh[:] + Modelica.ComplexMath.arg(loadBase.v[1]) .* systemDef.hrms[2:end];
  // intermediary variables for higher current harmonics
  Complex a[systemDef.numHrm - 1] = {Complex(cos(argAdj[i]), sin(argAdj[i])) for i in 1:systemDef.numHrm - 1};
  // Querry mag interplation in 2D at harmonics h>1, at power level P
  Real c[systemDef.numHrm - 1] = {HPF.Utilities.interpolateBilinear(mdl_H, mdl_P_h1, mdl_Z_mag, systemDef.hrms[i], P1) for i in 2:1:systemDef.numHrm};
  Real tmp_Ph[systemDef.numHrm - 1] "Real power at h > 1";
equation
/*
    Power draw at the fundamental
    Power at harmonics > 1.
  */
  tmp_Ph[:] = loadBase.v[2:systemDef.numHrm].re .* loadBase.i[2:systemDef.numHrm].re .+ loadBase.v[2:systemDef.numHrm].im .* loadBase.i[2:systemDef.numHrm].im;
  P1 = P - sum(tmp_Ph);
/*
    Solve for imaginary power Q_1 (fundamental). 
    power angle is negative of the model fundamental
  */
  argS1 = -HPF.Utilities.interpolateBilinear(mdl_H, mdl_P_h1, mdl_Z_arg, 1, P);
  P1 = S1 * cos(argS1);
  Q1 = S1 * sin(argS1);
/*
     In complex notation,
    S = P + jQ = V*conj(I)
      = (Vre*Ire + Vim*Iim) + j(Vim*Ire - Vre*Iim)

    //Complex(P, Q) = loadBase.v[1] * Modelica.ComplexMath.conj(loadBase.i[1]);
    P = (loadBase.v[1].re * loadBase.i[1].re) + (loadBase.v[1].im * loadBase.i[1].im);
    Q = (loadBase.v[1].im * loadBase.i[1].re) - (loadBase.v[1].re * loadBase.i[1].im);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    //rewriting the power relation
  */
  loadBase.i[1].re = (P1 * loadBase.v[1].re + Q1 * loadBase.v[1].im) / (loadBase.v[1].re ^ 2 + loadBase.v[1].im ^ 2);
  loadBase.i[1].im = (P1 * loadBase.v[1].im - Q1 * loadBase.v[1].re) / (loadBase.v[1].re ^ 2 + loadBase.v[1].im ^ 2);
/*
    current injection for the rest of the harmonics.
  */
  loadBase.i[2:1:systemDef.numHrm] = {c[i] * a[i] for i in 1:systemDef.numHrm - 1};
  PLoss = P - P_DC;
  connect(vDC.p, pin_p) annotation (
    Line(points = {{20, -2}, {20, 40}, {80, 40}}, color = {0, 0, 255}));
  connect(vDC.n, pin_n) annotation (
    Line(points = {{20, -22}, {20, -60}, {80, -60}}, color = {0, 0, 255}));
  connect(loadBase.pin_n, hPin_N) annotation (
    Line(points = {{-20, -20}, {-20, -60}, {-80, -60}}, color = {117, 80, 123}));
  connect(hPin_P, loadBase.pin_p) annotation (
    Line(points = {{-80, 40}, {-20, 40}, {-20, 0}}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio = false), graphics={  Rectangle(origin = {-1, 0}, extent = {{-99, 100}, {101, -100}}), Line(origin = {-47.7858, -4.01698}, points = {{-44.9518, 25.9597}, {-40.9518, 41.9597}, {-34.9518, 57.9597}, {-26.9518, 65.9597}, {-16.9518, 61.9597}, {-10.9518, 45.9597}, {-6.95182, 27.9597}, {-2.95182, 7.9597}, {5.04818, -8.0403}, {15.0482, -14.0403}, {27.0482, -4.0403}, {33.0482, 11.9597}, {37.0482, 25.9596}}, smooth = Smooth.Bezier), Line(origin = {-22.4063, 67.9889}, points = {{0, 24}, {0, -24}}), Line(origin = {-11.6348, 68.0442}, points = {{0, 14}, {0, -24}}), Line(origin = {-3.85568, 68.1837}, points = {{0, 4}, {0, -24}}), Line(origin = {23.0478, 68.1045}, points = {{0, -10}, {0, -24}}), Line(origin = {14.6624, 67.8344}, points = {{0, -6}, {0, -24}}), Line(origin = {5.18579, 67.6124}, points = {{0, -2}, {0, -24}}), Line(origin = {-3.63854, 43.8449}, rotation = -90, points = {{0, 36}, {0, -24}}), Line(origin = {48.7451, -24.5475}, points = {{-25, 0}, {25, 0}}), Line(origin = {49.1191, -47.2208}, points = {{-25, 0}, {25, 0}}, pattern = LinePattern.Dash), Line(origin = {1.01175, 2.8636e-05}, points = {{-101, -100}, {99, 100}}), Text(origin = {4, 0},lineColor = {92, 53, 102}, extent = {{-184, -120}, {176, -160}}, textString = "%name"), Text(origin = {70, 115}, extent = {{-54, 15}, {54, -15}}, textString = "Ploss")}),
    Diagram(coordinateSystem(preserveAspectRatio = false)),
    Documentation(info="<html>
<h4>Converter harmonic model</h4>
<p>Coupled harmonic model for an AC to DC converter. The harmonic model is based on empirical data from laboratory measurements. The AC side harmonics are modeled using a surface function evaluated at a given harmonic and real power at <i>h=1</i> using 2D interpolation.</p>
<h4>Converter loss model</h4>
<p>The converter loss is modeled as a 2-stage loss model:</p>
<p><br><img src=\"modelica://HPF/Resources/images/ConverterModels/SinglePhase/ACDC_EmpMdl/eq_pLoss_2stage.png\"/>.</p>
<p>The lambda function is implemented in <a href=\"modelica://HPF.PowerConverters.HelperFunctions.stbyPwrTransition\">stbyPwrTransition</a> function.</p>
<p><img src=\"modelica://HPF/Resources/images/ConverterModels/SinglePhase/ACDC_EmpMdl/eq_ploss.png\"/></p>
<p><br><h4>Converter model data files</h4></p>
<p>Data files for the converter model can be found in <span style=\"font-family: Courier;\">HPF/Data/ConverterModels/SinglePhase/ACDC/</span></p>
</html>"));
end ACDC_EmpMdl;