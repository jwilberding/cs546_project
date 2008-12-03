#include "pthread.h"
#include "stdio.h"

#define NUM_THREADS 10000

void *nothing ()
{
  int i = 0;
  i++;
}

int main (int argc, char *argv[])
{
  int t;
  pthread_t threads[NUM_THREADS];
  
  for(t=0; t<NUM_THREADS; t++){
    pthread_create(&threads[t], NULL, nothing, NULL);
  }
  
  pthread_exit(NULL);
}
