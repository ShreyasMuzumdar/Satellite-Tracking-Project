% Program: Test_Ultrasonic_Visual
% Name: Shreyas Muzumdar
% Assignment: Hardware Verification - Ultrasonic Sensor
% Description: Stress tests the HC-SR04 ultrasonic sensor and provides a 
% real-time graphical "radar" feed of distance data up to 400cm.

clear all; % Reset hardware
try
    a = arduino('COM4', 'Uno', 'Libraries', 'Ultrasonic');
    sensor = ultrasonic(a, 'D2', 'D3');
catch err
    fprintf('Check your COM port or connection: %s\n', err.message);
    return;
end

% --- FORCE FIGURE TO FRONT ---
fig = figure(1); 
clf(fig); 
set(fig, 'WindowStyle', 'normal'); 
movegui(fig, 'center'); 

% Graph Settings
maxPoints = 50;
distData = zeros(1, maxPoints);
ax = axes('Parent', fig, 'YLim', [0 400]);
hLine = plot(ax, distData, 'LineWidth', 2);
title('Distance Test'); grid on;

fprintf('Testing... Close the graph to stop.\n');

while ishandle(fig)
    dist = readDistance(sensor) * 100;
    if isinf(dist), dist = 400; end
    
    distData = [distData(2:end), dist];
    set(hLine, 'YData', distData);
    
    drawnow; 
end
