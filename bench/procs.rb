@small_proc = Proc.new do
  _html {
    _head {}
    _body {

      1.times do
        _ "Yo"
        _ "Yo"
        _ "Yo"
        _ "Yo"
        _ "Yo"

        __ "YoYo"
        __ "YoYo"
        __ "YoYo"
        __ "YoYo"
        __ "YoYo"

        _br
        _br
        _br
        _br
        _br

        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
      end

    }
  }
end


@large_proc = Proc.new do
  _html {
    _head {}
    _body {

      10.times do
        _ "Yo"
        _ "Yo"
        _ "Yo"
        _ "Yo"
        _ "Yo"

        __ "YoYo"
        __ "YoYo"
        __ "YoYo"
        __ "YoYo"
        __ "YoYo"

        _br
        _br
        _br
        _br
        _br

        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
      end

    }
  }
end


@verylarge_proc = Proc.new do
  _html {
    _head {}
    _body {

      1000.times do
        _ "Yo"
        _ "Yo"
        _ "Yo"
        _ "Yo"
        _ "Yo"

        __ "YoYo"
        __ "YoYo"
        __ "YoYo"
        __ "YoYo"
        __ "YoYo"

        _br
        _br
        _br
        _br
        _br

        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
        _div { _ "Hi" }
      end

    }
  }
end
