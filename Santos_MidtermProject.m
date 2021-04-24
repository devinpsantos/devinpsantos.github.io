% Devin Santos 
% Midterm Project
% EECE 566
% Dr. Alavi 
% Date Created: 03/22/2021
% This .m file reads an image and filters it in the 
% frequency domain. No DFT MATLAB commands can be used. 

clc; 
clear; 
close all; 

% Read Image 
orig_pic = imread('test-img.pgm'); 

% Display Original Image 
figure(); imagesc(orig_pic); colorbar; 
title('Original Image');

% Get size of M and N from orig_pic 
[M,N] = size(orig_pic);

% Calculate P and Q using M and N
P = 2*M - 1;
Q = 2*N - 1;

% Define Do
Do = 75;

% Create zero-pad using P and Q 
zero_pad = zeros(P,Q);

% Insert orig_pic into top left quadrant of zero-pad  
zero_pad(1:M,1:N) = orig_pic; 

% Multiply zero-padded image by (-1)^P+Q
for x = 1:P
    for y = 1:Q
        zero_pad(x,y) = zero_pad(x,y) * ( (-1)^(x+y) ); 
    end 
end 

% Take DFT of zero-padded image using fast 2D DFT method
% to get frequency domain
% Calculating 1st 2D matrix for y sigma portion 
A = zeros(P,Q); 
for x = 1:P
    for v = 1:Q
        for y = 1:Q
            w = zero_pad(x,y) * ( exp(-1*1i*2*pi*v*y/Q) );
            A(x,v) = A(x,v) + w ; 
        end 
    end 
end 

% Using "A" matrix to calculate F(u,v) for x sigma portion 
F = zeros(P,Q);
for u = 1:P
    for v = 1:Q
        for x = 1:P
            z = A(x,v) * ( exp(-1*1i*2*pi*u*x/P) );
            F(u,v) = F(u,v) + z; 
        end 
    end 
end 

% Calculate filter using function
H = my_filter(Do,P,Q);

% Multiply filter by picture in frequency domain 
G = H.*F; 

% Apply Inverse DFT to go back to spatial domain
% Solving for v sigma portion 
W = zeros(P,Q);
for u = 1:P
    for y = 1:Q
        for v = 1:Q
            k = G(u,v) * ( exp(1i*2*pi*v*y/Q) );
            W(u,y) = W(u,y) + k;
        end 
    end 
end 

% Solving for u sigma portion 
f = zeros(P,Q);
for x = 1:P
    for y = 1:Q
        for u = 1:P
            r = W(u,y) * ( exp(1i*2*pi*u*x/P) );
            f(x,y) = f(x,y) + r;
        end 
    end 
end 

% Multiply by 1/PQ to follow equation 
f = (1/(P*Q)).*f;

% Get Top Left Quad to remove zero-pad
top_left = f(1:M,1:N);

% Multiply by (-1)^(x+y) since we are back in spatial domain
for x = 1:M
    for y = 1:N
        top_left(x,y) = top_left(x,y) * ( (-1)^(x+y) ) ; 
    end 
end 

% Take only the real values of complex matrix 
filtered_img = real(top_left);

% Scale from 0-255
filtered_img = filtered_img - min(min(filtered_img)) ;
filtered_img = 255.*(filtered_img./(max(max(filtered_img))));

% Display Filtered Image 
figure(); imagesc(filtered_img); colorbar; 
title(sprintf('Filtered Image , Do = %d',Do)); 


% Filter Function 
function H = my_filter(Do,P,Q)
    D = zeros(P,Q);
for u = 1:P 
    for v = 1:Q
        D(u,v) = sqrt( ((u - P/2)^2) + ((v - Q/2)^2) );
    end 
end 

    H = zeros(P,Q);
    for u = 1:P
      for v = 1:Q
        if D(u,v) <= Do 
            H(u,v) = 1; 
        else 
            H(u,v) = 0; 
        end 
      end 
    end 
end 

