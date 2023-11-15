function cleanWaitbar()
    % Closes all waitbars
    % 
    
    WB = findall(0,'Type','figure','Tag','TMWWaitbar');
    delete(WB);
end