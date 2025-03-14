#literature 
## [Can you really use ANY activation function? (Universal Approximation Theorem) - YouTube](https://www.youtube.com/watch?v=IonQTF7kCMg)

All about [[ActivationFunction]]

In 1950’s, step function mimics boolean.
But derivative = 0, so can’t use gradient descent like back propagation

1980s, sigmoid and tanh fix problems above
Tanh is 0-centered, so helps convergence
But at either extreme, the gradient is small, slowing training

2010s, ReLU function used.
Derivative is very cheap
Barely nonlinear though

Now \[2024] in convolutional NN
Unexpected: Linear function also seemed to work
Pooling Layer uses Max Pooling which is itself nonlinear
Switch to linear Average pooling: now Linear model stops being able to learn

How about non-monotonic x^2, or periodic like sine: Both work!

## [How to Watermark Text (LLM Watermarking Explained) - YouTube](https://www.youtube.com/watch?v=55LXhbPjyeM&t=1s)
Tesla story at 2:10, was my exact idea for preventing corp leaking of emails!
  
>story from Tesla where some employees got sent an important confidential email every employee received a slightly different one with each word being separated by either one or two spaces giving it a distinct signature. When the letter was made public the leaker could be identified by that.