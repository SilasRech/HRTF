function cart = sph2cartVec(sph)
% Vectorized form wrapper for cart2sph
% PROVIDED %
% Sebastian J. Schlecht, Sunday 8. November 2020

azi = sph(:,1);
ele = sph(:,2);
r = sph(:,3);

[x,y,z] = sph2cart(azi,ele,r);

cart = [x,y,z];
