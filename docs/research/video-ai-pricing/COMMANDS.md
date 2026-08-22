# Commands used to build the pricing Excel

Working directory: repository root (`/home/yoshinaga_kosuke/workspace/quiz`).
Snapshot date encoded in the workbook: **2026-08-21**.

```bash
# 1. Go to repo root
cd /home/yoshinaga_kosuke/workspace/quiz

# 2. Install openpyxl if missing
python3 -c "import openpyxl" || pip install --user openpyxl

# 3. Generate the workbook (writes video-ai-pricing-compare.xlsx next to the script)
python3 docs/research/video-ai-pricing/build_pricing_xlsx.py

# 4. Confirm outputs
ls -la docs/research/video-ai-pricing/
```

Outputs:

| File | Role |
| --- | --- |
| `build_pricing_xlsx.py` | Generator script |
| `video-ai-pricing-compare.xlsx` | Workbook (consumer / API / Runway rates / sources / commands) |
| `COMMANDS.md` | This command log |

Re-run step 3 after editing the script to refresh the `.xlsx`.
