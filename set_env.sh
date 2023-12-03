#!/bin/bash

nnUNet_raw=nnUNet_raw="$PWD/nnUNet_raw"
nnUNet_preprocessed=nnUNet_preprocessed="$PWD/nnUNet_preprocessed"
nnUNet_results=nnUNet_results="$PWD/nnUNet_results"

echo setting up nnUNet environment
echo $nnUNet_raw
echo $nnUNet_preprocessed
echo $nnUNet_results

export $nnUNet_raw $nnUNet_preprocessed $nnUNet_results