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
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "749e1ab718d1ae0d2561afd93ec2377406fb7b4ef9f75ce02f1fdcdbd303c93a"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "f75d39aad357ade882cef502293bf6d162e08f6d56c12c90455b6ceef7b49626"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "043a533b51f8ad9ff76383dfba11d0eb2277e1d95709fde1fb37e8b4776ad6ae"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "67d1c37996bc3a0f024212f1dc2daefa50724682175df152fc6c1c4e31b3ccab"
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
