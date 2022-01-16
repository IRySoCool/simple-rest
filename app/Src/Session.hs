{-# LANGUAGE QuasiQuotes #-}

module Src.Session where

import           Data.Int
import           Data.Profunctor
import           Data.Tuple.Curry
import           Data.Vector
import           Hasql.Session
import           Hasql.TH
import           Src.Entity.Book


listBook :: Session (Vector Book)
listBook = statement () s
  where
    s = rmap
      (fmap (uncurryN Book))
      [vectorStatement|SELECT id :: int8, name :: text, author :: text FROM book|]

getBook :: Int64 -> Session (Maybe Book)
getBook = flip statement s
  where
    s = rmap
      (fmap (uncurryN Book))
      [maybeStatement|SELECT id :: int8, name :: text, author :: text FROM book WHERE id = $1 :: int8|]

insertBook :: Book -> Session ()
insertBook = flip statement s
  where
    s = lmap
      (\(Book a b c) -> (a, b, c))
      [resultlessStatement|INSERT INTO book (id, name, author) VALUES ($1 :: int8, $2 :: text, $3 :: text)|]

deleteBook :: Int64 -> Session ()
deleteBook = flip statement s
  where
    s = 
      [resultlessStatement|DELETE FROM book WHERE id = $1 :: int8|]