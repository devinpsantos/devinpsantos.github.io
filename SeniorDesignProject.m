% Created By: Devin Santos
% Date: 4/23/21
% EECE 490: Design Project
% This program performs coherent sampling for an ADC output using an 
% LTspice generated .RAW file to get FFT and SNR.
%--------------------------------------------------------------------------------------------

clc; 
clear; 
close all; 

%--------------------------------------------------------------------------------------------

% Load LTspice .raw file using LTspice2Matlab
raw_data = LTspice2Matlab('SAR_ADC.raw');

%--------------------------------------------------------------------------------------------

% Coherent Sampling Confirmation 
prompt = 'Enter your ADC sampling frequency. (Ex. --> 3000.45)\n--> ';  % user reads this 
user_fsample = input(prompt);  % what user enters is saved 
X = sprintf('Your ADC sampling frequency has been recorded as %f Hz',user_fsample);
disp(X);

%--------------------------------------------------------------------------------------------

prompt = 'Enter the odd number of windows chosen for coherent sampling.\n--> ';
user_Nwin = input(prompt);
prompt = 'Must enter ODD number of windows for coherent sampling.\n--> ';

%--------------------------------------------------------------------------------------------

while( rem(user_Nwin,2) == 0 )
user_Nwin = input(prompt);
end 

%--------------------------------------------------------------------------------------------

X = sprintf('%d is an accepted value for windows.',user_Nwin);
disp(X); 

%--------------------------------------------------------------------------------------------

prompt = 'Enter the chosen number of data samples that is a power of 2. (Ex. --> 256)\n--> ';
ones_count = 0; 

%--------------------------------------------------------------------------------------------

while (ones_count > 1) || (ones_count == 0) 
    user_Nsamples = input(prompt);
    shifted_num = user_Nsamples;
    ones_count = 0;
    
    while (shifted_num ~= 0)
        ones_count = ones_count + bitand(shifted_num,1); % bitwiseAND shifted_num with 1
        shifted_num = bitshift(shifted_num,-1); % logical shift right by 1 bit
    end

    if ones_count == 1 
        disp(sprintf('%d is a correct entry.',user_Nsamples));
    else 
        disp(sprintf('%d is an incorrect entry.',user_Nsamples));
    end 
    
end 

%--------------------------------------------------------------------------------------------

fsample = user_fsample;                     % sample frequency in hertz 
Nwin = user_Nwin;                           % number of cycles in sample period 
Nsamples = user_Nsamples;                   % number of data points in sample period 
fin = double((Nwin/Nsamples)*(fsample)) ;   % required freq input 
run_time = (1/fin)*Nwin + ((1/fin)*Nwin)/Nsamples;
%--------------------------------------------------------------------------------------------

disp(sprintf('Your required input frequency for LTspice is %f',fin));
disp(sprintf('Your required run time for LTspice simulation is %e seconds',run_time));
prompt = 'Are both input frequency and run time matching your LTspice simulation yes or no?\n--> ';
feedback = input(prompt, 's');
if strcmp(feedback,'yes')
    disp('Perfect!');

%--------------------------------------------------------------------------------------------

% LTspice Time Vector 
time_data = raw_data.time_vect; % loads LTspice time vector to time_data 
time_data = round(time_data,15,'significant'); % Need to round to match numbers 

%--------------------------------------------------------------------------------------------

% Desired Time Vector 
time_per_cycle = 1/fin;  % time for one full cycle  
stepsize = (time_per_cycle*Nwin)/Nsamples;  % stepsize to get Nsample data points for Nwin cycles
t = 0:stepsize:(Nwin*time_per_cycle)-stepsize;  % time matrix 
t = round(t,6,'significant'); % round each element to 6 sig figs after decimal point

%--------------------------------------------------------------------------------------------

%Extracting Desired Columns from LTspice time_vect
des_col_vect = zeros(1,length(t)); % desired columns vector
for i = 1:length(t) % length of desired time vector 
    
    for j = 1:length(time_data) % length of LTspice time vector 

        if t(1,i) == time_data(1,j) % if desired time matches LTspice time  
            des_col_vect(1,i) = j;  % record column numbers in a vector
        end 
        
    end
    
end 

%--------------------------------------------------------------------------------------------

% Display variable names for user 
disp( sprintf('\n\nThis file contains %.0f variables:\n', raw_data.num_variables) );
disp( sprintf('NAME         TYPE\n-------------------------') );
disp( [char(raw_data.variable_name_list), char(zeros(raw_data.num_variables,5)), ...
             char(raw_data.variable_type_list)] );
         
%--------------------------------------------------------------------------------------------  

% Get user to enter desired variable name  
prompt = '\nUse the provided list above and enter ADC output variable. (Ex. --> V(output) )\n--> '; 
desired_var = input(prompt, 's');  % what user enters is saved in desired_var

%--------------------------------------------------------------------------------------------

% Search for row number associated with variable name 
num = raw_data.num_variables;  % equals total amount of variables in file 
var_num = 0;  % declaring var_num 
for j = 1:num  % j goes through every variable in file 
    name = raw_data.variable_name_list{j}; % gets name one-by-one 
    if strcmp(desired_var,name)  % if user entered name matches 
        var_num = j; % set var_num using j 
    end 
end 

%--------------------------------------------------------------------------------------------

% Display to user if correct variable was found 
if var_num ~= 0 
    
if strcmp(desired_var,raw_data.variable_name_list{var_num})
    disp('Variable found.')
    disp('Generating your results!');

