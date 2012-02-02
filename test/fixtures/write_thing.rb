class WriteThing

  # this is used in testing the write buffer

  def self.hi(thing)
    'hi'
  end

  def self.hello(thing)
    'hello'
  end

  def self.hithere(thing)
    'hithere'
  end

  def self.prefix(thing, meth, level, indent)
    "#{level > 0 ? "\n": ''}#{' '*level*indent}"
  end

end
