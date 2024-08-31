______________________________________________________________________

Title: 'Notes'
Date: 02/12/2024
Author: 'Ernest Orlowski'

______________________________________________________________________

Ruby script to calculate the mean and standard deviation from a stream of numbers passed as lines of input.

```ruby
values = []

ARGF.each do |line|
    values << line.to_f if line =~ /\d/
end

sum   = values.inject(:+)
mean  = sum.to_f / values.size
diffs = values.map {|v| (v - mean)**2}
stdev = Math.sqrt(diffs.inject(:+).to_f / values.size)

puts "mean:  %7.3f" % mean
puts "stdev: %7.3f" % stdev
```

______________________________________________________________________

sync wsl clipboard (check if this works with $DISPLAY envvars)

______________________________________________________________________

```lua
if vim.fn.has('wsl') then
  vim.cmd([[
    augroup Yank
    autocmd!
    autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
    augroup END
    ]])
end
```
