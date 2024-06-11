# Copyright (c) 2020, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
# Training the model

Basic run (on CPU for 50 epochs):
    python examples/audio_tasks/speech_enhancement.py \
        # (Optional: --config-path=<path to dir of configs> --config-name=<name of config without .yaml>) \
        model.train_ds.manifest_filepath="<path to manifest file>" \
        model.validation_ds.manifest_filepath="<path to manifest file>" \
        trainer.devices=1 \
        trainer.accelerator='cpu' \
        trainer.max_epochs=50

PyTorch Lightning Trainer arguments and args of the model and the optimizer can be added or overriden from CLI
"""
import pytorch_lightning as pl
import torch
from omegaconf import OmegaConf

from nemo.collections.asr.models import EncMaskDecAudioToAudioModel
from nemo.core.config import hydra_runner
from nemo.utils import logging
from nemo.utils.exp_manager import exp_manager


@hydra_runner(config_path="./conf", config_name="masking")
def main(cfg):
    logging.info(f'Hydra config: {OmegaConf.to_yaml(cfg, resolve=True)}')

    trainer = pl.Trainer(**cfg.trainer)
    exp_manager(trainer, cfg.get("exp_manager", None))
    model = EncMaskDecAudioToAudioModel(cfg=cfg.model, trainer=trainer)

    # Initialize the weights of the model from another model, if provided via config
    model.maybe_init_from_pretrained_checkpoint(cfg)

    # Train the model
    trainer.fit(model)

    # Run on test data, if available
    if hasattr(cfg.model, 'test_ds') and cfg.model.test_ds.manifest_filepath is not None:
        if trainer.is_global_zero:
            # Destroy the current process group and let the trainer initialize it again with a single device.
            if torch.distributed.is_initialized():
                torch.distributed.destroy_process_group()

            # Run test on a single device
            trainer = pl.Trainer(devices=1, accelerator=cfg.trainer.accelerator)
            if model.prepare_test(trainer):
                trainer.test(model)


if __name__ == '__main__':
    main()  # noqa pylint: disable=no-value-for-parameter
