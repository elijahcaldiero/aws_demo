#!/usr/bin/env python3
import cgi
import cgitb

import os
import sys

cgitb.enable()
data = cgi.FieldStorage()

print("Content-Type: text/html\n")

embed = ''
if data:
	embed = """<iframe width="560" height="315" src="https://www.youtube.com/embed/8U1QIH53tbc?start=23&autoplay=1" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>"""

form = '<form method="POST"><label for="name">Your Name</label><input type="text" name="name" id="name" /><br/><label for="note">Leave a note</label><textarea id="note" name="note" rows="10" columns="80" /></textarea><input type="submit" id="submit" /></form>'

print(f'<html><head><title>Some stuff</title></head><body>{ embed }\n{form}</body></html>')
print("got: ", data)
