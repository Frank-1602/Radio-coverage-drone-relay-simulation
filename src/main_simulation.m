%% PROGETTO DI COPERTURA RADIO CON SUPPORTO DRONE
% -------------------------------------------------------------------------
% Obiettivo dello script:
% 1. Simulare la copertura radio di un trasmettitore fisso lungo un percorso
%    definito da coordinate geografiche.
% 2. Valutare la potenza ricevuta nei punti del percorso tramite modello
%    Longley-Rice.
% 3. Attivare un drone ripetitore quando il segnale scende sotto una certa 
%    soglia.
% 4. Aggiornare la posizione del drone in modo da mantenere:
%       - collegamento in ingresso dal trasmettitore fisso;
%       - collegamento in uscita verso la processione/ricevitore mobile.
% 5. Salvare i risultati finali in un file Excel.
%
% -------------------------------------------------------------------------

clearvars
clc

%% 1. INIZIALIZZAZIONE AMBIENTE E MODELLO DI PROPAGAZIONE

% Apertura del visualizzatore geografico con edifici ricavati dal file OSM.
viewer = siteviewer("Buildings", "bitonto1.osm");

% Modello di propagazione radio utilizzato per la stima della potenza.
pm = propagationModel("longley-rice");

% Frequenza di lavoro del sistema radio.
fc = 160e6;   % [Hz]

%% 2. DEFINIZIONE ANTENNA OMNIDIREZIONALE/DIPOLO

% Antenna usata dal trasmettitore fisso e dai ricevitori lungo il percorso.
antenna = design(dipole, fc);
antenna.Length = 0.15;
antenna.Width  = 0.01;

%% 3. DEFINIZIONE ANTENNA DIRETTIVA YAGI-UDA PER IL DRONE

% Antenna direttiva montata sul drone, utile per aumentare la potenza
% ricevuta nel punto servito tramite puntamento azimuth/elevation.
antennaYagi = design(yagiUda, fc);

antennaYagi.NumDirectors = 2;

antennaYagi.ReflectorLength  = 0.98;
antennaYagi.ReflectorSpacing = 0.30;

antennaYagi.DirectorLength   = 0.83;
antennaYagi.DirectorSpacing  = 0.28;

% Modifica delle dimensioni dell'elemento eccitatore della Yagi.
exciter = antennaYagi.Exciter;
exciter.Length = 0.90;
exciter.Width  = 0.01;
antennaYagi.Exciter = exciter;

% Orientamento iniziale della Yagi.
antennaYagi.Tilt = 90;
antennaYagi.TiltAxis = [1 -1 -1];

%% 4. COORDINATE INIZIALI E PERCORSO DELLA PROCESSIONE

% Coordinate di partenza/base del sistema.
StartingLat = 41.114503;
StartingLon = 16.690851;

% Contatore usato solo per visualizzare periodicamente pattern e linea di vista.
b = 0;

