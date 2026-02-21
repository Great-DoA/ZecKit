# ZecKit Sample Repo

> Reference implementation showing how to wire the
> [ZecKit E2E GitHub Action](https://github.com/marketplace/actions/zeckit-e2e)
> into a project's CI pipeline.

Move this folder to its own repository and push to GitHub.
The workflows run immediately without any extra configuration.

---

## CI Status

| Workflow | Purpose |
|---|---|
| [![ZecKit E2E CI](../../actions/workflows/ci.yml/badge.svg)](../../actions/workflows/ci.yml) | Golden E2E across both backends |
| [![Failure Drill](../../actions/workflows/failure-drill.yml/badge.svg)](../../actions/workflows/failure-drill.yml) | Artifact-collection verification |

*(Update badge URLs to point to your repo once moved.)*

---

## What Is This?

This repo demonstrates:

1. **Backend matrix CI** — the same ZecKit golden E2E flow
   (`generate UA → fund → autoshield → shielded send → rescan → verify`)
   runs against two backends in parallel:

   | Backend | Job name | Merge-blocking? |
   |---|---|---|
   | lightwalletd | `e2e-lwd` | **YES** — CI fails if this fails |
   | zaino | `e2e-zaino` | No — experimental; failure is reported, not enforced |

2. **Failure drills** — a dedicated workflow injects two types of
   deterministic failures and asserts that diagnostic artifacts
   (logs, JSON summary, faucet stats) are always uploaded:

   | Drill | Injected condition | Expected artifact |
   |---|---|---|
   | `send-overflow` | `send_amount=999 ZEC` (impossible) | `faucet-stats.json` showing real balance vs requested |
   | `startup-timeout` | `startup_timeout_minutes=1` with lwd (needs 3-4 min) | Partial `lightwalletd.log` and `zebra.log` |

---

## Repository Structure

```
.github/
  workflows/
    ci.yml              Normal CI – lwd (required) + zaino (experimental)
    failure-drill.yml   Failure injection + artifact assertion
README.md
```

---

## How to Use in Your Own Repo

### 1. Add the action to an existing workflow

```yaml
# .github/workflows/my-ci.yml
jobs:
  zcash-e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: zecdev/ZecKit@v1
        with:
          backend:      zaino
          ghcr_token:   ${{ secrets.GITHUB_TOKEN }}
```

### 2. Copy this sample as a starting point

```bash
# From ZecKit repo root
cp -r sample/ /path/to/your/new-repo/
cd /path/to/your/new-repo/
git init && git add . && git commit -m "chore: add ZecKit E2E CI"
```

### 3. Override defaults for your use case

```yaml
- uses: zecdev/ZecKit@v1
  with:
    backend:                 lwd        # or zaino
    startup_timeout_minutes: '15'       # default 10
    block_wait_seconds:      '90'       # default 75
    send_amount:             '0.1'      # default 0.05 ZEC
    send_address:            'uregtest1...'  # optional external UA
    upload_artifacts:        always     # always | on-failure | never
    ghcr_token:              ${{ secrets.GITHUB_TOKEN }}
```

Full input/output reference → [ZecKit docs/github-action.md](https://github.com/zecdev/ZecKit/blob/main/docs/github-action.md)

---

## Action Outputs

After the action runs, these outputs are available in subsequent steps:

```yaml
- uses: zecdev/ZecKit@v1
  id: zcash
  with:
    ghcr_token: ${{ secrets.GITHUB_TOKEN }}

- run: |
    echo "UA      : ${{ steps.zcash.outputs.unified_address }}"
    echo "Shield  : ${{ steps.zcash.outputs.shield_txid }}"
    echo "Send    : ${{ steps.zcash.outputs.send_txid }}"
    echo "Balance : ${{ steps.zcash.outputs.final_orchard_balance }} ZEC"
    echo "Height  : ${{ steps.zcash.outputs.block_height }}"
    echo "Result  : ${{ steps.zcash.outputs.test_result }}"
```

---

## Artifacts

When `upload_artifacts` is `always` or `on-failure` (default), a ZIP named
`zeckit-e2e-logs-<run_number>` is attached to the workflow run.

Contents:

| File | What it shows |
|---|---|
| `run-summary.json` | Machine-readable: backend, txids, balances, test_result |
| `faucet-stats.json` | Wallet balances at end of run |
| `zebra.log` | Full Zebra node output |
| `zaino.log` | Zaino indexer output |
| `lightwalletd.log` | Lightwalletd output |
| `faucet.log` | Faucet (Axum + Zingolib) output |
| `containers.log` | `docker ps -a` at teardown |
| `networks.log` | `docker network ls` at teardown |

Download via CLI:

```bash
gh run download <run-id> -n zeckit-e2e-logs-<run-number>
```

---

## Failure Drill – How to Run

The failure drill is triggered manually:

1. Go to **Actions → Failure Drill – Artifact Collection Verification**
2. Click **Run workflow**
3. Choose a drill (`both`, `send-overflow`, or `startup-timeout`)
4. After it completes, confirm both jobs have a ✅ next to
   "Assert artifact was uploaded"

A failure in the *assert* step (not the E2E drill itself) means the
artifact collection pipeline is broken and needs investigation.

---

## Common Issues

| Symptom | Fix |
|---|---|
| Lightwalletd job times out | Increase `startup_timeout_minutes` to `15` or `20` |
| Zaino experimental job fails | Check the `e2e-zaino` logs; failures here don't block CI |
| No artifacts uploaded | Ensure `ghcr_token` has `read:packages` scope |
| Drill asserts fail | The artifact-collection path in `action.yml` is broken; check the action version |

Full troubleshooting guide → [ZecKit docs/github-action.md](https://github.com/zecdev/ZecKit/blob/main/docs/github-action.md#common-failure-modes--troubleshooting)
