{-# LANGUAGE OverloadedStrings #-}
import qualified Data.Enumerator.List as EList
import qualified Data.ByteString.Char8 as BSChar8
import qualified Data.ByteString as ByteString
import           Data.ByteString (ByteString)
import Network.Socket(SockAddr(..), Family(..), SocketType(..))
import Network.Socket(socket, bindSocket, listen, accept)
import Network.Socket(setSocketOption, SocketOption(ReuseAddr))
import Network.Socket.Enumerator(enumSocket, iterSocket)
import Data.Enumerator(printChunks, ($$), runIteratee, Enumeratee)
import Control.Monad(forever)
import Control.Concurrent(forkIO)
import Control.Applicative
import System.Environment(getArgs)
import Data.Char (toUpper)
import Data.Word (Word8)

chunkSize = 1024
echoServer sock = runIteratee $ enumSocket chunkSize sock
                              $$ capper
                              $$ doubler
                              $$ iterSocket sock

doubler :: (Monad m) => Enumeratee ByteString ByteString m b
doubler = EList.map $ ByteString.concatMap doubleChar
  where
  doubleChar :: Word8 -> ByteString
  doubleChar 10 = "\n" -- doubling newlines is silly
  doubleChar w    = ByteString.pack [w, w]

capper :: (Monad m) => Enumeratee ByteString ByteString m b
capper = EList.map $ BSChar8.map toUpper

tcpListener port = do
    s <- socket AF_INET Stream 0
    setSocketOption s ReuseAddr 1
    bindSocket s $ SockAddrInet (fromIntegral port) 0
    listen s 5
    return s

main = do
    [portStr] <- getArgs
    port <- tcpListener (read portStr)
    forever $ do
         (client, clientAddr) <- accept port
         forkIO (() <$ echoServer client)

