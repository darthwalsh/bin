You start learning numbers like 1, 2, 100, 1/2 as being exact.
But in science every measurement has some uncertainty.

Instead of measuring as precisely as possible, it's better to take three separate measurements three times. This gives a good mean, but also accurately estimates the variance in the measurement.
## Significant Figures
In high school you'll learn SigFigs, counting how many of the digits are significant.
- `1.` means 0-2
- `120` means 110-130
- `1.230` means 1.229-1.231
This has a couple problems: 
- you normally want to model a Normal Distribution, but 1±1 is a much larger range than 9±1
- It's not possible to represent 100 to two significant figures, the range 90-110 using the normal notation, but could use scientific notation `1.0 × 10²`
## Unsure Calculator
Try the [Unsure Calculator](https://filiph.github.io/unsure/) online tool for 
- For example: Estimate the probability of dying in a pandemic, given an uncertain morbidity rate (how many people get sick) and mortality rate (how many infected people die):
- `(10~30 / 100) * (0.1~1.0 / 100) * 100 = 0.02~0.23` (0.2-2‰)