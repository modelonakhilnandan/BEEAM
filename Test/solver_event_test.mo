within HPF.Test;
model solver_event_test
  //inner discrete Boolean modeSelect;
  HPF.Test_components.event_check event_check1 annotation (
    Placement(visible = true, transformation(origin = {-14, 86}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  inner SystemDef systemDef annotation (
    Placement(visible = true, transformation(origin = {-70, 128}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation

annotation (
    Icon(coordinateSystem(grid = {0, 0})),
    Diagram(coordinateSystem(extent = {{-200, -200}, {200, 200}}, grid = {0, 0})));
end solver_event_test;
