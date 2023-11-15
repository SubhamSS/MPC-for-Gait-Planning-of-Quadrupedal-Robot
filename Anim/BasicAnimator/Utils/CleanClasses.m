function CleanClasses()
    % CleanClasses()
    %
    % This function is used to force the animation class to be destroyed
    % and to force all figures to close (the animation figure included).
    % Assuming the destructors are being called properly, this function
    % should not be needed.
    %
    close all force
    clearvars
    clear classes %#ok<CLCLS>
end