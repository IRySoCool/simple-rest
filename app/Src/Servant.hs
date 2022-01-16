module Src.Servant (app) where

import           Control.Monad.Except
import           Data.Aeson
import           Data.Function
import           Data.IORef
import qualified Data.Map.Strict          as M
import           GHC.Generics
import qualified Network.Wai.Handler.Warp as Warp
import           Options.Generic
import           Polysemy
import           Polysemy.State
import           Servant
import           Src.Config
import           Src.Logging
import           Src.Store

data Book = Book
  { id     :: Int
  , name   :: String
  , author :: String
  }
  deriving (Show, Generic, FromJSON, ToJSON)

type BookStore = Store Int Book

initBookStore :: M.Map Int Book
initBookStore = M.empty

type API = "books" :> Get '[JSON] [Book]
      :<|> "book"  :> Capture "bookid" Int :> Get '[JSON] (Maybe Book)
      :<|> "book"  :> ReqBody '[JSON] Book :> Post '[JSON] Bool

apiServer :: Members '[Logging, BookStore] r => ServerT API (Sem r)
apiServer = list :<|> get :<|> post
  where
    get :: Members '[Logging, BookStore] r => Int -> Sem r (Maybe Book)
    get bookId = do
      logInfo "Getting book API is called."
      getItem bookId

    list :: Members '[Logging, BookStore] r => Sem r [Book]
    list = do
      logInfo "Listing book API is called."
      (fmap . fmap) snd listItem

    post :: Members '[Logging, BookStore] r => Book -> Sem r Bool
    post book@(Book bookId _ _) = do
      logInfo "Inserting a book into bookstore"
      insertItem bookId book
      return True

api :: Proxy API
api = Proxy

initialize :: IO Application
initialize = do
  ref <- newIORef initBookStore
  pure . serve api . hoistServer api (interpreter ref) $ apiServer
 where
  interpreter ref sem = sem
    & runLoggingIO
    & runActionState
    & runStateIORef @(M.Map Int Book) ref
    & runM
    & fmap (handleErrors . Right)
    & Handler . ExceptT

  handleErrors (Left  _    ) = Left err404 { errBody = "Some error occur" }
  handleErrors (Right value) = Right value

app :: IO ()
app = do
  (Config port _) <- unwrapRecord "Application"
  initialize >>= Warp.run port
