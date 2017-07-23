function vars = radon_sig( A )
%%%%%%%%% get the input image %%%%%%%%%%%%%%%%%%%
A=imresize(A,[128 128]);
A = double(rgb2gray( A ));

% gradient magnitude
dx = imfilter(A,fspecial('sobel') ); % x, 3x3 kernel
dy = imfilter(A,fspecial('sobel')'); % y
gradmag = sqrt( dx.^2 + dy.^2 );

% mask by disk
R = min( size(A)/2 ); % radius
disk = insertShape(zeros(size(A)),'FilledCircle', [size(A)/2,R] );
mask = double(rgb2gray(disk)~=0);
gradmag = mask.*gradmag;

img=uint8(gradmag);

% radon transform for 180 values
theta = linspace(0,180,180);
vars = zeros(size(theta));
for u = 1:length(theta)
    [rad,xp] =radon( gradmag, theta(u) );
    indices = find( abs(xp)<R );
    % ignore radii outside the maximum disk area
    % so you don't sum up zeroes into variance
    vars(u) = var( rad( indices ) );
end
vars = vars/norm(vars);

%finding theta
thetas=0;
temp=0;
for i= 1:180
    if vars(i)>temp
        thetas=i;
        temp=vars(i);
    end
        
end
end

