function [T1,R1,T2,R2] = TR_aus_E(E)
% In dieser Funktion sollen die moeglichen euklidischen Transformationen
% aus der Essentiellen Matrix extrahiert werden

%% Input parser
P = inputParser;

% Notwendige Parameter
P.addRequired('E', @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 3 && size(x,3) == 1);

% Input lesen
P.parse(E);

% Variablen extrahieren
E = P.Results.E;

%%

R_Z1 = [0,-1,0;1,0,0;0,0,1];
R_Z2 = [0,1,0;-1,0,0;0,0,1];

% Singulärwertzerlegung von E
[U,S,V] = svd(E);

% Sicherstellen, dass U und V Rotationsmatrizen sind
if det(U) < 0
    U = U*diag([1,1,-1]);
end
if det(V) < 0
    V = V*diag([1,1,-1]);
end

% Rotationsmatrizen berechnen
R1 = U*R_Z1'*V';
R2 = U*R_Z2'*V';

% T-Dach berechnen
T1_hat = U*R_Z1*S*U';
T2_hat = U*R_Z2*S*U';

% Translationen extrahieren
T1 = [T1_hat(3,2);T1_hat(1,3);T1_hat(2,1)];
T2 = [T2_hat(3,2);T2_hat(1,3);T2_hat(2,1)];

end