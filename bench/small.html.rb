_html {
  _head {}
  _body {
    1.times do
      5.times do
        _span.awesome { _ "Yo" }
      end
      5.times do
        _span.cool! { __ "YoYo" }
      end
      5.times do
        _br
      end
      5.times do
        _div.last { _ "Hi" }
      end
    end
  }
}
