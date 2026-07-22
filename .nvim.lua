local vendor_guard = vim.api.nvim_create_augroup("VendorGuard", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vendor_guard,
  pattern = vim.fn.getcwd() .. "/addons/*",
  callback = function(args)
    vim.bo[args.buf].readonly = true
    vim.bo[args.buf].modifiable = false
  end,
})

vim.api.nvim_create_user_command("EditVendored", function()
  vim.bo.modifiable = true
  vim.bo.readonly = false
  print("Vendored file unlocked for editing.")
end, {})
