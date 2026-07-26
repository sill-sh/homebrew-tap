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
      sha256 "37915736f809522c069b165f25b6a14da54730f859696289050b16eb4b5559d4"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "1ff81ba30fb7e4e23c7aeb754ec51936a75226acad0724af46d18929a9f4890f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "9595b1734d9395780788325e0246b3d0c0f01912c6bb69a0919c6467cb08e7eb"
    else
      url "https://github.com/sill-sh/client/releases/download/v#{version}/sill-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "13dfac931b541825aa2dfccd9d40e09ad549bb37f674f91f2bbc90a149024a1c"
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
