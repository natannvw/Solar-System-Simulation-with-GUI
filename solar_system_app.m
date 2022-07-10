
% ========================= GUI Initialize ==============================

function varargout = solar_system_app(varargin)
% SOLAR_SYSTEM_APP MATLAB code for solar_system_app.fig
%      SOLAR_SYSTEM_APP, by itself, creates a new SOLAR_SYSTEM_APP or raises the existing
%      singleton*.
%
%      H = SOLAR_SYSTEM_APP returns the handle to a new SOLAR_SYSTEM_APP or the handle to
%      the existing singleton*.
%
%      SOLAR_SYSTEM_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOLAR_SYSTEM_APP.M with the given input arguments.
%
%      SOLAR_SYSTEM_APP('Property','Value',...) creates a new SOLAR_SYSTEM_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before solar_system_app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to solar_system_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help solar_system_app

% Last Modified by GUIDE v2.5 20-Jan-2021 14:49:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @solar_system_app_OpeningFcn, ...
                   'gui_OutputFcn',  @solar_system_app_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end

function solar_system_app_OpeningFcn(hObject, eventdata, handles, varargin)

    global db
    
    % Log create and start:
    handles.h_txt = fopen('sim_log.txt', 'w');
    log_datetime(handles);
    event_str = "App has been opened";
    log_datetime(event_str, handles);
    
    h_im = wait_image();                                      % opening image

    % ===================== space and planets creation ==================
    
    % space and planets creation:
    [handles.planets_struct, handles.space, handles.planets_arr]...
        = solar_system_creator();                             
    handles.n_planets = numel(handles.planets_arr);
    
    % settings:
    db.years = 10;                                            % total years for slider limitation (and so intervals...)
    db.days  = round(db.years * handles.planets_arr(2).T);    % total years in days (planets_arr.T = earth.year = 360 days)
    
    db.day  = 1;                                              % an iteration
    db.year = 0;                                              % year of iterations (365 days) for years_counter static text in GUI. see at loop_sim()
    
    % planets distances cell array creation:
    db.planets_locs_cell = cell(1, handles.n_planets);
    db.distances         = cell(1, handles.n_planets);
    locs                 = zeros(2, db.days);
    distances            = zeros(1, db.days);
    
    for planet = 1:handles.n_planets
        db.planets_locs_cell{planet} = locs;
        db.distances{planet}         = distances;
    end

    % graphics:
    handles.main_axes = ...
        handles.space.plot_space(handles.main_axes,...        % passing axes
        handles.planets_struct); 
    
    hold(handles.main_axes, 'on');

    planet_plot_update_and_distances_creator(handles);

    if exist('save.mat', 'file')
        filename = 'save.mat';
        
        matObj           = matfile(filename);
        [n_rows, n_cols] = size(matObj,'state');               % for efficiency
        state            = matObj.state(n_rows, n_cols);       % sizeMyVar ([n_rows, n_cols]) = [1, 1]
        
        db.planets_locs_cell = state.db.planets_locs_cell;
        db.distances         = state.db.distances;
        
        with_update = 1;
        only_update = db.day;                                              % input day!
        planet_plot_update_and_distances_creator(handles,...
                                                 with_update, only_update);
    end
    
    % ========================= Load Saved Meta Data =====================

    if exist('GUI_meta_data.mat', 'file')
        ans_file_GUI_meta_data = questdlg('Load previous simulation results?', 'Load previous?',...
            'Yes', 'No', 'No');
        switch ans_file_GUI_meta_data
            case 'Yes'
                filename = 'GUI_meta_data.mat';

                matObj           = matfile(filename);
                [n_rows, n_cols] = size(matObj,'state');               % for efficiency
                state            = matObj.state(n_rows, n_cols);       % sizeMyVar ([n_rows, n_cols]) = [1, 1]
                
                db.day              = state.db.day;
                db.year             = state.db.year;
          
                db.planets_locs_cell = state.db.planets_locs_cell;
                db.distances         = state.db.distances;
                
                with_update = 1;
                only_update = db.day;                                              % input day!
                planet_plot_update_and_distances_creator(handles,...
                    with_update, only_update);
                
                event_str = "Data has been loaded";
                log_datetime(event_str, handles);
        end
    end
    
    % ========================== Initialize =============================
        
    handles = colors_initialize(hObject, handles); 
    
    % years_counter
    text                         = [num2str(db.year), ' Years'];
    handles.years_counter.String = text;
    
    % Snapshot
    if exist('sim_frames.tif',  'file')
        delete sim_frames.tif
    end

    % Slider
    if exist('save.mat', 'file') & exist('GUI_meta_data.mat', 'file') & strcmp(ans_file_GUI_meta_data, 'Yes')
        slider_val = db.day;
    elseif exist('save.mat', 'file')
        slider_val = 1;
    else
        slider_val = db.day;
    end
    set(handles.slider, 'Min', 1, 'Max', db.days, 'Value', slider_val);

    handles.h_lis = addlistener(handles.slider, 'Value', 'PostSet', @(src, evnt)slider_callback(src, evnt, handles));
    
    % distances_plot():
    handles.issued_sun    = handles.planets_arr(1);
    handles.issued_planet = handles.planets_arr(2);
    distances_plot(db.selected_val, handles, hObject)
    
    set(handles.main_figure, 'Position',...
        [790.8462, 1.5000, 269.4615, 50.6765])                        % position:
    handles.debug.Visible = 'off';
    close(h_im)
    
    zoom(handles.main_figure, 'on')
    
    % ===================================================================

    handles.output = hObject;                                         % Choose default command line output for solar_system_app
    guidata(hObject, handles); 