% Coordinate geografiche principali del percorso.
% Ogni riga contiene: [latitudine, longitudine].
coords = [
    41.1141886, 16.6914815;
    41.11374,   16.6914815;
    41.1134571, 16.6911703;
    41.1130893, 16.6907412;
    41.1124467, 16.6900492;
    41.1118202, 16.6893572;
    41.1111169, 16.6885686;
    41.1105892, 16.6879755;
    41.1101325, 16.6874552;
    41.1100012, 16.6873218;
    41.1099032, 16.6872795;
    41.1091766, 16.6872433;
    41.108449,  16.6872245;
    41.1080873, 16.6871977;
    41.1079216, 16.6871816;
    41.1075457, 16.6871735;
    41.106901,  16.6871494;
    41.1068894, 16.6875276;
    41.1069075, 16.6878166;
    41.1069096, 16.6880486;
    41.106905,  16.688125;
    41.1069091, 16.6882216;
    41.106908,  16.6883088;
    41.1068843, 16.6883745;
    41.1068525, 16.6884382;
    41.1068257, 16.6884697;
    41.1068141, 16.6885153;
    41.1068029, 16.6885468;
    41.1067893, 16.688579;
    41.1067734, 16.6886118;
    41.106759,  16.688642;
    41.1067408, 16.6886628;
    41.106707,  16.6887265;
    41.106663,  16.688807;
    41.1065958, 16.6889196;
    41.1065059, 16.6890491;
    41.106469,  16.689094;
    41.1064978, 16.6891496;
    41.1065266, 16.6891959;
    41.1065488, 16.689214;
    41.1066024, 16.6892402;
    41.1066499, 16.689265;
    41.1066761, 16.6892744;
    41.1067267, 16.6892838;
    41.1067681, 16.6892891;
    41.1068118, 16.6892988;
    41.106854,  16.6893055;
    41.1069015, 16.6893049;
    41.1069429, 16.6893025;
    41.1070422, 16.6892797;
    41.1070647, 16.6893736;
    41.1070804, 16.6894497;
    41.1071011, 16.6895419;
    41.1071314, 16.6896804;
    41.1071418, 16.689728;
    41.1071473, 16.6897944;
    41.1071577, 16.6899014;
    41.1071683, 16.6900284;
    41.1071802, 16.690133;
    41.107186,  16.6901977;
    41.1071888, 16.6902802;
    41.1071875, 16.6903661;
    41.1071956, 16.6904096;
    41.1072057, 16.6904747;
    41.107211,  16.6905937;
    41.1072178, 16.6906822;
    41.1072282, 16.6907624;
    41.107213,  16.6908207;
    41.1073233, 16.6908666;
    41.1074132, 16.6909028;
    41.1074627, 16.6909243;
    41.1075223, 16.690939;
    41.1075961, 16.6909645;
    41.1076789, 16.6909873;
    41.1077598, 16.691041;
    41.1078164, 16.6911295;
    41.1078654, 16.6912012;
    41.1079381, 16.6913052;
    41.1079942, 16.6914051;
    41.10815,   16.6914618;
    41.1083763, 16.691671;
    41.1088916, 16.6921672;
    41.1092985, 16.6925341;
    41.1106768, 16.693886;
    41.1110203, 16.6942132;
    41.1111203, 16.694295;
    41.1112022, 16.6941783;
    41.1112739, 16.6940871;
    41.1113934, 16.6938889;
    41.1118986, 16.6930172;
    41.1121042, 16.6926529;
    41.1123345, 16.6922238;
    41.1125568, 16.6918375;
    41.112771,  16.6914835;
    41.1135106, 16.6914888;
    41.1137006, 16.6915854;
    41.1141886, 16.6914815
];

%% 5. INTERPOLAZIONE DEL PERCORSO

lat = coords(:,1);
lon = coords(:,2);

% Distanze approssimate tra punti consecutivi in gradi geografici.
d = sqrt(diff(lat).^2 + diff(lon).^2);

FinalRoute = [];

% Passo minimo in gradi. Viene usato per generare punti intermedi lungo
% ogni segmento del percorso.
Step = min(d);

%% 6. CALCOLO DEL PASSO MINIMO IN METRI

% Conversione approssimata delle distanze tra coordinate geografiche in metri.
R = 6371000;   % raggio medio terrestre [m]

d_m = R * sqrt( ...
    (deg2rad(diff(lat))).^2 + ...
    (cos(deg2rad(lat(1:end-1))) .* deg2rad(diff(lon))).^2 ...
);

Step_m = min(d_m);
disp("Passo minimo tra punti del percorso [m]:")
disp(Step_m)

% Interpolazione dei segmenti del percorso.
for i = 1:size(coords,1) - 1
    lat1 = coords(i,1);
    lon1 = coords(i,2);

    lat2 = coords(i+1,1);
    lon2 = coords(i+1,2);

    PathDistance = d(i);

    % Numero di punti interpolati sul segmento corrente.
    PointsforRoute = max(2, round(PathDistance / Step));

    lat_interp = linspace(lat1, lat2, PointsforRoute);
    lon_interp = linspace(lon1, lon2, PointsforRoute);

    Route = [lat_interp', lon_interp'];

    % Evita la duplicazione del primo punto dei segmenti successivi.
    if i > 1
        Route = Route(2:end,:);
    end

    FinalRoute = [FinalRoute; Route]; %#ok<AGROW>
