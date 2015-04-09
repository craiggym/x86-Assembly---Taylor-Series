#include <iostream>

using namespace std;

double newterm;

extern "C" double nextterm(double oldterm, long n, double x);

double nextterm(double oldterm, long n, double x)
{

  newterm = oldterm * x * x*(-1.0)/((2*n)*(2*n+1));
  return newterm;
}
