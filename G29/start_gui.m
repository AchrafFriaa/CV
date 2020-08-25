classdef start_gui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        DisparitygeneratorUIFigure  matlab.ui.Figure
        LoadImageButton             matlab.ui.control.Button
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
        UIAxes3                     matlab.ui.control.UIAxes
        GenerateDisparityMapButton  matlab.ui.control.Button
        UITable                     matlab.ui.control.Table
    end

    
    properties (Access = private)
        image_l
        image_r
        scene_path

       
    end
    
    methods (Access = private)
        
        
        function [Fx] = sobel_xy(~,input_image)
        % Image gradient computation
        % Interpolationsfilter
            di = [1 2 1];

        % Ableitungsfilter
            dd = [1 0 -1];

        % Ausnutzen der Separabilitt des Sobel-Filters. 
            Fx=conv2(di,dd,input_image,'same');
            Fy=conv2(dd,di,input_image,'same');
         
        end
    % Calculate image gradients in x-direction


      

        
       
            
        
    
    end    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadImageButton
        function show_plot(app, event)

            [app.scene_path] = uigetdir('Path Selector');
            fileList = dir(fullfile(app.scene_path, '*.png'));            
            app.image_l = imread(fullfile(app.scene_path, fileList(1).name));
            app.image_r = imread(fullfile(app.scene_path, fileList(2).name));
            imshow(app.image_l,'parent', app.UIAxes);
            imshow(app.image_r,'parent', app.UIAxes2);
            set(app.GenerateDisparityMapButton, 'enable','on');
            % save the updated handles object
            %guidata(app.DisparitygeneratorUIFigure);
        end

        % Button pushed function: GenerateDisparityMapButton
        function GenerateDisparityMapButtonPushed(app, event)
    addpath(genpath('./Achtpunktalgorithmus'));           
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
    calib_cell = readcell(fullfile(app.scene_path,'calib.txt'),opts);
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
    disp_range = 30;
    block_half = 2;
    block_size = 2 * block_half + 1;
        
        
        
        
        
        
        
                function gray_image = image_convert(Image)
                % berprfe, ob das Bild tatschlich drei Kanle hat
                    if size(Image,3)==1
                        gray_image=uint8(double(Image));
                        return;
        % Umwandlung nach ITU-Formel
                    elseif size(Image,3) == 3
                        R_ = Image(:,:,1);
                        G_ = Image(:,:,2);
                        B_ = Image(:,:,3);
                        gray_image = uint8(0.299*double(R_) + 0.587*double(G_) + 0.114*double(B_));
                    end
        end
        newimage_l = image_convert(app.image_l);
        newimage_r = image_convert(app.image_r);
        
        Merkmale1 = harris_detektor(newimage_l,'segment_length',9,'k',0.05,'min_dist',80,'N',50,'do_plot',false);
        Merkmale2 = harris_detektor(newimage_r,'segment_length',9,'k',0.05,'min_dist',80,'N',50,'do_plot',false);
        Korrespondenzen = punkt_korrespondenzen(newimage_l,newimage_r,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.9,'do_plot',false);
        Korrespondenzen_robust = F_ransac(Korrespondenzen,'tolerance',0.015);
        E = achtpunktalgorithmus(Korrespondenzen_robust,K);
        [T1,R1,T2,R2] = TR_aus_E(E);
        [T,R,lambdas,P1] = rekonstruktion(T1,T2,R1,R2,Korrespondenzen_robust,K);
        tdata = table(T1,R1,'VariableNames',{'Translation','Rotation'})
        
        
        app.UITable.Data = tdata;
        old_size = size(newimage_l);
        if old_size(1)<500
            ratio = [2,2];
        elseif old_size(1)<1000
            ratio = [3,3];
        else
            ratio = [4,4];
        end

        
        new_size = round(old_size(1,1:2)./ratio);
        newimage_l = imresize(newimage_l,new_size);
        newimage_r = imresize(newimage_r,new_size);

        
        
        
        [nrow, ncol, ndim]=size(newimage_r);
        
        Disparity = zeros(size(newimage_l));
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
            template = newimage_r(min_row:max_row, min_col:max_col);

            % Get the number of blocks in this search.
            num_blocks = max_d - min_d + 1;
            block_dis = zeros(num_blocks, 1);
            
            % Calculate difference between template and each of the blocks
            % in the other image
            for k = min_d:max_d
                % Select block from right image at the distance k
                block = newimage_l(min_row:max_row, (min_col + k):(max_col + k));
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

        %Disparity;
        %norm_disparity = 2 .* Disparity ./ (255 - 0);
        %rescale_disparity = rescale(Disparity, 'InputMax', 255);
        %disp_map_ground = Disparity(newimage_l, newimage_r)
        %clf;
    % Display disparity map
        %image(app.UIAxes3,DbasicSubpixel*36.42);


    
    I1 = resizeToInitialSize(Disparity, old_size);
    I2 = resizeToInitialSize(DbasicSubpixel, old_size);
    normD = I1 - min(I1(:));
    normD = normD ./ max(normD(:));
    
    normDsub = I2 - min(I2(:));
    normDsub = normDsub ./ max(normDsub(:));
    
    % Range disparity map 255
    I1 = uint8(255 * normD);
    I2 = uint8(255 * normDsub);

    
    % Disparity Map 
    D = I1;
    
    image(app.UIAxes3, D);
    colormap(app.UIAxes3,'jet');

        

    
    
 

        


        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create DisparitygeneratorUIFigure and hide until all components are created
            app.DisparitygeneratorUIFigure = uifigure('Visible', 'off');
            app.DisparitygeneratorUIFigure.Color = [1 1 1];
            app.DisparitygeneratorUIFigure.Position = [100 100 631 577];
            app.DisparitygeneratorUIFigure.Name = 'Disparity generator';
            app.DisparitygeneratorUIFigure.Scrollable = 'on';

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.DisparitygeneratorUIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @show_plot, true);
            app.LoadImageButton.Position = [271 346 100 22];
            app.LoadImageButton.Text = 'Load Image';

            % Create UIAxes
            app.UIAxes = uiaxes(app.DisparitygeneratorUIFigure);
            title(app.UIAxes, 'Left Scene')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Box = 'on';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.BackgroundColor = [1 1 1];
            app.UIAxes.Position = [13 381 300 185];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.DisparitygeneratorUIFigure);
            title(app.UIAxes2, 'Right Scene')
            xlabel(app.UIAxes2, '')
            ylabel(app.UIAxes2, '')
            app.UIAxes2.Box = 'on';
            app.UIAxes2.XTick = [];
            app.UIAxes2.YTick = [];
            app.UIAxes2.BackgroundColor = [1 1 1];
            app.UIAxes2.Position = [326 380 300 185];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.DisparitygeneratorUIFigure);
            title(app.UIAxes3, 'Disparity Map')
            xlabel(app.UIAxes3, '')
            ylabel(app.UIAxes3, '')
            app.UIAxes3.Box = 'on';
            app.UIAxes3.XTick = [];
            app.UIAxes3.YTick = [];
            app.UIAxes3.BackgroundColor = [1 1 1];
            app.UIAxes3.Position = [16 73 297 210];

            % Create GenerateDisparityMapButton
            app.GenerateDisparityMapButton = uibutton(app.DisparitygeneratorUIFigure, 'push');
            app.GenerateDisparityMapButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateDisparityMapButtonPushed, true);
            app.GenerateDisparityMapButton.Enable = 'off';
            app.GenerateDisparityMapButton.Tooltip = {''};
            app.GenerateDisparityMapButton.Position = [250 52 142 22];
            app.GenerateDisparityMapButton.Text = 'Generate Disparity Map';

            % Create UITable
            app.UITable = uitable(app.DisparitygeneratorUIFigure);
            app.UITable.ColumnName = {'Translation'; 'Rotation'};
            app.UITable.RowName = {};
            app.UITable.Position = [343 127 266 110];

            % Show the figure after all components are created
            app.DisparitygeneratorUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = start_gui

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.DisparitygeneratorUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.DisparitygeneratorUIFigure)
        end
    end
end