end

% Visualizzazione bidimensionale del percorso interpolato.
figure
plot(FinalRoute(:,2), FinalRoute(:,1), '-o')
xlabel('Longitudine')
ylabel('Latitudine')
grid on
axis equal
title('Percorso interpolato della processione')

%% 7. TRASMETTITORE FISSO E RICEVITORI LUNGO IL PERCORSO

% Trasmettitore fisso iniziale.
tx = txsite( ...
    Name="WalkieTX", ...
    Latitude=41.114503, ...
    Longitude=16.690851, ...
    AntennaHeight=1.5, ...
    TransmitterFrequency=160e6, ...
    TransmitterPower=5, ...
    Antenna=antenna);

% Valutazione preliminare della potenza ricevuta in ogni punto del percorso.
for i = 1:size(FinalRoute,1)
    rx = rxsite( ...
        Name="Sierra1", ...
        Latitude=FinalRoute(i,1), ...
        Longitude=FinalRoute(i,2), ...
        AntennaHeight=1.5, ...
        Antenna=antenna);

    ss = sigstrength(rx, tx, pm);
    disp("Nelle coordinate " + FinalRoute(i,1) + ", " + FinalRoute(i,2) + " è: " + ss);
end

% Mappa di copertura del trasmettitore fisso.
coverage(tx, pm, ...
    "SignalStrengths", -120:10:0, ...
    "MaxRange", 1300, ...
    "Resolution", 10, ...
    "Transparency", 0.6);

% Creazione di tutti i siti riceventi lungo il percorso interpolato.
sites = rxsite( ...
    'Latitude', FinalRoute(:,1), ...
    'Longitude', FinalRoute(:,2), ...
    AntennaHeight=1.5, ...
    Antenna=antenna);

show(sites)

%% 8. PREPARAZIONE STRUTTURA RISULTATI

% Numero totale di punti valutati lungo il percorso.
nPunti = size(FinalRoute,1);

% Tabella finale dei risultati. Le celle vengono inizializzate a NaN e poi
% compilate durante il ciclo principale.
RisultatiFinali = table( ...
    NaN(nPunti,1), ...
    NaN(nPunti,1), ...
    NaN(nPunti,1), ...
    NaN(nPunti,1), ...
    NaN(nPunti,1), ...
    'VariableNames', { ...
        'Potenza_con_drone_dBm', ...
        'Latitudine_drone', ...
        'Longitudine_drone', ...
        'Azimuth_Yagi_deg', ...
        'Elevation_Yagi_deg'});

%% 9. PARAMETRI DI GESTIONE DEL DRONE

v_drone = 10 / 3.6;        % velocità drone [m/s]
v_processione = 0.7 / 3.6; % velocità processione [m/s]

% Tempo impiegato dalla processione per percorrere lo step minimo.
t_Step = Step_m / v_processione;

% Distanza massima percorribile dal drone durante lo stesso intervallo.
copertura_drone = v_drone * t_Step;

baseDrone = [StartingLat, StartingLon];
CoordinateDrone = [StartingLat, StartingLon];

% Variabili di stato del drone.
drone_attivo = false;
drone_rientro = false;

% Angoli correnti dell'antenna Yagi del drone.
az_definitivo = 0;
el_definitivo = 0;

% Contatore di punti consecutivi con segnale sufficiente senza supporto drone.
k = 0;

% Variabile del trasmettitore drone. Viene creata quando il drone è attivo.
DroneTx = [];

%% 10. CICLO PRINCIPALE DI SIMULAZIONE

