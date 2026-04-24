% Program: Satellite_Strike_Final
% Name: Shreyas Muzumdar
% Assignment: Satellite Strike Interactive Game
% Description: An interactive MATLAB game using a joystick to control pan-tilt servos. 
% Uses an ultrasonic sensor for collision detection with "satellites" and displays 
% real-time score/time on an I2C LCD and a digital HUD.

clear all; % Resetting all hardware and variables

try
    fprintf('Initializing High-Speed Engine on COM4...\n');
    a = arduino('COM4', 'Uno', 'Libraries', {'Adafruit/NeoPixel', 'Ultrasonic', 'I2C', 'Servo'});
    
    % --- 1. SETTINGS & CALIBRATION ---
    numLEDs = 8;
    deadzone = 0.08;       % Sensitivity (0.01 to 0.20)
    invertX = true;        % Invert horizontal joystick direction
    xRange = 0.5;          % <--- LIMIT X-RANGE (0.1 = narrow, 0.7 = wide)
    yRange = 0.5;          % Limit Y-range (0.1 to 0.5)
    gameDuration = 15;     % 15-second mission timer
   
    % --- 2. HARDWARE SETUP ---
    strip = addon(a, 'Adafruit/NeoPixel', 'D8', numLEDs); 
    sensor = ultrasonic(a, 'D2', 'D3');
    s_pan = servo(a, 'D9');
    s_tilt = servo(a, 'D10');
    
    % LCD Initialization
    addrs = scanI2CBus(a);
    lcd = device(a, 'I2CAddress', addrs{1});
    init = [0x33, 0x32, 0x28, 0x0C, 0x06, 0x01];
    for cmd = init
        h = bitand(cmd, 0xF0) + 0x0C; l = bitshift(bitand(cmd, 0x0F), 4) + 0x0C;
        write(lcd, [h, h-4, l, l-4]);
    end
    
    % Set the Centered Static Message
    line1 = ' TRY TO HIT THE '; 
    line2 = '   SATELLITES   '; 
    write(lcd, [0x8C, 0x88, 0x0C, 0x08]); 
    for c = double(line1), h=bitand(c,0xF0)+0x0D; l=bitshift(bitand(c,0x0F),4)+0x0D; write(lcd,[h,h-4,l,l-4]); end
    write(lcd, [0xCC, 0xC8, 0x0C, 0x08]); 
    for c = double(line2), h=bitand(c,0xF0)+0x0D; l=bitshift(bitand(c,0x0F),4)+0x0D; write(lcd,[h,h-4,l,l-4]); end
    
    writeColor(strip, 1:numLEDs, [0 0.05 0]); 
catch err
    fprintf('Setup Error: %s\n', err.message); return;
end

% --- 3. FORCE-FRONT DASHBOARD SETUP ---
fig = figure(1); 
clf(fig); 
set(fig, 'Name', 'SATELLITE RADAR DASHBOARD', 'Color', 'black', 'NumberTitle', 'off');
movegui(fig, 'center'); 
shg; 

% 400cm Distance Graph
ax = subplot(2,1,1);
maxPoints = 60; timeData = zeros(1, maxPoints); distData = zeros(1, maxPoints);
hLine = plot(ax, timeData, distData, 'g', 'LineWidth', 2);
ylim(ax, [0 400]); grid on; title('SATELLITE PROXIMITY FEED', 'Color', 'g');
set(ax, 'Color', 'black', 'XColor', 'g', 'YColor', 'g');

% Computer HUD (Score & Time)
txtScore = annotation('textbox', [0.15, 0.2, 0.3, 0.15], 'String', 'SCORE: 0', ...
    'Color', 'cyan', 'FontSize', 30, 'FontWeight', 'bold', 'EdgeColor', 'none');
txtTime = annotation('textbox', [0.55, 0.2, 0.3, 0.15], 'String', 'TIME: 15s', ...
    'Color', 'yellow', 'FontSize', 30, 'FontWeight', 'bold', 'EdgeColor', 'none');

% Game Timing Logic
score = 0; canScore = true;
last_X = 0.5; last_Y = 0.5;
sensorTimer = tic; gameTimer = tic;

% --- 4. MAIN GAME LOOP ---
while toc(gameTimer) < gameDuration && ishandle(fig)
    
    % A. JOYSTICK & SERVOS
    vX = readVoltage(a, 'A0') / 5;
    vY = readVoltage(a, 'A1') / 5;
    
    if invertX, vX = 1 - vX; end
    
    % Apply Ranges (Centers at 0.5)
    targetX = (0.5 - xRange/2) + (vX * xRange); 
    targetY = (0.5 - yRange/2) + (vY * yRange); 
    
    % Only write if movement > deadzone
    if abs(targetX - last_X) > deadzone
        writePosition(s_pan, targetX);
        last_X = targetX;
    end
    if abs(targetY - last_Y) > deadzone
        writePosition(s_tilt, targetY);
        last_Y = targetY;
    end
    
    % B. SENSOR & COMPUTER HUD
    if toc(sensorTimer) >= 0.1
        dist = readDistance(sensor) * 100;
        if isinf(dist) || dist > 400, dist = 400; end
        
        if dist > 5 && dist < 30
            if canScore
                score = score + 100;
                writeColor(strip, 1:numLEDs, [0 0 1]); 
                canScore = false;
            end
        else
            writeColor(strip, 1:numLEDs, [0 0.05 0]); 
            canScore = true;
        end
        
        timeLeft = max(0, round(gameDuration - toc(gameTimer)));
        set(txtScore, 'String', sprintf('SCORE: %d', score));
        set(txtTime, 'String', sprintf('TIME: %ds', timeLeft));
        
        timeData = [timeData(2:end), toc(gameTimer)];
        distData = [distData(2:end), dist];
        set(hLine, 'XData', timeData, 'YData', distData);
        xlim(ax, [max(0, toc(gameTimer)-10), toc(gameTimer)]);
        sensorTimer = tic;
    end
    drawnow limitrate;
end

% --- 5. FINISH ---
writeColor(strip, 1:numLEDs, [1 0 0]); 
set(txtScore, 'String', 'GAME OVER!', 'Color', 'red');

line1Fin = '    Nice job    '; 
line2Fin = sprintf('   Score: %-5d   ', score); 
write(lcd, [0x8C, 0x88, 0x0C, 0x08]); 
for c = double(line1Fin), h=bitand(c,0xF0)+0x0D; l=bitshift(bitand(c,0x0F),4)+0x0D; write(lcd,[h,h-4,l,l-4]); end
write(lcd, [0xCC, 0xC8, 0x0C, 0x08]); 
for c = double(line2Fin), h=bitand(c,0xF0)+0x0D; l=bitshift(bitand(c,0x0F),4)+0x0D; write(lcd,[h,h-4,l,l-4]); end
