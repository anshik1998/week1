pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
// include ""; // hint: you can use more than one templates in circomlib-matrix to help you

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    // [bonus] insert your code here
    component equal = IsEqual(); 

    for(var i = 0; i < n; i++){
        var X = x[i];
        var ASum = 0;
        for(var j = 0; j < n; j++){
            ASum = ASum + A[j][i];
        }
        equal.in[0] <== ASum * X;
        equal.in[1] <== b[i];

        out <== equal.out;
    }


}

component main {public [A, b]} = SystemOfEquations(3);