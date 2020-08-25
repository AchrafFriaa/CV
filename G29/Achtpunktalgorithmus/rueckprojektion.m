function repro_error = rueckprojektion(Korrespondenzen, P1, I2, T, R, K)
% Diese Funktion berechnet die projizierten Punkte in Kamera 2 und den
% mittleren Rueckprojektionsfehler

%% Input parser
P = inputParser;

% Notwendige Parameter
P.addRequired('Korrespondenzen',    @(x) isnumeric(x) && size(x,1) == 4 && size(x,3) == 1);
P.addRequired('P1',                 @(x) isnumeric(x) && size(x,1) == 3 && size(x,3) == 1);
P.addRequired('I2',                 @(x) isnumeric(x) && size(x,3) == 1);
P.addRequired('T',                  @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 1);
P.addRequired('R',                  @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 3 && size(x,3) == 1);
P.addRequired('K',                  @(x) isnumeric(x) && size(x,1) == 3 && size(x,2) == 3);

% Input lesen
P.parse(Korrespondenzen,P1,I2,T,R,K);

% Variablen extrahieren
Korrespondenzen = P.Results.Korrespondenzen;
P1              = P.Results.P1;
I2              = P.Results.I2;
T               = P.Results.T;
R               = P.Results.R;
K               = P.Results.K;

%%

Korrespondenzen_number = size(Korrespondenzen,2);
x_2_pix = [Korrespondenzen(3:4,:); ones(1,Korrespondenzen_number)];

% Koordinaten von P1 umrechnen
P2_pix          = K*bsxfun(@plus,R*P1,T);
x_2_pix_rueck   = bsxfun(@times, P2_pix, 1./P2_pix(3,:));

%% Plotten

figure, imagesc(I2), colormap(gray), hold on
repro_error = 0;

% Alle Verbindungslinien zeichnen
for i = 1:Korrespondenzen_number
   plot([x_2_pix(1,i),x_2_pix_rueck(1,i)],[x_2_pix(2,i),x_2_pix_rueck(2,i)],'y');
   repro_error = repro_error + norm(x_2_pix - x_2_pix_rueck);
end

plot(x_2_pix(1,:),x_2_pix(2,:),'g*');
plot(x_2_pix_rueck(1,:),x_2_pix_rueck(2,:),'r*');

repro_error = repro_error/Korrespondenzen_number;

end