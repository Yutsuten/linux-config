# ruff: noqa: INP001, S603, S607, D100
import os
import subprocess

import toml

HOME = os.environ['HOME']

config = toml.load('pyproject.toml')
project_name = config['project']['name']

subprocess.run(
    ['rm', '-vf', f'{HOME}/.local/bin/{project_name}'],
    check=True,
)
