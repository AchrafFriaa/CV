function [T,R, lambdas, P1] = rekonstruktion(T1,T2,R1,R2,Korrespondenzen,K)
% Funktion zur Bestimmung der korrekten euklidischen Transformation, der
% Tiefeninformation und der 3D Punkte der Merkmalspunkte in Bild 1

%% Input parser
P = inputParser;
P1 = 0;

% Notwendige Parameter
P.addRequired('T1',                 @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 1);
P.addRequired('T2',                 @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 1);
P.addRequired('R1',                 @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 3 && size(x,3) == 1);
P.addRequired('R2',                 @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 3 && size(x,3) == 1);
P.addRequired('Korrespondenzen',    @(x) isnumeric(x) && size(x,1) == 4 && size(x,3) == 1);
P.addRequired('K',                  @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 3);

% Input lesen
P.parse(T1,T2,R1,R2,Korrespondenzen,K);

% Variablen extrahieren
T1              = P.Results.T1;
T2              = P.Results.T2;
R1              = P.Results.R1;
R2              = P.Results.R2;
Korrespondenzen = P.Results.Korrespondenzen;
K               = P.Results.K;

%%

Korrespondenzen_number = size(Korrespondenzen,2);
R(1:3,1:3,1)    = R1;
R(1:3,1:3,2)    = R1;
R(1:3,1:3,3)    = R2;
R(1:3,1:3,4)    = R2;
T(1:3,1)        = T1;
T(1:3,2)        = T2;
T(1:3,3)        = T1;
T(1:3,4)        = T2;

% In kalibrierte Koordinaten umrechnen
x_1 = K\[Korrespondenzen(1:2,:); ones(1,Korrespondenzen_number)];
x_2 = K\[Korrespondenzen(3:4,:); ones(1,Korrespondenzen_number)];

M_1 = zeros(3*Korrespondenzen_number,Korrespondenzen_number+1,4);
M_2 = M_1;

% Berechnen der Matrizen M_1 und M_2 für alle vier Fälle
for k = 1:Korrespondenzen_number
    R1x1 = R1*x_1(:,k);
       
    M_1((k-1)*3+1:k*3,k,1)      = hat(x_2(:,k))*R1x1;
    M_1((k-1)*3+1:k*3,end,1)    = hat(x_2(:,k))*T(:,1);
    M_2((k-1)*3+1:k*3,k,1)      = hat(R1x1)*x_2(:,k);
    M_2((k-1)*3+1:k*3,end,1)    = -hat(R1x1)*T(:,1);
    
    M_1((k-1)*3+1:k*3,end,2)    = hat(x_2(:,k))*T(:,2);
    M_2((k-1)*3+1:k*3,end,2)    = -hat(R1x1)*T(:,2);
    
    R2x1 = R2*x_1(:,k);
    
    M_1((k-1)*3+1:k*3,k,3)      = hat(x_2(:,k))*R2x1;
    M_1((k-1)*3+1:k*3,end,3)    = hat(x_2(:,k))*T(:,3);
    M_2((k-1)*3+1:k*3,k,3)      = hat(R2x1)*x_2(:,k);
    M_2((k-1)*3+1:k*3,end,3)    = -hat(R2x1)*T(:,3);
    
    M_1((k-1)*3+1:k*3,end,4)    = hat(x_2(:,k))*T(:,4);
    M_2((k-1)*3+1:k*3,end,4)    = -hat(R2x1)*T(:,4);
end

M_1(:,1:Korrespondenzen_number,2) = M_1(:,1:Korrespondenzen_number,1);
M_2(:,1:Korrespondenzen_number,2) = M_2(:,1:Korrespondenzen_number,1);
M_1(:,1:Korrespondenzen_number,4) = M_1(:,1:Korrespondenzen_number,3);
M_2(:,1:Korrespondenzen_number,4) = M_2(:,1:Korrespondenzen_number,3);

lambdas_1 = zeros(Korrespondenzen_number+1,4);
lambdas_2 = lambdas_1;

% Berechnen aller Lambdas
for i = 1:4
   [~,~,V] = svd(M_1(:,:,i));
   lambdas_1(:,i) = V(:,end);
   lambdas_1(:,i) = lambdas_1(:,i) ./ lambdas_1(end,i);
   
   [~,~,V] = svd(M_2(:,:,i));
   lambdas_2(:,i) = V(:,end);
   lambdas_2(:,i) = lambdas_2(:,i) ./ lambdas_2(end,i);
end

lambdas_1 = lambdas_1(1:end-1,:);
lambdas_2 = lambdas_2(1:end-1,:);

% Geometrisch plausible Matrizen R und T herausfinden
[~,index_max]   = max(sum((lambdas_1>0) + (lambdas_2>0)));
R               = R(:,:,index_max);
T               = T(:,index_max);
lambdas         = abs([lambdas_1(:,index_max),lambdas_2(:,index_max)]);

%% Plotten
%{
figure, hold on, grid on, axis equal, zoom on
xlabel('x');
ylabel('y');
zlabel('z');

P1 = zeros(3,Korrespondenzen_number);

% 3D-Punkte rekonstruieren und plotten
for i = 1:Korrespondenzen_number
   P1(:,i) = x_1(:,i)*lambdas(i,1);
   plot3([x_1(1,i),P1(1,i)], [x_1(2,i),P1(2,i)], [x_1(3,i),P1(3,i)]);
end

plot3(P1(1,:),P1(2,:),P1(3,:),'.k');
plot3(x_1(1,:),x_1(2,:),x_1(3,:),'g*');

% Kameras plotten
Image1          = imread('szeneL.jpg');
image_height    = size(Image1,1);
image_width     = size(Image1,2);
corners_pix     = [0,image_width,image_width,0,0;0,0,image_height,image_height,0;1,1,1,1,1];
corners1        = K\corners_pix;

% Kamera 1
%plot3(corners1(1,:),corners1(2,:),corners1(3,:),'k');

xImage1 = [corners1(1,1),corners1(1,2);corners1(1,4),corners1(1,3)];
yImage1 = [corners1(2,1),corners1(2,2);corners1(2,4),corners1(2,3)];
zImage1 = [corners1(3,1),corners1(3,2);corners1(3,4),corners1(3,3)];
%surf(xImage1,yImage1,zImage1,'CData',Image1,'FaceColor','texturemap');

% Kamera 2
corners2 = R\bsxfun(@plus,corners1,-T);
%plot3(corners2(1,:),corners2(2,:),corners2(3,:),'k');

x_2_plot = R\bsxfun(@plus,x_2,-T);
%plot3(x_2_plot(1,:),x_2_plot(2,:),x_2_plot(3,:),'g*');

Image2 = imread('szeneR.jpg');
xImage2 = [corners2(1,1),corners2(1,2);corners2(1,4),corners2(1,3)];
yImage2 = [corners2(2,1),corners2(2,2);corners2(2,4),corners2(2,3)];
zImage2 = [corners2(3,1),corners2(3,2);corners2(3,4),corners2(3,3)];
%surf(xImage2,yImage2,zImage2,'CData',Image2,'FaceColor','texturemap');

% Kamerawinkel und -position festlegen
camva(5.1789);
campos([12.3069,-36.0251,21.0613]);
%}
end

%% Dach-Operator
function [V_hat] = hat(V)
    V_hat = [0,-V(3),V(2);V(3),0,-V(1);-V(2),V(1),0];
end
