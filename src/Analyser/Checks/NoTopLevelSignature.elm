module Analyser.Checks.NoTopLevelSignature exposing (checker)

import AST.Ranges as Range
import ASTUtil.Inspector as Inspector exposing (Order(Inner, Skip), defaultConfig)
import Analyser.Checks.Base exposing (Checker)
import Analyser.Configuration exposing (Configuration)
import Analyser.FileContext exposing (FileContext)
import Analyser.Messages.Data as Data exposing (MessageData)
import Analyser.Messages.Schema as Schema
import Elm.Syntax.Expression exposing (Expression(..), Function)


checker : Checker
checker =
    { check = scan
    , info =
        { key = "NoTopLevelSignature"
        , name = "No Top Level Signature"
        , description = "We want our readers to understand our code. Adding a signature is part of this."
        , schema = Schema.schema |> Schema.rangeProp "range" |> Schema.varProp "varName"
        }
    }


scan : FileContext -> Configuration -> List MessageData
scan fileContext _ =
    Inspector.inspect
        { defaultConfig | onFunction = Inner onFunction, onDestructuring = Skip }
        fileContext.ast
        []


onFunction : (List MessageData -> List MessageData) -> Function -> List MessageData -> List MessageData
onFunction _ function context =
    case function.signature of
        Nothing ->
            let
                r =
                    function.declaration.name.range
            in
            (Data.init
                (String.concat
                    [ "No signature for top level definition `"
                    , function.declaration.name.value
                    , "` at "
                    , Range.rangeToString r
                    ]
                )
                |> Data.addVarName "varName" function.declaration.name.value
                |> Data.addRange "range" r
            )
                :: context

        Just _ ->
            context
