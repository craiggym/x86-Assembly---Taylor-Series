#include <iostream>
#include <iomanip>

using namespace std;
extern "C" double TaylorCompute(double *term);

int main()
{
 cout << "Welcome to CPSC 240." << endl;
 cout << "This machine belongs to Craig Marroquin and has a Core i7-4700MQ processor with a clock speed of 2.40 GHz.\n" << endl;

 double *nano = new double;
 double lastterm = TaylorCompute(nano);
 
 cout << "Thank you. The driver received these two numbers: " << lastterm << " and " << *nano <<endl;
 cout << "Enjoy your trigonometry Bye." << endl;
 cout << "The driver will now return error code 0 to the OS indicating successful completion.\n"<< endl;
return 0;
}
