module Src.Logging
    ( logInfo
    , logError
    , logFile
    , Logging
    , runLoggingIO
    ) where

import qualified Control.Monad.Logger as ML
import           Data.Text
import           Polysemy

data Logging m a where
    LogInfo  :: Text -> Logging m ()
    LogError :: Text -> Logging m ()
    LogFile  :: FilePath -> Text -> Logging m ()

makeSem ''Logging

runLoggingIO :: Member (Embed IO) r => Sem (Logging ': r) a -> Sem r a
runLoggingIO = interpret $ \case
    LogInfo msg    -> embed . ML.runStdoutLoggingT . ML.logInfoN $ msg
    LogError msg   -> embed . ML.runStderrLoggingT . ML.logErrorN $ msg
    LogFile fp msg -> embed . ML.runFileLoggingT fp . ML.logErrorN $ msg



