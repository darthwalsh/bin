#ai-slop 
# PLAN.md — Make `Dump` predictable for scalars and objects

## Goal
Produce a stable “debug dump” that:
- shows meaningful details for rich objects (all public properties)
- does something sensible for scalar/primitive-ish values (`string`, `decimal`, numbers, enums, `DateTime`, etc.)
- never silently prints “nothing” just because formatting chose a default view

## Why `Format-List -Property *` is unreliable
- PowerShell formatting has *type views* and special-cases “simple” scalars.
- Even when a scalar type technically has properties (e.g., `decimal` → `Scale`), the formatting layer may not expand them the way you expect.

## Approach
1. **Stop using formatting to discover structure**
   - Use reflection/member discovery (`Get-Member` or `[Type].GetProperties()`) to decide what to print.
2. **Classify input early**
   - Null
   - Enumerable (but not string)
   - Scalar (string/number/decimal/bool/enum/guid/datetime/timespan/uri, etc.)
   - Complex object (everything else)
3. **Render by classification**
   - Scalar: print `{ Type, Value }` plus any *chosen* extra fields you care about.
   - Enumerable: print `{ Type, Count }` and optionally first N items (each item dumped recursively).
   - Complex: print a property table:
     - `Select-Object -Property *` (or explicit property list) → output as `[pscustomobject]` to avoid format views.
4. **Avoid triggering format views**
   - Prefer returning objects (PSCustomObject) from `Dump` and letting the caller decide formatting.
   - If you must stringify, do it explicitly (don’t rely on `Format-*`).
5. **Add recursion + safety**
   - MaxDepth (default 2–3)
   - MaxItems for enumerables (default 20)
   - Track visited references (hashset) to avoid cycles
6. **Make output shape consistent**
   - Always include: `Type`, `ValuePreview` (or `ToString()`), and optionally `Properties` / `Items`.
   - Ensure scalars never produce empty output.

## Incremental steps
- [ ] Replace `Format-List -Property *` with “return a PSCustomObject describing the thing”.
- [ ] Implement `IsScalar($o)` and `IsEnumerable($o)` helpers.
- [ ] Implement `Dump-One($o, $depth)` returning a PSCustomObject.
- [ ] Implement recursion for enumerables + complex objects with depth/item limits.
- [ ] Add a `-AsString` switch that converts the structured object to text (optional).

## Test cases
- [ ] `$null`
- [ ] `"hi"`
- [ ] `"hi "`
- [ ] `[decimal]3.14`
- [ ] `Get-Date`
- [ ] `@("a", 1, [decimal]2.0)`
- [ ] `Get-Process | Select-Object -First 1`