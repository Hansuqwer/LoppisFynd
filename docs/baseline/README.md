# Baseline Tracking

This directory contains baseline snapshots for tracking migration progress.

## What are baselines?

Baselines are point-in-time snapshots of code quality metrics:
- **Analyzer issues** - `flutter analyze` output (errors, warnings, info)
- **Test results** - Test pass/fail counts and coverage
- **Performance metrics** - Build times, app size, startup time

## Current baseline

**Captured:** 2026-04-29  
**Analyzer issues:** 5,416 total
- Errors: 234
- Warnings: 1,892
- Info: 3,290

See `baseline-analyze.txt` for full analyzer output.

## Why track baselines?

During the Bokfynd migration, baselines help us:

1. **Measure progress** - Track reduction in analyzer issues over time
2. **Prevent regressions** - Ensure new code doesn't introduce more issues
3. **Prioritize work** - Focus on high-impact fixes (errors > warnings > info)
4. **Validate refactoring** - Confirm that complexity reduction actually reduces issues

## How to capture a new baseline

```bash
# Analyzer baseline
fvm flutter analyze --no-fatal-infos 2>&1 | tee docs/baseline/baseline-analyze-$(date +%Y%m%d).txt

# Test baseline
fvm flutter test --reporter=compact 2>&1 | tee docs/baseline/baseline-test-$(date +%Y%m%d).txt

# Coverage baseline (optional)
fvm flutter test --coverage
lcov --summary coverage/lcov.info 2>&1 | tee docs/baseline/baseline-coverage-$(date +%Y%m%d).txt
```

## Baseline comparison

To compare against the current baseline:

```bash
# Run analyzer and compare
fvm flutter analyze --no-fatal-infos > /tmp/current-analyze.txt 2>&1
diff docs/baseline/baseline-analyze.txt /tmp/current-analyze.txt
```

## Migration goals

**Target metrics for Bokfynd migration:**
- Analyzer issues: < 4,000 (26% reduction)
- Errors: 0 (100% reduction)
- Warnings: < 1,000 (47% reduction)
- Test coverage: > 60% (current unknown)

## Files in this directory

- `baseline-analyze.txt` - Initial analyzer baseline (5,416 issues)
- `baseline-analyze-YYYYMMDD.txt` - Dated snapshots for comparison
- `baseline-test-YYYYMMDD.txt` - Test result snapshots
- `baseline-coverage-YYYYMMDD.txt` - Coverage snapshots

## Related Documentation

- [Migration Plan](../migration/MIGRATION_PLAN.md) - See Phase 3 for codebase assessment strategy
- [Architecture Review](../loppisfynd-legacy/architecture-review.md) - Known technical debt

---

**Status:** Active tracking  
**Last Updated:** 2026-04-29
