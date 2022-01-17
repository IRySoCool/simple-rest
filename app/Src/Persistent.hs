{-# LANGUAGE ConstraintKinds            #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE UndecidableInstances       #-}
module Src.Persistent (
    Person (..),
    Book (..),
    Persistent,
    getEntity,
    listEntities,
    insertEntity,
    updateEntity,
    deleteEntity,
    runPersistIO,
    migrateAll,
    P.Key,
    P.Entity
    ) where
import           Data.Aeson
import           Data.Pool                   (Pool)
import qualified Database.Persist            as P
import qualified Database.Persist.Postgresql as P
import           Database.Persist.TH         (mkMigrate, mkPersist,
                                              persistLowerCase, share,
                                              sqlSettings)
import           GHC.Generics
import           Polysemy

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
    Person
        name String
        age Int Maybe
        deriving Show Generic FromJSON ToJSON
    Book
        title String
        authorId PersonId
        deriving Show Generic FromJSON ToJSON
|]

instance ToJSON (P.Entity Person) where
    toJSON = P.entityIdToJSON

instance FromJSON (P.Entity Person) where
    parseJSON = P.entityIdFromJSON

instance ToJSON (P.Entity Book) where
    toJSON = P.entityIdToJSON

instance FromJSON (P.Entity Book) where
    parseJSON = P.entityIdFromJSON

type EntityConstraint a = (P.PersistEntity a, P.PersistEntityBackend a ~ P.SqlBackend)

-- Try to implement these DB Function as an Effect system,
-- but I think the result is not quite good since it involves
-- too much types specific to the persistent library. It seems
-- not a proper use case of Polymesy.
data Persistent m a where
    GetEntity    :: EntityConstraint a => P.Key a -> Persistent m (Maybe (P.Entity a))
    ListEntities :: EntityConstraint a => [P.Filter a] -> [P.SelectOpt a] -> Persistent m [P.Entity a]
    InsertEntity :: EntityConstraint a => a -> Persistent m (P.Key a)
    UpdateEntity :: EntityConstraint a => P.Key a -> [P.Update a] -> Persistent m ()
    DeleteEntity :: EntityConstraint a => P.Key a -> Persistent m ()

makeSem ''Persistent

runPersistIO ::  (Member (Embed IO) r)=> Pool P.SqlBackend -> Sem (Persistent ': r) a -> Sem r a
runPersistIO p = interpret $ \case
    GetEntity k    -> embed $ P.runSqlPersistMPool (P.getEntity k) p

    ListEntities selector opts-> embed $ P.runSqlPersistMPool (P.selectList selector opts) p

    InsertEntity e -> embed $ P.runSqlPersistMPool (P.insert e) p

    UpdateEntity k fields -> embed $ P.runSqlPersistMPool (P.update k fields) p

    DeleteEntity k -> embed $ P.runSqlPersistMPool (P.delete k) p


