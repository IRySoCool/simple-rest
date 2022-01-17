{-# LANGUAGE FlexibleInstances #-}

module Src.Config where

import           Data.ByteString
import           Options.Generic

data Config w = Config
    { port     :: w ::: Int <!> "8080" <?> "Port number for the app"
    , size     :: w ::: Int <!> "10" <?> "Database Connection pool size"
    , connStr  :: w ::: ByteString <!> "host=localhost port=5432 user=test dbname=test password=test" <?> "Database Connection string"
    } deriving (Generic)

modifiers :: Modifiers
modifiers = defaultModifiers { shortNameModifier = firstLetter }

instance ParseRecord (Config Wrapped)
deriving instance Show (Config Unwrapped)
