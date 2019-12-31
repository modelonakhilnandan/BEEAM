within HPF.SinglePhase.Components;
model Capacitor
  extends HPF.SinglePhase.Interface.TwoPinBase;
  import Modelica.ComplexMath.j;

  parameter Real C(start = 1) = 1e-6;

equation
  /*
    vRe + j*vIm = (zRe*iRe - zIm*iIm) + j*(zRe*iIm + zIm*iRe);
    For a capacitor, zRe = 0
  */
  v[:].re =  i[:].im ./ ((2*Modelica.Constants.pi*systemDef.fFund*C).*systemDef.hrms);

  v[:].im = - i[:].re ./ ((2*Modelica.Constants.pi*systemDef.fFund*C).*systemDef.hrms);


annotation (
  defaultComponentName = "C",
    Icon(graphics = {Line(origin = {-11.6968, 0.240597}, points = {{0, 40}, {0, -40}}), Line(origin = {13.9928, 0.321502}, points = {{0, 40}, {0, -40}}), Line(origin = {-57, 0}, points = {{-37, 0}, {45, 0}}), Line(origin = {57.1739, -0.0661157}, points = {{-43, 0}, {37, 0}}), Text(origin = {-47, 61}, extent = {{-65, 31}, {165, -13}}, textString = "%name"), Text(origin = {-17, -61}, extent = {{-125, 19}, {179, -15}}, textString = "C=%C F")}, coordinateSystem(initialScale = 0.1)));
end Capacitor;
