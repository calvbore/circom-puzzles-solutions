pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";

// In this exercise , we will learn how to check the range of a private variable and prove that 
// it is within the range . 

// For example we can prove that a certain person's income is within the range
// Declare 3 input signals `a`, `lowerbound` and `upperbound`.
// If 'a' is within the range, output 1 , else output 0 using 'out'


template Range() {
    signal input a;
    signal input lowerbound;
    signal input upperbound;

    signal output out;
   
    component lte = LessEqThan(250);
    a          ==> lte.in[0];
    upperbound ==> lte.in[1];

    component gte = GreaterEqThan(250);
    a          ==> gte.in[0];
    lowerbound ==> gte.in[1];

    out <== lte.out * gte.out;
}

component main  = Range();


