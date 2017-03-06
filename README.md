# deploy-tomcat
Perl util for tomcat deployments

## Installation
```
perl Makefile.PL
make
make test
make install
```

or using `cpanm`
```
cpanm install .
```

## Usage

CLI is available `deploy-tool`.

Run `deploy-tool help` to get help on commands and keys.

## Config

By default `~/.deploy-tool/config.cfg` is used for storing configuration.
This behaviour might be overriden with `--config FILE` key.
Configuration is stored as Data::Dumper (Terse => 1) serialized HASH.
