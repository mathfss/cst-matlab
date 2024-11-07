% definindo caminho do arquivo e as unidades
addpath(genpath('D:\Matheus\3\CST-MATLAB-API-master'));
cst = actxserver('CSTStudio.application');
mws = cst.invoke('NewMWS');

Geometry = 'mm'; 
Frequency = 'GHz';
Time = 'ns';
TemperatureUnit = 'Kelvin';
Voltage = 'V';
Current = 'A';
Resistance = 'Ohm';
Conductance = 'S';
Capacitance = 'PikoF';
Inductance = 'NanoH';

CstDefineUnits(mws, Geometry, Frequency, Time, TemperatureUnit, Voltage, Current, Resistance, Conductance, Capacitance, Inductance);
ComponentList = 'component1';
CstDefineFrequencyRange(mws, 25, 35);
CstMeshInitiator(mws);

% definindo boundaries
minfrequency = 25;
Xmin = 'open';
Xmax = 'open';
Ymin = 'electric';
Ymax = 'electric';
Zmin = 'magnetic';
Zmax = 'magnetic';
CstDefineOpenBoundary(mws, minfrequency, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax);

XminSpace = 0;
XmaxSpace = 0;
YminSpace = 0;
YmaxSpace = 0;
ZminSpace = 5000;
ZmaxSpace = 5000;
CstDefineBackroundMaterial(mws, XminSpace, XmaxSpace, YminSpace, YmaxSpace, ZminSpace, ZmaxSpace);

CstCopperAnnealedLossy(mws);
CstFR4lossy(mws);

% definindo variaveis e o substrato

l = 4.6;
p = 2.3;
w = 0.36;
t_s = 1.4;
t_cu = 0.035;

Name = 'Substrate';
component = 'component1';
material = 'FR-4 (lossy)';
Xrange = [-l/2, l/2];  % unidade em mm, correspondente a lambda
Yrange = [-l/2, l/2];
Zrange = [0, t_s];  % espessura do substrato t_s
Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange);

% definindo o anel de cobre
Name = 'Ring';
component = 'component1';
material = 'Copper (annealed)';
Xrange = [-p/2, p/2];  % margem considerando p/2 em torno do anel
Yrange = [-p/2, p/2];
Zrange = [t_s, t_s+t_cu];  % espessura de cobre t_Cu
Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange);

% cortando o interior do anel
Name = 'innercut';
component = 'component1';
material = 'Copper (annealed)';
Xrange = [(-p/2)+w, (p/2)-w]; % interior do anel considerando largura w
Yrange = [(-p/2)+w, (p/2)-w];
Zrange = [t_s, t_s+t_cu];
Cstbrick(mws, Name, component, material, Xrange, Yrange, Zrange);

component1 = 'component1:Ring';
component2 = 'component1:innercut';
CstSubtract(mws, component1, component2);

% configurando as portas de entrada e saída
PortNumber = 1;
Xrange = [0, 0];
Yrange = [0, 4.6];
Zrange = [-5035, 6635];
XrangeAdd = [0, 0];
YrangeAdd = [0, 0];
ZrangeAdd = [0, 0];
CstWaveguidePort(mws, PortNumber, Xrange, Yrange, Zrange, XrangeAdd, YrangeAdd, ZrangeAdd, 'Full', 'xmin');

PortNumber = 2;
Xrange = [4.6, 4.6];
Yrange = [0, 4.6];
Zrange = [-5035, 6635];
XrangeAdd = [0, 0];
YrangeAdd = [0, 0];
ZrangeAdd = [0, 0];
CstWaveguidePort(mws, PortNumber, Xrange, Yrange, Zrange, XrangeAdd, YrangeAdd, ZrangeAdd, 'Full', 'xmax');

CstSaveProject(mws);
CstDefineTimedomainSolver(mws, -40);
