exports.config=config=max_delay:1000,overwrite_emit:yes
exports.patch=(socket)->
  #prepare socket
  socket._buffer=[]
  socket.buffer_emit=buffer_emit
  socket.buffer_send=buffer_send
  socket.on '__buffer',buffer_process
  socket.__emit=socket.emit#in case we need to overwrite
  if config.overwrite_emit
    socket.emit=buffer_emit

buffer_process=(buffer)->
  for action in buffer
    @$emit.apply @,action# '$emit' emits to this side
buffer_emit=(args...)->
  if args[0] is 'priority'
    priority =yes
    args.shift()
  @_buffer.push args
  if priority
    @buffer_send()
  else
    if @_buffer.length is 1#this is the first in the buffer, start the max_delay countdown
      @timeout=setTimeout (=>@buffer_send()),config.max_delay

buffer_send= ->
  clearTimeout @timeout
  @__emit '__buffer',@_buffer#call real emit, sending to other side's buffer_process
  @_buffer=[]
