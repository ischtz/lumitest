function result = ph_measure(device)
% Request a single measurement from photometer
% Device:  GOSSENS Mavo-Monitor USB
%
% Arguments:
% device      serial port device the photometer is connected to
%

result = -1;
while result < 0
    
    fprintf(device,'PHO?');
    WaitSecs(0.2);
    reply = fscanf(device, '%s');
    lum = cell2mat(textscan(reply, '%fCD/M2'));
    
    % If not a numerical result, try again, else return this value
    if(~isempty(lum))
        result = lum;
    end;
    
end;

end
