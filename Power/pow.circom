pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";

// Create a circuit which takes an input 'a',(array of length 2 ) , then  implement power modulo 
// and return it using output 'c'.

// HINT: Non Quadratic constraints are not allowed. 

template Pow(maxPow) {
   
   signal input a[2];
   signal l[maxPow];
   signal m[maxPow];
   signal n[maxPow];
   signal output c;


   component lt[maxPow];

   for (var i=0; i<maxPow; i++) {
      lt[i] = LessThan(250);
      i    ==> lt[i].in[0];
      a[1] ==> lt[i].in[1];
      // log(lt[i].out);

      l[i] <== a[0] * lt[i].out;
      // log(l[i]);
   }


   component isZ[maxPow];

   for (var i=0; i<maxPow; i++) {
      isZ[i] = IsZero();

      l[i] ==> isZ[i].in;
      m[i] <== l[i] + isZ[i].out;
      // log(m[i]);
   }

   n[0] <== m[0];
   for (var i=1; i<maxPow; i++) {
      n[i] <== n[i-1] * m[i];
      // log(n[i]);
   }

   c <== n[maxPow-2];
   // log(c);

}

component main = Pow(64);

