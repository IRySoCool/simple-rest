module Src.DB where

import           Hasql.Pool
import           Hasql.Session
import           Polysemy

data DB m a where
  RunSession :: Session a -> DB m a

makeSem ''DB

runDBIO ::  Member (Embed IO) r => Pool -> Sem (DB ': r) a -> Sem r a
runDBIO pool = interpret $ \case
    RunSession s -> embed $ do
      result <- use pool s
      case result of
        Left err -> error $ show err
        Right x  -> pure x
