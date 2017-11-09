clear;
load('CCCtable_2antenna')

%% Randomize Every Simulation %%
rng('shuffle')

%% �V�~�����[�V�������� %%
NO_user = 3;                                                                % ���[�U��
NO_Interference_cell = 19;                                                  % 19 Hexagonal area
NO_cell = 7;                                                                % picoBS��

Center_frequency = 2.0*10^9;                                                % ���S���g��
NO_SC_inRB = 12;                                                            % 1RB�Ɋ܂܂��subcarrier��
NO_RB = 24;                                                                 % 1OFDM�V���{���Ɋ܂܂��RB�̐�
NO_SC = NO_SC_inRB * NO_RB;                                                 % 1OFDM�V���{���Ɋ܂܂��subcarrier�̐�
Band_RB = 180*10^3;                                                         % 1RB�Ɏg�p������g���ш�
Band_SC = Band_RB / NO_SC_inRB;                                             % 1Subcarrier�Ɏg�p������g���ш�
Band = Band_RB * NO_RB;                                                     % �g�p������g���ш�
NO_time_trial = 3;                                                         % ���Ԃ̎��s��
Timing_interval = 60;                                                      % �`���l�����Œ肷��C���^�[�o��                                                  
NO_drop_trial = 1200;                                                         % ���[�U�h���b�v�̎��s��
TI = 60;                                                                   % Time Interval
NO_path = 6;                                                                % Jake's���f���ɂ�����p�X�̐�
Doppler = 5.55;                                                             % Jake's���f���ɂ�����h�b�v���[�V�t�g�l[Hz]
Decay = 1;                                                                  % Jake's���f���ɂ�����p�X���Ƃ̌�����
Interval = 1 / Band;                                                        % Jake's���f���ɂ�����T���v�����O�C���^�[�o��
JI = 600;                                                                   % JakeInterval...fade.m����������邽�߂ɐ��T���v�����ƂɎ��o���悤�ɂ���
rms_delay_spread = 1.0 * 10^(-6);                                           % �x���X�v���b�h�l
IS_distance = 500;                                                          % Inter-site distance
Shadowing_ave = 0;                                                          % Shadowing�̕��ϒl
Shadowing_var_Macro = 8;                                                    % MacroBS Shadowing�̕��U�l
Shadowing_var_Pico = 10;                                                    % PicoBS Shadowing�̕��U�l
Correlation_jake_coefficient = 0.44;                                        % ���֌W��0.5�ɑΉ�����jake�ɓ����W��
Penetration_loss = 20;                                                      % ���ߑ���
Antenna_gain_Macro = 17;                                                    % MacroBS�̃A���e�i����
Antenna_gain_Pico = 5;                                                      % PicoBS�̃A���e�i����
Receiver_noise_density = -174;
NO_EIRP_base = 1;                                                          % MacroBS���˓d�͐���W��
NO_EIRP_picobase = 1;                                                       % PicoBS���˓d�͐���W��(���͐��䂵�Ă��Ȃ�)
NO_Analyze = 10000;                                                         % ��͐�


%% HARUYA %%

% remove a couple of data in the beginning 
remove_beginning = 20;
% we will use the actual_interval
actual_interval = Timing_interval - remove_beginning;
% trial count
trial_count = 1;

% for each NO_time_trial we save, 
% input data:
channel_response = zeros(NO_RB, NO_user, NO_cell);
past_throughput = zeros(NO_user, 1);
% label data:
combination = zeros(NO_RB, 1);
% other data:
sumrate = zeros(1, 1);
% which means we get actual_interval as the number of data points per each
% NO_time_trail

% for saving, we divide the data for each NO_time_trail

% create the main folder for saving:
data_folder_name = datestr(datetime('now', 'TimeZone','local','Format','y-MM-dd_HH:mm'), 'yyyy-mm-dd_HH-MM');
[status, msg] = mkdir(data_folder_name);
if status ~= 1
    disp(msg);
end
% change directory:
% home: starting directory
%home = cd(data_folder_name); 
home = pwd;
data_root = fullfile(home, data_folder_name);

%% �g�Â��� %%
%EIRPNR_SC = zeros(NO_user,NO_SC,NO_EIRP_base);                             % SC����EIRP�l���i�[
%SINR_RB = zeros(NO_user,NO_RB,NO_EIRP_base);                               % RB����SNR�l���i�[
%SINR_RB_floor = zeros(NO_user,NO_RB,NO_EIRP_base);

% NOMA
SINR_RB_macro = zeros(NO_user,NO_RB,NO_EIRP_base);                          % MacroUser RB����SNR�l���i�[
SINR_RB_macro_floor = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_RB_pico = zeros(NO_user,NO_RB,NO_EIRP_base);                           % PicoUser RB����SNR�l���i�[
SINR_RB_pico_floor = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_SC_macro = zeros(NO_user,NO_SC,NO_EIRP_base);                          % MacroUser SC����SINR�l���i�[
SINR_SC_macro_floor = zeros(NO_user,NO_SC,NO_EIRP_base); 
SINR_SC_pico = zeros(NO_user,NO_SC,NO_EIRP_base);                           % PicoUser SC����SINR�l���i�[
SINR_SC_pico_floor = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_SC_user= zeros(NO_user,NO_SC,(NO_cell+1)^NO_user );

%NOMA_Conv
SINR_RB_macro_Conv = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_RB_macro_Conv_floor = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_SC_macro_Conv = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_SC_macro_Conv_floor = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_RB_pico_Conv = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_RB_pico_Conv_floor = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_SC_pico_Conv = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_SC_pico_Conv_floor = zeros(NO_user,NO_SC,NO_EIRP_base);

%OMA
SINR_RB_macro_oma = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_RB_macro_oma_floor = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_SC_macro_oma = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_SC_macro_oma_floor = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_RB_pico_oma = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_RB_pico_oma_floor = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_SC_pico_oma = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_SC_pico_oma_floor = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR_SC_user_floor = zeros(NO_user,NO_SC,(NO_cell+1)^NO_user);
EIRP_base = zeros(1,NO_EIRP_base);
EIRP_picobase = zeros(1,NO_EIRP_picobase);
SINR_RB_user = zeros(NO_user,NO_RB,NO_EIRP_base);
SINR_RB_user_floor = zeros (NO_user,NO_RB,NO_EIRP_base);

% Capacity_ave = 0;                                                         % Capacity�̕��ς��i�[
channel_responce_freq_m = zeros(NO_user,NO_SC);                             % �`���l�����i�[(���g���h���C��)
channel_responce_freq_p = zeros(NO_user,NO_SC);
channel_responce_freq_m_OMA = zeros(NO_user,NO_SC);                                   
channel_responce_freq_p_OMA = zeros(NO_user,NO_SC);
channel_responce_freq = zeros(NO_user,NO_cell,NO_SC); %
channel_responce_freq_m1 = zeros(NO_user,NO_SC);
channel_responce_freq_m2 = zeros(NO_user,NO_SC);
channel_responce_freq_p1 = zeros(NO_user,NO_SC);
channel_responce_freq_p2 = zeros(NO_user,NO_SC);
channel_responce_time_m = zeros(1,NO_SC);                                   % �`���l�����i�[(�^�C���h���C��)
channel_responce_time_p = zeros(1,NO_SC); 
channel_responce_time_m_OMA = zeros(1,NO_SC);                                     
channel_responce_time_p_OMA = zeros(1,NO_SC); 
channel_responce_time_rayleigh = zeros(NO_user,NO_cell,NO_SC); %
channel_responce_time_jake_m2 = zeros(1,NO_SC);
channel_responce_time_jake_p1 = zeros(1,NO_SC);
channel_responce_time_jake_p2 = zeros(1,NO_SC);

select_macrouser = zeros(1,NO_RB);                                          % ���[�U�[�I���̂��߂̃p�����[�^
select_picouser = zeros(1,NO_RB);                                     
select_macrouser_oma = zeros(1,NO_RB);                                    
select_picouser_oma = zeros(1,NO_RB);                                     
select_macrouser_Conv = zeros(1,NO_RB);                                     
select_picouser_Conv = zeros(1,NO_RB);                                     
select_macromod = zeros(1,NO_RB);                                           % �œK��mod���i�[
select_picomod = zeros(1,NO_RB);                    
select_macro_EIRP = ones(1,NO_RB);                                          % �œK�ȕ��˓d�͐���W�����i�[
select_phase_macro = zeros(1,NO_RB);                                        % �œK�ȃp�����[�^�ɑ΂���ʑ������i�[
select_phase_pico = zeros(1,NO_RB);
select_PA_user = zeros(1,NO_RB);                                            % �œK��PA���i�[
select_PA_picouser = zeros(1,NO_RB);
select_Conv_macromod = zeros(1,NO_RB);                         
select_Conv_picomod = zeros(1,NO_RB);                         
select_Conv_PA_macro = ones(1,NO_RB);                                      
select_Conv_PA_pico = zeros(1,NO_RB);                        
select_Conv_phase_macro = zeros(1,NO_RB);
select_Conv_phase_pico = zeros(1,NO_RB);
select_Conv_EIRP = ones(1,NO_RB);
select_oma_macromod = zeros(1,NO_RB);                         
select_oma_picomod = zeros(1,NO_RB);                        
select_oma_PA_macro = ones(1,NO_RB);                         
select_oma_PA_pico = zeros(1,NO_RB);                         
select_oma_phase = zeros(1,NO_RB);
select_oma_EIRP = ones(1,NO_RB);
Coordinates_table = zeros(floor(IS_distance / 2 / sqrt(3)),floor(IS_distance / 2));  % ���W����邽�߂̕\
Coordinates = zeros(1,NO_user);                                                      % ���[�U�̍��W���i�[
Coordinates_Interference = zeros(1,NO_Interference_cell);                                         % ����n��(Macro)�̍��W���i�[

Capacity_realnear_prop = zeros(1,NO_EIRP_base);
Capacity_realfar_prop = zeros(1,NO_EIRP_base);
Capacity_realnear_conv = zeros(1,NO_EIRP_base);
Capacity_realfar_conv = zeros(1,NO_EIRP_base);
Capacity_realnear_oma = zeros(1,NO_EIRP_base);
Capacity_realfar_oma = zeros(1,NO_EIRP_base);
count_pair_prop = zeros(600,600);                                           % ���[�U�y�A���͂̂��߂̑��֕\
count_pair_conv = zeros(600,600);                                           
select_prop_user = zeros(NO_user,NO_user,NO_RB);                            % ���[�U�y�A�̕��т̑I���𔻒f
select_conv_user = zeros(NO_user,NO_user,NO_RB);                           
select_oma_user = zeros(NO_user,NO_user,NO_RB);                             
Capacity_RB_cur_macro = zeros(NO_user,NO_user,NO_RB);                       % RB����Capacity
Capacity_RB_cur_pico = zeros(NO_user,NO_user,NO_RB);                        
Capacity_RB_cur_noma = zeros(NO_user,NO_user,NO_RB); 
Capacity_RB_cur_oma = zeros(NO_user,NO_user,NO_RB);                        

Capacity_byuser_macro = zeros(NO_user,NO_EIRP_base,NO_drop_trial);          % ���[�U���̗e�ʌv�Z
Capacity_byuser_pico = zeros(NO_user,NO_EIRP_base,NO_drop_trial);
Capacity_byuser_noma = zeros(NO_user,NO_EIRP_base,NO_drop_trial);
Capacity_byuser_macro_Conv = zeros(NO_user,NO_EIRP_base,NO_drop_trial);
Capacity_byuser_pico_Conv = zeros(NO_user,NO_EIRP_base,NO_drop_trial);
Capacity_byuser_Conv = zeros(NO_user,NO_EIRP_base,NO_drop_trial);
Capacity_byuser_oma = zeros(NO_user,NO_EIRP_base,NO_drop_trial);

Capacity_Analyze_noma = zeros(NO_Analyze,11);                               % ��͂̂��߂̘g
Capacity_Analyze_oma = zeros(NO_Analyze,10); 
Capacity_Analyze_Conv = zeros(NO_Analyze,11);                                         
Delay_profile = zeros(1,NO_path);
Analyze_index_macro = 1;
Analyze_index_Conv = 1;
Analyze_index_noma = 1;
Analyze_index_pico = 1;
Analyze_index_oma = 1;
Capacity_cell_site_prop = zeros(NO_EIRP_base,NO_drop_trial);
Capacity_cell_site_conv = zeros(NO_EIRP_base,NO_drop_trial);
Capacity_cell_site_oma = zeros(NO_EIRP_base,NO_drop_trial);
Capacity_cell_edge_prop = zeros(NO_EIRP_base,NO_drop_trial);
Capacity_cell_edge_conv = zeros(NO_EIRP_base,NO_drop_trial);
Capacity_cell_edge_oma = zeros(NO_EIRP_base,NO_drop_trial);

Distance_fromBS = zeros(NO_drop_trial,NO_cell,NO_user);
Distance_fromBS_pre = zeros(NO_drop_trial,NO_cell,NO_user);
PLR_fromBS = zeros(NO_drop_trial,NO_cell,NO_user);
Distance_fromPicoBS = zeros(NO_drop_trial,NO_user);
Distance_fromPicoBS_2 = zeros(NO_drop_trial,NO_user);
Distance_fromPicoBS_1 = zeros(NO_drop_trial,NO_user);
Distance_fromPicoBS_pre  = zeros(NO_drop_trial,NO_user);
PLR_fromPicoBS = zeros(NO_drop_trial,NO_user);

%Power_ratio_Macro_Pico_ave = zeros(NO_drop_trial,NO_user);
%Power_ratio_Pico_Macro_ave = zeros(NO_drop_trial,NO_user);
%Count_PA = zeros(21,2);

%% �ǉ��� %%

Distance_pre = zeros(NO_user,NO_cell-1); 
Distance = zeros(NO_user, NO_cell-1);                                       %����n��(Macro)�ƃ��[�U�̋���

Signal_power_fromBS_user = zeros(NO_user,NO_SC,NO_EIRP_base,(NO_cell+1)^NO_user);
Signal_power_fromBS_Interference_user = zeros(NO_user,NO_SC,NO_EIRP_base,(NO_cell+1)^NO_user);
Signal_power_fromPicoBS_macrouser = zeros(NO_user,NO_SC,NO_EIRP_picobase);
Signal_power_fromPicoBS_picouser = zeros(NO_user,NO_SC,NO_EIRP_picobase);
Signal_power_macrouser = zeros(NO_user,NO_SC,NO_EIRP_base);
Signal_power_picouser = zeros(NO_user,NO_SC,NO_EIRP_base);
SINR = zeros(NO_user,NO_SC,NO_EIRP_base);

Interference_Macropower = zeros(NO_user,NO_SC);
Interference_Picopower = zeros(NO_user,NO_SC);
Interference_Macropower_Conv = zeros(NO_user,NO_SC);
Interference_Picopower_Conv = zeros(NO_user,NO_SC);
Interference_Macropower_OMA = zeros(NO_user,NO_SC);
Interference_Picopower_OMA = zeros(NO_user,NO_SC);
Interference_power_pre = zeros(NO_user,NO_SC);
Interference_power_pre_Conv = zeros(NO_user,NO_SC);
Interference_power_pre_OMA = zeros(NO_user,NO_SC);
Interference_power = zeros(NO_user,NO_SC);
Interference_power_Conv = zeros(NO_user,NO_SC);
Interference_power_OMA = zeros(NO_user,NO_SC);

PA_user_pre = zeros(NO_user,NO_EIRP_base);
PA_user = zeros(NO_user,NO_EIRP_base);
PA_picouser = zeros(NO_user,NO_EIRP_base);
PA_picouser_pre = zeros(NO_user,NO_EIRP_base);
PA_user_Conv_pre = zeros(NO_user,NO_EIRP_base);
PA_user_Conv = zeros(NO_user,NO_EIRP_base);
PA_picouser_Conv = zeros(NO_user,NO_EIRP_base);
PA_picouser_Conv_pre = zeros(NO_user,NO_EIRP_base);
phase_macro = zeros(1,NO_user);
phase_pico = zeros(1,NO_user);
phase_macro_Conv = zeros(1,NO_user);
phase_pico_Conv = zeros(1,NO_user);
phase_macro_index = zeros(1,NO_user);
phase_pico_index = zeros(1,NO_user);
phase_macro_Conv_index = zeros(1,NO_user);
phase_pico_Conv_index = zeros(1,NO_user);
     

noma_EIRP = zeros(NO_drop_trial, NO_RB);
noma_macro_SINR = zeros(NO_drop_trial, NO_RB);
noma_pico_SINR = zeros(NO_drop_trial, NO_RB);
noma_phase_macro = zeros(NO_drop_trial, NO_RB);
noma_phase_pico = zeros(NO_drop_trial, NO_RB);
noma_PA = zeros(NO_drop_trial, NO_RB);
conv_EIRP = zeros(NO_drop_trial, NO_RB);
conv_macro_SINR = zeros(NO_drop_trial, NO_RB);
conv_pico_SINR = zeros(NO_drop_trial, NO_RB);
conv_phase_macro = zeros(NO_drop_trial, NO_RB);
conv_phase_pico = zeros(NO_drop_trial, NO_RB);
conv_PA = zeros(NO_drop_trial, NO_RB);
oma_EIRP = zeros(NO_drop_trial, NO_RB);
oma_macro_SINR = zeros(NO_drop_trial, NO_RB);
oma_pico_SINR = zeros(NO_drop_trial, NO_RB);
oma_PA = zeros(NO_drop_trial, NO_RB);

Coordinates_antenna = zeros(NO_cell);
%% BS�̍��W���� %%
Coordinates_antenna(1) = 0;
for a = 2:7
    Coordinates_antenna(a) = IS_distance * cos(a * pi/3 - pi/6) + 1i * IS_distance * sin(a * pi/3 - pi/6);
end

 for BS_index = 1:6
     Coordinates_Interference(BS_index) = 2*IS_distance * cos(BS_index * pi/3 - pi/6) + 2i * IS_distance * sin(BS_index * pi/3 - pi/6)+IS_distance * cos(BS_index * pi/3 - pi/6 + pi/3) + 1i * IS_distance * sin(BS_index * pi/3 - pi/6 + pi/3);
     for a = 1:6
         Coordinates_Interference(BS_index * 6 + a) = Coordinates_Interference(BS_index) + IS_distance * cos(a * pi/3 - pi/6) + 1i * IS_distance * sin(a * pi/3 - pi/6);
     end
 end

%% �x���v���t�@�C���쐬 %%
for path_index = 1:NO_path
    Delay_profile(path_index) = exp( - (path_index-1) / (rms_delay_spread/Interval) );
end
Delay_profile = Delay_profile / sum(Delay_profile);

%% ���[�U�z�u��ς��ăV�~�����[�V���� %%    
for Drop_index = 1:NO_drop_trial
    tic
    Drop_index;

    %% �s�R�Z��BS�̍��W����
    %Coordinates_Interference_pico(picoBS_index) = IS_distance * cos(BS_index * pi/3 - pi/6) + 1i * IS_distance * sin(BS_index * pi/3 - pi/6);
    %Coordinates_pico = zeros(1,1);                                              %�@���]�M���̃s�R��n��
    %Coordinates_Interference_pico = zeros(1,6);%�@���ƂȂ�s�R��n��
    %pico_radius = 1;
    %Coordinates_pico(1,1) =(IS_distance / sqrt(3)) * pico_radius * (cos(1*pi/3)+1i*(sin(1*pi/3))); % �Z�����a��2/3�̋����Ń}�N����n�ǔ��a��ɔz�u

    %Coordinates_Interference_pico(1) = (IS_distance / sqrt(3)) * pico_radius * (cos(1*pi/3)+1i*(-sin(1*pi/3)));
    %Coordinates_Interference_pico(2) = (IS_distance / sqrt(3)) * pico_radius * (cos(pi) + 1i*0);                       % �Z�����a��2/3�̋����Ń}�N����n�ǔ��a��ɔz�u
    %Coordinates_Interference_pico(3) = Coordinates_Interference_pico(1) + Coordinates_Interference(2);         % �Z���O�̃s�R��n��
    %Coordinates_Interference_pico(4) = Coordinates_Interference_pico(2) + Coordinates_Interference(6);
    %Coordinates_Interference_pico(5) = Coordinates_Interference_pico(1) + Coordinates_Interference(1);
    %Coordinates_Interference_pico(6) = Coordinates_Interference_pico(2) + Coordinates_Interference(1);

    %% ���[�U�z�u�̌��� %%

    for user_index = 1:NO_user
        Coordinates(user_index) = 0;
        while Coordinates(user_index) == 0
            dx = (rand-0.5) * 2 * IS_distance / sqrt(3);
            dy = (rand-0.5) * 2 * IS_distance / sqrt(3);
            if (abs(dx) - IS_distance / 2 / sqrt(3)) * sqrt(3) > IS_distance / 2 - abs(dy) || abs(dy) > IS_distance / 2 ... %�Z�����a289m�̘Z�p�`
                || abs(dx+dy*1i) < 10 ... %�}�N����n�ǂƃ��[�U�̍ŏ�����   
                %|| dx < 0 || dy < -1/sqrt(3) * dx ... %�Z�N�^�Ɍ���
                %|| abs((dx-real(Coordinates_pico(1,1)))-(dy-imag(Coordinates_pico(1,1))))<10 ...
                %|| abs((dx-real(Coordinates_Interference_pico(1)))-(dy-imag(Coordinates_Interference_pico(1))))<10 ... 
                %|| abs((dx-real(Coordinates_Interference_pico(2)))-(dy-imag(Coordinates_Interference_pico(2))))<10 ... %�s�R��n�ǂƃ��[�U�̍ŏ�����
                %|| dy < 1/sqrt(3) * dx %�Z�N�^�̔����Ɍ��� 1/6�Z�N�^�Ƃ���
                Coordinates(user_index) = 0;
            else
                user_cell = randi(7);
                if user_cell == 1
                    Coordinates(user_index) = dx+dy*1i;
                else
                    Coordinates(user_index) = Coordinates_antenna(user_cell - 1) +dx+dy*1i;
                end
            end
        end
    end

    for cell_index = 1:NO_cell
        Distance_fromBS_pre(Drop_index,cell_index,:) = abs(Coordinates - repmat(Coordinates_antenna(cell_index),1,NO_user));     %�@�}�N����n�ǂ���̒�������
        Distance_fromBS(Drop_index,cell_index,:) = abs(sqrt(Distance_fromBS_pre(Drop_index,cell_index,:).^2 + 8.5^2));           %�@�}�N����n�ǂ����3D����

        PLR_fromBS(Drop_index,cell_index,:) = 140.7 + 36.7 * log10(Distance_fromBS(Drop_index,cell_index,:)*0.001);  
    end

    %%�@�A���e�i�p�^�[���@%%
    Rank_distance = zeros(1,NO_user);
    Coordinates_pre = Coordinates;
    for Divide_index = 1:NO_user/2
        for user_index = 1:NO_user
            if abs(Coordinates_pre(user_index)) == max(abs(Coordinates_pre))
                Rank_distance(user_index) = -1;
                Coordinates_pre(user_index) = 0;
                break
            end
        end
    end
    pow_amp = [10^(-0.30) 10^(-0.00) 10^(-0.20)  10^(-0.6)  10^(-0.8)  10^(-1.0)];
    tot_pow = sum(pow_amp);
     
    
    %% ���Ԃ��Ƃɗe�ʌv�Z %%
    for Trial_time_index = 1:NO_time_trial
        Capacity_band_ave_oma = zeros(1,NO_user);                                  % Band���̕���Capacity���i�[
        Capacity_band_ave_noma = zeros(1,NO_user);
        Capacity_band_ave_Conv = zeros(1,NO_user);
        Capacity_band_ave_macro_Conv = zeros(1,NO_user);
        Capacity_band_ave_pico_Conv = zeros(1,NO_user);
        Capacity_band_ave_macro = zeros(1,NO_user);
        Capacity_band_ave_pico = zeros(1,NO_user);
        Conv_Capacity_band_ave_macro = zeros(1,NO_user);
        Conv_Capacity_band_ave_pico = zeros(1,NO_user);
    
       %% Rayleigh Fading�t�� %%
        GI = 32;       
        for user_index = 1:NO_user
            for cell_index = 1:7
            channel_responce_time_rayleigh (user_index,cell_index,1:length(pow_amp)) = (1/sqrt(2).*(randn(1,length(pow_amp))+1j*randn(1,length(pow_amp)))) .* sqrt(Delay_profile);
            channel_responce_time_rayleigh(user_index,cell_index,7:NO_SC) = zeros(1,1,NO_SC-NO_path);
            channel_responce_freq(user_index,cell_index,:) = fft(channel_responce_time_rayleigh(user_index,cell_index,:));
            end
        end
        
        %% Average %%
        for user_index = 1:NO_user
            for cell_index = 1: NO_cell
               for RB_index = 1:NO_RB
                    channel_response(RB_index, user_index, cell_index) = abs(mean(channel_responce_freq(user_index, cell_index, NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index)));
               end
            end
        end
        
       %% SINR�v�Z %%
        Interference_m = zeros(NO_user,NO_SC);                                 % ���l���i�[
        Interference_m_pre = zeros(NO_user,NO_SC);
        Interference_p = zeros(NO_user,NO_SC);                                   
        Interference_p_pre = zeros(NO_user,NO_SC);
        Interference_m_OMA = zeros(NO_user,NO_SC);                             % ���l���i�[
        Interference_m_pre_OMA = zeros(NO_user,NO_SC);
        Interference_p_OMA = zeros(NO_user,NO_SC);                                   
        Interference_p_pre_OMA = zeros(NO_user,NO_SC);
        Conv_Interference_m = zeros(NO_user,NO_SC);                            % ���l���i�[
        Conv_Interference_m_pre = zeros(NO_user,NO_SC);
        Conv_Interference_p = zeros(NO_user,NO_SC);                                   
        Conv_Interference_p_pre = zeros(NO_user,NO_SC);

       %% �V���h�E�C���O�v�Z %%
        Shadowing_correlation_matrix=ones(42,42);
        Shadowing_correlation_matrix=Shadowing_correlation_matrix*0.5;
        Shadowing=zeros(42,1);
        for BS_index = 1:42
            Shadowing(BS_index)=Shadowing_var_Pico.*randn(1,1)+Shadowing_ave;
            Shadowing_correlation_matrix(BS_index,BS_index)=1;
        end
        Shadowing_correlation_matrix=sqrtm(Shadowing_correlation_matrix);
        Shadowing=Shadowing_correlation_matrix*Shadowing;
        Shadowing=10.^((Shadowing)/10);

        Shadowing_macro = sqrt(Shadowing_var_Macro).*randn(1,1)+Shadowing_ave;
        Shadowing_macro = 10.^((Shadowing_macro)/10);
        %    Signal_power = Shadowing * 10.^((EIRP_base(EIRP_index)-repmat(PLR_fromBS',1,NO_SC))/10) .* abs(channel_responce_freq(:,:,19)).^2;    % ���˓d��*PLR*�t�F�[�W���O
        %    Signal_power_fromBS = Shadowing * 10.^((EIRP_base(EIRP_index)-repmat(PLR_fromBS(Drop_index,:)',1,NO_SC))/10) .* abs(channel_responce_freq(:,:,19)).^2;    % ���˓d��*PLR*�t�F�[�W���O
        %    Signal_power_fromPicoBS = Shadowing * 10.^((EIRP_picobase(EIRP_picoindex)-repmat(PLR_fromPicoBS(Drop_index,:)',1,NO_SC))/10) .* abs(channel_responce_freq(:,:,19)).^2;    % ���˓d��*PLR*�t�F�[�W���O

        %{
        Signal_power_fromBS_macrouser(:,:,EIRP_index) =10*log10(Shadowing_macro * 10.^((EIRP_base(EIRP_index)  - repmat(PLR_fromBS(Drop_index,:)',1,NO_SC))/10) .* abs(channel_responce_freq_m1(:,:,1)).^2);    %�}�N��BS����̎�M�d�� 
        Signal_power_fromBS_picouser(:,:,EIRP_index) =10*log10(Shadowing_macro * 10.^((EIRP_base(EIRP_index)   - repmat(PLR_fromBS(Drop_index,:)',1,NO_SC))/10) .* abs(channel_responce_freq_m2(:,:,1)).^2);    %�}�N��BS����̎�M�d��
        Signal_power_fromPicoBS_macrouser(:,:,1) = 10*log10(Shadowing_pico * 10.^((EIRP_picobase(1) - repmat(PLR_fromPicoBS(Drop_index,:)',1,NO_SC) )/10) .* abs(channel_responce_freq_p2(:,:,1)).^2);               %�s�RBS����̎�M�d��
        Signal_power_fromPicoBS_picouser(:,:,1) = 10*log10(Shadowing_pico * 10.^((EIRP_picobase(1)   - repmat(PLR_fromPicoBS(Drop_index,:)',1,NO_SC))/10) .* abs(channel_responce_freq_p1(:,:,1)).^2); 
        %}
        
       %% Antenna Pairing %%
        a = zeros(1,user_index);
        notpair = zeros(1,(NO_cell + 1)^NO_user);
        bb=1;
        for user_antenna_pair = 1:(NO_cell+1)^NO_user
            user_antenna_pair_shift = user_antenna_pair-1;
            for user_index = 1:NO_user
                a(user_index) = fix(user_antenna_pair_shift/(NO_cell+1)^(NO_user-user_index))+1;
                user_antenna_pair_shift = rem(user_antenna_pair_shift,(NO_cell+1)^(NO_user-user_index));
            end
            if a(1) ~= 8
                if a(1) == a(2)
                    notpair(bb) = user_antenna_pair;
                    bb = bb+1;
                elseif a(1) == a(3)
                    notpair(bb) = user_antenna_pair;
                    bb = bb+1;
                end
            end
            if a(2) ~= 8
                if a(2) == a(3)
                    notpair(bb) = user_antenna_pair;
                    bb = bb+1;
                end
            end
        end
            
        
       %% SINR�v�Z %%
        Noise_power = 1;   
        EIRP_index = 1;
        EIRP_base(EIRP_index) = 0 + 30 - (Receiver_noise_density + 10*log10(Band));       
        for user_antenna_pair = 1:(NO_cell+1)^NO_user 
            nono = find(user_antenna_pair == notpair(:));
            if isempty(nono) == 1
                user_antenna_pair_shift = user_antenna_pair-1;
                for user_index = 1:NO_user     
                    cell_index_select = fix(user_antenna_pair_shift/(NO_cell+1)^(NO_user-user_index))+1;
                    user_antenna_pair_shift = rem(user_antenna_pair_shift,(NO_cell+1)^(NO_user-user_index));

                    if cell_index_select == 8
                        Signal_power_fromBS_user(user_index,:,EIRP_index) = 0;
                    else
                        Signal_power_fromBS_user(user_index,:,EIRP_index,user_antenna_pair) = Shadowing_macro * 10.^((EIRP_base(EIRP_index)  - repmat(PLR_fromBS(Drop_index,cell_index_select,user_index)',NO_SC,1))/10) .* (abs(squeeze(channel_responce_freq(user_index,cell_index_select,:))).^2);    %�}�N��BS����̎�M�d�� 
                        for user_index_int = 1:NO_user
                            if user_index_int ~= user_index
                                Signal_power_fromBS_Interference_user(user_index_int,:,EIRP_index,user_antenna_pair) = squeeze(Signal_power_fromBS_Interference_user(user_index_int,:,EIRP_index,user_antenna_pair)).' + abs(Shadowing_macro * 10.^((EIRP_base(EIRP_index) - repmat(PLR_fromBS(Drop_index,cell_index_select,user_index_int)',NO_SC,1))/10) .* (abs(squeeze(channel_responce_freq(user_index_int,cell_index_select,:))).^2));    %�}�N��BS����̎�M�d��
                            end
                        end
                    end
                end
                for user_index = 1:NO_user
                    SINR_SC_user(user_index,:,user_antenna_pair) = 10*log10(abs(Signal_power_fromBS_user(user_index,:,EIRP_index,user_antenna_pair)) ./ (Noise_power + Signal_power_fromBS_Interference_user(user_index,:,EIRP_index,user_antenna_pair)));
                end
            else
                SINR_SC_user(:,:,user_antenna_pair) = -inf;
            end
        end
        %    SINR_SC = 10*log10(Signal_power ./ (Noise_power + Interference_power));
        %    Power_ratio_Macro_Pico = Signal_power_fromBS ./ Signal_power_fromPicoBS;
        %    Power_ratio_Pico_Macro = Signal_power_fromPicoBS ./ Signal_power_fromBS;
        %    Power_ratio_Macro_Pico_ave(Drop_index,:) = mean(Power_ratio_Macro_Pico,2)';
        %    Power_ratio_Pico_Macro_ave(Drop_index,:) = mean(Power_ratio_Pico_Macro,2)';
 
        EIRP_index = 1;
        for user_antenna_pair = 1:(NO_cell+1)^NO_user
            for user_index = 1:NO_user
               for RB_index = 1:NO_RB
                   % average
                    SINR_RB_macro(user_index,RB_index,EIRP_index) = mean(SINR_SC_macro(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,EIRP_index));
                    SINR_RB_pico(user_index,RB_index,EIRP_index) = mean(SINR_SC_pico(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,EIRP_index));
                    SINR_RB_pico_Conv(user_index,RB_index,EIRP_index) = mean(SINR_SC_pico_Conv(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,EIRP_index));
                    SINR_RB_macro_Conv(user_index,RB_index,EIRP_index) = mean(SINR_SC_macro_Conv(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,EIRP_index));
                    SINR_RB_pico_oma(user_index,RB_index,EIRP_index) = mean(SINR_SC_pico_oma(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,EIRP_index));
                    SINR_RB_macro_oma(user_index,RB_index,EIRP_index) = mean(SINR_SC_macro_oma(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,EIRP_index));

                    SINR_RB_user(user_index,RB_index,user_antenna_pair) = mean(SINR_SC_user(user_index,NO_SC_inRB*(RB_index-1)+1:NO_SC_inRB*RB_index,user_antenna_pair));
                    SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) = floor(SINR_RB_user(user_index,RB_index,user_antenna_pair));
                    if SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) == -inf
                        SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) = -inf;
                    elseif SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) <=-10
                        SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) = -10;
                    elseif SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) >= 30
                        SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) =30;
                    end
                end
            end   
        end

        %% SINR�l��ψ���ɏC�� %%
        for user_antenna_pair = 1:(NO_cell+1)^NO_user
            for user_index = 1:NO_user
                for SC_index = 1:NO_SC
                    SINR_SC_macro_floor(user_index,SC_index,EIRP_index) = floor(SINR_SC_macro(user_index,SC_index,EIRP_index)) ;
                    SINR_SC_pico_floor(user_index,SC_index,EIRP_index) = floor(SINR_SC_pico(user_index,SC_index,EIRP_index));
                    SINR_SC_pico_Conv_floor(user_index,SC_index,EIRP_index) = floor(SINR_SC_pico_Conv(user_index,SC_index,EIRP_index));
                    SINR_SC_macro_Conv_floor(user_index,SC_index,EIRP_index) = floor(SINR_SC_macro_Conv(user_index,SC_index,EIRP_index));
                    SINR_SC_pico_oma_floor(user_index,SC_index,EIRP_index) = floor(SINR_SC_pico_oma(user_index,SC_index,EIRP_index));
                    SINR_SC_macro_oma_floor(user_index,SC_index,EIRP_index) = floor(SINR_SC_macro_oma(user_index,SC_index,EIRP_index));

                    SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) = floor(SINR_SC_user(user_index,SC_index,user_antenna_pair));
                    if SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) == -inf
                        SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) = -inf;
                    elseif SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) <= -10
                        SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) = -10;
                    elseif SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) >= 30
                        SINR_SC_user_floor(user_index,SC_index,user_antenna_pair) = 30;
                    end

                    if SINR_SC_macro_floor(user_index,SC_index,EIRP_index)  <= -10
                        SINR_SC_macro_floor(user_index,SC_index,EIRP_index) = -10;
                    elseif SINR_SC_macro_floor(user_index,SC_index,EIRP_index) >= 30
                        SINR_SC_macro_floor(user_index,SC_index,EIRP_index) = 30;
                    end
                    if SINR_SC_pico_floor(user_index,SC_index,EIRP_index)  <=-10
                        SINR_SC_pico_floor(user_index,SC_index,EIRP_index) =-10;
                    elseif SINR_SC_pico_floor(user_index,SC_index,EIRP_index) >= 30
                        SINR_SC_pico_floor(user_index,SC_index,EIRP_index) = 30;
                    end
                    if SINR_SC_pico_Conv_floor(user_index,SC_index,EIRP_index)  <=-10
                        SINR_SC_pico_Conv_floor(user_index,SC_index,EIRP_index) =-10;
                    elseif SINR_SC_pico_Conv_floor(user_index,SC_index,EIRP_index) >= 30
                        SINR_SC_pico_Conv_floor(user_index,SC_index,EIRP_index) = 30;
                    end
                    if SINR_SC_macro_Conv_floor(user_index,SC_index,EIRP_index)  <=-10
                        SINR_SC_macro_Conv_floor(user_index,SC_index,EIRP_index) =-10;
                    elseif SINR_SC_macro_Conv_floor(user_index,SC_index,EIRP_index) >= 30
                        SINR_SC_macro_Conv_floor(user_index,SC_index,EIRP_index) = 30;
                    end   
                    if SINR_SC_pico_oma_floor(user_index,SC_index,EIRP_index)  <=-10
                        SINR_SC_pico_oma_floor(user_index,SC_index,EIRP_index) = -10;
                    elseif SINR_SC_pico_oma_floor(user_index,SC_index,EIRP_index) >= 30
                        SINR_SC_pico_oma_floor(user_index,SC_index,EIRP_index) = 30;
                    end
                    if SINR_SC_macro_oma_floor(user_index,SC_index,EIRP_index)  <= -10
                        SINR_SC_macro_oma_floor(user_index,SC_index,EIRP_index) = -10;
                    elseif SINR_SC_macro_oma_floor(user_index,SC_index,EIRP_index) >= 30
                        SINR_SC_macro_oma_floor(user_index,SC_index,EIRP_index) = 30;
                    end   
                end
            end
        end   

        for EIRP_index = 1:NO_EIRP_base 
            for user_index = 1:NO_user
                for RB_index = 1:NO_RB
                    SINR_RB_macro_floor(user_index,RB_index,EIRP_index) = floor(SINR_RB_macro(user_index,RB_index,EIRP_index));
                    SINR_RB_pico_floor(user_index,RB_index,EIRP_index) = floor(SINR_RB_pico(user_index,RB_index,EIRP_index));
                    SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) = floor(SINR_RB_pico_Conv(user_index,RB_index,EIRP_index));
                    SINR_RB_macro_Conv_floor(user_index,RB_index,EIRP_index) = floor(SINR_RB_macro_Conv(user_index,RB_index,EIRP_index));
                    SINR_RB_pico_oma_floor(user_index,RB_index,EIRP_index) = floor(SINR_RB_pico_oma(user_index,RB_index,EIRP_index));
                    SINR_RB_macro_oma_floor(user_index,RB_index,EIRP_index) = floor(SINR_RB_macro_oma(user_index,RB_index,EIRP_index));
                    if SINR_RB_macro_floor(user_index,RB_index,EIRP_index) <-10
                        SINR_RB_macro_floor(user_index,RB_index,EIRP_index) = -10;
                    elseif SINR_RB_macro_floor(user_index,RB_index,EIRP_index) > 30
                        SINR_RB_macro_floor(user_index,RB_index,EIRP_index) = 30;
                    end
                     if SINR_RB_pico_floor(user_index,RB_index,EIRP_index) < -10
                        SINR_RB_pico_floor(user_index,RB_index,EIRP_index) = -10;
                    elseif SINR_RB_pico_floor(user_index,RB_index,EIRP_index) > 30
                        SINR_RB_pico_floor(user_index,RB_index,EIRP_index) = 30;
                     end
                     if SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index)  <  -10
                            SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) = -10;
                    elseif SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) > 30
                            SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) = 30;
                    end
                    if SINR_RB_macro_Conv_floor(user_index,RB_index,EIRP_index)  < -10
                            SINR_RB_macro_Conv_floor(user_index,RB_index,EIRP_index) = -10;
                    elseif SINR_RB_macro_Conv_floor(user_index,RB_index,EIRP_index) > 30
                            SINR_RB_macro_Conv_floor(user_index,RB_index,EIRP_index) = 30; 
                    end
                    if SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index)  <  -10
                            SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) = -10;
                    elseif SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) > 30
                            SINR_RB_pico_Conv_floor(user_index,RB_index,EIRP_index) = 30;
                    end
                    if SINR_RB_macro_oma_floor(user_index,RB_index,EIRP_index)  < -10
                            SINR_RB_macro_oma_floor(user_index,RB_index,EIRP_index) = -10;
                    elseif SINR_RB_macro_oma_floor(user_index,RB_index,EIRP_index) > 30
                            SINR_RB_macro_oma_floor(user_index,RB_index,EIRP_index) = 30; 
                    end
                end
            end
        end
  
        Max_PFmetric_RB = zeros(Timing_interval,NO_RB);
        Max_PFmetric_RB_Conv = zeros(Timing_interval,NO_RB);
        Max_PFmetric_RB_oma = zeros(Timing_interval,NO_RB);

        Capacity_Analyze_band_ave_oma = zeros(Timing_interval,NO_user);
        Capacity_Analyze_band_ave_noma = zeros(Timing_interval,NO_user); 
        Capacity_Analyze_band_ave_Conv = zeros(Timing_interval,NO_user);
        Capacity_Analyze_band_ave_macro = zeros(Timing_interval,NO_user);
        Capacity_Analyze_band_ave_pico = zeros(Timing_interval, NO_user);
        Capacity_Analyze_band_ave_macro_Conv = zeros(Timing_interval,NO_user);
        Capacity_Analyze_band_ave_pico_Conv = zeros(Timing_interval, NO_user);

        select_user_antenna_pair = zeros(1,NO_RB);
        
        for Timing_interval_index = 1:Timing_interval
    
           %% PFmetric�v�Z %%
            Max_CC_modulation = zeros(NO_user,NO_RB,(NO_cell+1)^NO_user);
            modulation_index = zeros(NO_user,NO_RB,(NO_cell+1)^NO_user);
            select_usermod = zeros(NO_RB,NO_user);
            for RB_index = 1:NO_RB
                EIRP_index = 1;
                PA_user = 1;
                PFmetric_RB_Conv = zeros(1,(NO_cell+1)^NO_user);
                for user_antenna_pair = 1:(NO_cell+1)^NO_user
                    if Capacity_band_ave_macro_Conv(user_index) == 0
                        Conv_Capacity_band_ave_pre  = 1;
                    else
                        Conv_Capacity_band_ave_pre = Capacity_band_ave_macro_Conv(user_index);
                    end
                    for user_index = 1:NO_user
                        if SINR_RB_user_floor(user_index,RB_index,user_antenna_pair) ~= -inf
                            [Max_CC_modulation(user_index,RB_index,user_antenna_pair),modulation_index(user_index,RB_index,user_antenna_pair)] = max(squeeze(CCCtable_conv_SINRp_alphap_QAMq_QAMp(SINR_RB_user_floor(user_index,RB_index,user_antenna_pair)+11,1,1,:)));
                            PFmetric_RB_Conv(user_antenna_pair) = PFmetric_RB_Conv(user_antenna_pair) + Max_CC_modulation(user_index,RB_index,user_antenna_pair)*NO_SC*Timing_interval*NO_time_trial / Conv_Capacity_band_ave_pre; %%Conv_Capacity_band_ave_pre�����܂ł̕��ϒʐM�H�e��
                        end
                    end
                end
                if max(PFmetric_RB_Conv) >= Max_PFmetric_RB_Conv(Timing_interval_index,RB_index)
                    Max_PFmetric_RB_Conv(Timing_interval_index,RB_index) = max(PFmetric_RB_Conv);
                    index = find(PFmetric_RB_Conv == Max_PFmetric_RB_Conv(Timing_interval_index,RB_index));
                    % what I want:
                    select_user_antenna_pair(RB_index) = index(1,1);
                    for user_index = 1:NO_user
                        select_usermod(RB_index,user_index) = modulation_index(user_index,RB_index,select_user_antenna_pair(RB_index));
                    end
                end
            end
            
            
          %% �e�ʌv�Z (�]������)%%

            Capacity_trial_realnear_prop = 0;
            Capacity_trial_realfar_prop = 0;
            capacity_pico_Conv_SC = zeros(NO_user,NO_SC);
            capacity_macro_Conv_SC = zeros(NO_user,NO_SC);

            Capacity_byuser_cur_macro_Conv = zeros(1,NO_user);
            Capacity_byuser_cur_pico_Conv = zeros(1,NO_user);
            Capacity_byuser_cur_Conv = zeros(1,NO_user);

            for SC_index = 1:NO_SC
                RB_index = floor((SC_index-1)/NO_SC_inRB)+1;
                for user_index = 1:NO_user
                    SINR_user = SINR_SC_user_floor(user_index,SC_index,select_user_antenna_pair(RB_index))+11;
                    if SINR_user ~= -inf
                        farmod_index = select_usermod(RB_index,user_index);
                        capacity_macro_Conv_SC(user_index,SC_index) = CCCtable_conv_SINRp_alphap_QAMq_QAMp(SINR_user,1,1,farmod_index);     %���]�M���e��

                        %% ��̓v���O���� %%
                        if Timing_interval_index > 20
                            if mod(SC_index,NO_RB) == 2
                                if Analyze_index_Conv > 10000  || Analyze_index_Conv <= 0
                                else
                                   Capacity_Analyze_Conv(Analyze_index_Conv,1) = SINR_user;
                                end
                            end
                        end
                        Capacity_byuser_cur_macro_Conv(user_index) = Capacity_byuser_cur_macro_Conv(user_index) + capacity_macro_Conv_SC(user_index,SC_index) ;

                        if Timing_interval_index > 20
                            Capacity_byuser_macro_Conv(user_index,1,Drop_index) = Capacity_byuser_macro_Conv(user_index,1,Drop_index) + capacity_macro_Conv_SC(user_index,SC_index) ;
                        end

                        %% ��̓v���O���� %%
                        if Timing_interval_index > 20
                            if mod(SC_index,NO_RB) == 2
                                if Analyze_index_Conv > 10000  || Analyze_index_Conv <= 0
                                else
                                    Capacity_Analyze_Conv(Analyze_index_Conv,2) = SINR_user;
                                    Analyze_index_Conv = Analyze_index_Conv + 1;
                                end
                            end
                        end
                    end
                end
            end
            
            %% saving data
            
            if Timing_interval_index == 60
                
                % Get combination (base 10 to base 8)
                for rb_index= 1:NO_RB
                    a1 = floor((select_user_antenna_pair(1, rb_index)-1)/64) + 1;
                    tmp = mod((select_user_antenna_pair(1, rb_index)-1), 64);
                    a2 = floor(tmp/8) + 1;
                    tmp = mod(tmp, 8);
                    a3 = floor(tmp/1) + 1;
                    combination(rb_index, 1) = 100*a1 + 10*a2 + a3;
                end
                
                % Get past throughputs
                past_throughput(:, 1) = Capacity_band_ave_macro_Conv.';
                
                % Get sumrate of the network
                sumrate(1, 1) = sum(Capacity_byuser_cur_macro_Conv);
                
            end
            
            % one:
            Capacity_band_ave_macro_Conv = (1-1/TI)*Capacity_band_ave_macro_Conv + 1/TI*Capacity_byuser_cur_macro_Conv;
            % all:
            Capacity_Analyze_band_ave_macro_Conv(Timing_interval_index,:) = Capacity_band_ave_macro_Conv;
            
            
        end
        % end of timing_interval
        
        %% saving data
        %channel_response
        dir_trial_name = int2str(trial_count);
        basename = fullfile(data_root, dir_trial_name);
        [status, msg] = mkdir(basename);
        if status ~= 1
            disp(msg); % if any error
        end
        cd(basename);
        
        save('channel_response.mat', 'channel_response');
        save('combination.mat', 'combination');
        save('past_throughput.mat', 'past_throughput');
        save('sumrate.mat', 'sumrate');
        
        % clean up:
        trial_count = trial_count+1;
        cd(home)
        
    end 
    % end of trials
    disp("end of trials");
    toc
end

% end of drops

% �X���[�v�b�g�E�t�F�A�l�X�v�Z�O�̃f�[�^�ۑ�
%save (['Conv_Prop_NOMA_HetNet17_19cells_beforeCDF_',num2str(EIRP_index),'_user',num2str(NO_user),'_drop',num2str(NO_drop_trial),'_trial',num2str(NO_time_trial),datestr(now,'_yyyymmdd_HHMM'),'.mat']);
%Distance_fromPicoBS_serial = reshape(Distance_fromPicoBS,[1,numel(Distance_fromPicoBS)]);
%Power_ratio_Macro_Pico_ave_serial = reshape(Power_ratio_Macro_Pico_ave,[1,numel(Power_ratio_Macro_Pico_ave)]);
%Power_ratio_Pico_Macro_ave_serial = reshape(Power_ratio_Pico_Macro_ave,[1,numel(Power_ratio_Pico_Macro_ave)]);


%% CDF %%
   
% Capacity_byuser_macro_Conv(:,1,:) = Capacity_byuser_macro_Conv(:,1,:) / (NO_time_trial*(Timing_interval-20) * NO_SC);
% 
% Capacity_sum_macro_Conv = sum(sum(Capacity_byuser_macro_Conv,3),1) / NO_drop_trial;
% 
% Fairness_macro_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% Fairness_pico_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% %Fairness_oma_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% Fairness_noma_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% Fairness_macro_Conv_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% Fairness_pico_Conv_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% Fairness_Conv_pre = ones(1,NO_EIRP_base,NO_drop_trial);                % Fairness�l���i�[
% Fairness_noma = zeros(1,NO_EIRP_base);
% Fairness_macro = zeros(1,NO_EIRP_base);
% Fairness_pico = zeros(1,NO_EIRP_base);
% Fairness_Conv = zeros(1,NO_EIRP_base);
% Fairness_macro_Conv = zeros(1,NO_EIRP_base);
% Fairness_pico_Conv = zeros(1,NO_EIRP_base);
% %Fairness_oma = zeros(1,NO_EIRP_base);
% 
% for user_index = 1:NO_user
%     Fairness_macro_Conv_pre = Fairness_macro_Conv_pre .* Capacity_byuser_macro_Conv(user_index,1,:)*NO_user;
%     %Fairness_oma_pre = Fairness_oma_pre .* Capacity_byuser_oma(user_index,:,:)*NO_user;
% end
% 
% 
% Fairness_macro_Conv_pre = nthroot(Fairness_macro_Conv_pre,NO_user);
% 
% 
% for Drop_index = 1:NO_drop_trial
%     Fairness_macro_Conv = Fairness_macro_Conv + Fairness_macro_Conv_pre(1,1,Drop_index);
% end
% 
% Fairness_macro_Conv = Fairness_macro_Conv / NO_drop_trial;
% 
% 
% Capacity_value = zeros(1,3000);
% CDF_capacity_macro = zeros(1,3000);
% CDF_capacity_pico = zeros(1,3000);
% CDF_capacity_noma = zeros(1,3000);
% CDF_capacity_macro_Conv = zeros(1,3000);
% CDF_capacity_pico_Conv = zeros(1,3000);
% CDF_capacity_Conv = zeros(1,3000);
% %CDF_capacity_oma = zeros(1,3000);
% 
% for Capacity_index = 1:3000
%     Capacity_value(Capacity_index) = Capacity_index*0.002;
%     CDF_capacity_Conv(Capacity_index) = length(find(Capacity_byuser_macro_Conv(:,1,:)<Capacity_value(Capacity_index)));
% end
% 
% 
% CDF_capacity_Conv = CDF_capacity_Conv / (NO_user * NO_drop_trial);
% 
% 
% 
% save (['Conv_Prop_NOMA_HetNet_19cells_direct_',num2str(NO_EIRP_base),'_user',num2str(NO_user),'_drop',num2str(NO_drop_trial),'_trial',num2str(NO_time_trial),datestr(now,'_yyyymmdd_HHMM'),'.mat']);

% figure(1)
% plot(Capacity_value,CDF_capacity_macro,'-y','LineWidth',3)
% xlim([0 8]);
% hold on
% plot(Capacity_value,CDF_capacity_pico,'-.m','LineWidth',3);
% hold on
% %plot(Capacity_value,CDF_capacity_oma,'--k','LineWidth',3);
% %hold on
% plot(Capacity_value,CDF_capacity_noma,'-.c','LineWidth',3);
% hold on
% plot(Capacity_value,CDF_capacity_macro_Conv,'-g','LineWidth',3);
% hold on
% plot(Capacity_value,CDF_capacity_pico_Conv,'-.b','LineWidth',3);
% hold on
% plot(Capacity_value,CDF_capacity_Conv,'-.r','LineWidth',3);
% hold on
% grid on
% %legend('Macro user','Pico user','OMA','NOMA','Location','SouthEast')
% legend('Macro User (Prop.)','Pico User (Prop.)','Macro-Pico SUM (Prop.)','Macro User (Conv.)','Pico User (Conv.)','Macro-Pico SUM (Conv.)','Location','SouthEast')
% xlabel('Throughput [bit/subcarrier/user]','FontName','Arial','FontSize',14)
% ylabel('Cumulative Probability','FontName','Arial','FontSize',14)
% set(gca,'FontName','Arial','FontSize',10)
% hold off

