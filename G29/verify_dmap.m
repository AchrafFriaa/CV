function p = verify_dmap(D,G)
% This function calculates the PSNR of a given disparity map and the ground
% truth. The value range of both is normalized to [0,255].

%check that range of G is normalized to [0,255]
if (min(min(G)) ~= 0) && (max(max(G)) ~= 255)
    
    %Normalize the values of the Ground Truth of the diparity map
    minG=min(min(G));
    maxG=max(max(G));
    G=((G-minG).*255)./(maxG-minG);

end

%check that range of D is normalized to [0,255]
if (min(min(D)) ~= 0) && (max(max(D)) ~= 255)
    
    %Normalize the values of the Disparity map
    minG=min(min(D));
    maxG=max(max(D));
    D=((G-minD).*255)./(maxD-minD);

end
% Display the Groundtruth of the disparity map
% imshow(G_norm);
% axis image;
% colormap('jet');
% colorbar;
% caxis([0 255]);


% PSNR definition https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
%convert both images to double
G = double(G);
D = double(D);

% calculate the MSE
mse = sum((G(:)-D(:)).^2)/prod(size(G));


% Calculate the  PSNR (in dB)  with peak value 255
p = 10*log10(255*255/mse);

end

