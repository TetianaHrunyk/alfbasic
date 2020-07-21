from random_words import RandomWords
rw = RandomWords()

print("Enter the name of the file: ", end = "")
fname = str(input())
file = open(fname+".csv", "w+")
print("Number of strings: ", end = "")
n = int(input())

r_words = rw.random_words(letter = None, count = n)
for word in r_words:
    file.write(word+"\n")

file.close()