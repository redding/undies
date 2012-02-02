_html {
  _head {}
  _body {
    100.times do
      5.times do
        _ "Yo"
      end
      5.times do
        __ "YoYo"
      end
      5.times do
        _br
      end
      5.times do
        _div { _ "Hi" }
      end
    end
  }
}
