# Output Diffing Utility - Development Guide

**Tool:** output-diffing-utility (`odiff`)
**Language:** Rust
**Type:** CLI + Library
**Repository:** https://github.com/tuulbelt/output-diffing-utility
**Part of:** [Tuulbelt](https://github.com/tuulbelt/tuulbelt)

---

## Quick Reference

**Commands:**
```bash
cargo test              # Run all tests (108 total)
cargo clippy -- -D warnings  # Lint (zero warnings)
cargo fmt              # Format code
cargo build --release  # Build release binary
./target/release/odiff --help  # CLI help
```

**CLI Names:**
- Short: `odiff` (recommended)
- Long: `output-diff`

**Test Count:** 108 tests (library + CLI + integration)

---

## What This Tool Does

Semantic diff tool for JSON, text, and binary files with zero dependencies.

**Use Cases:**
- Test output comparison (JSON API responses, text logs, binary data)
- Build artifact diffing (detect changes in compiled outputs)
- Data pipeline validation (compare expected vs actual outputs)

**Key Features:**
- Text diffs with LCS algorithm (line-by-line comparison)
- JSON diffs with structural understanding (field paths, not lines)
- Binary diffs with byte-level comparison (hex output)
- Multiple output formats: unified, JSON, side-by-side, compact
- Proper exit codes: 0=identical, 1=differ, 2=error

---

## Architecture

**Core Components:**

1. **`src/lib.rs`** - Main library with diff algorithms
   - `diff_text()` - LCS-based text diffing
   - `diff_json()` - Structural JSON diffing
   - `diff_binary()` - Byte-level binary diffing
   - Output formatters: unified, JSON, side-by-side, compact

2. **`src/main.rs`** - CLI interface (both `odiff` and `output-diff`)
   - File loading and validation
   - Format detection (text, JSON, binary)
   - Output formatting and exit codes

3. **`tests/`** - Integration tests
   - End-to-end CLI testing
   - File comparison scenarios
   - Error handling verification

**Diff Algorithms:**
- **Text:** Longest Common Subsequence (LCS) - O(n*m) time
- **JSON:** Recursive structural comparison with field paths
- **Binary:** Byte-by-byte comparison with hex output

---

## Development Workflow

### Adding New Features

1. **Update library** (`src/lib.rs`)
2. **Add tests** (unit tests in `lib.rs`, integration tests in `tests/`)
3. **Update CLI** if needed (`src/main.rs`)
4. **Run quality checks:**
   ```bash
   cargo fmt
   cargo clippy -- -D warnings
   cargo test
   cargo build --release
   ```
5. **Update README** with examples
6. **Test dogfooding scripts** if applicable

### Testing Strategy

**Unit Tests (in `src/lib.rs`):**
- Test each diff function independently
- Cover edge cases: empty files, identical files, complex diffs
- Test output formatters

**Integration Tests (in `tests/`):**
- End-to-end CLI testing
- File I/O scenarios
- Exit code verification

**Run tests:**
```bash
cargo test                    # All tests
cargo test --lib              # Library tests only
cargo test --test '*'         # Integration tests only
cargo test diff_text          # Specific test
```

### Code Style

**Rust Standards:**
- Follow Rust idioms (use `?` operator, avoid `unwrap()`)
- Run `cargo fmt` before committing
- Zero clippy warnings: `cargo clippy -- -D warnings`
- Document public items with `///`

**Error Handling:**
```rust
pub fn diff_text(left: &str, right: &str, config: &DiffConfig) -> Result<DiffResult, DiffError> {
    // Use ? operator for error propagation
    let lines_left = parse_lines(left)?;
    let lines_right = parse_lines(right)?;

    // Return Result, not panics
    Ok(DiffResult { /* ... */ })
}
```

---

## Zero Dependencies Principle

**This tool has ZERO runtime dependencies.**

- Uses only Rust standard library (`std`)
- No external crates in `[dependencies]` section
- `cargo build` requires no network after first toolchain install

**Verification:**
```bash
# CI automatically checks this
awk '/^\[dependencies\]/,/^\[/ {if (!/^\[/ && !/^#/ && NF > 0) print}' Cargo.toml | grep -c '^[a-z]'
# Should output: 0
```

---

## Dogfooding

This tool is used by other Tuulbelt tools:

### Used By (Library Dependencies)

**Snapshot Comparison** uses `output-diffing-utility` as a library dependency:
```toml
[dependencies]
output_diffing_utility = { git = "https://github.com/tuulbelt/output-diffing-utility" }
```

When snapshots don't match, `odiff` provides rich semantic diffs:
```rust
use output_diffing_utility::{diff_text, diff_json, diff_binary};

let diff = match file_type {
    FileType::Text => diff_text(expected, actual, &config),
    FileType::Json => diff_json(expected, actual, &config),
    FileType::Binary => diff_binary(expected, actual, &config),
};
```

This is the **first Tuulbelt tool using library-level composition** (PRINCIPLES.md Exception 2).

### Dogfooding Scripts

**Test Flakiness Detection:**
```bash
./scripts/dogfood-flaky.sh  # Validate test determinism (20 runs)
```

**Output Consistency Validation:**
```bash
./scripts/dogfood-diff.sh   # Verify diff consistency (100 runs)
```

These scripts require monorepo context but tool works standalone.

---

## Release Checklist

Before tagging a new version:

- [ ] All tests pass: `cargo test`
- [ ] Zero clippy warnings: `cargo clippy -- -D warnings`
- [ ] Code formatted: `cargo fmt`
- [ ] Zero runtime dependencies verified
- [ ] README updated with new features
- [ ] CHANGELOG.md updated
- [ ] Version bumped in `Cargo.toml`
- [ ] Tag created: `git tag vX.Y.Z`
- [ ] Pushed to GitHub: `git push origin main --tags`

---

## Common Tasks

**Add new diff type:**
1. Add function to `src/lib.rs`: `pub fn diff_custom(...) -> Result<DiffResult, DiffError>`
2. Add tests in `src/lib.rs`
3. Update CLI in `src/main.rs` to support new type
4. Add integration tests in `tests/`
5. Update README with examples

**Add new output format:**
1. Update `OutputFormat` enum in `src/lib.rs`
2. Implement formatter function
3. Add tests
4. Update CLI to accept new format flag
5. Update README

**Performance optimization:**
1. Benchmark current implementation
2. Profile with `cargo build --release && perf record ./target/release/odiff ...`
3. Optimize algorithm or data structures
4. Verify tests still pass
5. Document performance improvement in CHANGELOG

---

## Troubleshooting

**Tests fail with "No such file or directory":**
- Integration tests expect test files in `tests/fixtures/`
- Run tests from repository root: `cargo test`

**Clippy warnings:**
- Run `cargo clippy --fix` for auto-fixes
- Manually fix remaining warnings
- Ensure `cargo clippy -- -D warnings` passes

**Binary size too large:**
- Use release profile: `cargo build --release`
- Strip symbols: already enabled in `Cargo.toml` (`strip = true`)
- Check with: `ls -lh target/release/odiff`

**Diff output differs from expected:**
- Text diff uses LCS algorithm (may differ from `git diff`)
- JSON diff is structural (field paths, not line diffs)
- Binary diff shows hex (byte-level comparison)

---

## Related Tools

**In Tuulbelt:**
- **Test Flakiness Detector** - Uses `odiff` to validate deterministic test outputs
- **Snapshot Comparison** - Uses `odiff` as library dependency for semantic diffs
- **CLI Progress Reporting** - Example of dogfooding for progress tracking

**External:**
- `diff` - Standard Unix diff (line-based, not semantic)
- `jq` - JSON processing (not diffing)
- `git diff` - Version control diff (not for arbitrary files)

---

## Links

- **Repository:** https://github.com/tuulbelt/output-diffing-utility
- **Meta Repo:** https://github.com/tuulbelt/tuulbelt
- **Issues:** https://github.com/tuulbelt/tuulbelt/issues (centralized)
- **Documentation:** https://tuulbelt.github.io/tuulbelt/tools/output-diffing-utility/
- **Principles:** https://github.com/tuulbelt/tuulbelt/blob/main/PRINCIPLES.md

---

**Last Updated:** 2025-12-29
**Version:** 0.1.0
**Status:** Active Development
