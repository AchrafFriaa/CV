function three_d_plot(scene_path)


Pprs3 = imread('im0.png'); 
% Colour Image
Pprs1 = rgb_to_gray(Pprs3);
% Grayscale Image
x = 0:size(Pprs1,2)-1;
y = 0:size(Pprs1,1)-1;
[X,Y] = meshgrid(x,y);

figure(1)
meshc(X, Y, Pprs1,Pprs3)    % Mesh Plot
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
colormap('jet')       