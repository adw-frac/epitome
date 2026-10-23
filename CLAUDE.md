# Epitome

## Branches and pull requests

Never commit or push directly to `main`. Do work on a branch of its own
(one per session or piece of work), push the branch, and open a pull
request for it; `main` changes only by merging pull requests. Several
sessions may be working on the repository at once, so:

- Start a branch from an up-to-date `origin/main`.
- To pick up changes that landed on `main` since, merge `origin/main` into
  the branch (and run the tests again) rather than rebasing a branch that
  has been pushed.
- Never force-push, and never push to a branch another session or person
  owns.

## Clean room

Epitome is written without reading LLVM's source. LLVM's documentation
(the LangRef) and the behaviour of LLVM's tools as programs (`llc`,
`clang`, run and compared against) are fair to use; its code is not.
