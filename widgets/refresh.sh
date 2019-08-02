#!/bin/sh

echo '0' > /tmp/geo_time.txt
ls *.coffee | while read f; do mv "$f" REFRESH; sleep 0.1; mv REFRESH "$f"; done
