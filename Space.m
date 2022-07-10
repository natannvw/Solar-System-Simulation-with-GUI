classdef Space < handle & matlab.mixin.Heterogeneous
    % todo API
    
    properties
        
        max_radious                          % Neptune distance from sun is 30 AU

    end
    
    properties (Constant)
        CENTER = [0, 0];
    end
    
    methods
    
        function space = Space(max_radious)
            % todo API
            
%             max_radious = 1.5;                            % Neptune distance from sun is 30 AU
            
            space.max_radious = 1.1 * max_radious;
            
        end
        
        function h_space_ax = plot_space(space, h_space_ax, planets_struct) 
            % todo API
            
            if ~exist('h_space_ax', 'var')                                 % if not exist h_ax then create one
                h_fig = figure()    ;
                h_space_ax  = axes(h_fig) ;
            end
            
%             CENTER_RECT = space.CENTER-space.max_radious;
%             DMTR = 2 * space.max_radious;
%             
%             pos = [CENTER_RECT, DMTR, DMTR];
%             
%             h_rect = rectangle('Position', pos, 'FaceColor', 'k');
%             
%             h_rect.EdgeColor = h_rect.FaceColor;
%             
%             z = zoom;
%             zoom on
            axis equal

            h_space_ax.XAxis.Visible = 'off';
            h_space_ax.YAxis.Visible = 'off';
            
            h_space_ax.Color = 'k';
            lim = [-space.max_radious, space.max_radious];
            
            set(h_space_ax, 'XLim', lim, 'YLim', lim);
%             set(h_rect, 'XLim', lim, 'YLim', lim);

            hold(h_space_ax, 'on');
            
            circles = cell(1, numel(planets_struct));
            for planet = 1:numel(planets_struct)
                circles{planet} = viscircles(h_space_ax, space.CENTER, planets_struct(planet).distance_norm,...
                    'Color', [0.3, 0.3, 0.3], 'LineWidth', 1, 'EnhanceVisibility', 0);
            end
        end
    end
    
end