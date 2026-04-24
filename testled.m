% Program: Test_NeoPixel_Strip
% Name: Shreyas Muzumdar
% Assignment: Hardware Verification - RGB LEDs
% Description: Tests the Adafruit NeoPixel strip functionality by cycling 
% colors to ensure all 8 LEDs are addressable and responding to commands.

clear all;
clc;

try
    % 1. Connect with the library enabled
    a = arduino('COM4', 'Uno', 'Libraries', 'Adafruit/NeoPixel');
    
    % 2. Initialize the strip (8 LEDs on Pin D8)
    numLEDs = 8; 
    strip = addon(a, 'Adafruit/NeoPixel', 'D8', numLEDs);
    
    fprintf('Testing %d LEDs on D8...\n', numLEDs);
    
    % 3. Turn the whole strip Red
    writeColor(strip, 1:numLEDs, [1 0 0]);
    pause(2);
    
    % 4. Turn off
    writeColor(strip, 1:numLEDs, [0 0 0]);
    fprintf('Success! All LEDs should have flashed.\n');
    
catch err
    fprintf('Error: %s\n', err.message);
end