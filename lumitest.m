function lumitest(ser_port, screenno, pausedur)
% Simple script to automate monitor luminance measurements 
% using a serial / USB-serial port based photometer. 
%
% To use a different device, reimplement ph_init.m and ph_measure.m!
%
% Arguments:
% ser_port      serial port device to use, e.g. 'COM4' or '/dev/ttyUSB0'
% screenno      screen number to use for Psychtoolbox
% pausedur      pause duration for each measurement (s)
%

% Function argument defaults
if nargin < 1
    ser_port = 'COM4';
end;
if nargin < 2
    screenno = max(Screen('Screens'));
end;
if nargin < 3
    pausedur = 2;
end;

% Create matrix for luminance values: [R; G; B; Sum]
lval = zeros(52 * 4, 3);
lval(1:52, 1) = [0:5:255];
lval(53:104, 2) = [0:5:255];
lval(105:156, 3) = [0:5:255];
lval(157:208, 1:3) = [0:5:255; 0:5:255; 0:5:255]';
lval(:, 4) = 0;

% Set up photometer device
phdev = ph_init(ser_port);

% Set up Psychtoolbox and run measurements
try
    %Screen('Preference', 'VBLTimestampingMode', 1); 
    Screen('Preference', 'Verbosity', 1);    % 1 = print errors
    Screen('Preference', 'Skipsynctests', 1);
    
    [win, wrect] = Screen('OpenWindow', screenno, [0 0 0]);
    Screen('TextFont', win, 'Arial');
    Screen('TextSize', win, 10);
    HideCursor();
    
    % Wait for PTB to initialize
    WaitSecs(5);
    
    % Print baseline luminance
    base_lum = ph_measure(phdev);
    msg = sprintf('Baseline luminance: %2.3f cd/m^2, press ENTER to start measurements sequence!', base_lum); 
    fprintf(msg);
    Screen('DrawText', win, msg, 10, 10, [255 255 255]);
    Screen('Flip', win);
    KbStrokeWait;

    % Measure each luminance value for 1s
    for idx = 1:size(lval, 1)

        % Set screen color / luminance value
        color = lval(idx, 1:3);
        Screen('FillRect', win, color, wrect);

        % Give some status info
        status = [num2str(idx) '/' num2str(size(lval,1))];

        cval = sprintf('%3d %3d %3d', color);
        Screen('DrawText', win, status, 10, 10, [127 127 127]);
        Screen('DrawText', win, cval, 10, 25, [127 127 127]);
        Screen('Flip', win);
        WaitSecs(pausedur);

        % Luminance measurement
        lum = ph_measure(phdev);
        lval(idx,4) = lum;
        
        fprintf('%3d\t%3d\t%3d\t%3d\t%2.3f\n', idx, color(1), color(2), color(3), lum);
        WaitSecs(0.5);
    end

    % Save data to .mat file
    fn = sprintf('lum_%s.mat', datestr(datetime('now'), 'yyyymmdd'));
    save(fn, 'lval', 'base_lum');
    disp('Measurement complete.');
    
    % Show plot
    figure();
    hold on;
    plot(0:5:255, lval(1:52, 4), 'r+');
    plot(0:5:255, lval(53:104, 4), 'g+');
    plot(0:5:255, lval(105:156, 4), 'b+');
    plot(0:5:255, lval(157:208, 4), 'k+');
    xlim([0 255]);
    title('Screen Luminance (use file menu to save figure)');
    xlabel('Pixel RGB Value [0..255]');
    ylabel('Luminance (cd/m^2)');

    Screen('CloseAll');
    fclose(phdev);
    
catch
    fclose(phdev);
    psychrethrow;
    ShowCursor;
    Screen('CloseAll')
end;

end

