"""Cleaning word file"""

import csv

new_list = open("words.txt", "w", encoding="utf-8")

uniques = set()

with open('DicFra.csv', encoding='latin-1') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in reader:
        if row[1].startswith("{"):
            split = row[1].split("}")
            word = split[0][1:]
        else:
            word = row[0]
        if word.endswith("!"):
            word = word[:-1]
        elif word.endswith("(s)"):
            word = word.split("(")[0]
        elif word.endswith(" (se)"):
            word = word.split(" ")[0]
        elif word == "Acide":
            word = "acide"
        if len(word) > 2 and not any(x in ["-", ".", " ", "(", "/", "æ", "'"] for x in word) and not any(x.isupper() for x in word):
            new_list.write(word + "\n")