end

function varargout = solar_system_app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

% =========================== Buttons ===================================

function play_Callback(hObject, eventdata, handles)

    global db
    persistent is_playing    
    
    if (is_playing)                                             % to "stop" if alredy started (is_playing = 1):
        is_playing                        = 0;
        event_str                         = hObject.String;
        log_datetime(event_str, handles);
        hObject.String                    = 'Play';
        hObject.ForegroundColor           = handles.OLIVE_COLOR;
        return
        
    end
    
    event_str = hObject.String;
    log_datetime(event_str, handles);
        
    % initital: is_playing == 1
    is_playing = 1;                                      % if is_playing = 0, then it won't change because persistent!

  % disable the other button (other start) and change current button string to 'Stop':
    hObject.String             = 'Pause';
    hObject.ForegroundColor    = handles.BORDO_COLOR;

  % if is_playing == 1 then enter the 'while':
    while is_playing

        if db.year ~= 10
            % Run the simulation:
            loop_sim(hObject, handles)
        else
            is_playing = 0;
            handles.play.Enable               = 'off';
            hObject.String                    = 'Simulation Ended';
            hObject.ForegroundColor           = [0, 0, 0];
            event_str                         = hObject.String;
            log_datetime(event_str, handles);
        end
            
    end    

end

function debug_Callback(hObject, eventdata, handles)

    global db
    
    disp('======= debug function ===========')



  % where to debag after setting a breakpoint:
    dbstop in debug_Callback;

    disp('==================================')
end

function snapshot_Callback(hObject, eventdata, handles)

    event_str = "Snapshoted";
    log_datetime(event_str, handles);
    
    fig                = handles.main_figure;
    fig.InvertHardcopy = 'off';
    set(fig, 'PaperPositionMode', 'auto',...
        'PaperOrientation', 'landscape', 'PaperType', 'a3');

    print(fig,'-dpdf','snapshot.pdf');

end

function save_Callback(hObject, eventdata, handles)

    global db

    handles.play.Enable     = 'off';
    handles.snapshot.Enable = 'off';
    handles.menu.Enable     = 'off';
    handles.slider.Enable   = 'off';
    drawnow();
    
    % ============================= Saving ==============================
    
    filename          = 'GUI_meta_data.mat';
    state.planets_arr = handles.planets_arr;
    state.db          = db;
    save(filename, 'state', '-v7.3', '-nocompression');
    
    event_str = "Data has been saved";
    log_datetime(event_str, handles);
    
    % ===================================================================

    handles.play.Enable     = 'on';
    handles.snapshot.Enable = 'on';
    handles.menu.Enable     = 'on';
    handles.slider.Enable   = 'on';
    drawnow();
end

% ============================ Slider ===================================

function slider_callback(hObject, eventdata, handles)

    global db
    
    if ~ishandle(handles.main_figure)
        return
    end
    
    event_str = "Slider used";
    log_datetime(event_str, handles);
    
    handles         = guidata(eventdata.AffectedObject);
    curr_slider_loc = round(eventdata.AffectedObject.Value);
    day             = curr_slider_loc;
    
    with_update     = 1;
    only_update     = day;                                           % input day!
    planet_plot_update_and_distances_creator(handles,...
        with_update, only_update);
    
    db.day          = day;
    db.year         = floor(db.day / handles.planets_arr(2).T);
    
    drawnow();
    
    if ~ishandle(handles.main_figure)
        return
    end
    distances_plot(db.selected_val, handles, hObject);

    % text update:
    text                         = [num2str(db.year), ' Years'];
    handles.years_counter.String = text;
        
end

% ============================= Menu ====================================

