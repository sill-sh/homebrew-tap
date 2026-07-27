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
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "e6dcb1784b177400bdabec9e2dd95566df00322bb788213f228e76f0f01a405a"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "6399679fc2eb095027541455e2b6f50ad3a303b8c6328ac87fd8952d26598b64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "470fd9734fd60eb842ea978b558a0399c9813e6441bf4568c255c827eeebcd4a"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "69b6d40ddc3a144aa2c4feaeaaba10be9fddfe35cee358a52ba838c5d1384419"
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
