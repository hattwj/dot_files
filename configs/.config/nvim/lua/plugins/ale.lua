return {
  "dense-analysis/ale",
  dependencies = {
    "prabirshrestha/vim-lsp",
    "rhysd/vim-lsp-ale",
  },
  init = function()
    vim.api.nvim_exec2(
      [[

        """
        " Vim ALE Linter Config
        " Always show linter gutter
        let g:ale_sign_column_always = 1
        " Disable linting on text change, will only lint on save instead
        "let g:ale_lint_on_text_changed = 'never'
        
        " Lint on save
        let g:ale_lint_on_save = 1
        
        " Set this. Airline will handle the rest.
        let g:airline#extensions#ale#enabled = 1
        " Require vim restart to run linters that are not installed
        let g:ale_cache_executable_check_failures = 1
        " Set this variable to 1 to fix files when you save them.
        let g:ale_fix_on_save = 0
        let g:ale_fixers = {
              \   '*': ['remove_trailing_lines', 'trim_whitespace'],
              \   'ruby': ['prettier', 'rubocop'],
              \   'scala': [ 'scalafmt' ],
              \   'yaml': [ 'prettier' ]
              \ }
        
        " Specify ruby linters, you'll likely want others enabled
        "      \ 'scala': [ 'scalatest']
        "      \ 'scala': [ 'metals' ]
        let g:ale_linters = {
              \ 'ruby': ['solargraph', 'rubocop', 'reek', 'ruby'],
              \ 'scala': ['scalatest', 'scalafmt', 'metals']
              \ }
        
        if executable('bb_scalafmt')
          let g:ale_scala_scalafmt_executable = 'bb_scalafmt'
        endif
      ]],
      {}
    )
  end,
}
