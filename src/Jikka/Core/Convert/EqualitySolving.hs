{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}

-- |
-- Module      : Jikka.Core.Convert.EqualitySolving
-- Description : equality solving. / 等式を解きます
-- Copyright   : (c) Kimiyuki Onaka, 2021
-- License     : Apache License 2.0
-- Maintainer  : hotman78@gmail.com
-- Stability   : experimental
-- Portability : portable
--
-- \[
--     \newcommand\int{\mathbf{int}}
--     \newcommand\bool{\mathbf{bool}}
--     \newcommand\list{\mathbf{list}}
-- \]
module Jikka.Core.Convert.EqualitySolving
  ( run,
    rule,
  )
where

import Jikka.Common.Error
import Jikka.Core.Language.BuiltinPatterns
import Jikka.Core.Language.Expr
import Jikka.Core.Language.Lint
import Jikka.Core.Language.RewriteRules

-- |
-- == List of functions which are reduced
--
-- === Basic arithmetical functions
--
-- * `Equal` \(: \int \to \int\)
rule :: Monad m => RewriteRule m
rule = simpleRewriteRule $ \case
  -- reduce identity
  Equal' _ a b | a == b -> Just LitTrue
  -- align value on the right side to 0
  Equal' IntTy a b | b /= Lit0 -> Just $ Equal' IntTy (Minus' a b) Lit0
  -- reduce injective function
  Equal' t (Minus' (Negate' a) (Negate' b)) Lit0 -> Just $ Equal' t (Minus' a b) Lit0
  Equal' t (Minus' (Not' a) (Not' b)) Lit0 -> Just $ Equal' t (Minus' a b) Lit0
  Equal' t (Minus' (BitNot' a) (BitNot' b)) Lit0 -> Just $ Equal' t (Minus' a b) Lit0
  Equal' t (Minus' (Fact' a) (Fact' b)) Lit0 -> Just $ Equal' t (Minus' a b) Lit0
  -- unpack list equality
  Equal' _ (Nil' _) _ -> Just LitFalse
  Equal' (ListTy t) (Cons' _ x xs) (Cons' _ y ys) -> Just $ And' (Equal' t x y) (Equal' (ListTy t) xs ys)
  -- reduce boolean equality
  Equal' _ a LitTrue -> Just a
  Equal' _ a LitFalse -> Just $ Not' a
  _ -> Nothing

runProgram :: MonadError Error m => Program -> m Program
runProgram = applyRewriteRuleProgram' rule

run :: MonadError Error m => Program -> m Program
run prog = wrapError' "Jikka.Core.Convert.EqualitySolving" $ do
  precondition $ do
    ensureWellTyped prog
  prog <- runProgram prog
  postcondition $ do
    ensureWellTyped prog
  return prog
