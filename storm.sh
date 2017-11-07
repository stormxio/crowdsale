#!/bin/bash

clear
echo
echo
echo compiled smart contracts
echo

{
rm -R bin

solc --optimize --abi -o bin --overwrite contracts/StormToken.sol 
solc --optimize --bin -o bin --overwrite contracts/StormToken.sol

solc --optimize --abi -o bin --overwrite contracts/StormCrowdsale.sol
solc --optimize --bin -o bin --overwrite contracts/StormCrowdsale.sol

solc --optimize --abi -o bin --overwrite contracts/TestCrowdsale.sol
solc --optimize --bin -o bin --overwrite contracts/TestCrowdsale.sol
} &> /dev/null

ls -l bin/Storm*
ls -l bin/Test*

echo
