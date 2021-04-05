function sph = cart2sphVec(cart)
% Vectorized form wrapper for cart2sph
% PROVIDED %
% Sebastian J. Schlecht, Sunday 8. November 2020

x = cart(:,1);
y = cart(:,2);
z = cart(:,3);

[az,elev,r] = cart2sph(x,y,z);

sph = [az,elev,r];
