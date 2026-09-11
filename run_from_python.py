"""Run the R logistic model (run_model.R) via subprocess and print the odds ratios.

Python only orchestrates here; all statistics are computed in R.

Usage:
    python run_from_python.py [input_csv] [output_csv]
"""

import glob
import os
import shutil
import subprocess
import sys
from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent


def find_rscript() -> str:
    r"""Return a path to Rscript: PATH first, then C:\Program Files\R\R-x.y.z\bin."""
    on_path = shutil.which("Rscript")
    if on_path:
        return on_path
    candidates = sorted(
        glob.glob(r"C:\Program Files\R\R-*\bin\Rscript.exe"), reverse=True
    )
    if candidates:
        return candidates[0]  # newest version sorts last, so first after reverse
    sys.exit(r"Rscript not found on PATH or under C:\Program Files\R")


def main(argv: list[str]) -> None:
    input_csv = argv[1] if len(argv) > 1 else "adults_clean.csv"
    output_csv = argv[2] if len(argv) > 2 else "odds_ratios.csv"

    rscript = find_rscript()
    cmd = [rscript, str(HERE / "run_model.R"), input_csv, output_csv]
    print("Running:", " ".join(cmd), flush=True)

    result = subprocess.run(cmd, cwd=HERE, capture_output=True, text=True)
    if result.stderr:
        print(result.stderr.strip(), file=sys.stderr)
    if result.returncode != 0:
        sys.exit(f"Rscript failed with exit code {result.returncode}")

    odds = pd.read_csv(HERE / output_csv)
    pd.set_option("display.width", 120)
    print("\nAdjusted odds ratios for diabetes (95% CI):")
    print(odds.round(3).to_string(index=False))


if __name__ == "__main__":
    main(sys.argv)