function menu_Callback(hObject, eventdata, handles)

    global db  
    
    contents        = get(hObject,'String');
    db.selected_val = get(hObject,'Value');
    selected_str    = contents{db.selected_val};
    
    log_datetime([selected_str, ' has been selected'], handles);
    
    distances_plot(db.selected_val, handles, hObject);
end

function menu_CreateFcn(hObject, eventdata, handles)

    global db

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    hObject.String  = {'Sun', 'Earth', 'Mars', 'Mercury', 'Venus', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'};
    hObject.Value   = 3;    % for Mars to be default
    db.selected_val = hObject.Value;
  
end

% ============================ helpers ==================================

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
    
    saturn.name             = 'Saturn';
    saturn.size_km          = 58232;
    saturn.size_norm        = saturn.size_km / earth.size_km;
    saturn.distance_Mk      = 1.434 * 1000 ;
    saturn.distance_norm    = saturn.distance_Mk / earth.distance_Mk;
    saturn.color            = [171/255, 96/255, 74/255];
    saturn.year             = 29 * earth.year;
    saturn.timeperiod       = 1;
    saturn.timeperiod_days  = saturn.year * saturn.timeperiod;
    
    uranus.name             = 'Uranus';
    uranus.size_km          = 25362 ;
    uranus.size_norm        = uranus.size_km / earth.size_km;
    uranus.distance_Mk      = 2.871 * 1000;
    uranus.distance_norm    = uranus.distance_Mk / earth.distance_Mk;
    uranus.color            = [172/255, 229/255, 238/255]; 
    uranus.year             = 84 * earth.year;
    uranus.timeperiod       = 1;
    uranus.timeperiod_days  = uranus.year * uranus.timeperiod;
    
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
    for field      = 1:planets_length
        distances(field) = planets_struct(field).distance_norm;
    end
    
    max_distance   = max(distances);
    space          = Space(max_distance);
    
    Sun     = Planet(sun.name, 5 * sun.size_norm, sun.distance_norm, sun.color, sun.timeperiod_days);
    Earth   = Planet(earth.name, 5 * earth.size_norm , earth.distance_norm, earth.color, earth.timeperiod_days);
    Mars    = Planet(mars.name, 5 * mars.size_norm , mars.distance_norm, mars.color, mars.timeperiod_days);
    Mercury = Planet(mercury.name, 5 * mercury.size_norm , mercury.distance_norm, mercury.color, mercury.timeperiod_days);
    Venus   = Planet(venus.name, 5 * venus.size_norm , venus.distance_norm, venus.color, venus.timeperiod_days);
    Jupiter = Planet(jupiter.name, 5 * jupiter.size_norm , jupiter.distance_norm, jupiter.color, jupiter.timeperiod_days);
    Saturn  = Planet(saturn.name, 5 * saturn.size_norm , saturn.distance_norm, saturn.color, saturn.timeperiod_days);
    Uranus  = Planet(uranus.name, 5 * uranus.size_norm , uranus.distance_norm, uranus.color, uranus.timeperiod_days);
    Neptune = Planet(neptune.name, 5 * neptune.size_norm , neptune.distance_norm, neptune.color, neptune.timeperiod_days);

    planets_arr = [Sun, Earth, Mars, Mercury, Venus, Jupiter, Saturn, Uranus, Neptune];

end

function loop_sim(hObject, handles)

    global db

    db.day = db.day + 1;
    
    with_update = 1;
    planet_plot_update_and_distances_creator(handles, with_update);
    
    db.year = floor(db.day / handles.planets_arr(2).T);
    
    text                         = [num2str(db.year), ' Years'];
    handles.years_counter.String = text;
    
    drawnow();
    
    if ~ishandle(handles.main_figure)
        return
    end
%     handles.slider.Value = db.day;
    update_slider_val(handles, db.day)
   
    distances_plot(db.selected_val, handles, hObject);

end

function handles = colors_initialize(hObject, handles)
    handles.FIG_COLOR                 = handles.main_figure.Color;     % ( ... = [0.94 0.94 0.94] )
    handles.RED_COLOR                 = [1.0000, 0.0000, 0.0000];      % for figure and also scatter
    handles.GREEN_COLOR               = [0.0000, 1.0000, 0.0000]; 
    handles.BORDO_COLOR               = [0.6350, 0.0780, 0.1840];
    handles.OLIVE_COLOR               = [0.4660, 0.6740, 0.1880];
end

function distances_plot(planet, handles, hObject)

    global db
    if ~ishandle(handles.main_figure)                            % check if the main_figure (GUI) not closed
        return
    end
    contents     = get(handles.menu,'String');
    selected_str = contents{db.selected_val};
    
    earth_dist   = handles.planets_struct(2).distance_norm;
    planet_dist  = handles.planets_struct(planet).distance_norm;
    min_dist     = floor(abs(earth_dist - planet_dist));
    max_dist     = ceil(earth_dist + planet_dist);
        
    days         = db.days / db.years;
    
    time         = 1:1:db.day; 
    distance     = db.distances{planet}(1 : (db.day));
    
    if isempty(time)
        p = plot(1,1,'Parent', handles.distance_ax);
    elseif strcmp(selected_str, handles.issued_planet.name)
        p = plot(time, distance, 'Parent', handles.distance_ax);
    else
        distance(distance == 0) = NaN;
%         distance(distance < min_dist) = NaN;
        p = plot(time, distance, 'Parent', handles.distance_ax);
    end
    p.LineWidth = 1;
    
    T                        = handles.planets_struct(2).timeperiod_days;
    handles.distance_ax.XLim = [- T + db.day, 0 + db.day];
        
    month                    = days / 12;                                       % days in month
    fixed_ticks              = -(days) : (3 * month) : 0;
    ticks                    = fixed_ticks + db.day;                            % dynamic for tick plot
    
    handles.distance_ax.XTick      = ticks;
    handles.distance_ax.XTickLabel = {fixed_ticks / month};

    if strcmp(selected_str, handles.issued_planet.name)
        handles.distance_ax.YLim = [-1, 1];
    elseif strcmp(selected_str, handles.issued_sun.name)
        handles.distance_ax.YLim = [0, 2];
    else
        handles.distance_ax.YLim = [min_dist, max_dist];
    end
    
    % Texts:
    handles.distance_ax.Title.String  = [selected_str, '''s Distance from ', handles.issued_planet.name];
    handles.distance_ax.XLabel.String = ['Time (', handles.issued_planet.name, '''s Months)'];
    handles.distance_ax.YLabel.String = 'Distance (AU)';
end

function log_datetime(varargin)

    if length(varargin) == 1
        handles    = varargin{1};
        
        A_DateTime = "Date and Time";
        A_Event    = "Event";
        %     h_title_sim_log = sprintf('%1$s\t%2$s', A_DateTime, A_Event);
        h_title_sim_log = fprintf(handles.h_txt, '%1$s\t\t%2$s', A_DateTime, A_Event);
        return
    end
    
    event_str  = varargin{1};
    handles    = varargin{2};
    
    A_DateTime = datetime();
    A_Event    = event_str;

%     h_new_line_sim_log = sprintf('\n%1$s\t%2$s', A_DateTime, A_Event);
    h_new_line_sim_log = fprintf(handles.h_txt, '\n%1$s\t%2$s', A_DateTime, A_Event);
end

function update_slider_val(handles, day)

    handles.slider.Value = day; 

end

function h_im = wait_image()

    I    = imread('solarsystemopening.jpg');
    h_im = figure();
    ax   = axes(h_im);

    set(h_im, 'MenuBar', 'none', 'NumberTitle', 'off'); %, 'Position', 1.0e+03 * [4.3374, 0.1838, 0.5600, 0.4200]);
    set(ax, 'DataAspectRatioMode', 'auto', 'Position', [0 0 1 1]);
    
    image(ax, I);

