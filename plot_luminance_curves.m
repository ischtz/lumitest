function plot_luminance_curves(lval, midline)

    figure();
    hold on;
    plot(0:5:255, lval(1:52, 4), 'r.-');
    plot(0:5:255, lval(53:104, 4), 'g.-');
    plot(0:5:255, lval(105:156, 4), 'b.-');
    plot(0:5:255, lval(157:208, 4), 'k.-');

    if nargin > 1
        % Show medium gray line (approx. [127 127 127])
        midval = (lval(182, 4) +  lval(183, 4)) / 2;
        yline(midval, 'k-'); 
    end
    
    xlim([0 255]);
    title('Screen Luminance (use file menu to save figure)');
    xlabel('Pixel RGB Value [0..255]');
    ylabel('Luminance (cd/m^2)');

end