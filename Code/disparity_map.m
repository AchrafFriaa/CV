function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.
    
    fprintf('---------------------------------------------------------------\n')
    fprintf('| Starting Processing...\n')
    fprintf('---------------------------------------------------------------\n\n')

    %% Automatic extraction of left/right images given scene path
    addpath(genpath('Achtpunktalgorithmus'));
    fileList = dir(fullfile(scene_path, '*.png'));
    % num_files = size(fileList)
    %% Define Parameters
    disp_range =20;
    block_half = 5;
    block_size = 2 * block_half + 1;
    
    
    %% Read Image
    image_l = imread(fullfile(scene_path, fileList(1).name));
    image_r = imread(fullfile(scene_path, fileList(2).name));
    
    %% Automatic extraction of camera parameters
    varNames = {'name','value'} ;
    varTypes = {'char', 'char'} ;
    delimiter = '=';
    dataStartLine = 1;
    extraColRule = 'ignore';
    opts = delimitedTextImportOptions('VariableNames',varNames,...
                                    'VariableTypes',varTypes,...
                                    'Delimiter',delimiter,...
                                    'DataLines', dataStartLine,...
                                    'ExtraColumnsRule',extraColRule); 
    calib_cell = readcell(fullfile(scene_path,'calib.txt'),opts);
    cam = cell(1,2);
    
    for i = 1:2
        cam{1,i} = calib_cell{i,2};
        cam{1,i} = regexprep(cam{1,i}, '\[(.*)\]', '$1');
        cam{1,i} = regexprep(cam{1,i}, '\;', '');
        cam{1,i} = regexp(cam{1,i}, '\s', 'split');
        cam{1,i} = str2double(cam{1,i});
        cam{1,i} = reshape(cam{1,i},[3,3])';
    end
    
    % Calibration Matrix K
    K = cam{1,1};
    
    %% RGB to Grayscale conversion to reduce complexity
    function gray_image = image_convert(Image)
        % �berpr�fe ob Grayscale image
        if size(Image,3)==1
            gray_image=uint8(double(Image));
            return;
        % Umwandlung nach ITU-Formel
        elseif size(Image,3) == 3
            R_ = Image(:,:,1);
            G_ = Image(:,:,2);
            B_ = Image(:,:,3);
            gray_image = uint16(0.299*double(R_) + 0.587*double(G_) + 0.114*double(B_));
        end
    end
    image_l = image_convert(image_l);
    image_r = image_convert(image_r);
   
    %% Calculate Rotation R and Translation T with Ransac & essential Matrix
    
    % Specify variables
    
    %% Harris-Merkmale berechnen
    Merkmale1 = harris_detektor(image_l,'segment_length',9,'k',0.05,'min_dist',80,'N',50);
    Merkmale2 = harris_detektor(image_r,'segment_length',9,'k',0.05,'min_dist',80,'N',50);
    %% Korrespondenzsch�tzung
    
    tic;
    Korrespondenzen = punkt_korrespondenzen(image_l,image_r,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.9,'do_plot',false);
    zeit_korrespondenzen = toc;
    
    disp(['Es wurden ' num2str(size(Korrespondenzen,2)) ' Korrespondenzpunktpaare in ' num2str(zeit_korrespondenzen) 's gefunden.'])
    %%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
    Korrespondenzen_robust = F_ransac(Korrespondenzen,'tolerance',0.015);
    disp(['Es wurden ' num2str(size(Korrespondenzen_robust,2)) ' robuste Korrespondenzpunktpaare mittels RanSaC bestimmt.'])
    
    %% Berechne die Essentielle Matrix
    E = achtpunktalgorithmus(Korrespondenzen_robust,K);
    disp(E);
    
    %% Extraktion der m?glichen euklidischen Bewegungen aus der Essentiellen Matrix und 3D-Rekonstruktion der Szene
    [T1,R1,T2,R2] = TR_aus_E(E);
    [T,R,lambdas] = rekonstruktion(T1,T2,R1,R2,Korrespondenzen_robust,K);

    %%  Downsample Images for faster computation
    old_size = size(image_l);
    % Ratio that downsamples the image for computation
    % [2,2] means downsampling 50%
    if old_size(1)<500
        ratio = [2,2];
    elseif old_size(1)<1000
        ratio = [3,3];
    else
        ratio = [4,4];
    end
    new_size = round(old_size(1,1:2)./ratio);
    image_l = imresize(image_l,new_size);
    image_r = imresize(image_r,new_size);
    
    %%  Block matching
    [nrow, ncol, ndim]=size(image_r);
    Disparity = zeros(size(image_l));
    
    % Iterate over rows
    for i = 1:nrow
        % Set min/max row bounds for the template and blocks.
        min_row = max(1, i - block_half);
        max_row = min(nrow, i + block_half);
        
        % Iterate over columns
        for j = 1:ncol
            % Specify max&min number of columns
            min_col = max(1, j - block_half);
            max_col = min(ncol, j + block_half);
            
            % Only search to the right for matching blocks
            min_d = 0;
            % min_d = max(-disp_range, 1-min_col);
            max_d = min(disp_range, ncol - max_col);
            
            % Select the block from the left image to use as the template.
            template = image_r(min_row:max_row, min_col:max_col);

            % Get the number of blocks in this search.
            num_blocks = max_d - min_d + 1;
            block_dis = zeros(num_blocks, 1);
            
            % Calculate difference between template and each of the blocks
            % in the other image
            for k = min_d:max_d
                % Select block from right image at the distance k
                block = image_l(min_row:max_row, (min_col + k):(max_col + k));
                % Set index for block_dis
                block_index = k - min_d + 1;
                % Compute block difference through sum of absolute
                % differences 
                % block_dis(block_index, 1) = sum(sum(abs(template - block).^2));
                % x = template - block;
                block_dis(block_index, 1) = sum(sum(abs(template - block).^2));
            end
            % Sort vector containing disparities & get index of first one
            [temp_unused, sorted_dis] = sort(block_dis);
            index_d_opt = sorted_dis(1, 1);
            
            Disparity(i, j) = index_d_opt + min_d;
            
            % Get the 1-based index of the closest-matching block.
            index_d_opt = sorted_dis(1, 1);

            % Convert the 1-based index of this block back into an offset.
            % This is the final disparity value produced by basic block matching.
            d = index_d_opt + min_d - 1;

            % Calculate a sub-pixel estimate of the disparity by interpolating.
            % Sub-pixel estimation requires a block to the left and right, so we 
            % skip it if the best matching block is at either edge of the search
            % window.
            if ((index_d_opt == 1) || (index_d_opt == num_blocks))
                % Skip sub-pixel estimation and store the initial disparity value.
                DbasicSubpixel(i, j) = d;
            else
                % Grab the SAD values at the closest matching block (C2) and it's 
                % immediate neighbors (C1 and C3).
                C1 = block_dis(index_d_opt - 1);
                C2 = block_dis(index_d_opt);
                C3 = block_dis(index_d_opt + 1);

                % Adjust the disparity by some fraction.
                % We're estimating the subpixel location of the true best match.
                DbasicSubpixel(i, j) = d - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
            end
        end
        % Update progress every 10th row.
        if (mod(i, 50) == 0)
            fprintf('  Image row %d / %d (%.0f%%)\n', i, nrow, (i / nrow) * 100);
        end
    end
    
    I1 = resizeToInitialSize(Disparity, old_size);
    I2 = resizeToInitialSize(DbasicSubpixel, old_size);
    % Normalize images 
    normD = I1 - min(I1(:));
    normD = normD ./ max(normD(:));
    
    normDsub = I2 - min(I2(:));
    normDsub = normDsub ./ max(normDsub(:));
    
    % Range disparity map 255
    I1 = uint8(255 * normD);
    I2 = uint8(255 * normDsub);
    
    D = I2;
end