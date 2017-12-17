module Msgs exposing (..)

import Models exposing (Translation)
import RemoteData exposing (WebData)
import Navigation exposing (Location)

type Msg
  = OnFetchTranslations (WebData (List Translation))
  | OnLocationChange Location
