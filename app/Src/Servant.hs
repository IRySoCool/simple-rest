module Src.Servant (app) where

import           Control.Monad.Except
import           Data.Function
import           Data.Int
import qualified Data.Map.Strict          as M
import           Data.Time.Clock
import           Data.Vector
import           Hasql.Connection         (settings)
import           Hasql.Pool
import qualified Network.Wai.Handler.Warp as Warp
import           Options.Generic
import           Polysemy
import           Servant
import           Src.Config
import           Src.DB
import           Src.Entity.Book
import           Src.Logging
import qualified Src.Session              as S

type API = "books" :> Get '[JSON] (Vector Book)
      :<|> "book"  :> Capture "bookid" Int64 :> Get '[JSON] (Maybe Book)
      :<|> "book"  :> ReqBody '[JSON] Book :> Post '[JSON] Bool
      :<|> "book"  :> Capture "bookid" Int64 :> Delete '[JSON] Bool

apiServer :: Members '[Logging, DB] r => ServerT API (Sem r)
apiServer = list :<|> get :<|> post :<|> delete
  where
    get :: Members '[Logging, DB] r => Int64 -> Sem r (Maybe Book)
    get bookId = do
      logInfo "Getting book API is called."
      runSession $ S.getBook bookId

    list :: Members '[Logging, DB] r => Sem r (Vector Book)
    list = do
      logInfo "Listing book API is called."
      runSession S.listBook

    post :: Members '[Logging, DB] r => Book -> Sem r Bool
    post book = do
      logInfo "Inserting a book into bookstore"
      runSession $ S.insertBook book
      pure True

    delete :: Members '[Logging, DB] r => Int64 -> Sem r Bool
    delete bookId = do
      logInfo "Deleting a book from bookstore"
      runSession $ S.deleteBook bookId
      pure True

api :: Proxy API
api = Proxy

app :: IO ()
app = do
  (Config port _) <- unwrapRecord "Application"
  pool <- acquire (100, 10 :: NominalDiffTime, settings "localhost" 5432 "test" "test" "test")
  putStrLn "Starting server..."
  Warp.run port . serve api . hoistServer api (interpreter pool) $ apiServer
  where
    interpreter pool sem = sem
      & runLoggingIO
      & runDBIO pool
      & runM
      & fmap (handleErrors . Right)
      & Handler . ExceptT

    handleErrors (Left  _    ) = Left err404 { errBody = "Some error occur" }
    handleErrors (Right value) = Right value
