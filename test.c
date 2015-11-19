#include <stdio.h>

int test (int s) {
   int array [s];

   return array[2];
}

int main (int argc, char** argv) {
   test(5); 
   return 0;
}
