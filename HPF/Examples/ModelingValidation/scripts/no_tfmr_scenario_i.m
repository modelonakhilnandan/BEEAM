
%% Modelica post processing
% Running simulations without transformer


% get voltage data on sec for all scenarios

close all

%% script initializations
addpath('./lib')
% load msr data
load('converters_msr_data.mat')
% load voltage data (transformer sec side)
load('vData_sec.mat')

% if scenario variable exists, skip
% this means one is running the external run script.
% one would iterate the variable and run all the scenarios.
if exist('scenario', 'var') ~= 1
    scenarios ={'Scenario_1_Data_Set_1_1';      % 1
            'Scenario_1_Data_Set_1_2';      % 2
            'Scenario_1_Data_Set_1_3';      % 3
            'Scenario_1_Data_Set_1_4';      % 4
            'Scenario_2_Data_Set_2_1';      % 5 
            'Scenario_2_Data_Set_2_2';      % 6
            'Scenario_2_Data_Set_2_3';      % 7
            'Scenario_2_Data_Set_2_4'};     % 8
    scenario = 2;
end

scn = str2num(scenarios{scenario}(strfind(scenarios{scenario}, '_Data')-1));
data_set = str2num(scenarios{scenario}(end));

modelicaWorkingDir = '/home/avpreetsingh/OpenModelica_workspace/';
% file path for OpenModelica mat file
matFile_path = [modelicaWorkingDir, 'HPF.Examples.ModelingValidation.NoTfmr.', ...
            scenarios{scenario}, '/HPF.Examples.ModelingValidation.NoTfmr.', ...
            scenarios{scenario}, '_res.mat'];

% speedup execution, prevents reloading matfile everytime.
% to load mat file, clear all the variables using 'clear'
if exist('res', 'var') ~= 1 || exist('loadOk', 'var') == 1
    res = modelicaImport(matFile_path);
end
% correction ---------------
% There is a bug in the 'modelicaImport.m' function. It fails to populate the varaible
% voltageSource.vSrc_phC.v
% Therefore, manually doing that.. functions with prefix 'tmp_' are all 
% temporary fix.
tmpVar = tmp_getModelicaVar_cmplxVect(matFile_path, 'voltageSource.vSrc_phC.v');
res.voltageSource.vSrc_phC.v = tmpVar;


numHrm = res.systemDef.numHrm;   % number of harmonics
h = res.systemDef.hrms; % system harmonics
% getting data from all the devices

%% getting data
% input 
inputVoltageSource = voltageSrc_3ph(numHrm, res.voltageSource);

% converters
LaptopCharger_3 = AC2DC_converter_1ph(numHrm, res.Laptop_Charger_3);
LaptopCharger_4 = AC2DC_converter_1ph(numHrm, res.Laptop_Charger_4);
LaptopCharger_5 = AC2DC_converter_1ph(numHrm, res.Laptop_Charger_5);
LedDriver_1 = AC2DC_converter_1ph(numHrm, res.LED_Driver_1);
LedDriver_2 = AC2DC_converter_1ph(numHrm, res.LED_Driver_2);
LedDriver_3 = AC2DC_converter_1ph(numHrm, res.LED_Driver_3);
PowerSupply_1 = AC2DC_converter_1ph(numHrm, res.Power_Supply_1);
PowerSupply_2 = AC2DC_converter_1ph(numHrm, res.Power_Supply_2);
PowerSupply_3 = AC2DC_converter_1ph(numHrm, res.Power_Supply_3);

%% system losses -----
% Output DC power for converters
DC_power = LaptopCharger_3.DC.P + LaptopCharger_4.DC.P + LaptopCharger_5.DC.P + ...
            LedDriver_1.DC.P + LedDriver_2.DC.P + LedDriver_3.DC.P + ...
            PowerSupply_1.DC.P + PowerSupply_2.DC.P + PowerSupply_3.DC.P;
        

%% overly complicated lookup for power level (only for power supplies)
% s1,ds1 = 
% powers are saved as, 0, 100, 200, 400 600
pwrSel = struct();
if scn == 1
    if data_set == 1
        pwrSel.PS1 = 1;
        pwrSel.PS3 = 1;
        pwrSel.PS2 = 1;
    elseif data_set == 2
        pwrSel.PS1 = 1;% balanced, all are similar 
        pwrSel.PS3 = 1;
        pwrSel.PS2 = 1;
    elseif data_set == 3
        pwrSel.PS1 = 3;
        pwrSel.PS2 = 3;
        pwrSel.PS3 = 3;
    elseif data_set == 4
        pwrSel.PS1 = 4;
        pwrSel.PS2 = 4;
        pwrSel.PS3 = 4;
    end
