#literature 
[Youtube Playlist](https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi)

## 1 [But what is a neural network?](https://www.youtube.com/watch?v=aircAruvnKk)
- [ ] read https://www.3blue1brown.com/lessons/neural-networks 🔼 
- explains the math of a neural network structure from scratch, next is learning
- newer techniques for specialized problems, not covered yet:
	- convolutional neural networks: Good for image recognition
	- and long short-term memory networks. Good for [[SpeechRecognition]] 
- this video focuses on a plain neural network, with two fully linked hidden layers
- for a [[ActivationFunction|squishification function]] using sigmoid 
- you can compute an entire layer at once with inputs and activations and all the weights with one matrix multiplication 
## 2 [Gradient descent, how neural networks learn](https://www.youtube.com/watch?v=IHZwWFHWa-w)
- [ ] Book link: http://neuralnetworksanddeeplearning.com/ 🔼 
- [ ] read https://www.3blue1brown.com/lessons/gradient-descent

Hypothesis: layers are pixel values, then parts of edges, then loops/lines, then finally the 10 outputs

Training: Gradient Descent
MNIST has tens of thousands of labelled examples for training data

> [!QUESTION] Could you also train inputs using tons of trash
>  output should be some 11th value, where none of digits 0-9 are high?
>  Could also training using letters, ditto but not really "trash"...

Cost function uses sum of squares of differences
Input: all 13k weights

Step size is proportional to the slope
Direction: negative of the gradient. Len of vector is the slope

Computing neural network efficiently is called Back Propagation

Continuous functions are important for small steps, which is why artificial neurons
used continuous floating point values instead of discrete binary state like real neurons

Abstractions
1) Weights and Biases: Neural Network
2) Cost function, given inputs and a network, what is the squared-sum of mistakes
3) Gradient \[of the cost function] -> Which changes to which weights impact cost most?

Answer to Hypothesis: No, seems the second layer is almost random

If you put in random input, a real output lights up.
Network definitely can't generate numbers (like today's generative AI)

This was Multilayer Perceptron

Example of proper vs random labelling: random means it needs more learning time, but gets to same quality

## 3 [What is backpropagation really doing?](https://www.youtube.com/watch?v=Ilg3gGewQ5U)
- [ ] Watch next!
- [ ] https://www.3blue1brown.com/lessons/neural-network-analysis
## 4 [Backpropagation calculus](https://www.youtube.com/watch?v=tIeHLnjs5U8)
- [ ] https://www.3blue1brown.com/lessons/backpropagation
- [ ] https://www.3blue1brown.com/lessons/backpropagation-calculus
## 5 [How large language models work, a visual intro to transformers](https://www.youtube.com/watch?v=wjZofJX0v4M)
- [ ] https://www.3blue1brown.com/lessons/gpt
## 6 [Attention in transformers, visually explained](https://www.youtube.com/watch?v=eMlx5fFNoYc)
- [ ] https://www.3blue1brown.com/lessons/attention
## 7 [How might LLMs store facts](https://www.youtube.com/watch?v=9-Jl0dxWQs8)
- [ ] https://www.3blue1brown.com/lessons/mlp
