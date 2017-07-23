clc;
clear all;
close all;

%you can load the .mat files directly by using load function, no need to do following steps, jump
%directly to training of multi class
arrayImage=load('array_image4_1.mat');
class = load('class_4.mat');

%% or do the following to generate arrayImage and class matrix

folder = 'C:\Users\Sameer\Desktop\ClothingPatterns\cloth_patterns'; %path containing all the training images
dirImage = dir(fullfile(folder,'*.jpg'));            %reading the contents of directory

numData = size(dirImage,1)    %no. of samples

arrayImage = zeros(numData, 133183); % zeros matrix for storing the extracted features from images

for i=1:numData
        nama = dirImage(i).name; 
        I=imread([folder, '/', nama]);  %%%% read the image  %%%%%
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
        arrayImage(i,1) = p11;
        arrayImage(i,2) = p22;
        arrayImage(i,3) = p44;

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
        arrayImage(i,4:1003) = kp;
        
        kpl = reshape(kpl', 1, (size(kpl,1)*size(kpl,2)));
        requiredpadding = 2000-(size(kpl,1)*size(kpl,2));
        kpl=[kpl zeros(1,requiredpadding)];
        arrayImage(i,1004:3003) = kpl;
        
        kpori = reshape(kpori', 1,size(kpori,1));
        requiredpadding = 1000-size(kpori,2);
        kpori=[kpori zeros(1,requiredpadding)];
        arrayImage(i,3004:4003) = kpori;
        
        kpmag = reshape(kpmag', 1, size(kpmag,1));
        requiredpadding = 1000-size(kpmag,2);
        kpmag=[kpmag zeros(1,requiredpadding)];
        arrayImage(i,4004:5003) = kpmag;
        
        kpd = reshape(kpd', 1,(size(kpd,1)*size(kpd,2)) );
        requiredpadding = 128000-(size(kpd,1)*size(kpd,2));
        kpd=[kpd zeros(1,requiredpadding)];
        arrayImage(i,5004:133003) = kpd;
        
        %%Radon Signature
        vars=radon_sig(I);
        arrayImage(i,133004:133183) = vars;
        
end

%% Generating label matrix which contains the class number of all the training images
class = zeros(numData,1);
for j=1:numData
    if  (0 < j) && (j < 157)
        class(j) = 0;    %class 0- Irregular
    else if (156 < j) && (j < 313)
            class(j) = 1;  %class 1- Patternless
        else if (312 < j) && (j < 470)
                class(j) = 2;  %class 2- Plaid
            else if (469 < j) && (j < 628)
                class(j) = 3;    %class 3- Striped
                end
            end
        end
    end
end

%% Training of Multi-class SVM with Feature matrix and labels
% -s specifies the type of SVM ( Here multi-class classification is used)
% -t specifies Kernel type( Here RBF kernel is used for training)
% -b 1 gives  probability estimates.
model = svmtrain(class,arrayImage,'-s 0 -t 2 -b 1'); 
%% Testing of trained model
% After training testing is done on training samples
% It ouputs the predicted class for each test input
% Also displys model's accuracy
[predicted_label] = svmpredict(class, arrayImage, model,'-b 1');

