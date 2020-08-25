classdef test < matlab.unittest.TestCase
    %Test your challenge solution here using matlab unit tests
    %
    % Check if your main file 'challenge.m', 'disparity_map.m' and 
    % verify_dmap.m do not use any toolboxes.
    %
    % Check if all your required variables are set after executing 
    % the file 'challenge.m'
    
    properties
    end
    methods (Test)
         
        function test_toolboxes(testCase)
            testCase.verifyEqual(used_toolboxes('challenge.m'),0);
            testCase.verifyEqual(used_toolboxes('verify_dmap.m'),0);
            testCase.verifyEqual(used_toolboxes('disparity_map.m'),0);
        end

        function test_variables(testCase)
            run('challenge.m');
            testCase.verifyEqual(group_number,29);
            testCase.verifyNotEmpty(members);
            testCase.verifyNotEmpty(mail);
            testCase.verifyNotEmpty(D);
            testCase.verifyNotEmpty(R);
            testCase.verifyNotEmpty(T);
            testCase.verifyNotEmpty(p);             
            testCase.verifyGreaterThan(elapsed_time,0);
            testCase.verifyEqual(psnr_fun(D,G),p,'RelTol',0.1);

 
        end
    end
end

function toolbox = used_toolboxes(file_name)

% https://www.mathworks.com/help/matlab/ref/matlab.codetools.requiredfilesandproducts.html
[fList,pList]=matlab.codetools.requiredFilesAndProducts(file_name);

toolbox_list = {pList.Name}'
toolbox_number = size(toolbox_list);

if (toolbox_number>1) %  use greater that 1, because MATLAB is also listed
    toolbox=1;
else
    toolbox=0;
end
end

function psnr_val = psnr_fun(D,G)
% truth. The value range of both is normalized to [0,255].
G_n= normalize(G);
D_n = normalize(D);
% PSNR definition https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
%convert both images to doubl

% calculate the MSE
mse = sum((G_n(:)-D_n(:)).^2)/prod(size(G_n));


% Calculate the  PSNR (in dB)  with peak value 255
p = 10*log10(255*255/mse);
psnr_val = psnr(D_n,G_n,255);
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

