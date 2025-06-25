# ruff: noqa: INP001, S603, S607, D100
import os
import subprocess

import toml

HOME = os.environ['HOME']

config = toml.load('pyproject.toml')
project_name = config['project']['name']

subprocess.run(
    ['pyinstaller', '--noconfirm', '--name', project_name, 'src/main.py'],
    check=True,
)
subprocess.run(
    ['ln', '-srfv', f'dist/{project_name}/{project_name}', f'{HOME}/.local/bin/'],
    check=True,
)
