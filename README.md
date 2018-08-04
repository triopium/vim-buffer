# vim-buffer
* Library of various functions which deal with buffers.
* faster buffer navigation with buffer#BufferListChanger() function

# Usage
## faster buffer navigation
* example mapping:
nnoremap <leader><leader>l buffer#BufferListChanger()
* automatic mappinggs local to buffer
enter	'go to buffer under cursor'
d		'delete (wipe) buffer under cursor from buffer list

## show outline of markup file in split buffer
* example mapping:
nnoremap <leader><leader>o buffer#OutlineTxtShow()
* automatic mappings local to buffer
u	'update outline'
-	'decrease the outline level
+	'increase the outline level

# Dependency
vim-array

# Testting
* There are commented tests. You can use vim-runner to run tests conveniently. 
