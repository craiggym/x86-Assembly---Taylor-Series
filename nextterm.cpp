#include <iostream>

using namespace std;

double result;

extern "C" double nextterm(double oldterm, long n, double x);

double nextterm(double oldterm, long n, double x)
{

  result = oldterm * x * x*(-1.0)/(2*n+1)/(2*n+2);
  return result;
}
