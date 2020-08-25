function p = verify_dmap(D,G)
% This function calculates the PSNR of a given disparity map and the ground
% truth. The value range of both is normalized to [0,255].
G_n= normalize(G);
D_n=normalize(D);
% PSNR definition https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
%convert both images to doubl

% calculate the MSE
mse = sum((G_n(:)-D_n(:)).^2)/prod(size(G_n));


% Calculate the  PSNR (in dB)  with peak value 255
p = 10*log10(255*255/mse);

end
function result = normalize(im)
image = double(im);
max_v= 255;
min_v=0;
Gmax = max(max(image));
Gmin = min(min(image));
norm = (max_v-min_v)*(image-Gmin)./(Gmax-Gmin);
result = norm;
end