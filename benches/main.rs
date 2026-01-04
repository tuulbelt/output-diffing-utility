//! Output Diffing Utility Benchmarks
//!
//! Measures performance of core operations using Criterion for statistical rigor.
//!
//! Run: cargo bench
//!
//! See: /docs/BENCHMARKING_STANDARDS.md

use criterion::{black_box, criterion_group, criterion_main, Criterion};
use output_diffing_utility::{diff_json, diff_text, DiffConfig};

fn text_diff_benchmarks(c: &mut Criterion) {
    let mut group = c.benchmark_group("Text Diff");

    let small_a = "line 1\nline 2\nline 3";
    let small_b = "line 1\nline 2 modified\nline 3";

    let medium_a: String = (1..=100)
        .map(|i| format!("line {}", i))
        .collect::<Vec<_>>()
        .join("\n");
    let medium_b: String = (1..=100)
        .map(|i| {
            if i % 10 == 0 {
                format!("line {} modified", i)
            } else {
                format!("line {}", i)
            }
        })
        .collect::<Vec<_>>()
        .join("\n");

    let large_a: String = (1..=1000)
        .map(|i| format!("line {}", i))
        .collect::<Vec<_>>()
        .join("\n");
    let large_b: String = (1..=1000)
        .map(|i| {
            if i % 50 == 0 {
                format!("line {} modified", i)
            } else {
                format!("line {}", i)
            }
        })
        .collect::<Vec<_>>()
        .join("\n");

    group.bench_function("small: 3 lines", |b| {
        b.iter(|| black_box(diff_text(small_a, small_b, &DiffConfig::default())))
    });

    group.bench_function("medium: 100 lines", |b| {
        b.iter(|| black_box(diff_text(&medium_a, &medium_b, &DiffConfig::default())))
    });

    group.bench_function("large: 1000 lines", |b| {
        b.iter(|| black_box(diff_text(&large_a, &large_b, &DiffConfig::default())))
    });

    group.finish();
}

fn json_diff_benchmarks(c: &mut Criterion) {
    let mut group = c.benchmark_group("JSON Diff");

    let small_a = r#"{"key": "value", "num": 42}"#;
    let small_b = r#"{"key": "modified", "num": 42}"#;

    let medium_a = r#"{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}], "meta": {"count": 2}}"#;
    let medium_b = r#"{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bobby"}], "meta": {"count": 2, "updated": true}}"#;

    group.bench_function("small: 2 keys", |b| {
        b.iter(|| black_box(diff_json(small_a, small_b, &DiffConfig::default())))
    });

    group.bench_function("medium: nested objects", |b| {
        b.iter(|| black_box(diff_json(medium_a, medium_b, &DiffConfig::default())))
    });

    group.finish();
}

criterion_group!(benches, text_diff_benchmarks, json_diff_benchmarks);
criterion_main!(benches);
