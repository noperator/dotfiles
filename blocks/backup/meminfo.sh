#!/usr/bin/env bash

# https://www.linuxatemyram.com/
# https://www.aliexpress.com/item/Smart-Card-Reader-w-cable-For-ThinkPad-T450S-FRU-04X5393/32863484154.html
# https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=34e431b0ae398fc54ea69ff85ec700722c9da773

getmem()
{
    awk -v type=$1 '
    /^MemAvailable:/ {
    	mem_available=$2
    }
    /^SwapTotal:/ {
    	swap_total=$2
    }
    /^SwapFree:/ {
    	swap_free=$2
    }
    END {
    	# full text
    	if (type == "swap")
    	    printf("%.1fG\n", (swap_total-swap_free)/1024/1024)
    	else
    	    printf("%.1fG ", mem_available/1024/1024)
    }
    ' /proc/meminfo
}
