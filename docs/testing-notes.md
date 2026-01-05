# Testing Notes

## Common Mistakes and Fixes

- String interpolation in Swift: do not escape quotes inside the interpolated expression. Use `", "` not `\", \"`. Example:
  - Good: `"\(exts.joined(separator: ", "))"`
  - Bad: `"\(exts.joined(separator: \", \"))"`

