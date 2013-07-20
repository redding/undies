class WriteThing

  # this is used in testing the write buffer

  def __hi
    'hi'
  end

  def __hello
    'hello'
  end

  def __hithere
    'hithere'
  end

  def __prefix(meth, level, indent)
    "#{level > 0 ? "\n": ''}#{' '*level*indent}"
  end

end
