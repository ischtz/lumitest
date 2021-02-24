function lumitest(ser_port, screenno, pausedur, win_rect)
% Simple script to automate monitor luminance measurements 
% using a serial / USB-serial port based photometer. 
%
% To use a different device, reimplement ph_init.m and ph_measure.m!
%
% Arguments:
% ser_port      serial port device to use, e.g. 'COM4' or '/dev/ttyUSB0',
%               can be empty matrix [] to fall back to manual input
% screenno      screen number to use for Psychtoolbox
% pausedur      pause duration for each measurement (s)
%

% Function argument defaults
if nargin < 1
    ser_port = [];
end
if nargin < 2
    screenno = max(Screen('Screens'));
end
if nargin < 3
    pausedur = 2;
end
if nargin < 4
    win_rect = [];
end

manual = false;
if isempty(ser_port)
    manual = true;
    fprintf('* Note: no serial port specified, falling back to manual entry!\n');
end

% Create matrix for luminance values: [R; G; B; Sum]
lval = zeros(52 * 4, 3);
lval(1:52, 1) = [0:5:255];
lval(53:104, 2) = [0:5:255];
lval(105:156, 3) = [0:5:255];
lval(157:208, 1:3) = [0:5:255; 0:5:255; 0:5:255]';
lval(:, 4) = 0;

% Set up photometer device
if ~manual
    phdev = ph_init(ser_port);
end

% Set up Psychtoolbox and run measurements
try
    KbName('UnifyKeyNames');
    %Screen('Preference', 'VBLTimestampingMode', 1); 
    Screen('Preference','TextRenderer', 0);
    Screen('Preference', 'Verbosity', 1);    % 1 = print errors
    Screen('Preference', 'SkipSyncTests', 1);
    
    [win, wrect] = Screen('OpenWindow', screenno, [0 0 0], win_rect);
    Screen('TextFont', win, 'Arial');
    Screen('TextSize', win, 10);
    HideCursor();
    
    % Wait for PTB to initialize
    WaitSecs(5);
    
    % Print baseline luminance
    if ~manual
        base_lum = ph_measure(phdev);
        msg = sprintf('Baseline luminance: %2.3f cd/m^2, press ENTER to start measurements sequence!', base_lum); 
    else
        msg = sprintf('Press ENTER to start measurements sequence!');
    end
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
        if ~manual
            lum = ph_measure(phdev);
        else
            response = GetEchoString(win, 'Enter value (cd/m^2): ', 10, 40, [127 127 127], color);
            lum = str2double(response);
        end
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
    if ~manual
        fclose(phdev);
    end
    
catch
    if ~manual
        fclose(phdev);
    end
    ShowCursor;
    Screen('CloseAll')
end

end

