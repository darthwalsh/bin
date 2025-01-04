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
Hofstadter: "\[about understanding language] if I were to take an hour in doing something, then chatGPT might take one second"

Previously, focused on narrow tasks, supervised learning: classify images or detect spam.
Modeled intuition but not reasoning, which would take a _chain of thought_

### State of Mind
> [!CITE] Serial Order: A Parallel Distributed Processing Approach
> May 1986
> Michael I. Jordan

Had "state of mind" using memory state neurons which were wired back into input: Recurrent Neural network
Trained network by hiding next letter in sequence. Then could use to generate next later.
Found that learned state tended to be "attractors"

### Word Boundaries and Clustering

> [!CITE] Finding structure in time
> March 1990
> Jeffrey L. Elman

Did the same as JORDON, but using language.
Didn't provide word boundaries, but the network learned it.
Found spatial clustering based on meaning
- animate:
	- human
	- non-human
- inanimate
	- inedible
	- edible
Chomsky said a simple system learning like this shouldn't be possible: "it has been argued that generalization about word order cannot be accounted for solely in terms of linear orders"
Toddlers learn by listening along to a speaker, guessing the next word and sometimes predicting correctly

Generalized: sentence can be thought of as a pathway.
(using open AI word embeddings, this could be a pathway in multi-dimensional space)

> [!TIP] Can your [[TrainOfThought]] be the same pathway, building to a multi-dimensional vector?
> I'm not sure AI word embeddings handler order: does "A B C" lead to the same embedding vector as "B C A"?
> Even though language has structure about word order, where common ways to compose ideas fall into recognizable patterns.
> I'm guessing that thoughts within a "sentence" aren't ordered: after all, different languages have very different sentence word orders

### First LLM
> [!CITE] Generating Text with Recurrent Neural Networks
> June 2011
> Ilya Sutskever / James Martens / Geoffrey Hinton

Better text compression basically requires intelligence.

If Intelligence is defined as ability to learn...
Learning is defined as compression of experiences into a predictive model of the world

