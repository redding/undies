_html {
  _head {}
  _body {
    1.times do
      5.times do
        _span { _ "Yo" }
      end
      5.times do
        _span { __ "YoYo" }
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
