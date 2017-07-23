%Testing the model on a single image

TestarrayImage = zeros(1, 133003);  %zeros matrix for storing test image's features
k=0;
I = imread('C:\Users\Sameer\Desktop\ClothingPatterns\patternless (6).jpg' );  %%%% read the image  %%%%%
I=imresize(I,[128 128]);

[mm nn oo]=size(I);

%%% rgb to gray conversion%%
Ig=rgb2gray(I);

[m n o]=size(Ig);

%%% WAVELET SUBBANDS--DWT and SWT %%%
%%%%%%%%apply 2D-discrete wavelet transform%%%%%%%%%%%%%%%
[a h v d]=dwt2(Ig,'db1');
t=[a h;v d];

%% LEVEL 1
%%%%%%%%apply 2D-stationary wavelet transform%%%%%%%%%%%%%%%
[a1 h1 v1 d1]=swt2(Ig,1,'db1');

t1=[a1 h1;v1 d1];

%% LEVEL 2
%%%%%%%%apply 2D-stationary wavelet transform%%%%%%%%%%%%%%%
Ig2=imresize(Ig,[64 64]);
[a2 h2 v2 d2]=swt2(Ig2,1,'db1');

t2=[a2 h2;v2 d2];

%% LEVEL 3
%%%%%%%%apply 2D-stationary wavelet transform%%%%%%%%%%%%%%%
Ig3=imresize(Ig,[32 32]);
[a3 h3 v3 d3]=swt2(Ig3,1,'db1');

t3=[a3 h3;v3 d3];

%% EXTRACTION OF STATISTICAL FEATURES(STA)
G=64;
[r1 c1]=size(a1);
ng=r1*c1;
H=imhist(a1);
for g=1:G
    p1(g)=g*H(g);                            %%mean
    p11=sum(p1);
    p2(g)=sqrt((g-p1(g)).^2.*H(g));              %%std deviation
    p22=sum(p2);
    p4(g)=(H(g)).^2;                              %%energy
    p44=sum(p4);
    p5(g)=(-H(g).*log2(H(g)));                  %%entopy
    p55=sum(p5);
end

%% GRAY TO BINARY
level=graythresh(Ig);
bw=im2bw(Ig,level);

%% SIFT %%
[kp,kpl,kpori,kpmag,kpd]=SIFT(Ig);

%Generating feature matrix for Image with contains STATISTICAL
%FEATURES(STA) and Scale Invariant Feature Transform (SIFT).

%appending STA features to Feature matrix
TestarrayImage(k,1) = p11;
TestarrayImage(k,2) = p22;
TestarrayImage(k,3) = p44;

%zeros matrix for storing different features as the no. of features
%will be variable for different images. So taking large matrice to
%ensure that all the features will be considered.
kp1=zeros(1,1000);
kpl1=zeros(1,2000);
kpori1=zeros(1,1000);
kpmag1=zeros(1,1000);
kpd1=zeros(1,128000);

%appending SIFT features to Feature matrix
kp = reshape(kp', 1, size(kp,1));
requiredpadding = 1000-size(kp,2);
kp=[kp zeros(1,requiredpadding)];
TestarrayImage(k,4:1003) = kp;

kpl = reshape(kpl', 1, (size(kpl,1)*size(kpl,2)));
requiredpadding = 2000-(size(kpl,1)*size(kpl,2));
kpl=[kpl zeros(1,requiredpadding)];
TestarrayImage(k,1004:3003) = kpl;

kpori = reshape(kpori', 1,size(kpori,1));
requiredpadding = 1000-size(kpori,2);
kpori=[kpori zeros(1,requiredpadding)];
TestarrayImage(k,3004:4003) = kpori;

kpmag = reshape(kpmag', 1, size(kpmag,1));
requiredpadding = 1000-size(kpmag,2);
kpmag=[kpmag zeros(1,requiredpadding)];
TestarrayImage(k,4004:5003) = kpmag;

kpd = reshape(kpd', 1,(size(kpd,1)*size(kpd,2)) );
requiredpadding = 128000-(size(kpd,1)*size(kpd,2));
kpd=[kpd zeros(1,requiredpadding)];
TestarrayImage(k,5004:133003) = kpd;

% prediction of test input using trained model
predicted_label = svmpredict(0, TestarrayImage, model,'-b 1');


if predicted_label==0
    fprintf('irregular\n')
else if predicted_label==1
        fprintf('patternless\n')
    else if predicted_label==2
            fprintf('plaid\n')
        else
            fprintf('striped\n')
        end
    end
end

Im_ColorLayer = color_detection_by_hue(I); 
[out,K]=max(cellfun(@(x)sum(Im_ColorLayer.(x)(:)), fieldnames(Im_ColorLayer)));
colors={'black';'white';'red';'yellow';'green';'cyan';'blue';'magenta'};
colors(K)
