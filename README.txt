Name: Rupa Shankar
SUID: rupss
Email: rupss@stanford.edu

This is my submission for assignment 1. I use the DoBeforeEachAction() function to keep track of the location of each lexeme. For multi line comments, I use a separate start condition to make sure that the other rules e.g tokenizing keywords such as void, tokenizing ints, etc does not occur for the content of the comments. Otherwise, I pretty much just used a bunch of regular expressions and let flex do the rest. 
