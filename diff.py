#!/usr/bin/python

import sys

# read the first file.
def get_dict(fname):
    d = {}
    with open(fname) as f:
        lines = f.readlines()
        for line in lines:
            if line.find('[') != -1 and line.find(']') != -1:
                words = line.split()
                pg_name = words[4]
                osd_list = words[5].replace('[', '').replace(']', '')
                osd_list = osd_list.replace(',', ' ').split()
                d[pg_name] = osd_list

    return d


def diff_dict(org, new):
    s = 0
    for k in org.keys():
        old_list = org[k]
        new_list = new[k]
        same = 6 - len(set(old_list + new_list))
        #print '%s %s %s = %s' % (k, old_list, new_list, 3 - same)
        s = s + 3 - same

    print 'Total = %s' % s


if len(sys.argv) != 3:
    print 'Usage: python diff.py org.txt new.txt'
    exit(0)

old = get_dict(sys.argv[1])
new = get_dict(sys.argv[2])
diff_dict(old, new)
