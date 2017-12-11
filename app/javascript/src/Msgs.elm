module Msgs exposing (..)

import Models exposing (Translation)
import RemoteData exposing (WebData)

type Msg
  = OnFetchTranslations (WebData (List Translation))
