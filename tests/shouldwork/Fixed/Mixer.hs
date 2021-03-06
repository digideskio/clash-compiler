module Mixer where

import CLaSH.Prelude

k               = 0.6
piFHalf         = 1.5707963267948966 :: SFixed 3 8

cordic angle
    | z < 0     =  k
    | otherwise = -k
    where
        z       | angle < 0 = piFHalf + angle
                | otherwise = (-piFHalf)+ angle


topEntity :: SFixed 3 8 -> SFixed 3 8
topEntity = cordic

testInput :: Signal (SFixed 3 8)
testInput = stimuliGenerator $(v [0.7853981633974483 :: (SFixed 3 8)])

expectedOutput :: Signal (SFixed 3 8) -> Signal Bool
expectedOutput = outputVerifier $(v [0.59765625 :: (SFixed 3 8)])
