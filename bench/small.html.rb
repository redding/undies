_html {
  _head {}
  _body {
    100.times do |n|
      _span "Yo", :id => "cool-#{n}!"
      _p "Yo", :class => "awesome"

      _br

      _div :class => 'last' do
        _span "Hi ", em('there'), '!!'
      end
    end
  }
}
