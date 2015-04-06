#include <iostream>

using namespace std;
extern "C" double TaylorCompute();

int main()
{
 cout << "Welcome to CPSC 240." << endl;
 cout << "This machine belongs to Craig Marroquin and has a Core i7-4700MQ processor with a clock speed of 2.40 GHz.\n" << endl;

double result = TaylorCompute();
 cout << result;

return 0;
}
