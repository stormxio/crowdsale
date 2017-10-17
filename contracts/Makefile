CC=sc-compile
DEPLOY=sc-push
TEST=sc-test

FILES=./StormToken.sol
TESTS=./deployment/StormToken.def
TOKEN_CONTRACT=StormToken
ABI=$(TOKEN_CONTRACT).abi
PORT=8545
GAS=5000000

all: compile push test

compile:
	$(CC) $(FILES)

push:
	$(DEPLOY) -c $(ABI) -t $(TESTS) -g $(GAS) -p $(PORT)

test:
	$(TEST) -n $(TOKEN_CONTRACT) -t $(TESTS) -g $(GAS) -p $(PORT)
