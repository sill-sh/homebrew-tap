# sill-sh/homebrew-tap

```sh
brew install sill-sh/tap/sill
```

`sill doctor` reports which of your CLIs can be credential-brokered and which cannot —
MIT, standalone, no account. See [sill-sh/client](https://github.com/sill-sh/client).

`Formula/sill.rb` is written by the release workflow in that repository, which fills the
checksums from the `SHA256SUMS` published with each tag. Editing it here by hand will be
overwritten by the next release, and a hand-pasted checksum is the thing the automation
exists to avoid.
