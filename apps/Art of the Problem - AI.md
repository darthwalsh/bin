[Art of the Problem](https://www.youtube.com/@ArtOfTheProblem) has an an interesting [playlist](https://www.youtube.com/playlist?list=PLbg3ZX2pWlgKV8K6bFJr5dhM7oOClExUJ) about [[AI]].

## [Intro to Artificial Intelligence (Neural Networks)](https://www.youtube.com/watch?v=YulgDAaHBKw)
- [ ] Notes
## [From Bacteria to Humans (Evolution of Learning)](https://www.youtube.com/watch?v=yLAwDEfzqRw)
- [ ] Notes

Evolution of learning is fascinating, talking through different ways that early learning hard codes knowledge into DNA, but now we as individuals can learn during our lives
## [How AI Learns (Backpropagation 101)](https://www.youtube.com/watch?v=r1U6fenGTrU)
- [ ] Notes

Talked about the first first neural networks, really interesting comparison to [CGP Grey: How AI *Really* Learns](https://youtu.be/wvWpdrfoEv0?si=az0uD5X6Ssc9i9b8&t=56) wall of dial adjustment bot.
Making the switch from binary output to floating point output meant that you could wiggle the dials and see how the output wiggles. I think this is talking using derivatives: the differential?


## [How AI Learns Concepts](https://www.youtube.com/watch?v=e5xKayCBOeU)
- [ ] Notes

- in 2D, linear neuron splits the space into two based on some line
- can have multiple neurons with other splits, which divide up the region with many slices 
Then the next region of neurons as an easy job just picking which regions it wants 
- doesn't account for Non-Linear neurons
	- [ ] i thought that combinations of linear was lacking an essential piece that you need a different activation function for...?
	- [ ] Maybe try to find that video that built up an explanation/motivation of non-linear functions, and how the "if x < 0 then y=0; else y = x" function was a "universal function approximator"

## [ChatGPT: 30 Year History - How AI Learned to Talk](https://www.youtube.com/watch?v=OFS90-FX6pg)
- [ ] Notes
## [How Intelligence Evolved - The Role of Simulation](https://www.youtube.com/watch?v=5EcQ1IcEMFQ)
Really interesting exploration of five stages of learning:
1. Nerve net: Primitive worms has neurons hard-coded in DNA that could navigate towards food
	1. (I think the video is oversimplifying) this was the same behavior using [[chemotaxis]] to move towards food, but that was in single-celled organisms
2. Trial and error: Early fishes have senses go into layers of neurons (cortex). Think skinner box
3. Simulation: Mammals can do this in neocortex. Rats stop in maze, imagined going down path
4. 3rd person Simulation: Primates have theory of mind: granual prefrontal cortex. Learn from observing another's mistake or tool-making
5. Language: Humans. We can simulate ideas based on words. We can learn from other's imagination
*Note, see [[#Related video [Kurzgesagt The Origin of Consciousness – How Unaware Things Became Aware](https //www.youtube.com/watch?v=H6u0VBqNBQ8)]]*

Re-pivoting the matrix at 13:30

|                      | Learning from Self                 | Learning from Others          |
| -------------------- | ---------------------------------- | ----------------------------- |
| **Physical Actions** | Reinforcement in early vertebrates | Mentalizing in early primates |
| **Imagined**         | Simulated in early mammals         | Speaking in early humans      |

- Connection with Large Language Models. Can a system short-cut learning all the earlier steps and jump straight into "understanding" by starting with language

- [ ] Learn more: "A brief history of intelligence" ~Max Bennett (maybe with ReadWise?)

I see some application towards [[ExpLang]]:
- The dopamine behavior of the learned senses means that you have expectations about what will happen next.
- Are simulations the same as explaining thinking through, enumerating different options?
- Language is powerful. Does human language have something that is missing, once you turn math into simple symbolic equations. 
- Maybe there's a reason that historical math always used written out sentences. Or, is it just as good for a kid to learn arithmetic from symbols instead of from word problems? 
## [The Amazing History of Reinforcement Learning](https://www.youtube.com/watch?v=Dov68JsIC4g)
- Non-Deterministic version of The tic tac toe machine could use many colored beads inside representing the different possible moves from each state. If a game is won or lost, you reinforce the possible States by removing or adding beads to all the boxes on the path 
- A limitation is the number of states explodes 
- Consider a chess game, with many, many states. Shannon had a research paper that talked about having an evaluation function, say a function which takes in any chessboard and produces a number from 0 to 1. The function could take the number of pawns, and the piece mobility, and how visible the king is, etc and multiply each one by some parameter then add them up to get the value. To do this is just like the neuron dot Product
- Then you could have a greedy algorithm that just picks the highest value of the possible next states. And this is pretty similar to what chess masters as experts actually do. They have an internal "feeling" about how good each possible board would be
- Shannon said that it would be great if the computer could learn from failures and update the weights itself. Arthur Samuel did this, with human defined features of checkers
- Samuel though the computer should be able to generate its own features. Neural network learned this, using thousands of machine learned features
- another innovation, in backgammon, was not just playing the game to the end in order to update weights or to learn, but instead compare its expected value function at step t and step t+1. If the expected value changed by a lot, then you could try to tweak the parameters to between the two boards. Start by learning this on the n-1 step and then next you can learn the n-2 step value function etc AKA "bootstrapping"
- Q learning: Don't train just a value function that takes in the state of the system (doesn't work well in more complex, continuous systems like robotics). Train a value function given the state of the board and the action 
- AlexNet, see Welch Labs below
- deep mind combined q learning with large neural networks: "deepQ" train to Neural Network to play different games where the only inputs was the screen pixels and the outputs was action to take. Used the game score as a value
- Q learning suffers when controlling robotics when there is a large continuous action space. The solution is to have a policy gradient approach, where you have like just a probability distribution controlling what your next action is 
- made progress in simulated robotics, where you could do thousands of hours of training cheaply. Learning in the real world is expensive and slow 
- An actor critic model is kind of a hack on that where you have other value functions defined. And proximal policy means you have the model resist making too big of a change at once 
- Researchers learned you could use Domain Randomization where you randomized a bit of noise in the simulation learning like gravity or lighting changing and then the model applied better in real life.
- OpenAI was able to control a hand that rotated a block, and it could rotate other shapes.
- Deepmind got robot soccer working, where the robots were able to do predictive blocking.
- People are wondering if you can take the models from GPT but instead of applying them to words, apply them to actions: an Action Model

## Related: [Welch Labs: The moment we stopped understanding AI: AlexNet](https://www.youtube.com/watch?v=UZDiGooFs54)
- it feels semantically correct to say that magic is in the input is magic, that the AI technology is magic because it magic is. Isn't it really just technology that's you can't differentiate from something.... Look up that quote!
- gives a good overview of how image AIS work, with kernels and tensors. You can visualize the first layer of kernel patterns, but the tensors are much harder to visualize 
- on the last layer, it outputs one of the thousand trained labels 
- very interestingly, if you look at the second to last layer, that's a latent space, meaning each dimension has some semantics. Semantics. Word embeddings. And pictures of elephants would be very similar in this space even though they were different in initial pixels 
- several similarities in the way that we think about the deep learning training model mathematical setup, with the language transformers in chatgbt 
- One of the creators of alexnet was Ilya Sutskever who went on to found OpenAI

## Related:  [Kurzgesagt: The Origin of Consciousness – How Unaware Things Became Aware](https://www.youtube.com/watch?v=H6u0VBqNBQ8)
Related: [[Consciousness]]
1. Early in evolution, simple creations starting at basic perception of themselves, allowing for *chemotaxis*
2. Then getting distance perception, like vision
3. Then getting memory, allowing for object permanence
4. Then getting theory of mind
5. Then language as the ultimate tool, allowing for complex though, planning, and communication



