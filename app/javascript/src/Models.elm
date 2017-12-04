module Models exposing (..)

type alias Model =
  { translations: List Translation
  }

initialModel: Model
initialModel =
  { translations = [
      Translation 1 "en" "test.key" "This is a test."
    ]
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
