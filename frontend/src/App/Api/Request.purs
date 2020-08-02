module App.Api.Request
  ( Token(..)
  , BaseUrl
  , RequestMethod(..)
  , login
  , verifyToken
  , readToken
  , writeToken
  , removeToken
  , makeAuthRequest
  , makeAuthRequest'
  ) where

import AppPrelude

import Affjax (Request, Response, printError, request)
import Affjax.RequestBody as RB
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as RF
import Affjax.ResponseHeader (ResponseHeader)
import Affjax.ResponseHeader as ResponseHeader
import App.Api.Endpoint (Endpoint(..), endpointCodec)
import App.Data.Profile (Profile)
import Control.Monad.Reader (ask)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, (.:))
import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (encodeJson)
import Data.Array as Array
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff, liftAff)
import Prim.Row as Row
import Record as Record
import Routing.Duplex (print)
import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage (getItem, removeItem, setItem)


newtype Token = Token String

derive instance newtypeToken :: Newtype Token _
derive instance eqToken :: Eq Token
derive instance ordToken :: Ord Token
derive newtype instance encodeJsonToken :: EncodeJson Token
derive newtype instance decodeJsonToken :: DecodeJson Token

instance showToken :: Show Token where
  show (Token _) = "Token {- token -}"


newtype BaseUrl
  = BaseUrl String

derive instance newtypeBaseUrl :: Newtype BaseUrl _


data RequestMethod
  = Get
  | Post (Maybe Json)
  | Put (Maybe Json)
  | Delete

type RequestOptionsRow =
  ( endpoint :: Endpoint
  , method :: RequestMethod
  , pagination :: Maybe Pagination
  )

type RequestOptions = { | RequestOptionsRow }

type RequestOptionsRowOptional =
  ( pagination :: Maybe Pagination
  )

type RequestOptionsOptional = { | RequestOptionsRowOptional }


type Pagination =
  { contentRange :: Maybe String
  , nextRange :: Maybe String
  }

type Paginated a =
  { body :: a, pagination :: Pagination }

defaultRequest ::
  forall opts opts'.
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  BaseUrl -> Maybe Token -> { | opts } -> Request Json
defaultRequest (BaseUrl baseUrl) auth opts =
  { method: Left method
  , url: baseUrl <> print endpointCodec endpoint
  , headers: authHeader <> paginationHeader
  , content: RB.json <$> body
  , username: Nothing
  , password: Nothing
  , withCredentials: false
  , responseFormat: RF.json
  }
  where
    def :: RequestOptionsOptional
    def = { pagination: Nothing }

    { endpoint, method, pagination } = Record.merge opts def :: RequestOptions

    Tuple method body = case method of
      Get -> Tuple GET Nothing
      Post b -> Tuple POST b
      Put b -> Tuple PUT b
      Delete -> Tuple DELETE Nothing

    authHeader :: Array RequestHeader
    authHeader = maybe [] pure $ auth # map \ (Token t) -> RequestHeader "Authorization" ("Bearer " <> t)

    paginationHeader :: Array RequestHeader
    paginationHeader = maybe [] pure $ RequestHeader "Range" <$> ( _.nextRange =<< pagination)


type LoginFields =
  { email :: String
  , password :: String
  }

login :: forall m. MonadAff m => BaseUrl -> LoginFields -> m (Either String (Tuple Token Profile))
login baseUrl fields = do
  let method = Post $ Just $ encodeJson fields
  requestUser baseUrl { endpoint: Login, method }

requestUser ::
  forall m opts opts'.
  MonadAff m =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  BaseUrl -> { | opts } -> m (Either String (Tuple Token Profile))
requestUser baseUrl opts = do
  let req = defaultRequest baseUrl Nothing opts
  processRequest req parse'

  where
    parse' :: Json -> Either String (Token /\ Profile)
    parse' body = do
      obj <- decodeJson body
      (/\) <$> (obj .: "token") <*> (obj .: "user")


verifyToken :: forall m. MonadAff m => BaseUrl -> Token -> m (Either String Profile)
verifyToken baseUrl token = do
  let opts = { endpoint: Login, method: Get }
  let req = defaultRequest baseUrl (Just token) opts
  processRequest req decodeJson


processRequest ::
  forall m a.
  MonadAff m =>
  Request Json ->
  (Json -> Either String a) ->
  m (Either String a)
processRequest req parse = do
  res <- liftAff $ request req
  pure $ processResponse (lmap printError res) parse


processResponse ::
  forall a.
  Either String (Response Json) ->
  (Json -> Either String a) ->
  Either String a
processResponse res parse = do
    body <- rmap _.body res
    case parse body of
      Left msg -> case parseError body of
        Left _ -> Left msg
        Right msg' -> Left msg'
      Right x -> Right x

  where
    parseError :: Json -> Either String String
    parseError body = do
      obj <- decodeJson body
      obj .: "error_message"


tokenKey = "token" :: String

readToken :: Effect (Maybe Token)
readToken = do
  str <- getItem tokenKey =<< localStorage =<< window
  pure $ map Token str

writeToken :: Token -> Effect Unit
writeToken (Token str) = setItem tokenKey str =<< localStorage =<< window

removeToken :: Effect Unit
removeToken = removeItem tokenKey =<< localStorage =<< window


extractPagination :: Array ResponseHeader -> Pagination
extractPagination hdrs =
  { contentRange: lookup' "content-range"
  , nextRange: lookup' "next-range"
  }
  where
    lookup' :: String -> Maybe String
    lookup' name = ResponseHeader.value <$> Array.find ((_ == name) <<< ResponseHeader.name) hdrs


makeAuthRequest ::
  forall m opts opts' r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  { | opts } -> m (Maybe Json)
makeAuthRequest opts = do
  res <- makeAuthRequest' opts
  pure $ _.body <$> res

makeAuthRequest' ::
  forall m opts opts' r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  { | opts } -> m (Maybe (Response Json))
makeAuthRequest' opts = do
  { baseUrl } <- ask
  token <- liftEffect readToken
  res <- liftAff $ request $ defaultRequest baseUrl token opts
  pure $ hush res
