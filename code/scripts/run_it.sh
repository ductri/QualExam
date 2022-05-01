#!/bin/bash
set -e

M=50
K=40
SNR=10
numTrials=1

main() {
    pathDir=./cvx_log
    mkdir -p $pathDir

    # {
    #     /usr/bin/time -v matlab -nodisplay -nodesktop \
    #     -r "methodName='$methodName'; expCodeName='$expCodeName'; M=$M; N=$N; L=$L; SNR=$SNR; numTrials=$numTrials; isCalibration=1; expSetup__script; quit" &
    # } 2>&1 | tee  "$pathDir"/logging_calibration.txt &

    {
        /usr/bin/time -v matlab -nodisplay -nodesktop \
        -r "M=$M; K=$K; N=$N; snr=$SNR; cvx_solver__test; quit" 
    } 2>&1 | tee  "$pathDir"/logging.txt 
}

for N in 1000 2000 
do
    main
done

