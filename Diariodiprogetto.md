# DIARIO DI PROGETTO

## IL FILE CENTRALE: PHASE ALIGNMENT ##
L'intenzione di partenza è quella di realizzare uno script semplice che compia in modo grezzo l'obbiettivo principale.
Poi, analizzare le problematiche incontrate e descrivere le posibili soluzioni, presentando alla fine la soluzione scelta.

### Ripensando la struttura: Segmentazione ###
Spiegazione della funzione SEGMENT.M, l'utilità di questa struttura (la cella).

### Primo approccio all'allineamento ###
Abbiamo osservato i risultati di allineamento applicando zero-padding avanti o dietro il segnale basato sui lags ottenuti tramite 
la cross-correlazione. Per affrontare l'analisi e calcoli sul segnale era più interesante la nuova struttura però come signale finale
era più semplice creare un vectore e riempirlo poco a poco con i segmenti in uscita. Per cui, nel caso del primo segmento si applica 
un padding...
