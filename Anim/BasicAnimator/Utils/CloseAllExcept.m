function CloseAllExcept(str)
    % CloseAllExcept(str);
    %
    % Closes all of the figures on the screen except those specified by
    % str; the reference to the figure may be the name, tag, or the number 
    % of the figure. This function will also close any existing waitbars.
    %
    % Inputs:
    %   str - A char array specifying a single name, a vector of figure
    %       numbers, or a cell array with any combination of figure names
    %       and numbers.
    %
    
    if isvector(str) && isnumeric(str)
        str = num2cell(str);
    elseif ischar(str)
        str = {str};
    end
    allFigs = findall(0,'type','figure');
    valid = ones(1,length(allFigs));
    for n = 1:length(allFigs)
        for j = 1:numel(str)
            if ischar(str{j})
                valid(n) = valid(n) & ~any([strcmp(allFigs(n).Name,str{j}),strcmp(allFigs(n).Tag,str{j})]);
            elseif isnumeric(str{j}) && ~isempty(allFigs(n).Number)
                valid(n) = valid(n) & (allFigs(n).Number~=str{j});
            else
                valid(n) = 1;
            end
        end
    end
    allFigs = allFigs(logical(valid));
    delete(allFigs);
end

