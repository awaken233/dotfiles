return {
  "mfussenegger/nvim-jdtls",
  opts = {
    cmd = {
      "python3",
      vim.fn.stdpath("data") .. "/mason/packages/jdtls/bin/jdtls",
      "--java-executable",
      "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home/bin/java",
    },
  },
}
