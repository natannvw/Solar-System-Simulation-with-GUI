classdef Planet < handle & matlab.mixin.Heterogeneous
    % todo API
    
    properties
    
        % Appearence:
        name
        label
        size
        color
        
        % Parameters:
        radius                 % distance from sun
        theta
        location
        
        T
        omega
        
        illustration
        rings
        x_ring
        y_ring
        
    end
    
    methods
        
        function obj = Planet(name, size, distance, color, year) %h_ax) %location, velocity) %?
            
                % todo API
            
            % Appearence:
            obj.name = name;
            obj.size = size;
            obj.color = color;
            
            % Parameters:
            obj.radius = distance;             % distance from sun in AU
            obj.theta = 0;                     % [radians]

            [x, y] = pol2cart(obj.theta, obj.radius);
            obj.location = [x, y];

            obj.T = year;                  % time period [months]
            
            if year == 0
                obj.T = 1;
            end
                
            obj.omega = (2 * pi) / obj.T;  %  angular velocity [1/sec]
    
        end
        
        function plot_planet(obj, h_ax)
            
            if ~exist('h_ax', 'var')
                h_fig = figure()    ;
                h_ax  = axes(h_fig) ;
            end
            
            % plot the planet (illustration):
            if isempty(obj.illustration)
                obj.illustration = scatter(h_ax, obj.location(1), obj.location(2),...
                    obj.size, obj.color, 'filled');
                
                if strcmp(obj.name, 'Saturn')
                    x1 = obj.location(1) + 1/(obj.location(1));
                    y1 = obj.location(2) + 1/(obj.location(1));             % y's shift = 0
                    x2 = obj.location(1) - 1/(obj.location(1));
                    y2 = obj.location(2) - 1/(obj.location(1));             % y's shift = 0
                    e  = 0.96;
                    
                    a = 1/2*sqrt((x2-x1)^2+(y2-y1)^2);
                    b = a*sqrt(1-e^2);
                    t = linspace(0,2*pi);
                    X = a*cos(t);
                    Y = b*sin(t);
                    w = atan2(y2-y1,x2-x1);
                    x = (x1+x2)/2 + X*cos(w) - Y*sin(w);
                    y = (y1+y2)/2 + X*sin(w) + Y*cos(w);
                    
                    obj.rings = plot(x, y, 'y-', 'Parent', h_ax);
                    
                    set(obj.rings, 'LineWidth', 1, 'Color', [192/255, 192/255, 192/255]);
                    
                    obj.x_ring = obj.rings.XData;
                    obj.y_ring = obj.rings.YData;
                    
        
                end   
                    
                obj.label = text(h_ax, obj.location(1) + 0.2, obj.location(2) + 0.2, obj.name);
                set(obj.label, 'Color', [1, 1, 1], 'FontSize', 8);
                
            else
                obj.illustration.XData = obj.location(1);
                obj.illustration.YData = obj.location(2);
                
                if strcmp(obj.name, 'Saturn')

%                     obj.rings.XData = obj.radius + (obj.x_ring - obj.location(1));
%                     obj.rings.YData = obj.radius + (obj.y_ring - obj.location(2));
%                    
                    obj.rings.XData = obj.x_ring - (obj.radius - obj.location(1));
                    obj.rings.YData = obj.y_ring + (obj.radius - (obj.radius - obj.location(2)));
                    
%                     obj.rings.XData = (obj.radius - obj.x_ring);% obj.x_ring + (obj.location(1) - obj.x_ring); % obj.x_ring - (obj.x_ring - obj.rings.XData);%obj.x_ring + obj.location(1);
%                     obj.rings.YData = (obj.location(2) - obj.y_ring);
                  
                end   
                
                set(obj.label, 'Position', [obj.location(1) + 0.2, obj.location(2) + 0.2, 0])
            end
                            
        end
        
        function orbite_a_planet(obj, day)
            
            if nargin == 2  % for slider
                time_interval = day;
                obj.theta     = 0;
            else
                time_interval = obj.T / obj.T; % = 1 earth's day always                 % time interval of a day (of earth) % obj.T / 6 = 1/6 year (time period)
            end
            theta_change = obj.omega * time_interval;
            
            % update theta:
            obj.theta = obj.theta + theta_change;
            
            % update location:
            [x, y] = pol2cart(obj.theta, obj.radius);
            obj.location = [x, y];
            
            obj.illustration.XData = x;
            obj.illustration.YData = y;

        end
        
    end
    
    
end
