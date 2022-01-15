module Main where

import Polysemy
import qualified Src.KVS as KVS 

f :: t -> (Integer, t)
f = (1, )

g :: a -> b -> (a, b)
g = (,)

h :: String -> Int
h = read @Int

main :: IO ()
main = getLine  >>= print . f . g KVS.f . h