# vim-buffer
* Library of various functions which deal with buffers.
* faster buffer navigation with buffer#BufferListChanger() function

# Usage
* example mapping
nnoremap <leader><leader>l buffer#BufferListChanger()
* automatic buffer list local mappings
enter	'go to buffer under cursor'
d		'delete (wipe) buffer under cursor from buffer list
# Dependency
vim-array

# Testting
* There are commented tests. You can use vim-runner to run tests conveniently. 
