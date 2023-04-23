pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";

// Input 3 values using 'a'(array of length 3) and check if they all are equal.
// Return using signal 'c'.

template Equality() {
   signal input a[3];
   signal b[2];
   signal e;
   signal output c;

   b[0] <== a[0] - a[1];
   b[1] <== a[0] - a[2];

   e <== b[0] - b[1];

   component isZ = IsZero();

   e ==> isZ.in;

   c <== isZ.out;
}

component main = Equality();