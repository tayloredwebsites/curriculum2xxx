module Models exposing (..)

import RemoteData exposing (WebData)

type alias Model =
  { translations: WebData (List Translation)
  }

initialModel: Model
initialModel =
  { translations = RemoteData.Loading
  }

type alias TranslationId =
  Int

type alias Translation =
  { id: TranslationId
    , locale: String
    , code: String
    , message: String
  }

new : Translation
new =
    { id = 0
    , locale = ""
    , code = ""
    , message = ""
    }
