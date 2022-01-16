{-# LANGUAGE FlexibleInstances #-}

module Src.Config where

import Options.Generic

data Config w = Config
    { port :: w ::: Int <!> "8080" <?> "Port number for the app" 
    , foo  :: w ::: String <!> "bar" <?> "This field is useless"
    } deriving (Generic)

modifiers :: Modifiers
modifiers = defaultModifiers { shortNameModifier = firstLetter }

instance ParseRecord (Config Wrapped)
deriving instance Show (Config Unwrapped)