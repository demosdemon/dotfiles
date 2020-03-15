# source.d

The files in this directory are imported in lexographical order automatically by [`.bash_profile`](../links/.bash_profile) on shell inititialization. Whether or not they should be sourced during `.bashrc` has yet to be determined.

## Convention

* All bash configuration options are in [`00-bash-opts.sh`](00-bash-opts.sh)
* Core utilitiy functions are defined in [`00-utils.sh`](00-utils.sh)
* Functions that environment definitions depend on are prefixed with `01`, e.g., [`01-prepend-path.sh`](01-prepend-path.sh)
* Environment definitions (except `PATH`) are prefixed with `02`, e.g., [`02-brew.sh`](02-brew.sh), [`02-go.sh`](02-go.sh), [`02-java.sh`](02-java.sh)
* All `PATH` and `MANPATH` modifications are in [`03-path.sh`](03-path.sh)
* The remaining files should be named such that they are ordered in a way that does not cause dependency violations.
* Variable exports should be grouped into a named file indicative of their purpose
* Interactive shell functions should be implemented one-per-file
* Non-interactive shell functions should be implemented as dedicated scripts and placed into `bin`.
