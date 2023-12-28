function out = onlineripfilter(raw)

window = 19; %samples
gi_dec = .2;
gi_inc = 1.2;

%initialize with average of first 19 samples
filt = nan(length(raw),1);
filt(window) = mean(raw(1:window));

for i = 20:length(raw)
    if raw(i) > filt(i-1)  % envelope increasing
        filt(i) = filt(i-1) + gi_inc*(abs(raw(i))-filt(i-1));
    else  % envelope decreasing
        filt(i) = filt(i-1) + gi_dec*(abs(raw(i))-filt(i-1));
    end
end

out = filt;

end

