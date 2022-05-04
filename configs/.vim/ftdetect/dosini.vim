" .INI file for MSDOS
au BufNewFile,BufRead *.ini               setf dosini
au BufNewFile,BufRead */etc/yum.conf      setf dosini
au BufNewFile,BufRead */.aws/config       setf dosini
au BufNewFile,BufRead */.aws/credentials  setf dosini

