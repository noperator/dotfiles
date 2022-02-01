#!/usr/bin/env jq

# Take an array of N arrays of key-value pairs (i.e., what you might get from
# map(to_entries)) and convert it to:
# - 1 array of keys (a column header), and
# - N arrays (rows) of values.
#
# This makes it easy to pipe the values into the column utility for
# pretty-printing tabular data on the CLI. For example:
#
# ```
# $ echo '
# [
#   {
#     "name": "Jane Doe",
#     "birthday": "1970-01-01",
#     "social": "123-45-6789"
#   },
#   {
#     "name": "Dane Hoe",
#     "birthday": "2022-02-01",
#     "social": "098-76-5432"
#   }
# ]
# ' | jq -r 'map(to_entries) | tab | @tsv' | column -ts $'\t'
#
# name      birthday    social
# Jane Doe  1970-01-01  123-45-6789
# Dane Hoe  2022-02-01  098-76-5432
# ```
#
# See also:
# - https://stedolan.github.io/jq/manual#to_entries,from_entries,with_entries
def tab: (.[0] | map(.key)), (.[] | map(.value));
