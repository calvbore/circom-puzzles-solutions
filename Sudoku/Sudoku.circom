pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";


/*
    Given a 4x4 sudoku board with array signal input "question" and "solution", check if the solution is correct.

    "question" is a 16 length array. Example: [0,4,0,0,0,0,1,0,0,0,0,3,2,0,0,0] == [0, 4, 0, 0]
                                                                                   [0, 0, 1, 0]
                                                                                   [0, 0, 0, 3]
                                                                                   [2, 0, 0, 0]

    "solution" is a 16 length array. Example: [1,4,3,2,3,2,1,4,4,1,2,3,2,3,4,1] == [1, 4, 3, 2]
                                                                                   [3, 2, 1, 4]
                                                                                   [4, 1, 2, 3]
                                                                                   [2, 3, 4, 1]

    "out" is the signal output of the circuit. "out" is 1 if the solution is correct, otherwise 0.                                                                               
*/

// find if an array has a single instance of a number
template ArraySingleInstance(length) {
    signal input array[length];
    signal input instance;
    signal output out; // truthy

    component isE[length];
    for (var i=0; i<length; i++) {
        isE[i] = IsEqual();
        array[i] ==> isE[i].in[0];
        instance ==> isE[i].in[1];
    }

    signal l[length];
    l[0] <== isE[0].out;
    for (var i=1; i<length; i++) {
        l[i] <== l[i-1] + isE[i].out;
    }

    component isOne = IsEqual();
    1           ==> isOne.in[1];
    l[length-1] ==> isOne.in[0];

    out <== isOne.out;
}


