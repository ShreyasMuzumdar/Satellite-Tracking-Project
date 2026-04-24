% Program: Test_TT_Motor
% Name: Shreyas Muzumdar
% Assignment: Hardware Verification - DC Motors
% Description: Drives a TT DC motor at 60% power for 5 seconds using PWM 
% signals to verify the motor driver wiring and directional logic.

clear all;

% Connect to Arduino
a = arduino('COM8', 'Uno'); 

% Define Pins
pwm_pin = 'D11';
dir_pin1 = 'D12';
dir_pin2 = 'D13';

% Set desired speed (60% power)
target_speed = 0.6; 

try
    fprintf('Starting motor at %.0f%% power...\n', target_speed * 100);
    
    % Set Direction (Forward)
    writeDigitalPin(a, dir_pin1, 1);
    writeDigitalPin(a, dir_pin2, 0);
    
    % Apply the constant speed
    writePWMDutyCycle(a, pwm_pin, target_speed);
    
    % Run for 5 seconds
    pause(5);
    
    % Stop the motor
    writePWMDutyCycle(a, pwm_pin, 0);
    fprintf('Motor Stopped.\n');

catch ME
    % Safety stop
    writePWMDutyCycle(a, pwm_pin, 0);
    rethrow(ME);
end
