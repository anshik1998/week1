// [assignment] please copy the entire modified sudoku.circom here
pragma circom 2.0.3;

include "/home/anshik1998/Desktop/ZKCohort/week1/Q3/node_modules/circomlib-matrix/circuits/matAdd.circom";
include "/home/anshik1998/Desktop/ZKCohort/week1/Q3/node_modules/circomlib-matrix/circuits/matElemMul.circom";
include "/home/anshik1998/Desktop/ZKCohort/week1/Q3/node_modules/circomlib-matrix/circuits/matElemSum.circom";
include "/home/anshik1998/Desktop/ZKCohort/week1/Q3/node_modules/circomlib-matrix/circuits/matElemPow.circom";
include "/home/anshik1998/Desktop/ZKCohort/week1/Q3/node_modules/circomlib/circuits/poseidon.circom";
include "/home/anshik1998/Desktop/ZKCohort/week1/Q3/contracts/circuits/RangeProof.circom";
//[assignment] include your RangeProof template here

template sudoku() {
    signal input puzzle[9][9]; // 0  where blank
    signal input solution[9][9]; // 0 where original puzzle is not blank
    signal output out;

    // check whether the solution is zero everywhere the puzzle has values (to avoid trick solution)

    component mul = matElemMul(9,9);
    
    //[assignment] hint: you will need to initialize your RangeProof components here
    component proof[9][9];
    component solve[9][9];
    
    
    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            // assert(puzzle[i][j]>=0); //[assignment] change assert() to use your created RangeProof instead
            // assert(puzzle[i][j]<=9); //[assignment] change assert() to use your created RangeProof instead
            // assert(solution[i][j]>=0); //[assignment] change assert() to use your created RangeProof instead
            // assert(solution[i][j]<=9); //[assignment] change assert() to use your created RangeProof instead
            proof[i][j] = RangeProof(32);
            proof[i][j].in <== puzzle[i][j];
            proof[i][j].range[0] <== 0;
            proof[i][j].range[1] <== 9;
            assert(proof[i][j].out);

            solve[i][j] = RangeProof(32);
            solve[i][j].in <== puzzle[i][j];
            solve[i][j].range[0] <== 0;
            solve[i][j].range[1] <== 9;
            assert(solve[i][j].out);
            // proof.range[0] <== solution[i][j];
            // proof.range[1] <== solution[i][j];
            // proof.range[0][1] <== puzzle[i][j];
            // proof.range[0][1] <== solution[i][j];
            // proof.range[0][1] <== solution[i][j];
            mul.a[i][j] <== puzzle[i][j];
            mul.b[i][j] <== solution[i][j];
        }
    }
    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            mul.out[i][j] === 0;
        }
    }

    // sum up the two inputs to get full solution and square the full solution

    component add = matAdd(9,9);
    
    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            add.a[i][j] <== puzzle[i][j];
            add.b[i][j] <== solution[i][j];
        }
    }

    component square = matElemPow(9,9,2);

    for (var i=0; i<9; i++) {
        for (var j=0; j<9; j++) {
            square.a[i][j] <== add.out[i][j];
        }
    }

    // check all rows and columns and blocks sum to 45 and sum of sqaures = 285

    component row[9];
    component col[9];
    component block[9];
    component rowSq[9];
    component colSq[9];
    component blockSq[9];


    for (var k=0; k<9; k++) {
        row[k] = matElemSum(1,9);
        col[k] = matElemSum(1,9);
        block[k] = matElemSum(3,3);

        rowSq[k] = matElemSum(1,9);
        colSq[k] = matElemSum(1,9);
        blockSq[k] = matElemSum(3,3);

        for (var i=0; i<9; i++) {
            row[k].a[0][i] <== add.out[k][i];
            col[k].a[0][i] <== add.out[i][k];

            rowSq[k].a[0][i] <== square.out[k][i];
            colSq[k].a[0][i] <== square.out[i][k];
        }
        var x = 3*(k%3);
        var y = 3*(k\3);
        for (var i=0; i<3; i++) {
            for (var j=0; j<3; j++) {
                block[k].a[i][j] <== add.out[x+i][y+j];
                blockSq[k].a[i][j] <== square.out[x+i][y+j];
            }
        }
        row[k].out === 45;
        col[k].out === 45;
        block[k].out === 45;

        rowSq[k].out === 285;
        colSq[k].out === 285;
        blockSq[k].out === 285;
    }

    // hash the original puzzle and emit so that the dapp can listen for puzzle solved events

    component poseidon[9];
    component hash;

    hash = Poseidon(9);
    
    for (var i=0; i<9; i++) {
        poseidon[i] = Poseidon(9);
        for (var j=0; j<9; j++) {
            poseidon[i].inputs[j] <== puzzle[i][j];
        }
        hash.inputs[i] <== poseidon[i].out;
    }

    out <== hash.out;
}

component main = sudoku();
