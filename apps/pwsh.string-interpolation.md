https://stackoverflow.com/q/61026258/771768
### Does Powershell string interpolation support format specifiers?
Answer: **NO**
Best workaround is to either use `-f` or `.ToString()`

This works in powershell:
```powershell
>>> "x={0,5} and y={1:F3}" -f $x, $y
x=   10 and y=0.333

>>> $x=10
>>> $y=1/3
>>> "x=$x and y=$y"
x=10 and y=0.333333333333333
```

Works in C#:
```csharp
> var x = 10;
> var y = 1.0/3.0;
> $"x={x,5} and y = {y:F2}";
"x=   10 and y = 0.33"
```

