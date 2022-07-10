
function orbit_simulator()
    
    global db
    
    
    [planets_struct, space, planets_arr] = solar_system_creator();

    h_fig = figure();
    h_ax = axes(h_fig);
    h_space_ax = space.plot_space(h_ax, planets_struct);
    hold(h_space_ax, 'on');
    
    n_planets = numel(planets_arr);
    
    for planet = 1:n_planets
        planets_arr(planet).plot_planet(h_space_ax);
    end
    clear planet;

    %% Loop:
    db.year = 0;
    years = 10;
%     days = years * planets_arr(2).T;    % planets_arr.T = earth.year = 360 days
    days = 365;
    planets_cell = cell(1, n_planets);
    locs = zeros(2, days);
    
    for planet = 1:n_planets
        planets_cell{planet} = locs;
    end
    
    clear planet
    
    for day = 1:days
        
        
        for planet = 1:n_planets
            planets_arr(planet).orbite_a_planet();
            planets_arr(planet).plot_planet(h_space_ax);
            
            
            planets_cell{planet}(1, day) = planets_arr(planet).location(1);
            planets_cell{planet}(2, day) = planets_arr(planet).location(2);
            
        end
        
        
%      
%          days = 365;
%     planets_cell = cell(1, handles.n_planets);
%     locs = zeros(2, days);
%     for day = 1:days
%         
%         
%         for planet = 1:handles.n_planets
%             handles.planets_arr(planet).orbite_a_planet(space);
%             handles.planets_arr(planet).plot_planet(h_space_ax);
%             
%             
%             locs(1, day) = handles.planets_arr(planet).location(1);
%             locs(2, day) = handles.planets_arr(planet).location(2);
%             
%             if day == days
%                     planets_cell{planet} = locs;
%             end
% 
%         end
%         
%         
        if mod(day, planets_arr(2).T) == 0
            db.year = db.year + 1;
            h_space_ax.Title.String = [num2str(db.year), ' Years'];
        end
        
        drawnow();
    end
    
end

