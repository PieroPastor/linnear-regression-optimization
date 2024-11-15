#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

typedef struct thread{
    pthread_t thr;
    int size;
    int id;
    double *x;
    double *y;
    double sum_x;
    double sum_y;
    double sum_xy;
    double sum_xx;
} thread;

void *multithread_function(void *threads){
    thread *aux_thread = (thread*) threads;
    aux_thread->sum_x = aux_thread->sum_y = aux_thread->sum_xy = aux_thread->sum_xx = 0;
    for(int i=0; i < aux_thread->size; i++){
        aux_thread->sum_x += aux_thread->x[i];
        aux_thread->sum_y += aux_thread->y[i];
        aux_thread->sum_xy += aux_thread->x[i] * aux_thread->y[i];
        aux_thread->sum_xx += aux_thread->x[i] * aux_thread->x[i];
    }
}

void regresion_lineal_doubles_multithreading(double *x, double *y, int n, double *b, int ths){
    float sum_x=0, sum_y=0, sum_xy=0, sum_xx=0;
    int size_thread=(n/ths);
    thread threads[ths];
    for(int i=0; i < ths; i++){
        threads[i].size = size_thread; //Tamaño de los hilos
        threads[i].id = i; //Id del hilo
        threads[i].x = x + i * size_thread; //Esta operación es para que apunte a un índice del arreglo y lo tome como inicio, por eso es comienzo + i * tamaño que debe saltarse porque otro hilo ya lo está haciendo
        threads[i].y = y + i * size_thread;
    }

    multithread_function((void *)&threads[0]);

    if(ths > 1){
        for (int i = 1; i < ths; ++i) pthread_create(&threads[i].thr, NULL, multithread_function, (void *)&threads[i]);
        for (int i = 1; i < ths; ++i) pthread_join(threads[i].thr, NULL);
    }

    for(int i=0; i < ths; i++){
        sum_x += threads[i].sum_x;
        sum_y += threads[i].sum_y;
        sum_xy += threads[i].sum_xy;
        sum_xx += threads[i].sum_xx;
    }
    if(ths > 1){
        b[1] = (n * sum_xy - sum_x * sum_y)/(n * sum_xx - sum_x * sum_x);
        b[0] = (sum_y - (b[1])*sum_x) / n;
    }
}
