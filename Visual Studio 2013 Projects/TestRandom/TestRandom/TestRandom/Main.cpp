using namespace std;
#include <iostream>
#include <random>

#define		HIT_PROBABILITY		80
void main()
{
	int nHitCount		= 0;
	int nMissCount		= 0;
	int nRandom			= 0;

	for (int i = 0; i < 1000; i++)
	{
		std::random_device rd;
		nRandom = rd() % 100;
		if (nRandom >=0 && nRandom < HIT_PROBABILITY )
		{
			nHitCount++;
			printf("Random %d   Value Is %d\n", i, nRandom);
		} 
		else
		{
			nMissCount++;
			printf("Random %d   Value Is %d\n", i, nRandom);
		}
	}
	printf("Random 1000 Times Percent 80 HitCount  Is %d\n", nHitCount);
	printf("Random 1000 Times Percent 80 MissCount Is %d\n", nMissCount);
	getchar();
	getchar();
}