elseif scn == 2
    if data_set == 1
        pwrSel.PS1 = 1;
        pwrSel.PS2 = 1;
        pwrSel.PS3 = 1;
    elseif data_set == 2
        pwrSel.PS1 = 5; 
        pwrSel.PS2 = 1; 
        pwrSel.PS3 = 5;
    elseif data_set == 3
        pwrSel.PS1 = 3; 
        pwrSel.PS2 = 4; 
        pwrSel.PS3 = 5;
    elseif data_set == 4
        pwrSel.PS1 = 5; 
        pwrSel.PS2 = 4; 
        pwrSel.PS3 = 1;
    end
end

% plotting 
figure
plot(inputVoltageSource.phA.wv.v)
hold on
plot(inputVoltageSource.phB.wv.v)
plot(inputVoltageSource.phC.wv.v)
legend('Ph A', 'Ph B', 'Ph C')       

disp( ' ========================================')        
disp([' Results for:  ', scenarios{scenario}]) 
disp( ' ========================================') 
disp(['System losses (Simulated) --- '])
disp(['Input power:        ', num2str(inputVoltageSource.P), ' W']);
disp(['Output DC power:    ', num2str(DC_power), ' W']);
% System losses
disp(['System Losses:      ', num2str(inputVoltageSource.P - DC_power), ' W']);
disp(['System Effi:        ', num2str((DC_power/inputVoltageSource.P)*100), ' %']);
msr.Pin = msr.Led(1).Pin + msr.Led(2).Pin + msr.Led(3).Pin + ...
            msr.Laptop(1).Pin + msr.Laptop(2).Pin + msr.Laptop(3).Pin + ...
            msr.PS(1).Pin(pwrSel.PS1) + msr.PS(2).Pin(pwrSel.PS2) + msr.PS(3).Pin(pwrSel.PS3);
msr.Pout = msr.Led(1).Pout + msr.Led(2).Pout + msr.Led(3).Pout + ...
            msr.Laptop(1).Pout + msr.Laptop(2).Pout + msr.Laptop(3).Pout + ...
            msr.PS(1).Pout(pwrSel.PS1) + msr.PS(2).Pout(pwrSel.PS2) + msr.PS(3).Pout(pwrSel.PS3);
disp(['System losses (Measured) --- '])
disp(['Input power:        ', num2str(msr.Pin), ' W']);
disp(['Output DC power:    ', num2str(msr.Pout), ' W']);
% System losses
disp(['System Losses:      ', num2str( msr.Pin - msr.Pout ), ' W']);
disp(['System Effi:        ', num2str((msr.Pout / msr.Pin)*100), ' %']);
P_loss = LedDriver_1.Ploss + LedDriver_2.Ploss + LedDriver_3.Ploss + ...
            LaptopCharger_3.Ploss + LaptopCharger_4.Ploss + LaptopCharger_5.Ploss + ...
            PowerSupply_1.Ploss + PowerSupply_2.Ploss + PowerSupply_3.Ploss;
disp('-----------------------------')
disp(['Converter losses:   ', num2str(P_loss), ' W'])

