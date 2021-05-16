import random

foo = open('/usr/share/dict/words').readlines()

words = [w for w in foo if len(w) > 10]
random.shuffle(words)

for x in words[:50]:
	print(x[:-1], ',', end='')
