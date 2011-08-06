two:
	(cd two && cabal configure --bindir=bin)
	(cd two && cabal build)
	(cd two && cabal copy)

clean:
	(cd two && cabal clean)
	rm -rf two/bin

.PHONY: two clean
