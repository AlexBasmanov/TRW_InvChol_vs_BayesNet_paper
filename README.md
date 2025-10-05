# Reproducible Notebooks

This repository contains three self-contained Jupyter notebooks for the TRW pipeline:

- `examples/BN_bogs.ipynb` — NPBN/BN analysis for **bogs** (`py-banshee`)
- `examples/BN_herons.ipynb` — NPBN/BN analysis for **heron colonies** (`py-banshee`)
- `examples/IC_herons.ipynb` — **IC / classical statistics** for heron colonies (no `py-banshee`)

Each notebook includes a **commented `(-1) Bootstrap` cell**. You can uncomment it and run to install
pinned dependencies *inside the current kernel*. This is optional if you already prepared an environment.

**Recommended Python:** 3.11.x (tested with 3.11.13)

# Quick Start — Option A (RECOMMENDED): Conda / Mambaforge
**Install Mambaforge (or Miniforge/Conda).**

**Create and activate an environment with the recommended Python:**

conda create -n trwpy python=3.11.13
conda activate trwpy

**Install JupyterLab:**

conda install -c conda-forge jupyterlab

**Launch JupyterLab from the repo root:**

jupyter lab

*You can either use the Conda environment as is *(**installing the libraries yourself***),* 
**or uncomment the Bootstrap cell (-1) inside the notebook to extract the pinned versions!**

# Quick Start — Option B: pip (Windows cmd)
**This repo provides a Windows batch script that sets up a local virtual environment and installs pinned deps via pip.**
**Note:** On Windows, the script prefers the `py -3.11` launcher (Python 3.11) if available; otherwise it uses `python` on PATH. Make sure Python 3.11.x is installed.

**From the repository root:**

bootstrap_pip.bat --jupyter

**Omitting --jupyter installs only the scientific stack; add it if you plan to run notebooks.**

**By default, the script creates/uses .venv in the repository root.**

**Use bootstrap_pip.bat --no-venv to install into the current/global interpreter (not recommended).**

**After completion, run:**

jupyter lab

**Linux/macOS pip:**
**For Unix-like systems, use a standard virtual environment and pip:**

python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade "pip<25.3"

**Then install the same pinned stack:**

pip install \
  numpy==2.2.6 pandas==2.3.2 matplotlib==3.10.6 scipy==1.16.1 \
  arch==7.2.0 joblib==1.5.2 openpyxl==3.1.5 xlrd==2.0.2 \
  py-banshee==1.1.2
  
**(Optional) Jupyter**
pip install "jupyterlab>=4,<5" "ipykernel>=6.29"
jupyter lab
