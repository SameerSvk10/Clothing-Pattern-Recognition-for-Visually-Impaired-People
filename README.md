# Clothing-Pattern-Recognition-for-Visually-Impaired-People

This is a MATLAB based implementation which recognizes clothing patterns into 4 categories (plaid, striped, patternless, and irregular) and identifies 6 clothing colors.
To recognize clothing patterns, Radon Signature descriptor,statistical properties from wavelet subbands(STA) and Scale Invariant Feature Transform (SIFT) features are used . The extracted global and local features are combined to recognize clothing patterns by using Support Vector Machines (SVMs) classifier. The recognition of clothing color is implemented by quantizing clothing color in the HSI space. In the end, the recognition results of both clothing patterns and colors mutually provide a meaningful description of clothes to users.

Reference : ASSISTIVE CLOTHING PATTERN RECOGNITION FOR VISUALLY IMPAIRED PEOPLE published in IEEE TRANSACTIONS ON HUMAN-MACHINE SYSTEMS, VOL. 44, NO. 2, APRIL 2014. 
Here's a link to the paper: https://pdfs.semanticscholar.org/eb57/cb0379d2300bc80c693e9d0e2ec41eea6df1.pdf

The dataset can be downloaded from here : https://drive.google.com/open?id=0BxQQt3lCU844Nko4WTltdVk3QWNySXBPWDU1MU1WSnBpMmF3