Gave some memory neurons (?or tied output back to input), and generated text
but the network (wasn't big enough) and the generated texts stop making sense. Sentences veered of course

### Sentiment in a Neuron
> [!CITE] Learning to Generate Reviews and Discovering Sentiment
> April 2017
> Alec Radford / Rafal Jozefowicz / Ilya Sutskever

OpenAI built on prev
Trained on 82 million amazon reviews
probed Sentiment neuron which corresponded to how positive/negative the review text was
Astonishing because normally this required (supervised?) (labeled?) data, but the network achieved this on its own
Forced his sentiment neuron hi/lo, and it generated positive/negative review text
Problem with RNN: all context was squeezed into a narrow window

Problem with RNN, i tried to overcome by processing all text at once but the network needed to be too deep and you couldn't train it

### Transformers
> [!CITE] Attention Is All You Need
> June 2017
> Ashish Vaswani / Noam Shazeer / Niki Parmar / Jakob Uszkoreit / Llion Jones / Aidan N. Gomez / Lukasz Kaiser / Illia Polosukhin

Focused on translating between languages
Created the idea of transformers where the network adapts connection weights based on context of inputs, known as self-attention layer
Led to shallower network: more trainable
Attention Head in network is like a mini network that for a specific step applies the waitings based on the similarity between pairwise words
Called **Transformers** because they take each word and Transform meaning shaped by words around it
BUT, still narrow to problem of translation, trained in a supervised way. (This was *not* ChatGPT v0)

### GPT-1
> [!CITE] Improving Language Understanding by Generative Pre-Training
> June 2018
> Alec Radford / Karthik Narasimhan / Tim Salimans / Ilya Sutskever

OpenAI trained on 7000 books
Able to generate a sentences coherently
Had some Zero-shot learning: being able to generalize from training data

### GPT-2
> [!CITE] Language Models are Unsupervised Multitask Learners
> February 2019
> Alec Radford / Jeffrey Wu / Rewon Child / David Luan / Dario Amodei / Ilya Sutskever

Scraped all of the web that was linked by Reddit posts with at least 3 karma.
Much larger network 300k neurons
Could translate between languages, even though that hadn't been a training goal
Still drifted off to nonsense after long context

### GPT-3
> [!CITE] Language Models are Few-Shot Learners
> May 2020
> Tom B. Brown / Benjamin Mann / Nick Ryder / Melanie Subbiah / Jared Kaplan / Prafulla Dhariwal / Arvind Neelakantan / Pranav Shyam / Girish Sastry / Amanda Askell / Sandhini Agarwal / Ariel Herbert-Voss / Gretchen Krueger / Tom Henighan / Rewon Child / Aditya Ramesh / Daniel M. Ziegler / Jeffrey Wu / Clemens Winter / Christopher Hesse / Mark Chen / Eric Sigler / Mateusz Litwin / Scott Gray / Benjamin Chess / Jack Clark / Christopher Berner / Sam McCandlish / Alec Radford / Ilya Sutskever / Dario Amodei

GPT3 made everything 100x bigger
Trained on all common web, wikipedia, books
Showed In Context Learning, where you can teach the network new things even after training is complete
Passed Wug Test: Given made up words, which it was able to use in a sentence. (milestone in child linguistic development)
Model with frozen weights can still "learn" by combining/composing it's internal model

### ChatGPT / GPT-4
> [!CITE] Large Language Models are Zero-Shot Reasoners
> May 2022
> Takeshi Kojima / Shixiang Shane Gu / Machel Reid / Yutaka Matsuo / Yusuke Iwasawa

Shaped behavior to follow human instructions (labeling good following instructions)
This is InstructGPT, became ChatGPT

Showed that adding "think step by step" gave better results, where a loop over sub-thoughts allowed it to follow a chain of reasoning

> [!TIP] Reminds me of: [[LLM AI are like System One thinking]]
> "Could you repeatedly trigger System One thinking, and "simulate" System Two thinking step-by-step?"

> [!CITE] Voyager: An Open-Ended Embodied Agent with Large Language Models
> May 2023
> Guanzhi Wang / Yuqi Xie / Yunfan Jiang / Ajay Mandlekar / Chaowei Xiao / Yuke Zhu / Linxi Fan / Anima Anandkumar
> 
Researchers put agents into game like Minecraft and see the models learn to use tools

### Tool use
> [!CITE] Toolformer: Language Models Can Teach Themselves to Use Tools
> February 2023
> Timo Schick / Jane Dwivedi-Yu / Roberto Dessì / Roberta Raileanu / Maria Lomeli / Luke Zettlemoyer / Nicola Cancedda / Thomas Scialom

Using LLM with robots with physical cameras and actuators

### Not just a chat bot
LLMs aren't a chatbot or word generator. Instead there's an analogy to a kernel process of an emerging OS:
- RAM is the context window
- Disk is the File System + Embeddings
- Existing Tools like Calculator, Python interpreter, Terminal
- I/O Through video/audio
- Network/Ethernet through Browser
- Communicate with other LLMs
- Model is trying to page relevant info in and out of context window


> [!CITE] GPT-4 Technical Report
> March 2023
> OpenAI *(about 200 contributors)*

10x bigger
Seems like AI has unified around the idea of treating all problem domains as language problems: a series of information-bearing symbols then training networks on predictions using self-attention.
Something core to learning in both biological and artificial neural networks is predicting future perception
Imagination is great for survival: it minimizes surprise

> [!TIP] Did we **invent** or **discover** this kind of learning
> It feels like we might have been trying to understand how our own brains work, when creating LLMs

Noel Chomsky says this is glorified autofill. These systems can't tell us anything about language, learning, intelligence, or thought
But! Saying it's just statistics is ignoring that it's extracting semantic meanings from the sentence to predict next word, which you could call understanding.
## [How Intelligence Evolved - The Role of Simulation](https://www.youtube.com/watch?v=5EcQ1IcEMFQ)
Really interesting exploration of five stages of learning:
1. Nerve net: Primitive worms has neurons hard-coded in DNA that could navigate towards food
	1. (I think the video is oversimplifying) this was the same behavior using [[chemotaxis]] to move towards food, but that was in single-celled organisms
2. Trial and error: Early fishes have senses go into layers of neurons (cortex). Think skinner box
3. Simulation: Mammals can do this in neocortex. Rats stop in maze, imagined going down path
4. 3rd person Simulation: Primates have theory of mind: granular prefrontal cortex. Learn from observing another's mistake or tool-making
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