template Sudoku () {
    // Question Setup 
    signal input question[16];
    signal input solution[16];
    signal output out;
    
    // Checking if the question is valid
    for(var v = 0; v < 16; v++){
        log(solution[v],question[v]);
        assert(question[v] == solution[v] || question[v] == 0);
    }
    log(" ");

    
    var m = 0 ;
    component row1[4];
    for(var q = 0; q < 4; q++){
        row1[m] = IsEqual();
        row1[m].in[0]  <== question[q];
        row1[m].in[1] <== 0;
        m++;
    }
    3 === row1[3].out + row1[2].out + row1[1].out + row1[0].out;

    m = 0;
    component row2[4];
    for(var q = 4; q < 8; q++){
        row2[m] = IsEqual();
        row2[m].in[0]  <== question[q];
        row2[m].in[1] <== 0;
        m++;
    }
    3 === row2[3].out + row2[2].out + row2[1].out + row2[0].out; 

    m = 0;
    component row3[4];
    for(var q = 8; q < 12; q++){
        row3[m] = IsEqual();
        row3[m].in[0]  <== question[q];
        row3[m].in[1] <== 0;
        m++;
    }
    3 === row3[3].out + row3[2].out + row3[1].out + row3[0].out; 

    m = 0;
    component row4[4];
    for(var q = 12; q < 16; q++){
        row4[m] = IsEqual();
        row4[m].in[0]  <== question[q];
        row4[m].in[1] <== 0;
        m++;
    }
    3 === row4[3].out + row4[2].out + row4[1].out + row4[0].out; 

    // Write your solution from here.. Good Luck!

    // create mask for solution
    signal mask[16];
    component isZ[16];
    for (var i=0; i<4; i++) {
        isZ[i] = IsZero();
        row1[i].out ==> isZ[i].in;
        mask[i] <== isZ[i].out;
    }

    for (var i=0; i<4; i++) {
        isZ[i+4] = IsZero();
        row2[i].out ==> isZ[i+4].in;
        mask[i+4] <== isZ[i+4].out;
    }

    for (var i=0; i<4; i++) {
        isZ[i+8] = IsZero();
        row3[i].out ==> isZ[i+8].in;
        mask[i+8] <== isZ[i+8].out;
    }

    for (var i=0; i<4; i++) {
        isZ[i+12] = IsZero();
        row4[i].out ==> isZ[i+12].in;
        mask[i+12] <== isZ[i+12].out;
    }

    // mask solution
    signal derivedQ[16];
    for (var i=0; i<16; i++) {
        derivedQ[i] <== solution[i] * mask[i];
        // log(derivedQ[i]);
    }
    derivedQ === question;

    signal inter[12];

    // check all rows
    component asiRow1[4];
    // check row1
    for (var i=0; i<4; i++) {
        asiRow1[i] = ArraySingleInstance(4);
        for (var j=0; j<4; j++) {
            solution[j] ==> asiRow1[i].array[j];
            // log(solution[j], i+1);
        }
        i+1 ==> asiRow1[i].instance;
        // log(asiRow1[i].out);
        // log(" ");
    }
    inter[0] <== asiRow1[0].out + asiRow1[1].out + asiRow1[2].out + asiRow1[3].out;

    component asiRow2[4];
    // check row2
    for (var i=0; i<4; i++) {
        asiRow2[i] = ArraySingleInstance(4);
        for (var j=4; j<8; j++) {
            solution[j] ==> asiRow2[i].array[j-4];
        }
        i+1 ==> asiRow2[i].instance;
    }
    inter[1] <== asiRow2[0].out + asiRow2[1].out + asiRow2[2].out + asiRow2[3].out;

    component asiRow3[4];
    // check row3
    for (var i=0; i<4; i++) {
        asiRow3[i] = ArraySingleInstance(4);
        for (var j=8; j<12; j++) {
            solution[j] ==> asiRow3[i].array[j-8];
        }
        i+1 ==> asiRow3[i].instance;
    }
    inter[2] <== asiRow3[0].out + asiRow3[1].out + asiRow3[2].out + asiRow3[3].out;

    component asiRow4[4];
    // check row4
    for (var i=0; i<4; i++) {
        asiRow4[i] = ArraySingleInstance(4);
        for (var j=12; j<16; j++) {
            solution[j] ==> asiRow4[i].array[j-12];
        }
        i+1 ==> asiRow4[i].instance;
    }
    inter[3] <== asiRow4[0].out + asiRow4[1].out + asiRow4[2].out + asiRow4[3].out;

    // check all columns
    component asiCol1[4];
    // check col1
    for (var i=0; i<4; i++) {
        asiCol1[i] = ArraySingleInstance(4);
        var k = 0;
        for (var j=0; j<16; j+=4) {
            solution[j] ==> asiCol1[i].array[k];
            k++;
            // log(solution[j], i+1);
        }
        i+1 ==> asiCol1[i].instance;
        // log(asiRow1[i].out);
        // log(" ");
    }
    inter[4] <== asiCol1[0].out + asiCol1[1].out + asiCol1[2].out + asiCol1[3].out;

    component asiCol2[4];
    // check col2
    for (var i=0; i<4; i++) {
        asiCol2[i] = ArraySingleInstance(4);
        var k = 0;
        for (var j=1; j<16; j+=4) {
            solution[j] ==> asiCol2[i].array[k];
            k++;
        }
        i+1 ==> asiCol2[i].instance;
    }
    inter[5] <== asiCol2[0].out + asiCol2[1].out + asiCol2[2].out + asiCol2[3].out;

    component asiCol3[4];
    // check col3
    for (var i=0; i<4; i++) {
        asiCol3[i] = ArraySingleInstance(4);
        var k = 0;
        for (var j=2; j<16; j+=4) {
            solution[j] ==> asiCol3[i].array[k];
            k++;
        }
        i+1 ==> asiCol3[i].instance;
    }
    inter[6] <== asiCol3[0].out + asiCol3[1].out + asiCol3[2].out + asiCol3[3].out;

    component asiCol4[4];
    // check col4
    for (var i=0; i<4; i++) {
        asiCol4[i] = ArraySingleInstance(4);
        var k = 0;
        for (var j=3; j<16; j+=4) {
            solution[j] ==> asiCol4[i].array[k];
            k++;
        }
        i+1 ==> asiCol4[i].instance;
    }
    inter[7] <== asiCol4[0].out + asiCol4[1].out + asiCol4[2].out + asiCol4[3].out;

    // check all boxes
    signal box1[4];
    box1[0] <== solution[0];
    box1[1] <== solution[1];
    box1[2] <== solution[4];
    box1[3] <== solution[5];

    component asiBox1[4];
    for (var i=0; i<4; i++) {
        asiBox1[i] = ArraySingleInstance(4);
        // for (var j=0; j<4; j++) {
        //     box1[j] ==> asiBox1[i].array[j];
        // }
        box1 ==> asiBox1[i].array;
        i+1 ==> asiBox1[i].instance;
    }
    inter[8] <== asiBox1[0].out + asiBox1[1].out + asiBox1[2].out + asiBox1[3].out;

    signal box2[4];
    box2[0] <== solution[0];
    box2[1] <== solution[1];
    box2[2] <== solution[4];
    box2[3] <== solution[5];

    component asiBox2[4];
    for (var i=0; i<4; i++) {
        asiBox2[i] = ArraySingleInstance(4);
        // for (var j=0; j<4; j++) {
        //     box2[j] ==> asiBox2[i].array[j];
        // }
        box2 ==> asiBox2[i].array;
        i+1 ==> asiBox2[i].instance;
    }
    inter[9] <== asiBox2[0].out + asiBox2[1].out + asiBox2[2].out + asiBox2[3].out;

    signal box3[4];
    box3[0] <== solution[0];
    box3[1] <== solution[1];
    box3[2] <== solution[4];
    box3[3] <== solution[5];

    component asiBox3[4];
    for (var i=0; i<4; i++) {
        asiBox3[i] = ArraySingleInstance(4);
        // for (var j=0; j<4; j++) {
        //     box3[j] ==> asiBox3[i].array[j];
        // }
        box3 ==> asiBox3[i].array;
        i+1 ==> asiBox3[i].instance;
    }
    inter[10] <== asiBox3[0].out + asiBox3[1].out + asiBox3[2].out + asiBox3[3].out;

    signal box4[4];
    box4[0] <== solution[0];
    box4[1] <== solution[1];
    box4[2] <== solution[4];
    box4[3] <== solution[5];

    component asiBox4[4];
    for (var i=0; i<4; i++) {
        asiBox4[i] = ArraySingleInstance(4);
        // for (var j=0; j<4; j++) {
        //     box4[j] ==> asiBox4[i].array[j];
        // }
        box4 ==> asiBox4[i].array;
        i+1 ==> asiBox4[i].instance;
    }
    inter[11] <== asiBox4[0].out + asiBox4[1].out + asiBox4[2].out + asiBox4[3].out;

    signal interDiv[12];
    for (var i=0; i<12; i++) {
        interDiv[i] <== inter[i] / 4;
    }

    signal interProd[12];
    interProd[0] <== interDiv[0];
    for (var i=1; i<12; i++) {
        interProd[i] <== interProd[i-1] * interDiv[i];
    }

    component isE = IsEqual();
    interProd[11] ==> isE.in[0];
    1             ==> isE.in[1];

    out <== isE.out;
    log(out);
    log(" ");

}


component main = Sudoku();

