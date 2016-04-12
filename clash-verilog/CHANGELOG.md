# Changelog for the [`clash-systemverilog`](http://hackage.haskell.org/package/clash-systemverilog) package

## 0.6.6
* New features:
  * Support `clash-prelude` 0.11

## 0.6.6 *March 11th 2016*
* Support `clash-lib` 0.6.11

## 0.6.5 *January 29th 2016*
* New features:
  * Support clash-lib-0.6.9
  * Support for `Debug.Trace.trace`, thanks to @ggreif

## 0.6.4 *January 13th 2016*
* New features:
  * Support for Haskell's: `Char`, `Int8`, `Int16`, `Int32`, `Int64`, `Word`, `Word8`, `Word16`, `Word32`, `Word64`.
  * Int/Word/Integer bitwidth for generated Verilog is configurable using the `-clash-intwidth=N` flag, where `N` can be either 32 or 64.

## 0.6.3 *November 17th 2015*
* Fixes bugs:
  * Name collision in verilog code [#93](https://github.com/clash-lang/clash-compiler/issues/93)
  * Integer literals missing "32'sd" prefix when used in assignments.
  * HO-primitives incorrect for nested vectors.

## 0.6.2 *October 21st 2015*
* New features:
  * Support `clash-prelude` 0.10.2

## 0.6.1 *October 16th 2015*
* New features:
  * Support for `clash-prelude` 0.10.1

## 0.6
* New features:
  * Support `clash-prelude-0.10`

## 0.5.10 *September 21st 2015*
* New features:
  * Report simulation time in assert messages

## 0.5.9 *September 14th 2015*
* Support for clash-lib-0.5.12

## 0.5.8 *September 7th 2015*
* Fixes bugs:
  * Fix primitive for CLaSH.Sized.Internal.Signed.size# [#72](https://github.com/clash-lang/clash-compiler/pull/72)
  * rem and quot on Signed are broken [#73](https://github.com/clash-lang/clash-compiler/issues/73)

## 0.5.7 *June 26th 2015*
* New features:
  * Generate Verilog-2001 instead of Verilog-2005: generated Verilog is now accepted by Altera/Quartus

## 0.5.6 *June 25th 2015*
* New features:
  * Support `clash-prelude-0.9`

* Fixes bug:
  * Can not operate "shiftR" on Int [#63](https://github.com/clash-lang/clash-compiler/issues/63)
  * Fail to generate verilog when using "quot" and "div" on Index [#64](https://github.com/clash-lang/clash-compiler/issues/64)

## 0.5.5 *June 3rd 2015*
* Initial release
