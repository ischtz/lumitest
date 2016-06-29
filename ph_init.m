function device_handle = ph_init(ser_port)
% Initialize communication with photometer and set parameters
% Device:  GOSSENS Mavo-Monitor USB
%
% Arguments:
% ser_port      serial port device the photometer is connected to
%

% Device parameters
BAUD = 9600;
DATA = 7;
STOP = 2;
PARITY = 'even';

% Open serial port
mavo = serial(ser_port, 'BaudRate', BAUD, 'DataBits', DATA, 'Parity', PARITY, 'StopBits', STOP);
fopen(mavo);
disp('Setting up photometer...');

% Set auto range
fprintf(mavo,'RANGE:AUTO ON\n');
WaitSecs(0.2);
disp(sprintf('Sent RANGE:AUTO ON, Photometer replied: %s', fscanf(mavo, '%s')));
WaitSecs(0.2);

% Turn echo mode off
fprintf(mavo, 'ECHO OFF\n');
WaitSecs(0.2);
disp(sprintf('Sent ECHO OFF, Photometer replied: %s', fscanf(mavo, '%s')));
WaitSecs(0.2);

% Test request
reply = ph_measure(mavo);
disp(sprintf('Sent PHO?, Photometer replied: %s', reply));

% Return handle
device_handle = mavo;

end