function [planets_struct, space, planets_arr] = solar_system_creator()

    earth.name              = 'Earth';
    earth.size_km           = 6370;
    earth.size_norm         = earth.size_km / earth.size_km;
    earth.distance_Mk       = 150;
    earth.distance_norm     = earth.distance_Mk / earth.distance_Mk;
    earth.color             = 'c';
    earth.year              = 365; % in days resolution
    earth.timeperiod        = 1;
    earth.timeperiod_days   = earth.year * earth.timeperiod;

    sun.name                = 'Sun';
    sun.size_km             = 696340;
    sun.size_norm           = sun.size_km / earth.size_km;
    sun.distance_Mk         = 0;
    sun.distance_norm       = 0;
    sun.color               = 'y';
    sun.year                = 0; 
    sun.timeperiod          = 0;
    sun.timeperiod_days     = sun.year * sun.timeperiod;

    mars.name               = 'Mars';
    mars.size_km            = 3389.5;
    mars.size_norm          = mars.size_km / earth.size_km;
    mars.distance_Mk        = 228.82;
    mars.distance_norm      = mars.distance_Mk / earth.distance_Mk;
    mars.color              = 'r';
    mars.year               = 687;
    mars.timeperiod         = 1;
    mars.timeperiod_days    = mars.year * mars.timeperiod;
    
    mercury.name            = 'Mercury';
    mercury.size_km         = 2439.7;
    mercury.size_norm       = mercury.size_km / earth.size_km;
    mercury.distance_Mk     = 58.171;
    mercury.distance_norm   = mercury.distance_Mk / earth.distance_Mk;
    mercury.color           = [139/255, 125/255, 130/255];
    mercury.year            = 88;
    mercury.timeperiod      = 1;
    mercury.timeperiod_days = mercury.year * mercury.timeperiod;
    
    venus.name              = 'Venus';
    venus.size_km           = 6051.8;
    venus.size_norm         = venus.size_km / earth.size_km;
    venus.distance_Mk       = 108.5;
    venus.distance_norm     = venus.distance_Mk / earth.distance_Mk;
    venus.color             = [219/255, 206/255, 202/255];
    venus.year              = 225;
    venus.timeperiod        = 1;
    venus.timeperiod_days   = venus.year * venus.timeperiod;
    
    jupiter.name            = 'Jupiter';
    jupiter.size_km         = 69911;
    jupiter.size_norm       = jupiter.size_km / earth.size_km;
    jupiter.distance_Mk     = 903.36 ;
    jupiter.distance_norm   = jupiter.distance_Mk / earth.distance_Mk;
    jupiter.color           = [216/255, 202/255, 157/255];
    jupiter.year            = 12 * earth.year;
    jupiter.timeperiod      = 1;
    jupiter.timeperiod_days = jupiter.year * jupiter.timeperiod;
    
    saturn.name            = 'Saturn';
    saturn.size_km         = 58232;
    saturn.size_norm       = saturn.size_km / earth.size_km;
    saturn.distance_Mk     = 1.434 * 1000 ;
    saturn.distance_norm   = saturn.distance_Mk / earth.distance_Mk;
    saturn.color           = [171/255, 96/255, 74/255];
    saturn.year            = 29 * earth.year;
    saturn.timeperiod      = 1;
    saturn.timeperiod_days = saturn.year * saturn.timeperiod;
    
    uranus.name            = 'Uranus';
    uranus.size_km         = 25362 ;
    uranus.size_norm       = uranus.size_km / earth.size_km;
    uranus.distance_Mk     = 2.871 * 1000;
    uranus.distance_norm   = uranus.distance_Mk / earth.distance_Mk;
    uranus.color           = [172/255, 229/255, 238/255]; 
    uranus.year            = 84 * earth.year;
    uranus.timeperiod      = 1;
    uranus.timeperiod_days = uranus.year * uranus.timeperiod;
    
    neptune.name            = 'Neptune';
    neptune.size_km         = 24622 ;
    neptune.size_norm       = neptune.size_km / earth.size_km;
    neptune.distance_Mk     = 4.4759 * 1000;
    neptune.distance_norm   = neptune.distance_Mk / earth.distance_Mk;
    neptune.color           = 'b';
    neptune.year            = 165 * earth.year;
    neptune.timeperiod      = 1;
    neptune.timeperiod_days = neptune.year * neptune.timeperiod;
    
    
     
    
    
    planets_struct = [sun, earth, mars, mercury, venus, jupiter, saturn, uranus, neptune];
    
    planets_length = length(planets_struct);
    distances      = zeros(1, planets_length);
    for field = 1:planets_length
        distances(field) = planets_struct(field).distance_norm;
    end
    
    max_distances = max(distances);
    space         = Space(max_distances);
    
    Sun     = Planet(sun.name, sun.size_norm, sun.distance_norm, sun.color, sun.timeperiod_days);
    Earth   = Planet(earth.name, earth.size_norm , earth.distance_norm, earth.color, earth.timeperiod_days);
    Mars    = Planet(mars.name, mars.size_norm , mars.distance_norm, mars.color, mars.timeperiod_days);
    Mercury = Planet(mercury.name, mercury.size_norm , mercury.distance_norm, mercury.color, mercury.timeperiod_days);
    Venus   = Planet(venus.name, venus.size_norm , venus.distance_norm, venus.color, venus.timeperiod_days);
    Jupiter = Planet(jupiter.name, jupiter.size_norm , jupiter.distance_norm, jupiter.color, jupiter.timeperiod_days);
    Saturn = Planet(saturn.name, saturn.size_norm , saturn.distance_norm, saturn.color, saturn.timeperiod_days);
    Uranus  = Planet(uranus.name, uranus.size_norm , uranus.distance_norm, uranus.color, uranus.timeperiod_days);
    Neptune = Planet(neptune.name, neptune.size_norm , neptune.distance_norm, neptune.color, neptune.timeperiod_days);

    
    planets_arr = [Sun, Earth, Mars, Mercury, Venus, Jupiter, Saturn, Uranus, Neptune];





end