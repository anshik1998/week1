pragma circom 2.0.0;


// [assignment] Modify the circuit below to perform a multiplication of three signals
template Multiplier2 () {  

   // Declaration of signals.  
   signal input a;  
   signal input b;  
   signal output c;  

   // Constraints.  
   c <== a * b;  
}

template Multiplier3 () {  

   // Declaration of signals.  
   signal input in1;  
   signal input in2;
   signal input in3;
   signal output in4;  

   component mult1 = Multiplier2();
   component mult2 = Multiplier2();

   mult1.a <== in1;
   mult1.b <== in2;
   mult2.a <== mult1.c;
   mult2.b <== in3;
   in4 <== mult2.c;

}

component main = Multiplier3();