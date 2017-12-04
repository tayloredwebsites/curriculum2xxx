module Translations.Listing exposing(..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Models exposing (Translation)
import Msgs exposing (Msg)

view : List Translation -> Html Msg
view translations =
  div []
    [ nav
    , list translations
    ]


nav : Html Msg
nav =
  div [ class "clearfix mb2 white bg-black" ]
    [ div [ class "left" ] [ text "Translations" ] ]

list : List Translation -> Html Msg
list translations =
  div [ class "p2" ]
    [ table []
      [ thead []
        [ tr []
          [ th [] [ text "Id" ]
          , th [] [ text "Locale" ]
          , th [] [ text "Code" ]
          , th [] [ text "Message" ]
          ]
        ]
      , tbody [] (List.map translationRow translations)
      ]
    ]

translationRow : Translation -> Html Msg
translationRow translation =
  tr []
    [ td [] [ text (toString translation.id) ]
    , td [] [ text translation.locale ]
    , td [] [ text translation.code ]
    , td [] [ text translation.message ]
    , td []
        []
    ]
