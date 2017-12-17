// Run this example by adding <%= javascript_pack_tag "hello_elm" %> to the
// head of your layout file, like app/views/layouts/application.html.erb.
// It will render "Hello Elm!" within the page.

import Elm from '../src/Main'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.createElement('div')
  // const target = document.getElementById('elm-body')

  document.body.appendChild(target)
  Elm.Main.embed(target)
})
