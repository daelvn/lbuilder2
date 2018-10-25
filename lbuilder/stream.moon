-- lbuilder2 | Stream class

class Stream
  new: (data="", pointer=0) =>
    @data    = data
    @pointer = pointer

  read:            => @data\sub @pointer, @pointer
  consume: (ptr=1) =>
    @pointer += ptr
    @data\sub   @pointer-ptr

Stream
