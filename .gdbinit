define redirect_stdout
  call rb_eval_string("$_old_stdout, $stdout = $stdout,
    File.open('/tmp/ruby-debug.' + Process.pid.to_s, 'a'); $stdout.sync = true")
end

define evalr
  call(rb_p(rb_eval_string_protect($arg0,(int*)0)))
end

define rb_bt
  set $ary = backtrace(-1)
  set $count = ((struct RArray) *$ary).len
  set $index = 0
  while $index < $count
    x/1s ((struct RString) *rb_ary_entry($ary, $index)  ).ptr
    set $index = $index + 1
  end
end
