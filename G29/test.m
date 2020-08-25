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
            testCase.verifyGreaterThan(D,0);
            testCase.verifyGreaterThan(R,0);
            testCase.verifyGreaterThan(T,0);
            testCase.verifyGreaterThan(p,0);             
            testCase.verifyGreaterThan(elapsed_time,0);
 
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
