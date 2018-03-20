# Field description scraper

This simple script downloads all beta and alpha registers as `.rsf` files, and
extracts the field descriptions.

It gets even the custom descriptions (which aren't available from the field
register).

At the moment it uses regex, but to do it properly it would search for a system
entry that appends the field, get the hash, then hash all the other items, find
the matching item, and use the latest one of those.
