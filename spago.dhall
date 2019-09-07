{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
, name =
    "werbematerial-gh-pages"
, dependencies =
    [ "affjax"
    , "console"
    , "debug"
    , "effect"
    , "foreign-generic"
    , "foreign-object"
    , "node-fs"
    , "node-process"
    , "prelude"
    , "psci-support"
    , "react-basic"
    , "test-unit"
    ]
, packages =
    ./packages.dhall
}
