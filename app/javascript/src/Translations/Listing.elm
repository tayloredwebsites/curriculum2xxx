module Translations.Listing exposing(..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Models exposing (Translation)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)

view : WebData (List Translation) -> Html Msg
view response =
  div []
    [ nav
    , maybeList response
    ]


nav : Html Msg
nav =
  div [ class "clearfix mb2 white bg-black" ]
    [ div [ class "left" ] [ text "Translations" ] ]

maybeList : WebData (List Translation) -> Html Msg
maybeList response =
  case response of
    RemoteData.NotAsked -> text ""

    RemoteData.Loading -> text "Loading..."

    RemoteData.Success translations ->
      list translations

    RemoteData.Failure error ->
      text (toString error)


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