for i = 1:size(FinalRoute,1)

    % Inizializzazione dei valori da salvare per il punto corrente.
    Pr_con_drone = NaN;
    lat_drone_log = NaN;
    lon_drone_log = NaN;
    az_log = NaN;
    el_log = NaN;

    % Potenza ricevuta dal trasmettitore fisso nel punto corrente.
    ss = sigstrength(sites(i), tx, pm);

    %% 10.1 ATTIVAZIONE O GESTIONE DRONE SE IL SEGNALE È INSUFFICIENTE

    if ss < -65
        k = 0;

        % Caso 1: il drone non è attivo oppure sta rientrando.
        % In questo caso viene attivato/riattivato e puntato verso il sito.
        if drone_attivo == false || drone_rientro == true

            drone_attivo = true;
            drone_rientro = false;

            DroneTx = txsite( ...
                Name="DroneTX", ...
                Latitude=CoordinateDrone(1), ...
                Longitude=CoordinateDrone(2), ...
                AntennaHeight=60, ...
                TransmitterFrequency=160e6, ...
                TransmitterPower=2, ...
                Antenna=antennaYagi);

            % Calcolo dell'azimuth iniziale tra drone e ricevitore corrente.
            az0 = azimuth(DroneTx.Latitude, DroneTx.Longitude, ...
                          sites(i).Latitude, sites(i).Longitude);

            % Distanza orizzontale geodetica tra drone e ricevitore.
            distanza = distance(DroneTx.Latitude, DroneTx.Longitude, ...
                                sites(i).Latitude, sites(i).Longitude, ...
                                wgs84Ellipsoid);

            % Differenza di quota tra ricevitore e drone.
            dh = sites(i).AntennaHeight - DroneTx.AntennaHeight;

            % Elevation iniziale stimata.
            el0 = atan2d(dh, distanza);

            disp("Elevation iniziale stimata [deg]:")
            disp(el0)

            %% 10.1.1 RICERCA ANGOLO DI PUNTAMENTO ANTENNA

            % Prima ricerca grossolana degli angoli.
            az_coarse = az0 - 180:10:180;
            el_coarse = el0 + (-75:5:75);

            Pr_best = -Inf;
            az_best = az0;
            el_best = el0;

            for az = az_coarse
                for el = el_coarse
                    DroneTx.AntennaAngle = [az, el];
                    Pr = sigstrength(sites(i), DroneTx, pm);

                    if Pr > Pr_best
                        Pr_best = Pr;
                        az_best = az;
                        el_best = el;
                    end
                end
            end

            % Seconda ricerca fine attorno al miglior punto trovato.
            az_fine = az_best + (-2:0.25:2);
            el_fine = el_best + (-2:0.25:2);

            for az = az_fine
                for el = el_fine
                    DroneTx.AntennaAngle = [az, el];
                    Pr = sigstrength(sites(i), DroneTx, pm);

                    if Pr > Pr_best
                        Pr_best = Pr;
                        az_best = az;
                        el_best = el;
                    end
                end
            end

            DroneTx.AntennaAngle = [az_best, el_best];

            az_definitivo = DroneTx.AntennaAngle(1);
            el_definitivo = DroneTx.AntennaAngle(2);

            show(DroneTx);
            pattern(DroneTx);
            los(DroneTx, sites(i));

        else

            %% 10.1.2 DRONE GIÀ ATTIVO: RICERCA NUOVA POSIZIONE OTTIMA

            if drone_attivo == true

                center_lat = CoordinateDrone(1);
                center_lon = CoordinateDrone(2);

                % Numero di punti della griglia locale di ricerca.
                N_punti = 5;

                % Griglia di possibili spostamenti del drone in coordinate ENU.
                asseX = linspace(-copertura_drone, copertura_drone, N_punti);
                asseY = linspace(-copertura_drone, copertura_drone, N_punti);

                [Xgrid, Ygrid] = meshgrid(asseX, asseY);
                Zgrid = zeros(size(Xgrid));

                wgs84 = referenceEllipsoid('wgs84');

                % Conversione della griglia locale ENU in coordinate geografiche.
                [lat_grid, lon_grid, ~] = enu2geodetic( ...
                    Xgrid, Ygrid, Zgrid, ...
                    center_lat, center_lon, 50, wgs84);

                lat_list = lat_grid(:);
                lon_list = lon_grid(:);

                x_list = Xgrid(:);
                y_list = Ygrid(:);

                % Ogni riga contiene:
                % [latD, lonD, az_best, el_best, Pr_best, ss_in]
                infoTx = [];

                for j = 1:numel(lat_list)

                    latD = lat_list(j);
                    lonD = lon_list(j);

                    xD = x_list(j);
                    yD = y_list(j);

                    % Ricevitore virtuale sul drone, usato per verificare la
                    % potenza in ingresso ricevuta dal trasmettitore fisso.
                    droneRx = rxsite( ...
                        Name="DroneRX", ...
                        Latitude=latD, ...
                        Longitude=lonD, ...
                        AntennaHeight=50, ...
                        Antenna=antenna, ...
                        AntennaAngle=[0; -90]);

                    ss_in = sigstrength(droneRx, tx, pm);
                    distanza_punto = sqrt(xD^2 + yD^2);

                    % Il punto candidato è valido solo se:
                    % - è raggiungibile dal drone nello step corrente;
                    % - riceve un segnale sufficiente dal trasmettitore fisso.
                    if distanza_punto <= copertura_drone && ss_in > -65

                        DroneTx = txsite( ...
                            Name="DroneTX", ...
                            Latitude=latD, ...
                            Longitude=lonD, ...
                            AntennaHeight=50, ...
                            TransmitterFrequency=160e6, ...
                            TransmitterPower=2, ...
                            Antenna=antennaYagi);

                        % Verifica della linea di vista verso il ricevitore corrente.
                        % Il risultato viene calcolato ma non usato come filtro.
                        visibile = los(DroneTx, sites(i)); 

                        Pr_best = -Inf;
                        az_best = az_definitivo;
                        el_best = el_definitivo;

                        % Ricerca locale degli angoli intorno al puntamento precedente.
                        az_fine = az_definitivo + (-10:1:10);
                        el_fine = el_definitivo + (-1:0.25:1);

                        for az = az_fine
                            for el = el_fine
                                DroneTx.AntennaAngle = [az, el];
                                Pr = sigstrength(sites(i), DroneTx, pm);

                                if Pr > Pr_best
                                    Pr_best = Pr;
                                    az_best = az;
                                    el_best = el;
                                end
                            end
                        end

                        infoTx = [infoTx; latD, lonD, az_best, el_best, Pr_best, ss_in]; %#ok<AGROW>
                    end
                end

                % Se non ci sono posizioni candidate valide, il drone mantiene
                % la posizione precedente e il ciclo passa al punto successivo.
                if isempty(infoTx)
                    warning("Nessuna posizione valida trovata per il drone al punto %d.", i);
                else
                    [Pr_max, idx_best] = max(infoTx(:,5));
                    bestRow = infoTx(idx_best,:);

                    CoordinateDrone = [bestRow(1), bestRow(2)];

                    az_definitivo = bestRow(3);
                    el_definitivo = bestRow(4);

                    % Potenza in ingresso del drone nel punto migliore.
                    InPower = bestRow(6);

                    DroneTx = txsite( ...
                        Name="DroneTX", ...
                        Latitude=CoordinateDrone(1), ...
                        Longitude=CoordinateDrone(2), ...
                        AntennaHeight=50, ...
                        TransmitterFrequency=160e6, ...
                        TransmitterPower=2, ...
                        Antenna=antennaYagi);

                    DroneTx.AntennaAngle = [az_definitivo, el_definitivo];

                    disp("Migliore potenza trovata in uscita:")
                    disp(Pr_max)

                    disp("Potenza in ingresso:")
                    disp(InPower)

                    disp("Coordinate drone aggiornate:")
                    disp(CoordinateDrone)

                    disp("Angolo antenna finale:")
                    disp(DroneTx.AntennaAngle)

                    show(DroneTx);

                    b = b + 1;
                    if b == 15
                        pattern(DroneTx);
                        los(DroneTx, sites(i));
                        b = 0;
                    end
                end
            end
        end
    end

    %% 10.2 RIENTRO DEL DRONE SE IL SEGNALE TORNA SUFFICIENTE

    if ss > -65 && drone_attivo == true

        k = k + 1;

        % Dopo 4 punti consecutivi con segnale sufficiente, il drone rientra.
        if k >= 4
            drone_rientro = true;
            disp("Drone in rientro verso la base")

            wgs84 = referenceEllipsoid('wgs84');

            lat_base = baseDrone(1);
            lon_base = baseDrone(2);

            lat_attuale = CoordinateDrone(1);
            lon_attuale = CoordinateDrone(2);

            % Coordinate della base rispetto alla posizione attuale del drone.
            [x_base, y_base, ~] = geodetic2enu(lat_base, lon_base, 0, ...
                lat_attuale, lon_attuale, 0, wgs84);

            distanza_base = sqrt(x_base^2 + y_base^2);

            disp("Distanza drone-base: " + distanza_base);

            if distanza_base <= copertura_drone

                % Il drone riesce a rientrare alla base nello step corrente.
                CoordinateDrone = baseDrone;

                drone_attivo = false;
                drone_rientro = false;
                k = 0;

                disp("Drone rientrato alla base.")
            else

                % Il drone compie uno spostamento verso la base pari alla
                % distanza massima percorribile nello step corrente.
                versore_x = x_base / distanza_base;
                versore_y = y_base / distanza_base;

                x_step = versore_x * copertura_drone;
                y_step = versore_y * copertura_drone;

                [lat_new, lon_new, ~] = enu2geodetic(x_step, y_step, 0, ...
                    lat_attuale, lon_attuale, 0, wgs84);

                CoordinateDrone = [lat_new, lon_new];

                disp("Nuova posizione del drone durante il rientro:")
                disp(CoordinateDrone)
            end
        end
    end

    %% 10.3 SALVATAGGIO RISULTATI PER IL PUNTO CORRENTE

    if drone_attivo == true || drone_rientro == true

        lat_drone_log = CoordinateDrone(1);
        lon_drone_log = CoordinateDrone(2);

        if ~isnan(az_definitivo) && ~isnan(el_definitivo)
            [az_definitivo, el_definitivo] = safeAntennaAngle(az_definitivo, el_definitivo);
        end

        az_log = az_definitivo;
        el_log = el_definitivo;

        % Potenza ricevuta con il drone, se il trasmettitore drone è presente.
        if isnan(Pr_con_drone) && ~isempty(DroneTx)
            Pr_con_drone = sigstrength(sites(i), DroneTx, pm);
            Pr_con_drone = safeScalar(Pr_con_drone);
        end
    end

    RisultatiFinali.Potenza_con_drone_dBm(i) = Pr_con_drone;
    RisultatiFinali.Latitudine_drone(i) = lat_drone_log;
    RisultatiFinali.Longitudine_drone(i) = lon_drone_log;
    RisultatiFinali.Azimuth_Yagi_deg(i) = az_log;
    RisultatiFinali.Elevation_Yagi_deg(i) = el_log;
end

%% 11. STAMPA E SALVATAGGIO RISULTATI

disp(" ")
disp("RISULTATI FINALI:")
disp(RisultatiFinali)

writetable(RisultatiFinali, "RisultatiDrone.xlsx");

%% 12. FUNZIONI LOCALI

function [az_safe, el_safe] = safeAntennaAngle(az, el)
%SAFEANTENNAANGLE Normalizza gli angoli dell'antenna.
%   L'azimuth viene riportato nell'intervallo [-180, 180], mentre
%   l'elevation viene limitata all'intervallo fisico [-90, 90].

    az_safe = wrapAzimuth180(az);
    el_safe = max(min(el, 90), -90);
end

function az_wrapped = wrapAzimuth180(az)
%WRAPAZIMUTH180 Riporta l'azimuth nell'intervallo [-180, 180].

    az_wrapped = mod(az + 180, 360) - 180;
end

function valore = safeScalar(x)
%SAFESCALAR Converte il risultato di sigstrength in uno scalare robusto.
%   Se il valore è vuoto restituisce NaN, altrimenti restituisce il massimo.

    x = x(:);

    if isempty(x)
        valore = NaN;
    else
        valore = max(x);
    end
end
