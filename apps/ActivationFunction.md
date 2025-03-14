For Neural Networks, they need some "Activation Function" which translates the weighted sum of incoming weighted neurons, and normalizes to i.e. `[0, 1]` range

Desirable features
1. must be non-linear
	1. See [[#What happens with linear function]]
2. differentiable everywhere
	1. for gradient descent
3. Derivative is cheap
	2. ReLU is extremely simple


![activation functions](https://datascience.aero/wp-content/uploads/2020/11/Captura-de-pantalla-2020-11-23-a-las-17.33.45.png)
> The [softmax function](https://en.wikipedia.org/wiki/Softmax_function) is often used as the last activation function of a neural network to normalize the output of a network to a probability distribution over predicted output classes.

## What happens with linear function
If linear, training quickly plateaus. 
Each new layer of the deep neural network would just be linear combinations.
See [Why Neural Networks can learn (almost) anything - Emergent Garden](https://www.youtube.com/watch?v=0QczhVg5HaI) for visual examples of linearity collapsing multiple layers into essentially one layer.