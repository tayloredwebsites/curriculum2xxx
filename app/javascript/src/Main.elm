module Main exposing (..)

-- commands import
-- updates import
-- import Routing exposing (parseLocation)

import Html exposing (Html, div, h1, program, text)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Models exposing (Model, Route(..), Translation, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Translations.Listing exposing (list, nav)
import UrlParser exposing (..)


-- INIT


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
    ( initialModel currentRoute, fetchTranslations )


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map TranslationsRoute top
        , map TranslationsRoute (s "translations")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute



--, Cmd.none) --
-- VIEW


view : Model -> Html Msg
view model =
    -- h1 [style [("display", "flex"), ("justify-content", "center")]]
    --    [ text "Hello Elm!" ]
    div []
        [ page model
        ]


page : Model -> Html Msg
page model =
    case model.route of
        Models.TranslationsRoute ->
            Translations.Listing.view model.translations

        Models.NotFoundRoute ->
            notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]



-- MESSAGE (see Msgs.elm)
-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchTranslations response ->
            ( { model | translations = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
            ( { model | route = newRoute }
            , Cmd.none
            )



-- COMMANDS


fetchTranslations : Cmd Msg
fetchTranslations =
    Http.get fetchTranslationsUrl translationsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchTranslations


fetchTranslationsUrl : String
fetchTranslationsUrl =
    "http://localhost:5000/translations.json"


translationsDecoder : Decode.Decoder (List Translation)
translationsDecoder =
    Decode.list translationDecoder


translationDecoder : Decode.Decoder Translation
translationDecoder =
    decode Translation
        |> required "id" Decode.int
        |> required "locale" Decode.string
        |> required "key" Decode.string
        |> required "value" Decode.string



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    -- Html.program
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
