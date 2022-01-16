module Src.Store where

import qualified Data.Map.Strict as M
import           Polysemy
import           Polysemy.State

data Store k v m a where
  ListItem   :: Store k v m [(k, v)]
  GetItem    :: k -> Store k v m (Maybe v)
  InsertItem :: k -> v -> Store k v m ()
  DeleteItem :: k -> Store k v m ()

makeSem ''Store

runActionState
  :: (Member (State (M.Map k v)) r, Ord k) => Sem (Store k v ': r) a -> Sem r a
runActionState = interpret $ \case
  ListItem       -> M.toList <$> get
  GetItem k      -> M.lookup k <$> get
  InsertItem k v -> modify (M.insert k v)
  DeleteItem k   -> modify (M.delete k)