end

function planet_plot_update_and_distances_creator(handles, ~, day)

    % when initialized: only plotting and create distances (no update)
    % when simultating: updateing (orbit), plotting and createing distances
    % when slider: updateing (orbit) with [day] variable and plotting.
    
    global db
    
    for planet = 1:handles.n_planets
        if nargin == 2                                      
            handles.planets_arr(planet).orbite_a_planet(); 
        elseif nargin == 3                                           % for slider
            handles.planets_arr(planet).orbite_a_planet(day);
        end
        handles.planets_arr(planet).plot_planet(handles.main_axes);  % nargin = 1,2,3 
        if nargin == 3                                               % only update and plot (for slider)
            if planet == handles.n_planets
                return                                               % return and dont continue
            end
            continue                                                 % dont create distances
        end
        
% from this line, when nargin is 1 or 2:        
        db.planets_locs_cell{planet}(1, db.day) = handles.planets_arr(planet).location(1);
        db.planets_locs_cell{planet}(2, db.day) = handles.planets_arr(planet).location(2);
    end
    clear planet
    
    for planet = 1:handles.n_planets
        db.distances{planet}(db.day) = norm(db.planets_locs_cell{planet}(:,db.day) - db.planets_locs_cell{2}(:,db.day));
    end
    clear planet 
    
end

% ========================== Close GUI ==================================

function main_figure_CloseRequestFcn(hObject, eventdata, handles)

% global db
event_str = "App has been closed";
log_datetime(event_str, handles);

if handles.play.Value == 1
    play_Callback(handles.play, eventdata, handles)
end

fclose('all');
delete(hObject);

clear db
clear persistent;

end
