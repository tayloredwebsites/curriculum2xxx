module Uploads.Listing exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Models exposing (Upload)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)


view : WebData (List Upload) -> Html Msg
view response =
    div []
        [ nav
        , maybeList response
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left" ] [ text "Uploads" ] ]


maybeList : WebData (List Upload) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success uploads ->
            list uploads

        RemoteData.Failure error ->
            text (toString error)


list : List Upload -> Html Msg
list uploads =
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
