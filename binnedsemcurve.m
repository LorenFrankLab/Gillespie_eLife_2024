function [validinds, means, sems] = binnedsemcurve(data, filledbins, centers, binmin,varargin)
 
binmin = 5;
% process varargin and overwrite default values
if (~isempty(varargin))
    assign(varargin{:});
end

for b = 1:length(centers)
        binavg1(1,b) = mean(data(filledbins(:,b),b));
        binsem1(1,b) = std(data(filledbins(:,b),b))/sqrt(sum(filledbins(:,b)));
end
validinds = sum(filledbins)>binmin;
means = binavg1;
sems = binsem1;

end
