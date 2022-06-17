#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <math.h>

#define CLOCKTYPE CLOCK_MONOTONIC

uint64_t* sieve_of_atkin_f(uint64_t n);
void sieve_of_atkin_s(uint64_t n, uint64_t **r);
uint64_t sum(uint64_t *arr);
void print_array(uint64_t *arr);

int main(int argc, char **argv)
{
	static const int COUNT = 200;
	static uint64_t N;
	uint64_t *r = NULL, res;
	double elaps_s;
	long elaps_ns;
	int cntr;

	struct timespec tsi, tsf;

	if (argc > 1)
		N = strtoul(argv[1], NULL, 10);
	else
		N = 2000000;

	printf("sieve_of_atkin_f\n");
	clock_gettime(CLOCKTYPE, &tsi);
	for(cntr = 0; cntr < COUNT; cntr++)
	{
		if (r != NULL)
		{
			free(r);
			r = NULL;
		}
		r = sieve_of_atkin_f(N);
	}
	res = sum(r);
	clock_gettime(CLOCKTYPE, &tsf);
	elaps_s = difftime(tsf.tv_sec, tsi.tv_sec);
	elaps_ns = tsf.tv_nsec - tsi.tv_nsec;
	printf("S = %llu\n", res);
	printf("Elapsed time: %15.11f s\n", elaps_s +
			((double)elaps_ns/1.0e9));
	free(r);
	r = NULL;

	printf("sieve_of_atkin_s\n");
	clock_gettime(CLOCKTYPE, &tsi);
	for(cntr = 0; cntr < COUNT; cntr++)
	{
		if (r != NULL)
		{
			free(r);
			r = NULL;
		}
		sieve_of_atkin_s(N, &r);
	}
	res = sum(r);
	clock_gettime(CLOCKTYPE, &tsf);
	elaps_s = difftime(tsf.tv_sec, tsi.tv_sec);
	elaps_ns = tsf.tv_nsec - tsi.tv_nsec;
	printf("S = %llu\n", res);
	printf("Elapsed time: %15.11f s\n", elaps_s +
			((double)elaps_ns/1.0e9));
	free(r);
}

uint64_t* sieve_of_atkin_f(uint64_t n)
{
	uint64_t* r = NULL;
	uint64_t i, j, idx, cnt;
	uint64_t l = (uint64_t) floor(sqrt(n));

	char* sieve = (char*) calloc(n, sizeof(char));

	if (n == 2)
	{
		r = (uint64_t*) malloc(sizeof(uint64_t));
		r[0] = 2;
		return r;
	}

	if (n < 5)
	{
		r = (uint64_t*) malloc(2*sizeof(uint64_t));
		r[0] = 2;
		r[1] = 3;
		return r;
	}

	sieve[1] = 1;
	sieve[2] = 1;

	for (i = 1; i <= l; i++)
		for(j = 1; j <= l; j++)
		{
			idx = 4*i*i + j*j;
			if (idx < n && (idx % 12 == 1 || idx % 12 == 5))
				sieve[idx - 1] = !sieve[idx - 1];

			idx = 3*i*i + j*j;
			if (idx < n && idx % 12 == 7)
				sieve[idx - 1] = !sieve[idx - 1];

			idx = 3*i*i - j*j;
			if (i > j && idx < n && idx % 12 == 11)
				sieve[idx - 1] = !sieve[idx - 1];
		}

	for (i = 5; i <= l; i++)
		if (sieve[i - 1])
		{
			j = 1;
			for (;;)
			{
				idx = j*i*i;
				if (idx > n)
					break;
				if (sieve[idx - 1]) sieve[idx - 1] = 0;
				j += 1;
			}
		}

	cnt = 0;
	for (i = 0; i < n; i++)
		if (sieve[i])
			cnt++;

	r = (uint64_t*)malloc((cnt + 1)*sizeof(uint64_t));
	r[cnt] = 0;

	cnt = 0;
	for (i = 0; i < n; i++)
		if (sieve[i])
		{
			r[cnt] = i + 1;
			cnt++;
		}

	free(sieve);
	return r;
}

void sieve_of_atkin_s(uint64_t n, uint64_t **r)
{
	uint64_t i, j, idx, cnt;
	uint64_t l = (uint64_t) floor(sqrt(n));

	char* sieve = (char*) calloc(n, sizeof(char));

	if (*r != NULL)
		free(*r);

	if (n == 2)
	{
		(*r) = (uint64_t*) malloc(sizeof(uint64_t));
		(*r)[0] = 2;
		return;
	}

	if (n < 5)
	{
		(*r) = (uint64_t*) malloc(2*sizeof(uint64_t));
		(*r)[0] = 2;
		(*r)[1] = 3;
		return;
	}

	sieve[1] = 1;
	sieve[2] = 1;

	for (i = 1; i <= l; i++)
		for(j = 1; j <= l; j++)
		{
			idx = 4*i*i + j*j;
			if (idx < n && (idx % 12 == 1 || idx % 12 == 5))
				sieve[idx - 1] = !sieve[idx - 1];

			idx = 3*i*i + j*j;
			if (idx < n && idx % 12 == 7)
				sieve[idx - 1] = !sieve[idx - 1];

			idx = 3*i*i - j*j;
			if (i > j && idx < n && idx % 12 == 11)
				sieve[idx - 1] = !sieve[idx - 1];
		}

	for (i = 5; i <= l; i++)
		if (sieve[i - 1])
		{
			j = 1;
			for (;;)
			{
				idx = j*i*i;
				if (idx > n)
					break;
				if (sieve[idx - 1]) sieve[idx - 1] = 0;
				j += 1;
			}
		}

	cnt = 0;
	for (i = 0; i < n; i++)
		if (sieve[i])
			cnt++;

	(*r) = (uint64_t*)malloc((cnt + 1)*sizeof(uint64_t));
	(*r)[cnt] = 0;

	cnt = 0;
	for (i = 0; i < n; i++)
		if (sieve[i])
		{
			(*r)[cnt] = i + 1;
			cnt++;
		}

	free(sieve);
}

uint64_t sum(uint64_t *arr)
{
	if (arr == NULL)
		return 0;

	uint64_t r = 0;
	uint64_t *t = arr;

	while(*t)
	{
		r += *t;
		t += 1;
	}

	return r;
}

void print_array(uint64_t *arr)
{
	if (arr == NULL)
	{
		printf("[]\n");
		return;
	}

	uint64_t *t = arr;

	printf("[ ");
	while(*t)
	{
		printf("%llu ", *t);
		t += 1;
	}
	printf("]\n");
}