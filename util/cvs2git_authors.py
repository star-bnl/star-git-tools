#!/usr/bin/env python3
#
# 1. Create a list of logins contributed to Git repo
#
#    git shortlog --summary --all > cvs_authors.txt
#
# 2. Create a list of logins + full names by running finger on this list
#
#     while read l; do echo "$l" | awk '{print $2}' | xargs finger -m | head -1; done < cvs_authors.txt > cvs_authors.tmp
#     mv cvs_authors.tmp cvs_authors.txt
#
# 3. Create sqlite3 database from starweb.sql dump. Requires some cleaning
#
#     cat starweb_members.sql | sqlite3 starweb_members.db
#
# 4. Run this script as
#
#     cvs2git_authors.py path/to/starweb_members.db path/to/cvs_authors.txt > author_transforms
#
# 5. Insert the contents of author_transforms into 
#

import re


def similar(a, b):
    from difflib import SequenceMatcher
    a = ''.join(a.split())
    b = ''.join(b.split())
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()


def read_members(sqlite_db_file):
    import sqlite3
    conn = sqlite3.connect('starweb_members.db')
    c = conn.cursor()
    records = c.execute('SELECT * FROM members')

    members = []

    for record in records:
        email = f'{record[16]}'
        if not email or email == "None": continue
        members += [(record[2], record[1], email)]

    return members


def read_authors(cvs_authors_file):
    with open(cvs_authors_file, 'r') as slfile:
        finger_list = slfile.read()

    re_block = re.compile(r"^Login:\s*(.*)\s*Name: (.+)\s*$", re.MULTILINE)

    cvs_authors = []

    for author_matches in re_block.finditer(finger_list):
        cvs_authors += [tuple(token.strip() for token in author_matches.groups())]

    return cvs_authors


def contains_word(w):
    return re.compile(r'\b({0})\b'.format(w), re.IGNORECASE).search


def best_member(members, full_name):
    full_name_split = full_name.split()
    full_first = full_name_split[0]
    full_last  = full_name_split[-1]

    best_i = None
    best_score = 0

    for i, (f, l, e) in enumerate(members):
        score = 0

        if len(l) < 4 and similar(l, full_last) < 1 and similar(l, full_first) < 1:
            continue
        if len(f) < 4 and similar(f, full_first) < 1 and similar(f, full_last) < 1:
            continue
        if contains_word(l)(full_name):
            score += 10
        else:
            continue
        if contains_word(f)(full_name):
            score += 10

        score += similar(f'{f}{l}', full_name) * 10

        ff = similar(f, full_first)
        ll = similar(l, full_last)

        if (ff > 0.5 and ll > 0.5):
            score += ff * ll * 20

        lf = similar(l, full_first)
        fl = similar(f, full_last)

        if (lf > 0.5 and  fl > 0.5):
            score += lf * fl * 10

        if score > best_score:
            best_score = score
            best_i = i

    return best_i, best_score


def match_authors_members(authors, members):
    matches = []

    for i1, (login, full_name) in enumerate(authors):
        i2, score = best_member(members, full_name)
        matches += [(i1, i2, score)]

    return matches


def print_matches(matches, authors, members):
    matches = sorted(matches, key=lambda tup: tup[2])

    for i1, i2, score in matches:

        login, full_name = authors[i1] if i1 is not None else (None, None)
        fn, ln, e = members[i2] if i2 is not None else (None, None, None)

        if not e or score < 16.90:
            e = f'{login}'

        #print(f'{score:5.2f}: {login} -- {full_name} -- {fn} {ln} -- {e}')
        print(f'\'{login}\': \'{full_name} <{e}>\',')


if __name__ == "__main__":
    import sys
    if len(sys.argv) is not 3:
        print("Usage: sys.argv[0] path/to/starweb_members.db path/to/cvs_authors.txt")
        exit(1)

    members = read_members(sys.argv[1])
    authors = read_authors(sys.argv[2])
    matches = match_authors_members(authors, members)
    print_matches(matches, authors, members)