%%
disp('         Pin_msr     Pin_sim      Pout_msr        Pout_sim       Effi_msr       Effi_sim    Ploss_msr   Ploss_sim')
fprintf('Led(1)    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.Led(1).Pin, LedDriver_1.AC.P, msr.Led(1).Pout, LedDriver_1.DC.P, msr.Led(1).Pout/msr.Led(1).Pin, (LedDriver_1.DC.P/LedDriver_1.AC.P), msr.Led(1).Pin-msr.Led(1).Pout, LedDriver_1.Ploss)
fprintf('Led(2)   %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.Led(2).Pin, LedDriver_2.AC.P, msr.Led(2).Pout, LedDriver_2.DC.P, msr.Led(2).Pout/msr.Led(2).Pin, LedDriver_2.DC.P/LedDriver_2.AC.P, msr.Led(2).Pin-msr.Led(2).Pout, LedDriver_2.Ploss)
fprintf('Led(3)   %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.Led(3).Pin, LedDriver_3.AC.P, msr.Led(3).Pout, LedDriver_3.DC.P, msr.Led(3).Pout/msr.Led(3).Pin, LedDriver_3.DC.P/LedDriver_3.AC.P, msr.Led(3).Pin-msr.Led(3).Pout, LedDriver_3.Ploss)
fprintf('Lap_3    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.Laptop(1).Pin, LaptopCharger_3.AC.P, msr.Laptop(1).Pout, LaptopCharger_3.DC.P, msr.Laptop(1).Pout/msr.Laptop(1).Pin, LaptopCharger_3.DC.P/LaptopCharger_3.AC.P, msr.Laptop(1).Pin-msr.Laptop(1).Pout, LaptopCharger_3.Ploss)
fprintf('Lap_4    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.Laptop(2).Pin, LaptopCharger_4.AC.P, msr.Laptop(2).Pout, LaptopCharger_4.DC.P, msr.Laptop(2).Pout/msr.Laptop(2).Pin, LaptopCharger_4.DC.P/LaptopCharger_4.AC.P, msr.Laptop(2).Pin-msr.Laptop(2).Pout, LaptopCharger_4.Ploss)
fprintf('Lap_5    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.Laptop(3).Pin, LaptopCharger_5.AC.P, msr.Laptop(3).Pout, LaptopCharger_5.DC.P, msr.Laptop(3).Pout/msr.Laptop(3).Pin, LaptopCharger_5.DC.P/LaptopCharger_5.AC.P, msr.Laptop(3).Pin-msr.Laptop(3).Pout, LaptopCharger_5.Ploss)
fprintf('PS(1)    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.PS(1).Pin(pwrSel.PS1), PowerSupply_1.AC.P, msr.PS(1).Pout(pwrSel.PS1), PowerSupply_1.DC.P, msr.PS(1).Pout(pwrSel.PS1)/msr.PS(1).Pin(pwrSel.PS1), PowerSupply_1.DC.P/PowerSupply_1.AC.P, msr.PS(1).Pin(pwrSel.PS1)-msr.PS(1).Pout(pwrSel.PS1), PowerSupply_1.Ploss)
fprintf('PS(2)    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.PS(2).Pin(pwrSel.PS2), PowerSupply_2.AC.P, msr.PS(2).Pout(pwrSel.PS2), PowerSupply_2.DC.P, msr.PS(2).Pout(pwrSel.PS2)/msr.PS(2).Pin(pwrSel.PS2), PowerSupply_2.DC.P/PowerSupply_2.AC.P, msr.PS(2).Pin(pwrSel.PS2)-msr.PS(2).Pout(pwrSel.PS2), PowerSupply_2.Ploss)
fprintf('PS(3)    %f	 %f      %f      %f      %f      %f     %f      %f\n', msr.PS(3).Pin(pwrSel.PS3), PowerSupply_3.AC.P, msr.PS(3).Pout(pwrSel.PS3), PowerSupply_3.DC.P, msr.PS(3).Pout(pwrSel.PS3)/msr.PS(3).Pin(pwrSel.PS3), PowerSupply_3.DC.P/PowerSupply_3.AC.P, msr.PS(3).Pin(pwrSel.PS3)-msr.PS(3).Pout(pwrSel.PS3), PowerSupply_3.Ploss)


%% plot figures
% read harmonics date from 
% harmonics mag
figure
hrms = [1:1:2*numHrm]';
magMsr = zeros(2*numHrm, 1);
magMsr(2:2:end) = vData.(['scenario_', num2str(scn)]).(['data_set_', num2str(data_set)]).phB.mag;
magSim = zeros(2*numHrm, 1);
magSim(2:2:end) = inputVoltageSource.phA.V.mag;
stem(hrms, magMsr)
hold on
grid on
stem(hrms, magSim)
legend('Measurement', 'Simulation')
xlabel('Harmonics')
ylabel('|V| (volts)')
%savefig(['scenario_', num2str(scn), '_data_set_', num2str(data_set), '_phB_mag'])

% waveform
figure
argMsr = zeros(2*numHrm, 1);
argMsr(2:2:end) = vData.(['scenario_', num2str(scn)]).(['data_set_', num2str(data_set)]).phB.arg;
y = real(ifft(fftCoefReconstruct(magMsr, argMsr, 1302)));
plot(inputVoltageSource.phB.wv.v)
hold on
plot(y)

%% create csv file
c = cell(1, 9);
c(1, 1) = {scenarios{scenario}};
c(2:11, 1:2) = {'losses (Simulated)', '';
    'Pin', inputVoltageSource.P;
    'Pout_DC', DC_power;
    'P_loss',  inputVoltageSource.P - DC_power;
    'Effi', (DC_power/inputVoltageSource.P);
    'Losses (msrd)', '';
    'Pin', msr.Pin;
    'Pout_DC', msr.Pout;
    'P_loss',  msr.Pin - msr.Pout;
    'Effi', (msr.Pout / msr.Pin);
    };
c(size(c, 1)+1, 1) = {''};
c(size(c, 1)+1, :) = {'', 'Pin_Msr', 'Pin_sim', 'Pout_msr', 'Pout_sim', 'Effi_msr', 'Effi_sim', 'Ploss_msr', 'Ploss_sim'};
c(size(c, 1)+1:size(c, 1)+9, :) = {'LED_1', msr.Led(1).Pin, LedDriver_1.AC.P, msr.Led(1).Pout, LedDriver_1.DC.P, msr.Led(1).Pout/msr.Led(1).Pin, (LedDriver_1.DC.P/LedDriver_1.AC.P), msr.Led(1).Pin-msr.Led(1).Pout, LedDriver_1.Ploss;
    'LED_2', msr.Led(2).Pin, LedDriver_2.AC.P, msr.Led(2).Pout, LedDriver_2.DC.P, msr.Led(2).Pout/msr.Led(2).Pin, LedDriver_2.DC.P/LedDriver_2.AC.P, msr.Led(2).Pin-msr.Led(2).Pout, LedDriver_2.Ploss;
    'LED_3', msr.Led(3).Pin, LedDriver_3.AC.P, msr.Led(3).Pout, LedDriver_3.DC.P, msr.Led(3).Pout/msr.Led(3).Pin, LedDriver_3.DC.P/LedDriver_3.AC.P, msr.Led(3).Pin-msr.Led(3).Pout, LedDriver_3.Ploss;
	'Laptop_3', msr.Laptop(1).Pin, LaptopCharger_3.AC.P, msr.Laptop(1).Pout, LaptopCharger_3.DC.P, msr.Laptop(1).Pout/msr.Laptop(1).Pin, LaptopCharger_3.DC.P/LaptopCharger_3.AC.P, msr.Laptop(1).Pin-msr.Laptop(1).Pout, LaptopCharger_3.Ploss;
	'Laptop_4', msr.Laptop(2).Pin, LaptopCharger_4.AC.P, msr.Laptop(2).Pout, LaptopCharger_4.DC.P, msr.Laptop(2).Pout/msr.Laptop(2).Pin, LaptopCharger_4.DC.P/LaptopCharger_4.AC.P, msr.Laptop(2).Pin-msr.Laptop(2).Pout, LaptopCharger_4.Ploss;
	'Laptop_5', msr.Laptop(3).Pin, LaptopCharger_5.AC.P, msr.Laptop(3).Pout, LaptopCharger_5.DC.P, msr.Laptop(3).Pout/msr.Laptop(3).Pin, LaptopCharger_5.DC.P/LaptopCharger_5.AC.P, msr.Laptop(3).Pin-msr.Laptop(3).Pout, LaptopCharger_5.Ploss;
	'PS_1', msr.PS(1).Pin(pwrSel.PS1), PowerSupply_1.AC.P, msr.PS(1).Pout(pwrSel.PS1), PowerSupply_1.DC.P, msr.PS(1).Pout(pwrSel.PS1)/msr.PS(1).Pin(pwrSel.PS1), PowerSupply_1.DC.P/PowerSupply_1.AC.P, msr.PS(1).Pin(pwrSel.PS1)-msr.PS(1).Pout(pwrSel.PS1), PowerSupply_1.Ploss;
    'PS_2', msr.PS(2).Pin(pwrSel.PS2), PowerSupply_2.AC.P, msr.PS(2).Pout(pwrSel.PS2), PowerSupply_2.DC.P, msr.PS(2).Pout(pwrSel.PS2)/msr.PS(2).Pin(pwrSel.PS2), PowerSupply_2.DC.P/PowerSupply_2.AC.P, msr.PS(2).Pin(pwrSel.PS2)-msr.PS(2).Pout(pwrSel.PS2), PowerSupply_2.Ploss;
	'PS_3', msr.PS(3).Pin(pwrSel.PS3), PowerSupply_3.AC.P, msr.PS(3).Pout(pwrSel.PS3), PowerSupply_3.DC.P, msr.PS(3).Pout(pwrSel.PS3)/msr.PS(3).Pin(pwrSel.PS3), PowerSupply_3.DC.P/PowerSupply_3.AC.P, msr.PS(3).Pin(pwrSel.PS3)-msr.PS(3).Pout(pwrSel.PS3), PowerSupply_3.Ploss};

writecell(c, ['data_no_tfmr_', scenarios{scenario}, '.csv'], 'Delimiter', 'comma')