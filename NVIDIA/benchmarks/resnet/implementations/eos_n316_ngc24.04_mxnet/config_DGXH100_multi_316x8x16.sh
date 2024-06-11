source $(dirname ${BASH_SOURCE[0]})/config_DGXA100_common.sh
## DL params --35k
export OPTIMIZER="sgdwfastlars"
export BATCHSIZE="16"
export KVSTORE="horovod"
export LR="19.4"
export WARMUP_EPOCHS="24"
export EVAL_OFFSET="1" #Targeting epoch 70 (total 70)
export EVAL_PERIOD="4"
export WD="0.0001"
export MOM="0.95"
export LARSETA="0.001"
export LABELSMOOTHING="0.1"
export LRSCHED="pow2"
export NUMEPOCHS=${NUMEPOCHS:-"70"}
# using hparams for 49k GBS


export NETWORK="resnet-v1b-fl"
export BN_GROUP=2
export MXNET_CUDNN_NHWC_BN_HEURISTIC_GBN=3

export DALI_THREADS=8
export DALI_PREFETCH_QUEUE="3"
export DALI_NVJPEG_MEMPADDING="256"
export DALI_CACHE_SIZE="24576"
export DALI_HW_DECODER_LOAD="0.99"
export INPUT_BATCH_MULTIPLIER="16"

#DALI buffer presizing hints
export DALI_PREALLOCATE_WIDTH="5980"
export DALI_PREALLOCATE_HEIGHT="6430"
export DALI_DECODER_BUFFER_HINT="1315942" #1196311*1.1
export DALI_CROP_BUFFER_HINT="165581" #150528*1.1
export DALI_TMP_BUFFER_HINT="118522776" #871491*batch_size
export DALI_NORMALIZE_BUFFER_HINT="441549" #401408*1.1

# Default is no NCCL and BWD overlap
export HOROVOD_CYCLE_TIME=0.1
export HOROVOD_FUSION_THRESHOLD=67108864
export HOROVOD_NUM_NCCL_STREAMS=1
export MXNET_HOROVOD_NUM_GROUPS=1
export MXNET_EXEC_BULK_EXEC_MAX_NODE_TRAIN_FWD=999
export MXNET_EXEC_BULK_EXEC_MAX_NODE_TRAIN_BWD=999
export MXNET_FUSE_CONV_BN_RELU=1
export MXNET_FUSE_CONV_BN_DUAL_ADD_RELU=1

export SBATCH_NETWORK=sharp
#export NCCL_COLLNET_ENABLE=1
#export NCCL_ALGO=COLLNETCHAIN
#export SHARP_COLL_ENABLE_PCI_RELAXED_ORDERING=0
#export USE_NVSHMEM=1

## System run parms
export DGXNNODES=316
export DGXSYSTEM=$(basename $(readlink -f ${BASH_SOURCE[0]}) | sed 's/^config_//' | sed 's/\.sh$//' )
export WALLTIME=$(( ${NEXP:-1} * 5 + 10 ))
