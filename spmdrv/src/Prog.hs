-- simple SPMD risc-v assembler with regular loop constructs
-- programs are "widened" to vector instructions and all
-- non-loop control flow is linearized
--
-- TODO: size changes?
module Prog where

type Reg = Int
type TArg = (Reg, Reg, Reg)
type DArg = (Reg, Reg)

-- TODO this is a proof of concept, restructure data to be easier to extend and add a concept of uniformity

data SInstruction = 
                Add TArg
              | Sub TArg
              | While [SInstruction]
              | If Reg [SInstruction] [SInstruction]
              | BEq Reg Reg Int
              | Break


-- Int is the mask register
data VInstruction = 
                VAdd Int TArg
              | VSub Int TArg
              | VWhile Int [VInstruction]
              | VZero Int Reg
              | VBreak

-- we only allow structured control flow to avoid issues with mask register allocation
-- TODO maybe figure this out? one could also just allow unstructured flow in uniform cases
-- this compiler does not have uniforms just yet
--
--
-- normal if - else is translated to simple masking, while while loops are or reductions over the mask
-- break sets all active instances' mask to 0

-- vectorize the function transforming all control flow to dataflow (except VWhile, which is translated in the next step)

vectorize :: [SInstruction] -> [VInstruction]
vectorize i =
    -- vectorize keeping track of nesting level
    let vectorRec level i = case i of
                              Add x -> [VAdd level x]
                              Sub x -> [VSub level x]
                              While is -> [VWhile level (concatMap (vectorRec (level + 1)) is)]
                              If x is1 is2 -> [VZero (level + 1) x] ++ (concatMap (vectorRec (level + 1)) is1) ++ (concatMap (vectorRec (level + 1)) is2)
                              Break -> [VBreak]
                              _        -> undefined
     in concatMap (vectorRec 0) i
