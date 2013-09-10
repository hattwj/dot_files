svn status|grep ? | sed 's/\s\+/ /g' | cut -d' ' -f2|xargs svn add
