# Systems Stack Rules

Use these shared rules for Go, Rust, CLIs, workers, data pipelines, and
performance-sensitive services.

- Pass cancellation through service boundaries with `context.Context` in Go and
  explicit async cancellation patterns in Rust.
- Prefer typed errors and structured logging over stringly-typed control flow.
- Keep concurrency ownership clear: define worker lifetimes, shutdown paths, and
  backpressure behavior.
- Benchmark before optimizing and keep profiling evidence for non-trivial
  performance changes.
- Avoid production `unwrap()` in Rust and unexplained `interface{}` in Go.
- Test edge cases around retries, timeouts, partial failure, malformed input, and
  concurrent execution.
