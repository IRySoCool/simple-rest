module Src.Entity.Book where

import           Data.Aeson
import           Data.Int
import           Data.Text
import           GHC.Generics

data Book = Book
  { id     :: Int64
  , name   :: Text
  , author :: Text
  }
  deriving (Show, Generic, FromJSON, ToJSON)
