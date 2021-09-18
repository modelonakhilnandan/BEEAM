within HPF.Examples.Basics;

model AC2DC_Simple_Inverter_1P
  extends Modelica.Icons.Example;
  import Modelica.ComplexMath.j;
  inner HPF.SystemDef systemDef(hrms = {i for i in 1:2:20})  annotation(
    Placement(visible = true, transformation(origin = {-78, 82}, extent = {{-14, -14}, {14, 10}}, rotation = 0)));
  HPF.SinglePhase.Sources.VoltageSource V_Grid(vArg = {0 for i in 1:systemDef.numHrm}, vMag = cat(1, {115}, {0 for i in 2:systemDef.numHrm}))  annotation(
    Placement(visible = true, transformation(origin = {-60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  HPF.SinglePhase.Components.Ground Ground_AC annotation(
    Placement(visible = true, transformation(origin = {-40, -48}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
  Modelica.Electrical.Analog.Basic.Ground Ground_DC annotation(
    Placement(visible = true, transformation(origin = {40, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  HPF.Sources.DC.FixedVoltage_FixedCurrent DC_Source annotation(
    Placement(visible = true, transformation(origin = {60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  HPF.PowerConverters.SinglePhase.ACDC_1pInverterSimple Simple_Inverter annotation(
    Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(Simple_Inverter.hPin_N, Ground_AC.pin) annotation(
    Line(points = {{-10, -8}, {-19, -8}, {-19, -20}, {-40, -20}, {-40, -40}}, color = {117, 80, 123}));
  connect(V_Grid.pin_n, Ground_AC.pin) annotation(
    Line(points = {{-60, -10}, {-60, -20}, {-40, -20}, {-40, -40}}, color = {117, 80, 123}));
  connect(Simple_Inverter.hPin_L, V_Grid.pin_p) annotation(
    Line(points = {{-10, 8}, {-20, 8}, {-20, 20}, {-60, 20}, {-60, 10}}, color = {92, 53, 102}));
  connect(Simple_Inverter.pin_n, Ground_DC.p) annotation(
    Line(points = {{10, -8}, {20, -8}, {20, -20}, {40, -20}, {40, -40}}, color = {0, 0, 255}));
  connect(DC_Source.n, Ground_DC.p) annotation(
    Line(points = {{60, -10}, {60, -20}, {40, -20}, {40, -40}}, color = {0, 0, 255}));
  connect(DC_Source.p, Simple_Inverter.pin_p) annotation(
    Line(points = {{60, 10}, {60, 20}, {20, 20}, {20, 8}, {10, 8}}, color = {0, 0, 255}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio = false)),
    Diagram(coordinateSystem(preserveAspectRatio = false)),
    Documentation(info = "<html>
<p>This example demonstrates a simple DC to AC inverter (no distortion, fixed power factor). This is a placeholder model.</p>
</html>"),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 1),
    __OpenModelica_commandLineOptions = "--matchingAlgorithm=PFPlusExt --indexReductionMethod=dynamicStateSelection -d=initialization,NLSanalyticJacobian,newInst -d=initialization ",
    __OpenModelica_simulationFlags(lv = "LOG_RES_INIT,LOG_SOTI,LOG_STATS", outputFormat = "mat", s = "dassl", ls = "totalpivot", nls = "newton"));
end AC2DC_Simple_Inverter_1P;