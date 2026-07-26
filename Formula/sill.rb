# Homebrew formula for sill — https://sill.sh
#
# Lives in the tap sill-sh/homebrew-tap:
#
#     brew install sill-sh/tap/sill
#
# This installs a prebuilt binary from the GitHub release rather than building from
# source, so there is one sha256 per platform. The version string and all four
# PLACEHOLDER_SHA256_* values below are rewritten by the release workflow from the
# SHA256SUMS file published with the tag. A placeholder that reaches a real tap is a bug
# in that workflow, and brew will refuse to install it rather than skip the check.
class Sill < Formula
  desc "Report which CLIs can be credential-brokered, and which cannot"
  homepage "https://sill.sh"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "dceda7e1aaa5bc3a838b9b6cce777b97b40a88e96679649a9f80c7f38ce52993"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "21f63f0dc8c3930d9b305a85da7e3e5217385a165432c32c9cda14c120cd4dbf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "d54efa28d66fe5d0b10dca899e6428505e1f408b80fc47edcf671c1cd864a9c6"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "98b461f2556d4446602336297bfc1775ce7c916825862b29125ebc6ec3cfa0dd"
    end
  end

  def install
    # Each tarball contains exactly one file: the executable.
    bin.install "sill"
  end

  test do
    assert_match "sill #{version}", shell_output("#{bin}/sill --version")

    # `catalog` prints the whole compatibility catalogue. It is worth testing rather than
    # `--help` because the catalogue is compiled into the binary with include_str!, so
    # this proves the TOML parsed and the table rendered — while touching neither the
    # network nor anything outside the sandbox. shell_output raises unless the exit
    # status is 0, so this asserts that too.
    catalog = shell_output("#{bin}/sill catalog")
    assert_match "Base classifications", catalog
    assert_match "flyctl", catalog
    assert_match "Vercel CLI", catalog
    assert_match "base-URL override", catalog
    assert_match "* = installed here", catalog

    # A usage error must not look like success. clap exits 2 for an unknown subcommand.
    shell_output("#{bin}/sill not-a-subcommand 2>&1", 2)
  end
end
