within HPF.Sources.ThreePhase;
model VotlageSource "Three phase voltage source. Specify parameters as a Modelica vector {x1, x2, ...}."
  outer SystemDef systemDef;
  HPF.SinglePhase.Interface.HPin_P pinP_phA(h = systemDef.numHrm)  annotation (
    Placement(visible = true, transformation(origin = {100, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.SinglePhase.Interface.HPin_P pinP_phB(h = systemDef.numHrm)  annotation (
    Placement(visible = true, transformation(origin = {102, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.SinglePhase.Interface.HPin_P pinP_phC(h = systemDef.numHrm)  annotation (
    Placement(visible = true, transformation(origin = {100, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, -80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.SinglePhase.Interface.HPin_N pinN(h = systemDef.numHrm)  annotation (
    Placement(visible = true, transformation(origin = {100, -80}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, -102}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.SinglePhase.Sources.VoltageSource vSrc_phA( vArg = vArg_phA[1:systemDef.numHrm],vMag = vMag_phA[1:systemDef.numHrm])  annotation (
     Placement(visible = true, transformation(origin = {-10, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  HPF.SinglePhase.Sources.VoltageSource vSrc_phC(vMag = vMag_phC[1:systemDef.numHrm], vArg = vArg_phC[1:systemDef.numHrm]) annotation (
    Placement(visible = true, transformation(origin = {-10, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  HPF.SinglePhase.Sources.VoltageSource vSrc_phB(vMag = vMag_phB[1:systemDef.numHrm], vArg = vArg_phB[1:systemDef.numHrm]) annotation (
    Placement(visible = true, transformation(origin = {-10, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));

  parameter Modelica.SIunits.Voltage vMag_phA[:] = {1} "Phase A magnitude";
  parameter Real vArg_phA[:] = {1} "Phase A angle";
  parameter Modelica.SIunits.Voltage vMag_phB[:] = {1} "Phase B magnitude";
  parameter Real vArg_phB[:] = {1} "Phase B angle";
  parameter Modelica.SIunits.Voltage vMag_phC[:] = {1} "Phase C magnitude";
  parameter Real vArg_phC[:] = {1} "Phase C angle";

//protected

equation
  connect(vSrc_phA.pin_p, pinP_phA) annotation (
    Line(points = {{0, 60}, {98, 60}, {98, 60}, {100, 60}}, color = {92, 53, 102}));
  connect(vSrc_phA.pin_n, pinN) annotation (
    Line(points = {{-20, 60}, {-60, 60}, {-60, -80}, {100, -80}, {100, -80}}, color = {117, 80, 123}));
  connect(vSrc_phC.pin_p, pinP_phC) annotation (
    Line(points = {{0, -40}, {100, -40}, {100, -40}, {100, -40}}, color = {92, 53, 102}));
  connect(vSrc_phB.pin_p, pinP_phB) annotation (
    Line(points = {{0, 0}, {100, 0}, {100, 0}, {102, 0}}, color = {92, 53, 102}));
  connect(vSrc_phB.pin_n, pinN) annotation (
    Line(points = {{-20, 0}, {-60, 0}, {-60, -80}, {100, -80}, {100, -80}}, color = {117, 80, 123}));
  connect(vSrc_phC.pin_n, pinN) annotation (
    Line(points = {{-20, -40}, {-60, -40}, {-60, -80}, {100, -80}, {100, -80}}, color = {117, 80, 123}));

annotation (
    Icon(graphics={  Rectangle(extent = {{-100, 100}, {100, -100}}), Ellipse(origin = {-15, 7}, extent = {{-45, 53}, {75, -67}}, endAngle = 360),                                                                                                                     Line(origin = {0.249088, 0.860912}, points = {{-40.0807, -1.02713}, {-38.0807, 8.97287}, {-32.0807, 20.9729}, {-26.0807, 28.9729}, {-18.0807, 32.9729}, {-8.08074, 24.9729}, {-4.08074, 12.9729}, {-0.0807397, -1.02713}, {3.91926, -13.0271}, {5.91926, -19.0271}, {11.9193, -29.0271}, {21.9193, -35.0271}, {31.9193, -25.0271}, {35.9193, -17.0271}, {37.9193, -7.02713}, {39.9193, -1.02713}, {39.9193, -1.02713}}, smooth = Smooth.Bezier), Text(origin = {105, -93}, extent = {{-11, 3}, {35, -37}}, textString = "C"), Text(origin = {109, -15}, extent = {{-11, 3}, {35, -37}}, textString = "B"), Text(origin = {109, 61}, extent = {{-11, 3}, {35, -37}}, textString = "A"), Text(origin = {-56, 40}, lineColor = {92, 53, 102}, extent = {{-150, 60}, {254, 100}}, textString = "%name")}, coordinateSystem(initialScale = 0.1)),
    Documentation(info = "<html><head></head><body>Input data should be a mat file. File path should be a unix style path, exmaple, for a file named 'dataFile.mat'.<div><br></div><div>path = \"/HPF/InputData/dataFile.mat\"</div><div><br></div><div>The files must reside in the HPF library. All the paths are relative to the library.</div><div><br></div><div>For more information regarding structure of the matfile, please refer to the documentation.&nbsp;</div></body></html>"));
end VotlageSource;
