#literature 
- [ ] Link similar concepts to other LLM notes
## **[Large Language Models from scratch - YouTube](https://www.youtube.com/watch?v=lnA9DMvHtfI)**
Think about Autocomplete: given prompt “TY” need to suggest most likely next letter
Sort by word frequency, take first.
Search Prompt could do the same

Goal is to solve `P(phrase)` but solving for “frequency” might not work, 
I.e. for “She just won the 2032 election” won’t come up yet for another 8 years

Will we exhaust all possible english sentences? 100k words ** 10 words => 10\*\*50 huge number

Need to model grammar. Starting with some sentence, you can merge “nodes” in a “graph” and give equal probabilities to all possible transitions, now you have a Language Model.
Can generate new sentences, but often nonsense.
What if you use more text? No, still nonsense.
Model is too limiting, to just take P(x<sub>n</sub>|x<sub>n-1</sub>)
Could use triples of words, called Trigrams. Slightly better.
Problem is that words can depend on other words really far away in the sentence.
Way too complex to exactly get P(x<sub>n</sub>|x<sub>n-1</sub>,x<sub>n-2</sub> … x<sub>n-13</sub>) but can approximate

Some existing approximations:
- Fourier series using sines and cousins
- Taylor series using polynomials
- Neural Networks, where neuron uses i.e. Sigmoid

Example Neuron function is w<sub>5</sub>S(w<sub>1</sub>x) + w<sub>6</sub>S(w<sub>2</sub>x) + …
Define E = SUM(f(x) - y)\*\*2 then update weights using thousands of iterations.
Very closely approximates input function!

Can think of some energy function, defined over the space of all weight dimensions.
Instead of working with the whole function, just get the gradient of which direction improves each param the most. Then “roll downhill”

Can propagate partial derivatives backward in the network: Back Prop

MetaParams matter:
If the network doesn’t have enough capacity, you can’t approximate a complex function.
Or if using ReLU, you need more pieces to approximate a curvy function.

## **[Large Language Models: Part 2 - YouTube](https://www.youtube.com/watch?v=YDiSFS-yHwk&list=PLKaROnFIQQruTJe5zglUBBQ3KnAMa40Mc&index=4)**
Modeling language
Need to map words to numbers.
Instead of just mapping 0->100k you want similar words to have "similar" numbers.
Instead of just one dimension, Word Embedding uses thousands of dims.

Do you just make one huge, fully-connected neural layer?
When trying to figure out one missing words at the end of the sentence, instead of paying attention to all input words, really only a few matter. 
Can you train a neural network to recognize which words matter?
Some Attention Network needed.

Can you train both Attention Network together with Prediction?
Worlds well! Combined, this is called a **Transformer**
It’s a little more complicated: the Context for each word is calculated, by taking a weighted sum of the words that each word depends on.

To generate text, get the Prediction of a word, then make it the input to the LLM in order to predict the next.
To give more capacity, can stack multiple of these Transformer blocks. GPT-3 has 96 of these. 
If bottom layer can pay attention to Syntax, top layers can pay attention to Semantics.

Often fail at Arithmetic, big factoring.
But good at generating poems, songs, and recipes.
Can generate code for using pytorch
