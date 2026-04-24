% Program: Test_Servo_Sweep
% Name: Shreyas Muzumdar
% Assignment: Hardware Verification - Servos
% Description: Validates the movement range of the SG90 pan-tilt servos 
% by performing a continuous sweep between 0, 90, and 180 degrees.

clear all;

% 1. Connect to Arduino
if ~exist('a', 'var')
    a = arduino('COM4', 'Uno', 'Libraries', 'Servo'); 
end

% 2. Initialize the Servo object on Pin D9
s = servo(a, 'D9');

fprintf('Servo active on Pin 9. Starting sweep...\n');

try
    while true
        % Move to 0 degrees
        writePosition(s, 0);
        pause(1);
        
        % Move to 90 degrees (Middle)
        writePosition(s, 0.5);
        pause(1);
        
        % Move to 180 degrees
        writePosition(s, 1);
        pause(1);
    end
catch
    fprintf('\nServo test stopped.\n');
end
