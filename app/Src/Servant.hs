module Src.Servant (app) where

import           Control.Monad.Except
import           Control.Monad.Logger        (logInfoN, runStdoutLoggingT)
import           Data.Function
import qualified Data.Map.Strict             as M
import           Database.Persist.Postgresql (createPostgresqlPool,
                                              runMigration, runSqlPersistMPool)
import qualified Network.Wai.Handler.Warp    as Warp
import           Options.Generic
import           Polysemy
import           Servant
import           Src.Config
import           Src.Logging
import           Src.Persistent

type BookAPI = Get '[JSON] [Entity Book]
          :<|> Capture "bookid" (Key Book) :> Get '[JSON] (Maybe (Entity Book))
          :<|> ReqBody '[JSON] Book :> Post '[JSON] (Key Book)
          :<|> Capture "bookid" (Key Book) :> Delete '[JSON] ()

bookServer :: Members '[Logging, Persistent] r => ServerT BookAPI (Sem r)
bookServer = list :<|> get :<|> post :<|> delete
  where
    get :: Members '[Logging, Persistent] r => Key Book -> Sem r (Maybe (Entity Book))
    get bookId = logInfo "Getting book API is called." >> getEntity bookId

    list :: Members '[Logging, Persistent] r => Sem r [Entity Book]
    list = logInfo "Listing book API is called." >> listEntities [] []

    post :: Members '[Logging, Persistent] r => Book -> Sem r (Key Book)
    post book = logInfo "Inserting a book into bookstore" >> insertEntity book

    delete :: Members '[Logging, Persistent] r => Key Book -> Sem r ()
    delete bookId = logInfo "Deleting a book from bookstore" >> deleteEntity bookId

-- For simplicity, omit logging stuff and some APIs here
type PersonAPI = Get '[JSON] [Entity Person]
            :<|> Capture "personid" (Key Person) :> Get '[JSON] (Maybe (Entity Person))
            :<|> ReqBody '[JSON] Person :> Post '[JSON] (Key Person)

personServer ::Members '[Logging, Persistent] r => ServerT PersonAPI (Sem r)
personServer = listEntities [] []
          :<|> getEntity
          :<|> insertEntity

type API = "book" :> BookAPI :<|> "person" :> PersonAPI

apiServer :: Members '[Logging, Persistent] r => ServerT API (Sem r)
apiServer = bookServer :<|> personServer

api :: Proxy API
api = Proxy

app :: IO ()
app = runStdoutLoggingT $ do
  (Config port poolSize connStr) <- unwrapRecord "Application"
  pool <- createPostgresqlPool connStr poolSize
  liftIO $ do
    runSqlPersistMPool (runMigration migrateAll) pool
    Warp.run port . serve api . hoistServer api (interpreter pool) $ apiServer
  where
    interpreter pool sem = sem
      & runLoggingIO
      & runPersistIO pool
      & runM
      & fmap Right -- we should add error handling here, not just lift it to (Either ServerError a)
      & Handler . ExceptT
