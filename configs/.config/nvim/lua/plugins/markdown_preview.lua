return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    require("lazy").load({ plugins = { "markdown-preview.nvim" } })
    -- build = "cd app && yarn install",
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown", "plantuml", "puml" },
  --build = ":call mkdp#util#install()",
  init = function()
    -- """
    -- " Vim-markdown preview configuration
    -- " set to 1, the nvim will auto close current preview window when change
    -- " from markdown buffer to another buffer
    -- " default: 1
    vim.g.mkdp_auto_close = 1
    --
    -- " set to 1, the vim will refresh markdown when save the buffer or
    -- " leave from insert mode, default 0 is auto refresh markdown as you edit or
    -- " move the cursor
    -- " default: 0
    vim.g.mkdp_refresh_slow = 0
    --
    -- " set to 1, the MarkdownPreview command can be use for all files,
    -- " by default it can be use in markdown file
    -- " default: 0
    vim.g.mkdp_command_for_global = 0
    --
    -- " set to 1, preview server available to others in your network
    -- " by default, the server listens on localhost (127.0.0.1)
    -- " default: 0
    vim.g.mkdp_open_to_the_world = 0
    --
    -- " preview server port
    vim.g.mkdp_port = 9001
    --
    -- " use custom IP to open preview page
    -- " useful when you work in remote vim and preview on local browser
    -- " more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
    -- " default empty
    vim.g.mkdp_open_ip = "127.0.0.1"
    --
    -- " specify browser to open preview page
    -- " default: ''
    vim.g.mkdp_browser = ""
    --
    -- " set to 1, echo preview page url in command line when open preview page
    -- " default is 0
    vim.g.mkdp_echo_preview_url = 1
    --
    -- " a custom vim function name to open preview page
    -- " this function will receive url as param
    -- " default is empty
    vim.g.mkdp_browserfunc = "g:EchoUrl"

    vim.api.nvim_exec2(
      [[
        function! g:EchoUrl(url)
          :echo a:url
        endfunction
      ]],
      {}
    )
    -- " options for markdown render
    -- " mkit: markdown-it options for render
    -- " katex: katex options for math
    -- " uml: markdown-it-plantuml options
    -- " maid: mermaid options
    -- " disable_sync_scroll: if disable sync scroll, default 0
    -- " sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
    -- "   middle: mean the cursor position alway show at the middle of the preview page
    -- "   top: mean the vim top viewport alway show at the top of the preview page
    -- "   relative: mean the cursor position alway show at the relative positon of the preview page
    -- " hide_yaml_meta: if hide yaml metadata, default is 1
    -- " sequence_diagrams: js-sequence-diagrams options
    -- " content_editable: if enable content editable for preview page, default: v:false
    -- " disable_filename: if disable filename header for preview page, default: 0
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {
        -- TODO: https://github.com/iamcco/markdown-preview.nvim has a PR up to add better mermaid support
        --       - Fork the repo, pull in the change and get the new version of mermaid
        -- The MarkdownPreview plugin by default will reach out to the plantuml.com website,
        -- which is something that we don't want. Instead, we need to run our own server and 
        -- connect to it.
        -- ssh some-remote-machine -L 8080:localhost:8080
        -- docker run -d -p 127.0.0.2:8080:8080  --name plantuml-tomcat plantuml/plantuml-server:tomcat
        server = 'http://127.0.0.2:8080',
      },
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = 0,
      disable_filename = 0,
    }

    -- " use a custom markdown style must be absolute path
    -- " like '/Users/username/markdown.css' or expand('~/markdown.css')
    vim.g.mkdp_markdown_css = ""

    -- " use a custom highlight style must absolute path
    -- " like '/Users/username/highlight.css' or expand('~/highlight.css')
    vim.g.mkdp_highlight_css = ""

    -- " preview page title
    -- " ${name} will be replace with the file name
    vim.g.mkdp_page_title = "「${name}」"
    --
    -- " recognized filetypes
    -- " these filetypes will have MarkdownPreview... commands
    vim.g.mkdp_filetypes = { "markdown", "plantuml", "puml" }

    -- " set to 1, nvim will open the preview window after entering the markdown buffer
    -- " default: 0
    vim.g.mkdp_auto_start = 0
  end,
}