%--------------------------------------------------------------------------------------------

% Load Desired Variable from LTspice to xt 
xt = raw_data.variable_mat(var_num,:); % xt is time domain signal

%--------------------------------------------------------------------------------------------

% Use Desired Columns to Extract Data from Signal 
desired_data = zeros(1,length(t)); 
for k = 1:length(des_col_vect)

    desired_data(1,k) = xt(1,des_col_vect(1,k));

end

%--------------------------------------------------------------------------------------------

% Experiment to fix non-continuous signal
% Extend time by one stepsize 
t = 0:stepsize:(Nwin*time_per_cycle); %-stepsize;  % time matrix 
t = round(t,6,'significant'); % round each element to 6 sig figs after decimal point

%--------------------------------------------------------------------------------------------

%Extracting Desired Columns from LTspice time_vect
des_col_vect = zeros(1,length(t)); % desired columns vector
for i = 1:length(t) % length of desired time vector 
    
    for j = 1:length(time_data) % length of LTspice time vector 

        if t(1,i) == time_data(1,j) % if desired time matches LTspice time  
            des_col_vect(1,i) = j;  % record column numbers in a vector
        end 
        
    end
    
end 

%--------------------------------------------------------------------------------------------

for k = 1:length(des_col_vect)
    desired_data(1,k) = xt(1,des_col_vect(1,k));
end

%--------------------------------------------------------------------------------------------

expmt_d = desired_data(1,2:end); % exclude data in 1st column
t_d = 0:stepsize:(Nwin*time_per_cycle)-stepsize;

%--------------------------------------------------------------------------------------------

% FFT 
F = 1/stepsize;                   % frequency range            
Fs = 1/((Nwin*time_per_cycle));   % frequency step size 
fn = 0:Fs:F-Fs;                   % frequency axis 
fn_2 = fn-F/2;                    % centers around zero 
expmt_d = expmt_d - mean(expmt_d); % remove DC offset
Xs = fft(expmt_d);                 % Perform FFT to find frequency domain signal
L_Xs = length(Xs);                 % Measuring length of Xs to perform AMPLITUDE NORMALIZATION
Xs_2 =fftshift(Xs)./(L_Xs./2);     % FFTSHIFT and AMPLITUDE NORMAILZATION

%--------------------------------------------------------------------------------------------

% Finding which data point the signal is in 
for i = 1:length(fn_2)
    if (floor(fn_2(1,i))) == (floor(fin))
        my_sig = i ;  % my_sig is the column location where signal data is
    end 
end 
samples = abs(Xs_2) ; % using abs to get magnitude
my_sig_v_amp = samples(1,my_sig); % getting amplitude of signal 

%--------------------------------------------------------------------------------------------

% Loop for finding frequency 0 column 
for i = 1:length(fn_2)
    if round(fn_2(1,i)) == 0
        z_column = i ;  % column where 0 (center) is 
    end 
end

%--------------------------------------------------------------------------------------------

% Loop for noise array 
j = 1; 

for i = (z_column+1):length(samples)
    
    if i ~= my_sig
        my_noise(1,j) = samples(1,i);
    else 
        my_noise(1,j) = 0; 
    end 
    
    j = j + 1; 
end 

%--------------------------------------------------------------------------------------------

% Square and Sum noise array 
my_noise = my_noise.*my_noise;
my_noise = (sum(my_noise));

%--------------------------------------------------------------------------------------------

% Calculate SNR 
signal_rms = sqrt(mean(my_sig_v_amp.*my_sig_v_amp)); 
noise_rms = sqrt(my_noise); 
my_SNR = floor(20*log10(signal_rms/noise_rms));
prompt = 'Enter the number of bits your ADC is.\n--> ';
N = input(prompt);
best_SNR = 6.02*N + 1.76; 
disp(sprintf('The best case scenario SNR is %f dB, your SNR is %f dB',best_SNR,my_SNR));
half_best_SNR = 0.5*best_SNR;
almost_best = 0.8*best_SNR;

%--------------------------------------------------------------------------------------------

% Plot LTspice variable 
figure(); plot(time_data,xt); title('RAW LTspice Data');

%--------------------------------------------------------------------------------------------

% Plot Coherent Sampled Data
figure(); plot(t_d,expmt_d); title('Coherent Sampled Data');

%--------------------------------------------------------------------------------------------

% Visualizing FFT
figure();
plot(fn_2, abs(Xs_2));
axis([0 F/2 0 10]); 
grid on;
title('FFT');
xlabel('Frequency');
ylabel('Amplitude');

%--------------------------------------------------------------------------------------------

if my_SNR < half_best_SNR
    disp('You need to improve your SNR.');
end 

%--------------------------------------------------------------------------------------------

if (my_SNR > half_best_SNR) && (my_SNR <= almost_best)
    disp('Your SNR value is okay, it could be better.');
end

%--------------------------------------------------------------------------------------------

if my_SNR >= almost_best
    disp('Your SNR value is looking awesome!');
end 

%--------------------------------------------------------------------------------------------

if my_SNR > best_SNR
    disp('No way dude, check your work.');
end 

%--------------------------------------------------------------------------------------------

end

%--------------------------------------------------------------------------------------------

else
    disp('Could not find variable :(')
end

%--------------------------------------------------------------------------------------------

else 
    disp('Please enter correct input frequency and run time in LTspice and simulate again.');
    disp('You will then need to bring the new .RAW file into MATLAB.');
end

%--------------------------------------------------------------------------------------------
