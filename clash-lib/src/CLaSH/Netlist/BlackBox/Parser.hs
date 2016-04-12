{-|
  Copyright  :  (C) 2012-2016, University of Twente
  License    :  BSD2 (see the file LICENSE)
  Maintainer :  Christiaan Baaij <christiaan.baaij@gmail.com>

  Parser definitions for BlackBox templates
-}

module CLaSH.Netlist.BlackBox.Parser
  (runParse)
where

import           Data.Text.Lazy                           (Text, pack)
import qualified Data.Text.Lazy                           as Text
import           Text.ParserCombinators.UU
import           Text.ParserCombinators.UU.BasicInstances hiding (Parser)
import qualified Text.ParserCombinators.UU.Core           as PCC (parse)
import           Text.ParserCombinators.UU.Utils          hiding (pBrackets)

import           CLaSH.Netlist.BlackBox.Types

type Parser a = P (Str Char Text LineColPos) a


-- | Parse a text as a BlackBoxTemplate, returns a list of errors in case
-- parsing fails
runParse :: Text -> (BlackBoxTemplate, [Error LineColPos])
runParse = PCC.parse ((,) <$> pBlackBoxD <*> pEnd)
         . createStr (LineColPos 0 0 0)

-- | Parse a BlackBoxTemplate (Declarations and Expressions)
pBlackBoxD :: Parser BlackBoxTemplate
pBlackBoxD = pSome pElement

-- | Parse a single Template Element
pElement :: Parser Element
pElement  =  pTagD
         <|> C <$> pText
         <|> C <$> (pack <$> pToken "~ ")

-- | Parse the Text part of a Template
pText :: Parser Text
pText = pack <$> pList1 (pRange ('\000','\125'))

-- | Parse a Declaration or Expression element
pTagD :: Parser Element
pTagD =  IF <$> (pTokenWS "~IF" *> pTagE)
            <*> (pSpaces *> (pToken "~THEN" *> pBlackBoxD))
            <*> (pToken "~ELSE" *> pBlackBoxD <* pToken "~FI")
     <|> D <$> pDecl
     <|> pTagE

-- | Parse a Declaration
pDecl :: Parser Decl
pDecl = Decl <$> (pTokenWS "~INST" *> pNatural) <*>
        ((:) <$> pOutput <*> pList pInput) <* pToken "~INST"

-- | Parse the output tag of Declaration
pOutput :: Parser (BlackBoxTemplate,BlackBoxTemplate)
pOutput = pTokenWS "~OUTPUT" *> pTokenWS "<=" *> ((,) <$> (pBlackBoxE <* pTokenWS "~") <*> pBlackBoxE) <* pTokenWS "~"

-- | Parse the input tag of Declaration
pInput :: Parser (BlackBoxTemplate,BlackBoxTemplate)
pInput = pTokenWS "~INPUT" *> pTokenWS "<=" *> ((,) <$> (pBlackBoxE <* pTokenWS "~") <*> pBlackBoxE) <* pTokenWS "~"

-- | Parse an Expression element
pTagE :: Parser Element
pTagE =  O                 <$  pToken "~RESULT"
     <|> I                 <$> (pToken "~ARG" *> pBrackets pNatural)
     <|> L                 <$> (pToken "~LIT" *> pBrackets pNatural)
     <|> (Clk . Just)      <$> (pToken "~CLK" *> pBrackets pNatural)
     <|> Clk Nothing       <$  pToken "~CLKO"
     <|> (Rst . Just)      <$> (pToken "~RST" *> pBrackets pNatural)
     <|> Rst Nothing       <$  pToken "~RSTO"
     <|> (Sym Text.empty)  <$> (pToken "~SYM" *> pBrackets pNatural)
     <|> Typ Nothing       <$  pToken "~TYPO"
     <|> (Typ . Just)      <$> (pToken "~TYP" *> pBrackets pNatural)
     <|> TypM Nothing      <$  pToken "~TYPMO"
     <|> (TypM . Just)     <$> (pToken "~TYPM" *> pBrackets pNatural)
     <|> Err Nothing       <$  pToken "~ERRORO"
     <|> (Err . Just)      <$> (pToken "~ERROR" *> pBrackets pNatural)
     <|> TypElem           <$> (pToken "~TYPEL" *> pBrackets pTagE)
     <|> IndexType         <$> (pToken "~INDEXTYPE" *> pBrackets pTagE)
     <|> CompName          <$  pToken "~COMPNAME"
     <|> Size              <$> (pToken "~SIZE" *> pBrackets pTagE)
     <|> Length            <$> (pToken "~LENGTH" *> pBrackets pTagE)
     <|> Depth             <$> (pToken "~DEPTH" *> pBrackets pTagE)
     <|> FilePath          <$> (pToken "~FILE" *> pBrackets pTagE)
     <|> Gen               <$> (True <$ pToken "~GENERATE")
     <|> Gen               <$> (False <$ pToken "~ENDGENERATE")
     <|> SigD              <$> (pToken "~SIGD" *> pBrackets pSigD) <*> (Just <$> (pBrackets pNatural))
     <|> (`SigD` Nothing)  <$> (pToken "~SIGDO" *> pBrackets pSigD)
     <|> IW64              <$  pToken "~IW64"
     <|> (HdlSyn Vivado)   <$  pToken "~VIVADO"
     <|> (HdlSyn Other)    <$  pToken "~OTHERSYN"
     <|> (BV True)         <$> (pToken "~TOBV" *> pBrackets pSigD) <*> pBrackets pTagE
     <|> (BV False)        <$> (pToken "~FROMBV" *> pBrackets pSigD) <*> pBrackets pTagE
     <|> IsLit             <$> (pToken "~ISLIT" *> pBrackets pNatural)
     <|> IsVar             <$> (pToken "~ISVAR" *> pBrackets pNatural)
     <|> GenSym            <$> (pToken "~GENSYM" *> pBrackets pSigD) <*> pBrackets pNatural
     <|> And               <$> (pToken "~AND" *> listParser pTagE)
     <|> Vars              <$> (pToken "~VARS" *> pBrackets pNatural)


-- | Parse a bracketed text
pBrackets :: Parser a -> Parser a
pBrackets p = pSym '[' *> p <* pSym ']'

-- | Parse a token and eat trailing whitespace
pTokenWS :: String -> Parser String
pTokenWS keyw = pToken keyw <* pSpaces

-- | Parse the expression part of Blackbox Templates
pBlackBoxE :: Parser BlackBoxTemplate
pBlackBoxE = pSome pElemE

-- | Parse an Expression or Text
pElemE :: Parser Element
pElemE = pTagE
      <|> C <$> pText

-- | Parse SigD
pSigD :: Parser [Element]
pSigD = pSome (pTagE <|> (C (pack "[") <$ (pack <$> pToken "[\\"))
                     <|> (C (pack "]") <$ (pack <$> pToken "\\]"))
                     <|> (C <$> (pack <$> pList1 (pRange ('\000','\90'))))
                     <|> (C <$> (pack <$> pList1 (pRange ('\94','\125')))))
